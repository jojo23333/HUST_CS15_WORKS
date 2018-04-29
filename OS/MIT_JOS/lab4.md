# LAB4
## Part A Multiprocessor Support and Cooperative Multitasking
### 背景知识


### Exercise 1
LAPIC本来应该在0xFE000000处，由于jos的系统寸限制无法寻址到这么高的物理地址
jos 在（ULIM == MMIOBASE = 0xef800000）预留了4M空间给LAPIC，需要在mmio_map_region中作出映射
```c
void * mmio_map_region(physaddr_t pa, size_t size)
{
	static uintptr_t base = MMIOBASE;
	void *mmio_base;
	size = ROUNDUP(size,PGSIZE);
	if ( base+size > MMIOLIM )
		panic("base+size:%08x graeter than MMIOLIM:%08x",base+size,MMIOLIM);
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
	mmio_base = (void *)base;
	base += (uintptr_t)size;
	return mmio_base;
}
```
base作为一个静态成员变量始终下一个可以映射的地址

#### Exercise 2
为了将mpentry.s中代码放入内存页中运行，要求我们修改kern/init.c以让MPENTRY_PADDR处页不加入到空闲页的链表中去。
```c
		else if ( paddr == MPENTRY_PADDR )
			continue;
```
跳过MPENTRY_PADDR处即可

**Question 1:**  
Compare kern/mpentry.S side by side with boot/boot.S. Bearing in mind that kern/mpentry.S is compiled and linked to run above KERNBASE just like everything else in the kernel, what is the purpose of macro MPBOOTPHYS? Why is it necessary in kern/mpentry.S but not in boot/boot.S? In other words, what could go wrong if it were omitted in kern/mpentry.S? 
Hint: recall the differences between the link address and the load address that we have discussed in Lab 1.   
MPBOOTPATH是为了设置正确的物理地址  
这里的mpentry.S的代码是链接到KERNBASE之上的，也就是说，其中的符号的地址都是在KERNBASE之上的，但是实际上现在是将这些代码移动到了物理地址0X7000处，而且当前的AP处于实模式下，只支持1MB的物理地址寻址，所以这个时候需要计算相对于0X7000的地址，才能跳转到正确的位置上去  


#### Exercise 3
为每一个cpu设置相应的内核栈，相关内存地址和结构lab2中的memlayout已经给出
```c
static void
mem_init_mp(void)
{
	for (int i=0; i<NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i-KSTKSIZE , KSTKSIZE, PADDR(&percpu_kstacks[i]), PTE_W | PTE_P );
	}
}
```
第i个内核栈的其实地址为kstacktop_i， 大小为KSTKSIZE， 并在kstacktop_i+KSTKSIZE上有KSTKGAP大小的为分配内存空间用来在栈空间溢出时印发异常，也避免了这种情况下导致写入其他内核的栈空间。

**问题描述**
check_kern_pgdir失败：
```
error: pa 0x0032d000 i 0x00000000
kernel panic on CPU 0 at kern/pmap.c:869: assertion failed: check_va2pa(pgdir, KERNBASE + i) == i
```
将错误地址打印出来发现kernelbase被错误映射，由于kstacktop == kernelbase,怀疑mem_init_mp中映射边界未处理好。
更正之后

这里要求为每个cpu分别映射其栈帧的物理地址，并在每个栈帧之间插入kSTKGAP Bytes的guard pages以在越界时抛出异常。


#### Exercise 4
前面给每个CPU都单独的映射了一个内核栈,这里,就要把设置的内核栈用起来.内核栈的栈地址存储在TSS段中,而每个CPU都有一个独立的TSS段,在用户态向内核态切换的时候,需要用到TSS段中的部分信息,其中就包括esp0和ss0两个信息,esp0指向相应的CPU的内核栈,ss0指向内核的堆栈段寄存器(这个寄存器实际情况下作用应该就是指明其特权级,即指出处于内核态还是用户态而已)所以,进程在进入中断的时候,栈指针能够通过对应的CPU的TSS寄存器自动的把栈转换为内核栈. 
需要我们修改trap_init_percpu以为不同的pcu正确的设置Task State Segment  
其中需要注意的是需要将全局的ts替换成当前cpu对应的task state结构体指针。
**遇到的问题**
SMP: CPU 0 found 4 CPU(s)
Incoming TRAP frame at 0xf0125f7c
kernel panic on CPU 0 at kern/trap.c:338: kernel mode fault

检查trap_init_percpu确认无误后怀疑是初始化设置的时候权限设置错误，发现少加了写权限。
```c
void
trap_init_percpu(void)
{

	struct CpuInfo *cpu = thiscpu;
	uint32_t id = cpu->cpu_id;

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	cpu->cpu_ts.ts_esp0 = KSTACKTOP - id*(KSTKSIZE + KSTKGAP);
	cpu->cpu_ts.ts_ss0 = GD_KD;

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + id] = SEG16(STS_T32A, (uint32_t) (&(cpu->cpu_ts)),
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + id].sd_s = 0;
	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(id<<3));

	// Load the IDT
	lidt(&idt_pd);
}
```

### Exercise 5
为防止多个cpu在内核态的竞争，使用lock_kernel() and unlock_kernel() 加锁使只有一个环境能运行在内核态上
1. 在启动的时候，BSP启动其余的CPU之前，BSP需要取得内核锁
2. Mp_main中，也就是CPU被启动之后执行的第一个函数，这里应该是调用调度函数，选择一个进程来执行的，但是在执行调度函数之前，必须获取锁
3. trap函数也要修改，因为可以访问临界区的CPU只能有一个，所以从用户态陷入到内核态的话，要加锁，因为可能多个CPU同时陷入内核态
4. Env_run函数，也就是启动进程的函数，之前在试验3中实现的，在这个函数执行结束之后，就将跳回到用户态，此时离开内核，也就是需要将内核锁释放

这里只用分别加lock_kernel() 和 unlock_kernel()即可

思考：程序会在什么时候加锁？又会通过什么机制在什么地方解锁？

**Question 2**
It seems that using the big kernel lock guarantees that only one CPU can run the kernel code at a time. Why do we still need separate kernel stacks for each CPU? Describe a scenario in which using a shared kernel stack will go wrong, even with the protection of the big kernel lock.  
对于运行两个用户进程的cpu如果同时抛出了异常，则对栈帧的访问是不互斥的，会导致栈帧上tarapframe结构的破坏。

### Exercise 6
要求我们在sys_yeild中实现一个轮转调度。  
根据注释提示，我们总是寻找当前一个进程后面一个可运行进程，若所有其他进程不可运行，且当前进程还可以运行，继续运行当前进程，否则挂起。  
当没有进程可运行时，挂起程序会调用monitor从而进入shell界面
**遇到的问题**  
1. 缺页错误
```
TRAP frame at 0xf0125f84 from CPU 0
  edi  0x00000000
  esi  0x00010074
  ebp  0xf0125fd8
  oesp 0xf0125fa4
  ebx  0xf03ce000
  edx  0x00000400
  ecx  0xf03ed000
  eax  0x0000007c
  es   0x----0010
  ds   0x----0010
  trap 0x0000000e Page Fault
  cr2  0x000000d0
  err  0x00000000 [kernel, read, not-present]
  eip  0xf0104b06
  cs   0x----0008
  flag 0x00000003
kernel panic on CPU 0 at kern/trap.c:340: kernel mode fault
```
看到cr2值很低，可能是idle值出现偏差，发现是在实现sched_yield时没考虑到sched_yield为空的情况。
2. 在运行程序 make run-dumbfork 之后程序没有正确回到monitor
发现在sched_yield当中出现死循环
```c
//....
	for (idle=s; idle!=s || flag ; idle++) {
		if ( idle >= envs+NENV ) 	idle = envs;
		if ( idle->env_status == ENV_RUNNABLE ) {
			env_run(idle);
			return;
		}
		flag = false;
	}
//....
```
上述代码何时会出现死循环呢？  
当idle=envs时，由于总是会在  
if ( idle >= envs+NENV ) 	idle = envs;  
这条语句之后对idle++,因而idle!=s这个条件一直满足。  


**Questions 3**  
In your implementation of env_run() you should have called lcr3(). Before and after the call to lcr3(), your code makes references (at least it should) to the variable e, the argument to env_run. Upon loading the %cr3 register, the addressing context used by the MMU is instantly changed. But a virtual address (namely e) has meaning relative to a given address context--the address context specifies the physical address to which the virtual address maps. Why can the pointer e be dereferenced both before and after the addressing switch? 
在执行env_setup_vm 为新进程创建页表时将内核的对应的页表复制了过来，虽然页表变了，但是相应地址的页表项值相同  
memcpy(pgdir, kern_pgdir, PGSIZE);

**Question 4**  
Whenever the kernel switches from one environment to another, it must ensure the old environment's registers are saved so they can be restored properly later. Why? Where does this happen?  
在trap中保存
```c
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
```


### Exercise 7
要求实现一系列系统调用的函数为后面实现map时候铺垫。  
由于用户态的程序不能访问内核代码，所以需要通过系统调用主动切换到内核态以执行相应操作。因而需要编写相应的接口。  
在接下来的这些函数中基本上都会用到envid2env函数，这个函数通过传入的进程id来返回指向进程控制块结构的指针。
这里这个函数的第二个参数必须要置为1,这样envid2env会检查操作的目标进程是否是当前进程或当前进程的直接子进程。如果不是，就会返回错误。加上这个检查可以防止进程利用系统调用随意对其他进程进行改写。
```c
static envid_t
sys_exofork(void)
{
	struct Env *e;
	int ret = env_alloc(&e, curenv->env_id);
	if ( ret < 0 )
		return ret;
	e->env_status =  ENV_NOT_RUNNABLE;
	e->env_tf = curenv->env_tf;
	// return 0 in child proccess
	e->env_tf.tf_regs.reg_eax = 0;
	return e->env_id;
}
```
这里申请一个新进程的进程控制结构，将寄存器状态复制到新的进程。
这里的重点是将 trapframe 中 eax 的值设置为 0，由于子进程的 trapframe 与父进程的相同，所以运行子进程时，会执行父进程调用 fork 时的下一条指令，而此时返回值是存在 eax 中的，这样就实现了在子进程中返回 0
```c
static int
sys_env_set_status(envid_t envid, int status)
{
	struct Env *e;
	if ( status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE )
		return -E_INVAL;
	int ret = envid2env(envid, &e, 1);
	if ( ret < 0 )	return ret;
	e->env_status = status;
	return 0;	
}
```
这里设置某个进程的状态，只能设置为ENV_NOT_RUNNABLE或者ENV_RUNNABLE
```c
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	struct Env *e;
	struct PageInfo *pg;
	int ret;

	// inproperate perm
	if ( !(perm & PTE_U) || !(perm & PTE_P) )// || perm & (~PTE_SYSCALL) )
		return -E_INVAL;
	if ( (uint32_t)va % PGSIZE || (uint32_t)va >= UTOP )
		return -E_INVAL;
	
	//get env	
	ret = envid2env(envid, &e, 1);
	if ( ret < 0 )	
		return ret;

	// caller increase pp_ref
	pg = page_alloc(ALLOC_ZERO);
	// pg->pp_ref++;
	if ( !pg )
		return -E_NO_MEM;

	ret = page_insert( e->env_pgdir, pg, va, perm);
	// free page if fail
	if ( ret < 0 ) {
		page_free(pg);
		cprintf("debug: %08x\n",curenv->env_id);
		return -E_NO_MEM;		
	}
	return 0;
}
```
主要是根据注释做了大量的参数是否合法的判断。注意当page_insert失败的时候要释放page_alloc申请的空间否则会造成内存泄漏。
```c
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	struct Env *srce,*dste;
	struct PageInfo *pgsrc;
	pte_t *pte;

	if ( !(perm & PTE_U) || !(perm & PTE_P) )//|| perm & (~PTE_SYSCALL) )
		return -E_INVAL;
	if ( (uint32_t)srcva % PGSIZE || (uint32_t)srcva >= UTOP || (uint32_t)dstva % PGSIZE || (uint32_t)dstva >= UTOP )
		return -E_INVAL;
	
	if ( envid2env(srcenvid, &srce, 1) < 0 || envid2env(dstenvid, &dste, 1) < 0 )	
		return -E_BAD_ENV;
	
	pgsrc = page_lookup(srce->env_pgdir, srcva, &pte);
	// srcva is not mapped in srcenvid's address space.
	if ( !pgsrc || ((~(*pte) & PTE_W) && (perm & PTE_W)) )
		return -E_INVAL;
	if ( page_insert(dste->env_pgdir, pgsrc, dstva, perm) < 0)
		return -E_NO_MEM;
	return 0;
}
```
同样对参数作出大量的条件判断。
```c
static int
sys_page_unmap(envid_t envid, void *va)
{
	struct Env *e;
	if ( (uint32_t)va % PGSIZE || (uint32_t)va >= UTOP )
		return -E_INVAL;
	if ( envid2env(envid, &e, 1) < 0 )
		return -E_BAD_ENV;
	page_remove(e->env_pgdir, va);
	return 0;
}
```
## Part B Copy-on-Write Fork
### 背景知识

### Exercise 8
实现一个设置页错误系统调用的syscall
```c
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env * e;
	if ( envid2env(envid, &e, 1) < 0 )
		return -E_BAD_ENV;
	e->env_pgfault_upcall = func;
	return 0;
}
```

### Exercise 9、10、11
做接下来几个练习前，最好先理清下用户异常处理的调用关系
 
* 用户程序调用位于 pgfault.c 的 set_pgfault_handler()，作用是设置异常处理程序，为用户异常栈分配页面，并将 env_pgfault_upcall 设置为 _pgfault_upcall
* 当在用户态出现页错误时，trap_dispatch() 调用 page_fault_handler()， 然后设置用户异常栈，将 esp 指向该栈顶，eip 指向之前设置的 env_pgfault_upcall，即 _pgfault_upcall，并调用 env_run()
* 根据 eip，执行位于 pfentry.S 的 _pgfault_upcall，首先调用之前设置的异常处理程序，完成后恢复 trapframe 中的寄存器，继续执行用户态指令

根据以上调用关系依次实现
```c
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
		int ret;
		if ( (ret = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
			panic("sys_page_alloc fail in set_pgfault_handler %e",ret);
		if ( (ret = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
			panic("sys_env_set_pgfault_upcall fail in set_pgfault_handler %e",ret);
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
}
```
分配以UXSTACKTOP为栈顶的用户异常栈。通过系统调用设置当前进程页错误的处理函数入口为汇编代码_pgfault_call处
最后将handler保存下来一方便汇编代码调用

```c
	// in page_fault_handler()
	uintptr_t	esp;
	struct UTrapframe* utrap;
	if ( curenv->env_pgfault_upcall != NULL ) {
		if ( tf->tf_esp > UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP )
			esp = tf->tf_esp - 4 - sizeof(struct UTrapframe);
		else
			esp = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)esp, sizeof(struct UTrapframe), PTE_U | PTE_W | PTE_P);
		utrap = (struct UTrapframe *)esp;
		utrap->utf_fault_va = fault_va;
		utrap->utf_err = tf->tf_err;
		utrap->utf_regs= tf->tf_regs;
		utrap->utf_eip = tf->tf_eip;
		utrap->utf_eflags = tf->tf_eflags;
		utrap->utf_esp = tf->tf_esp;

		tf->tf_esp = esp;
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
		env_run(curenv);
	}
```
这里是关键，作为传入参数需要向用户异常栈中压入 UTrapframe，需要判断可能发生多次异常，这种情况下需要在之前的栈顶后先留下一个空位，再压入 UTrapframe，之后会用到这个空位，然后设置 esp 和 eip 并调用 env_run()，进而进入之前设置的_pgfault_upcall汇编代码执行过程。
(注意检查内存是否够可写)
```c
//in 
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
	movl _pgfault_handler, %eax
	call *%eax
	addl $4, %esp			// pop function argument

	//
	// Explanation:
	//   We must prepare the trap-time stack for our eventual return to
	//   re-execute the instruction that faulted.
	//   Unfortunately, we can't return directly from the exception stack:
	//   We can't call 'jmp', since that requires that we load the address
	//   into a register, and all registers must have their trap-time
	//   values after the return.
	//   We can't call 'ret' from the exception stack either, since if we
	//   did, %esp would have the wrong value.
	//   So instead, we push the trap-time %eip onto the *trap-time* stack!
	//   Below we'll switch to that stack and call 'ret', which will
	//   restore %eip to its pre-fault value.
	//
	//   In the case of a recursive fault on the exception stack,
	//   note that the word we're pushing now will fit in the
	//   blank word that the kernel reserved for us.
	//
	// Throughout the remaining code, think carefully about what
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	movl 48(%esp), %eax
	subl $4, %eax
	movl %eax, 48(%esp)
	movl 40(%esp), %ebx
	movl %ebx, (%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	addl $8, %esp
	popal

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	addl $4, %esp
	popfl

	// Switch back to the adjusted trap-time stack.
	popl %esp

	// Return to re-execute the instruction that faulted.
	ret
```
* 往 trap-time esp 所指的栈顶（可能是普通栈也可能是异常栈）后面的空位写入 trap-time eip 并将 trap-time esp 往下移指向该位置 
* 跳过 fault_va 和 err，然后恢复通用寄存器 
* 跳过 eip，然后恢复 efalgs，如果先恢复 eip 的话，指令执行的位置会改变，所以这里必须跳过 
* 恢复 esp，如果第一处不将 trap-time esp 指向下一个位置，这里 esp 就会指向之前的栈顶 
* 由于第一处的设置，现在 esp 指向的值为 trap-time eip，所以直接 ret 即可达到恢复上一次执行的效果


**遇到的问题以及解决方案**  
在测试faultalloc.c时出现问题
```
fault deadbeef
fault 4
fault 7b569758
fault 6134727c
fault edcb0a08
fault d49ddb48
fault 1000
fault 8c969790
fault 72747320
fault ff0b0aac
[00001000] user panic in <unknown> at user/faultalloc.c:14: allocating at ff0b0aac in page fault handler: invalid parameter
```
观察发现，第一异常处理的是成功的，就对应pfentry.S call _page_fault_handler后面的回避汇编代码有问题  
检查发现后面的汇编代码	subl 4, %eax在表示常数的时候忘了加'$'导致访存引发异常。才会有上面的fault 4  

**对测试程序 faultalloc 和faultallocbad的理解**  
faultalloc理解如代码注释所示
```c
void
handler(struct UTrapframe *utf)
{
	int r;
	void *addr = (void*)utf->utf_fault_va;

	cprintf("fault %x\n", addr);
	//这里为出错地址处分配了页面
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	//snprintf 传入参数100,会尝试为之后的100个byte依次赋值
	// 但是由于0xCafeBffe加1byte之后就会到下一页，而下一页是没有分配内存的，因而再次引发页错误
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}
void
umain(int argc, char **argv)
{
	set_pgfault_handler(handler);
	cprintf("%s\n", (char*)0xDeadBeef);
	cprintf("%s\n", (char*)0xCafeBffe);
}
```
对于faultallocbad，其调用的syscput为系统在内核态调用的函数，进行了自己的内存空间检查。


### Exercise 12
前面的dumpfork选择直接复制整个内存空间，这样在执行fork指令的时候开销比较大。  
而copy on write 则使用了一种巧妙的方式，一开始只复制内存的映射，把相应的页设置为可读以及copy on write。这个时候子进程和父进程和同一片内存的读操作是共享的，但一旦有一方尝试使用写操作则会引发页错误，在页错误的中断处理函数中在调用相关函数复制该页，改变映射关系再重新设置为可写，这样避免掉了大量的复制上的时间开销，提高了fork的效率也节省了系统空间。

实现fork
```c
envid_t
fork(void)
{
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	envid_t child_envid;
	int ret;

	// set up page_fault handler
	set_pgfault_handler(pgfault);
	// create a child
	if ( (child_envid = sys_exofork()) < 0 ){
		panic("error %e",child_envid);
		return child_envid;
	}
	
	// in case of child proccess here
	if ( child_envid == 0 ) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	for (uintptr_t va=0; va < USTACKTOP; va += PGSIZE)
		if ( (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P) )
			duppage(child_envid, PGNUM(va));
	
	// allocte new page for child's user exception stack
	if ( ( ret = sys_page_alloc(child_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P) )){
		panic("error %e",ret);
		return ret;
	}
	
	if ((ret = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall) ) < 0){
		panic("error %e",ret);
		return ret;
	}
	if ( ( ret = sys_env_set_status(child_envid, ENV_RUNNABLE) ) < 0 ) {
		panic("error %e",ret);
		return ret;
	}
	return child_envid;
}
```
设置异常处理函数，创建子进程，映射页面到子进程，为子进程分配用户异常栈并设置 pgfault_upcall 入口，将子进程设置为可运行的 。
```c
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	 
	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid();
	int perm = PGOFF(uvpt[pn]);
	if (perm & (PTE_W | PTE_COW)) {
		perm |= PTE_COW;
		perm &= ~PTE_W;
	}
	if ((r = sys_page_map(curenvid, (void *) (pn * PGSIZE), envid, (void *) (pn * PGSIZE), perm)) < 0) {
		cprintf("pn :%08x\n",pn*PGSIZE);
		panic("duppage: %e", r);
	}
	if ((r = sys_page_map(curenvid, (void *) (pn * PGSIZE), curenvid, (void *) (pn * PGSIZE), perm)) < 0) {
		panic("duppage: %e", r);
	}
	return 0;
	// if ( (ret = envid2env(child_envid, &child_env, 1)) < 0)
	// 	panic("Error get child env %e", ret);
}
```
先判断权限，然后建立映射，注意父进程页表也需要重新建立映射,因为fork了之后子进程和父进程对共享的内存都是COW的。

```c
	// in page_fault
	if ( !(err & FEC_WR ) || !( uvpt[PGNUM(addr)] & PTE_COW ))
		panic("pgfault error");

	if ( (r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W )) < 0 )
		panic("pgfault error on alloc page %e\n",r);
	addr = ROUNDDOWN(addr, PGSIZE);
	memcpy((void *)PFTEMP, addr, PGSIZE);

	if ( (r = sys_page_unmap(envid, addr)) < 0 )
		panic("pgfault map error %e",r);
	if ( (r = sys_page_map(envid, (void *)PFTEMP, envid, addr, PTE_W | PTE_U | PTE_P)) < 0 )
		panic("pgfault map error %e",r);
	if ( (r = sys_page_unmap(envid, (void *)PFTEMP))< 0)
		panic("Can't unmap error %e",r);
```
pg_fault做的事情如下：  
* 检查 err 和 pte 是否符合条件
* 分配页面到地址 PFTEMP
* 复制内容到刚分配的页面中
* 将虚拟地址 addr（需要向下对齐）映射到分配的页面
* 取消地址 PFTEMP 的映射


**这里关键解释一下为何可以用uvpd 和 uvpt访问二级和一级页表**
这里采用了一个技巧
```c
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
```
在前面初始化环境的时候有这么一句话。这一句话PADDR (kern_pgdir) 开始的一页成为了虚拟地址的 PDX = PDX(UVPT) 的页表。  
我们来想正常的地址翻译是经过两层转换，先找二级页表偏移，再找一级页表偏移，最后加上页内偏移形成实际地址，那么现在我们不想要这个页内偏移只想要pte的地址真么办呢。
虚拟地址结构如下所示
```
// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |      Index     |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \---------- PGNUM(la) ----------/
```
是不是只要想办法将前20位向右移动10位即可。  
这个时候加上这么一句话，然后考虑UVPT+PGNUM(la)*4所代表的地址的含义
首先这个地址的pdx（UVPT+PGNUM(la)*4） == PDX（UVPT），我们发现第一次地址转换后虚拟地址和线性地址一样。  
那么此时进行第二次转化则得到的就是pte的地址。  
纵观整个过程实际上uvpt[PGNUM]等价于e->env_pgdir[PDX(la)] + 4*PTX(la) 因而巧妙的完成了pte的取址   
在jos当中uvpt虚拟地址为PDX(UVPT)<<22  而uvpd代表页目录的虚拟地址为 PDX(UVPT)<<22 | PDX(UVPT)<<12 

## Part C Preemptive Multitasking and Inter-Process communication (IPC)

### 背景知识

### Exercise 13、14
exercise 13要为硬件中断设置中断向量和中断处理函数，这个流程和lab3中相关步骤完全相同。
在exercise 14中需要打开之前关闭的硬件中断同时为当时钟中断到来时调用sys_yield以使当前进程放弃cpu控制权，这样便实现了时间片轮转调度。
```c
// in trap_dispatch
	if ( tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
		lapic_eoi();
		sched_yield();
	}
// in env_alloc
e->env_tf.tf_eflags |= FL_IF;
```
完成上述代码之后同时将sched_halt()中的sti指令取消注释以打开中断。


**遇到的问题以及解决方案**
刚刚解决了一个史诗级bug....不行了我要来记录一下
为了这个bug我一路狂debug，绕了大半个地球才解决
起因都来于开硬件中断之后的assert error.....
```
kernel panic on CPU 0 at kern/trap.c:323: assertion failed: !(read_eflags() & FL_IF)
```
emm??说我没关外中断？？早有准备一下，在assert之前加上一句print_trapframe(tf)看看是哪个exception啊？  
紧接着问题变成了
```
TRAP frame at 0xefffffbc from CPU 0
  edi  0x00000000
  esi  0x00000000
  ebp  0xeebfdfd0
  oesp 0xefffffdc
  ebx  0x00000000
  edx  0x00000000
TRAP frame at 0xeffffdec from CPU 0
  edi  0x00000379
  esi  0x0000000a
  ebp  0xeffffe60
  oesp 0xeffffe0c
  ebx  0x00003201
  edx  0x0000037a
  ecx  0x000003d4
  eax  0x00000008
  es   0x----0010
  ds   0x----0010
  trap 0x00000020 Hardware Interrupt
  err  0x00000000
  eip  0xf01003b2
  cs   0x----0008
  flag 0x00000246
TRAP frame at 0xeffffcac from CPU 0
  edi  0x00000379
  esi  0xeffffd18
  ebp  0xeffffd70
  oesp 0xeffffccc
  ebx  0xf01293c0
  edx  0x00000000
  ecx  0x00000000
  eax  0x00000000
  es   0x----0010
  ds   0x----0010
  trap 0x0000000e Page Fault
  err  0x00000000 [kernel, read, not-present]
  eip  0xf01069f6
  cs   0x----0008
  flag 0x00000006
kernel panic on CPU 0 at kern/trap.c:381: kernel mode fault
```
喵喵喵？？？好吧好吧，我错了还不行吗  
可以看到内核错误的上一个中断是外设备中断，应该是在处理它的过程当中报道出现了偏差  
在patch_trap处理时钟中断处打上断点一点点调试进去。。结果发现在调度结束后进入env_run时发生了页错误  
emmmm 紧接着在env_run中发现是在kernel_realease处引发异常。。。  
啥玩意啊。。咋回事啊。。

只好大力debug kernel_lock  
通过gdb定位到发生异常的汇编语句
```asm
=> 0xf01069f3 <spin_unlock+53>:	mov    0x8(%ebx),%eax
spin_unlock (lk=0xf01293c0 <kernel_lock>) at kern/spinlock.c:92
92				cpunum(), lk->name, lk->cpu->cpu_id);
(gdb) 
=> 0xf01069f6 <spin_unlock+56>:	movzbl (%eax),%edi
91			cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
(gdb) 
=> 0xf0104d72 <pagefault_handler+2>:	jmp    0xf0104df0 <_alltraps>
0xf0104d72 in pagefault_handler () at kern/trapentry.S:63
63	TRAPHANDLER(pagefault_handler,T_PGFLT);
```
在kernel.asm中找到对应段落
```c
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01069d3:	8b 43 08             	mov    0x8(%ebx),%eax
f01069d6:	0f b6 38             	movzbl (%eax),%edi	<- Pagefault here
f01069d9:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01069dc:	e8 5b fc ff ff       	call   f010663c <cpunum>
f01069e1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01069e5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01069e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069ed:	c7 04 24 94 89 10 f0 	movl   $0xf0108994,(%esp)
f01069f4:	e8 45 d6 ff ff       	call   f010403e <cprintf>
f01069f9:	89 f3                	mov    %esi,%ebx
```
其中%ebx是lk指针，通过函数压栈分析出错误就在调用lk->cpu->cpuid时  
分析原因很可能由于lk->cpu = NULL 查阅相关结构体了解到代表此时锁没有被占用  
没有lock 过 就realse 导致pagefault。。。好吧。。  
回到最开始的assertion error突然醒悟过来这尼玛是中断没关在cprintf的时候外中断又打断了此次中断导致跳过了本应该在用户系统调用阶段处理acquire的lock。。。醉了  
检查发现为啥没关中断被打断前进入trap是因为发生了系统调用。。去看trap_init。。  
回过头去看一眼SETGATE的定义其中第二个参数原文是这么写的。。  
```c
// - istrap: 1 for a trap (= exception) gate, 0 for an interrupt gate.
    //   see section 9.6.1.3 of the i386 reference: "The difference between
    //   an interrupt gate and a trap gate is in the effect on IF (the
    //   interrupt-enable flag). An interrupt that vectors through an
    //   interrupt gate resets IF, thereby preventing other interrupts from
    //   interfering with the current interrupt handler. A subsequent IRET
    //   instruction restores IF to the value in the EFLAGS image on the
    //   stack. An interrupt through a trap gate does not change IF."
```
然后看了眼syscall那里。。1。。oh shit  
就这么一个小bug，完全是因为在做lab3时对SETGATE和 exception|interrupt理解不够造成的。。  

### Exercise 15
```
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	struct Env *e;
	pte_t *pte;
	int r;

	if ( envid2env(envid, &e, 0) < 0 )
		return -E_BAD_ENV;
	if ( !e->env_ipc_recving )
		return -E_IPC_NOT_RECV;
	
	if ( e->env_ipc_dstva && srcva && (uintptr_t)srcva < UTOP ) {
		r = sys_page_map2(curenv->env_id, srcva, envid, e->env_ipc_dstva, perm);
		if ( r < 0 )	return r;
		e->env_ipc_perm = perm;
	}
	else {
		e->env_ipc_perm = 0;
	}
	e->env_ipc_recving = 0;
	e->env_ipc_value = value;
	e->env_ipc_from = curenv->env_id;

	e->env_tf.tf_regs.reg_eax = 0;
	e->env_status = ENV_RUNNABLE;
	return 0;
}
```
首先对参数进行检查，如果需要建立页面才建立相关映射。注意这里最后要考虑让接受进程能够正常返回，其trapframe中的返回值eax应该置为0。并取消其阻塞，让其能够被正常的调度。见下面recv的代码
```c
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ( (uint32_t)dstva >= UTOP || (dstva && ((uint32_t)dstva % PGSIZE)) )
		return -E_INVAL;
	curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_ipc_recving = true;
	curenv->env_ipc_dstva = dstva;
	sys_yield();
}
```
接受方并不是主动去接受消息，消息传递的过程更像是，接受方做好收消息的一切准备，然后挂起，这个时候消息发送方主动去检测接受方是否做好准备，做好准备则直接写入，并通过修改接受方的进程状态和返回值来通知消息是否应经传输成功。  
```c
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	int ret;
	// pg = (pg==NULL)? (void*)UTOP:pg;
	while(1) {
		ret = sys_ipc_try_send(to_env, val, pg, perm);
		if ( ret == 0 )	break;
		if ( ret != -E_IPC_NOT_RECV  && ret <0){
			cprintf("pg : %d perm: %d \n",pg,perm);
			panic("error in ipc_send %e",ret);
		}
		sys_yield();
	}
}
```
由于上面所说的原因，消息发送方并不知道接受方什么时候准备好，因而要不断的循环尝试发送消息，一旦成功就退出。  
同时为了不让其由于死循环一直占用cpu，每循环一次主动放弃一次cou控制权。  
```c
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	// LAB 4: Your code here.
	int ret;
	ret = sys_ipc_recv(pg);

	if ( from_env_store ) {
		*from_env_store = ( ret < 0 )? 0 : thisenv->env_ipc_from;
	}
	if ( perm_store ) {
		*perm_store = ( ret < 0 )? 0 : thisenv->env_ipc_perm;
	}
	if ( ret < 0 )	return ret;
	return thisenv->env_ipc_value;
}
```
同样根据上面所讲的这个函数，应该先调用系统调用get消息，当返回的时候一定是消息传输成功的，因而不用循环。