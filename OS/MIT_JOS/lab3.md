# LAB3 

## Part A User Environments and Exception Handling
实验这一部分要求我们编写代码完成对多环境（进程），和异常处理的支持。

### 初始化与管理用户进程
这里实使用了enviroment一词来区别jos的进程和UNIX proccess，一下统称为进程。
jos使用结构体链表struct Env来管理空闲进程，env_free_list指向空闲进程单项链表的链表头。envs为保存着所有环境的链表的结构的数组。curenv指向当前运行的进程。
记录进程状态的结构体如下所示其对应成员释义见注释
```
struct Env {
	struct Trapframe env_tf;	// 保存的进程现场的寄存器组
	struct Env *env_link;		// 若进程在空闲队列当中，指向下一个空间进程
	envid_t env_id;			    // 进程的id
	envid_t env_parent_id;		// 父进程的id
	enum EnvType env_type;		// 进程种类
	unsigned env_status;		// 进程状态
	uint32_t env_runs;		    // 进程运行过的次数

	// Address space
	pde_t *env_pgdir;		    // 指向该进程的页表
}；
```
进程的最大数量为1024个，定义在env.h当中

关于ELF文件的知识补充：

### Exercise 1
这里要求对管理进程的链表分配空间并将其映射到内核UENV处，内核为其预留的空间大小为PTSIZE=4M。 
仿照lab2当中对pages的分配和映射方法即可。  
```c
	envs = (struct Env *)boot_alloc(sizeof(struct Env)*NENV);
	memset(envs , 0, sizeof(struct Env)*NENV);
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(sizeof(struct Env)*NENV, PGSIZE), PADDR(envs), PTE_U | PTE_P);
```  

### Exercise 2
这里要求编写函数建立用户进程。由于现在还没有文件系统，需要通过载入ELF文件来建立映射。
给出了初始化的流程如下所示：
```
start (kern/entry.S)
	i386_init (kern/init.c)
		cons_init
		mem_init
		env_init
		trap_init (still incomplete at this point)
		env_create
		env_run
			env_pop_tf	
```
先编写env_init
```c

void env_init(void)
{
	// Set up envs array
	for (int i=NENV-1; i>=0; i--) {
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
}
```
如上述代码，env_init将envs数组当中的所有环境初始化，关键是倒序插入空闲链表当中，这样env_id为0的链表一定在envs头部。


接下来调用到了env_create
```c
void env_create(uint8_t *binary, enum EnvType type)
{
	// LAB 3: Your code here.
	struct Env *e;
	int ret;
	ret = env_alloc(&e,0);
	if ( ret < 0 ) {
		panic("Error allocting env: %e",ret);
	}
	load_icode(e,binary);
	e->env_type = type;
}
```
根据注释，带用env_alloc后申请到的进程管理结构的指针保存在e当中，深入观察env_alloc发现，env_alloc主要分配进程控制结构体以及调用env_set_vm来设置进程的虚拟地址空间。

完成env_set_vm
```c
	p->pp_ref++;
	
	pde_t *pgdir = page2kva(p);
	memcpy(pgdir, kern_pgdir, PGSIZE);
	e->env_pgdir = pgdir;
```
lab2中有提到过每一个进程有其自己的虚拟进程映射空间，而对于各种进程来说pages envs 物理内存等等的映射也是必不可少的，简单起见，可以直接把kern_pgdir的一级页表复制过去。


完成region_alloc一方便后面函数调用
```c
static void region_alloc(struct Env *e, void *va, size_t len)
{
	void *addr, *eaddr;
	addr = ROUNDDOWN(va,PGSIZE);
	eaddr = ROUNDUP(va+len,PGSIZE);
	
	struct PageInfo *pp;
	for (; addr < eaddr; addr += PGSIZE) {
		pp = page_alloc(ALLOC_ZERO);
		if ( !pp ) {
			panic("Out of memory!");
			continue;
		}
		int ret = page_insert(e->env_pgdir, pp, addr, PTE_U | PTE_W | PTE_P);
		if ( ret < 0 )
			panic("out of memory!");
	}
}
```
为env分配物理内存然后映射到虚拟内存上去，注意，这里就明显体现了分配得到的物理内存不一定连续，但是虚拟内存一定连续。

完成load_icode
```c
static void
load_icode(struct Env *e, uint8_t *binary)
{
	// LAB 3: Your code here.
	lcr3( PADDR(e->env_pgdir));
	struct Elf *env_elf;
	struct Proghdr *ph,*eph;
	env_elf = (struct Elf*)binary;
	ph = (struct Proghdr*)((uint8_t*)binary + env_elf->e_phoff );
	eph = ph + env_elf->e_phnum;

	for (; ph<eph; ph++) {
		if ( ph->p_type == ELF_PROG_LOAD ) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memcpy((void *)(ph->p_va), (void*)binary + ph->p_offset, ph->p_filesz);
		}
	}
	e->env_tf.tf_eip = env_elf->e_entry;
	lcr3( PADDR(kern_pgdir));
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
}
```
这个函数作用是将elf文件读入用户进程e的地址空间中，这一部分参考了bootloader中的做法，关于elf文件头的格式见之前的背景知识处。  
中间的循环是为了将elf文件当中所有应该载入的段咋如，载入的虚拟地址位置由该段的p_va决定。
由于该操作是在用户进程的也表上完成，开始之前结束之后反而别要切换到用户和内核的页表上去。同时需要把用户进程寄存器组的eip指向可执行文件的第一条指令，那么下次切换到这个进程时就从加载进来的程序开始部分开始执行。结束之后同样要为该进程加载的程序运行时所需要的栈分配空间。  

实现env_run
```c
void
env_run(struct Env *e)
{
	if (curenv && curenv->env_status == ENV_RUNNING) {
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
	curenv->env_status = ENV_RUNNING;
	curenv->env_runs++;
	lcr3(PADDR(curenv->env_pgdir));
	env_pop_tf(&(curenv->env_tf));
}
```
运行 env ，需要设置状态并切换页表，这里起到关键作用的函数是 env_pop_tf ，通过查看代码可以知道，它将 trapframe 里保存的信息 pop 到了对应的寄存器上，注意在 load_icode 函数的最后一句把 trapframe 中的 eip 设置到了二进制文件的入口，所以在执行完 env_pop_tf 后，下一条指令的地址将会是二进制文件的入口，因此达到了切换的目的

### Exercise 3
关于中断知识的补充

### Exercise 4
需要我们修改trapentry.S and trap.c 来实现中断
```
// trapentry.S
TRAPHANDLER_NOEC(divide_zero_handler,T_DIVIDE);
TRAPHANDLER_NOEC(debug_handler,T_DEBUG);
TRAPHANDLER_NOEC(nmi_handler,T_NMI);
TRAPHANDLER_NOEC(breakpoint_handler,T_BRKPT);
TRAPHANDLER_NOEC(overflow_handler,T_OFLOW);
TRAPHANDLER_NOEC(bound_check_handler,T_BOUND);
TRAPHANDLER_NOEC(illegal_opcode_handler,T_ILLOP);
TRAPHANDLER_NOEC(device_not_available_handler,T_DEVICE);
TRAPHANDLER(double_fault_handler,T_DBLFLT);
TRAPHANDLER(invalid_tss_handler,T_TSS);
TRAPHANDLER(segment_not_present_handler,T_SEGNP);
TRAPHANDLER(stack_handler,T_STACK);
TRAPHANDLER(general_protection_fault_handler,T_GPFLT);
TRAPHANDLER(pagefault_handler,T_PGFLT);
TRAPHANDLER_NOEC(floating_point_error_handler,T_FPERR);
TRAPHANDLER(alignment_check_handler,T_ALIGN);
TRAPHANDLER_NOEC(machine_check_handler,T_MCHK);
TRAPHANDLER_NOEC(simid_floating_point_error_handler,T_SIMDERR);

TRAPHANDLER_NOEC(syscall_handler,T_SYSCALL);
_alltraps:
	push %ds 
	push %es 
	pushal

	mov $GD_KD,%ax
	mov %ax,%ds
	mov %ax,%es

	//pass pointer to tapframe as argument
	pushl %esp
	
	call trap
```
其中TRAPHANDLER和TRAPHANDLER_NOEC是对应的两个汇编宏展开，其将我们设置的处理函数名展开成一个函数定义。 

根据之前所说，在引发异常时 CPU 会把 SS 寄存器到 EIP 寄存器压入栈中，如果需要 error code 的话也会压入，而在上面宏定义的函数中，trapno 也被压入了，所以这里只需要 push 余下的寄存器，注意需要根据 trapframe 的结构倒序压入， pushal 指令会按顺序将 eax 到 edi 压入栈中，call 之后的指令是当 call trap 失败时可以还原相关寄存器。此外根据不同的中断，是否会压入中断码的情况也不相同。因此需要查表设置对应的正确的宏展开。


```
// in trap_init()
	void divide_zero_handler();
	void debug_handler();
	void nmi_handler();
	void breakpoint_handler();
	void overflow_handler();
	void bound_check_handler();
	void illegal_opcode_handler();
	void device_not_available_handler();
	void double_fault_handler();
	void invalid_tss_handler();
	void segment_not_present_handler();
	void stack_handler();
	void general_protection_fault_handler();
	void pagefault_handler();
	void floating_point_error_handler();
	void alignment_check_handler();
	void machine_check_handler();
	void simid_floating_point_error_handler();

	SETGATE (idt[T_DIVIDE], 0, GD_KT, divide_zero_handler, 0);
	SETGATE (idt[T_DEBUG], 0, GD_KT, debug_handler, 0);
	SETGATE (idt[T_NMI], 0, GD_KT, nmi_handler, 0);
	SETGATE (idt[T_BRKPT], 0, GD_KT, breakpoint_handler, 3);
	SETGATE (idt[T_OFLOW], 0, GD_KT, overflow_handler, 0);
	SETGATE (idt[T_BOUND], 0, GD_KT, bound_check_handler, 0);
	SETGATE (idt[T_ILLOP], 0, GD_KT, illegal_opcode_handler, 0);
	SETGATE (idt[T_DEVICE], 0, GD_KT, device_not_available_handler, 0);
	SETGATE (idt[T_DBLFLT], 0, GD_KT, double_fault_handler, 0);
	SETGATE (idt[T_TSS], 0, GD_KT, invalid_tss_handler, 0);
	SETGATE (idt[T_SEGNP], 0, GD_KT, segment_not_present_handler, 0);
	SETGATE (idt[T_STACK], 0, GD_KT, stack_handler, 0);
	SETGATE (idt[T_GPFLT], 0, GD_KT, general_protection_fault_handler, 0);
	SETGATE (idt[T_PGFLT], 0, GD_KT, pagefault_handler, 0);
	SETGATE (idt[T_FPERR], 0, GD_KT, floating_point_error_handler, 0);
	SETGATE (idt[T_ALIGN], 0, GD_KT, alignment_check_handler, 0);
	SETGATE (idt[T_MCHK], 0, GD_KT, machine_check_handler, 0);
	SETGATE (idt[T_SIMDERR], 0, GD_KT, simid_floating_point_error_handler, 0);
```
通过SETGATE宏设置不同的中断向量的入口地址。注意最后一个参数DPL，由于普通用户也可以使用DPL需要等于3。 SETGATE的定义位于inc/mmu.h当中。特权级需要小于等于所设置的这个值才能执行中断，而为了让用户能够使用 breakpoint，dpl设置为3.


## Part B

### Exercise 5
修改trap_dispatch以处理页错误的情况。
这里只需要根据tf->trapno来判断异常的类型然后分配给相应函数即可。
对应代码见Exercise 7

### Exercise 6
修改trap_dispatch以处理breakpoint的情况
同上一样,不过调用的函数变成了monitor

### Exercise 7
增加syscall的中断向量。  
```c
// trapentry.S
TRAPHANDLER_NOEC(syscall_handler, T_SYSCALL)

// trap.c
// trap_init()
extern void syscall_handler();
SETGATE(idt[T_SYSCALL], 0, GD_KT, syscall_handler, 3);

// trap_dispatch
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if ( tf->tf_trapno == T_PGFLT ) 
		page_fault_handler(tf);
	else if ( tf->tf_trapno == T_BRKPT ) 
		monitor(tf);
	else if ( tf->tf_trapno == T_SYSCALL ) {
		int ret = syscall ( tf->tf_regs.reg_eax,
				tf->tf_regs.reg_edx,
				tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx,
				tf->tf_regs.reg_edi,
				tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	else {
		print_trapframe(tf);
		if (tf->tf_cs == GD_KT)
			panic("unhandled trap in kernel");
		else {
			env_destroy(curenv);
			return;
		}
	}
}
```
增加中断向量的方式同上，syscall函数的定义在syscall.c当中  
根据注释提示，顺序将寄存器的值当参数传入函数，同时返回值存储在寄存器eax当中

### Exercise 8

```
// libmain.c
// libmain()
thisenv = &envs[ENVX(sys_getenvid())];
```
由于之前没有设置 thisenv 的值，所以运行到 hello 的第二句时会出现错误，这里根据 id 取出索引，然后找到相应 env

### Exercise 9
```c
// trap.c
// page_fault_handler()
if ((tf->tf_cs & 3) == 0) {
    panic("page fault in kern");
}
```
由于 cs 寄存器的低 2 位的值与 CPL 相等，所以可以根据 cs 寄存器判断是否在内核态
```c
int user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t cva = (uintptr_t)va;
	uintptr_t eva = (uintptr_t)(va + len -1);
	perm = perm|PTE_U|PTE_P;
	for (; cva <= eva; cva+=PGSIZE ) {
		if (cva >= ULIM) {
			user_mem_check_addr = cva;
			return -E_FAULT;
		}
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)cva, 0);
		if ( pte == NULL || (*pte & perm) != perm ) {
			user_mem_check_addr = cva;
			return -E_FAULT;
		}
		cva = ROUNDDOWN(cva, PGSIZE);
	}
	return 0;
}
```
通过页表找到相应的 pte ，然后判断是否具有权限，这里需要记录第一个出错的虚拟地址，所以一开始不能将 va 对齐，还有这种写法的 high 不能向下对齐，因为结果可能会比 low 还小


```c
// syscall.c
// sys_cputs()
user_mem_assert(curenv, s, len, 0);
// kdebug.c
// debuginfo_eip()
if (user_mem_check(curenv, (void *) USTABDATA, sizeof(struct UserStabData), 0) < 0) {
    return -1;
}
//...
if (user_mem_check(curenv, (void *) stabs, stab_end - stabs, 0) < 0 || user_mem_check(curenv, (void *) stabstr, stabstr_end - stabstr, 0) < 0) {
    return -1;
}
```
增加检查的部分。

关于最后一个问题，在调用 backtrace 后显示如下
```
K> backtrace
Stack backtrace:
 ebp efffff20 eip f0100c79 args 00000001 efffff38 f0198000 00000000 f0175840
     kern/monitor.c:217: monitor+276
 ebp efffff90 eip f01039a0 args f0198000 efffffbc 00000000 00000082 00000000
     kern/trap.c:192: trap+199
 ebp efffffb0 eip f0103aa8 args efffffbc 00000000 00000000 eebfdfd0 efffffdc
     kern/trapentry.S:80: <unknown>+0
 ebp eebfdfd0 eip 00800073 args 00000000 00000000 eebfdff0 00800049 00000000
     lib/libmain.c:26: libmain+58
 ebp eebfdff0 eip 00800031 args 00000000 00000000Incoming TRAP frame at 0xeffffea4
kernel panic at kern/trap.c:261: page fault in kern
```
这里引发页错误的原因是访问到了用户栈顶以上，可以看到， libmain 的两个参数都是 0 ，回想一下，在 lib/entry.S 中，系统在 USTACKTOP 执行了两次 pushl $0 ，所以当往上找第三个参数时就到达了上面的空内存，所以引发了页错误



## questions 
1. What is the purpose of having an individual handler function for each exception/interrupt? (i.e., if all exceptions/interrupts were delivered to the same handler, what feature that exists in the current implementation could not be provided?)
    根据不同的异常，硬件有的会提供errcode，有的不会，设置独立的处理函数方便根据不同的异常补全栈帧当中的trapframe结构，若是使用同一个处理程序，将无法限制调用错误处理程序的代码的特权级，也无法得知中断向量的值。
2. Did you have to do anything to make the user/softint program behave correctly? The grade script expects it to produce a general protection fault (trap 13), but softint's code says int $14. Why should this produce interrupt vector 13? What happens if the kernel actually allows softint's int $14 instruction to invoke the kernel's page fault handler (which is interrupt vector 14)?
    仅有内核代码允许执行页错误处理程序，尽管调用了int $14，仍然因为保护机制而生成了中断向量13。如果允许会导致用户程序能够破坏内核的运行。
3. The break point test case will either generate a break point exception or a general protection fault depending on how you initialized the break point entry in the IDT (i.e., your call to SETGATE from trap_init). Why? How do you need to set it up in order to get the breakpoint exception to work as specified above and what incorrect setup would cause it to trigger a general protection fault?
    0: general protection
    3: breakpoint exception
    DPL字段代表的含义是段描述符优先级（Descriptor Privileged Level），如果我们想要当前执行的程序能够跳转到这个描述符所指向的程序哪里继续执行的话，有个要求，就是要求当前运行程序的CPL，RPL的最大值需要小于等于DPL，否则就会出现优先级低的代码试图去访问优先级高的代码的情况，就会触发general protection exception。那么我们的测试程序首先运行于用户态，它的CPL为3，当异常发生时，它希望去执行 int 3指令，这是一个系统级别的指令，用户态命令的CPL一定大于 int 3 的DPL，所以就会触发general protection exception，但是如果把IDT这个表项的DPL设置为3时，就不会出现这样的现象了，这时如果再出现异常，肯定是因为我们还没有编写处理break point exception的程序所引起的，所以是break point exception。

4. What do you think is the point of these mechanisms, particularly in light of what the user/softint test program does?
   保护内核和用户环境的相互独立

## Bugs encountered during the lab
### bug 描述
在做到实验8的时候，初始化用户环境崩溃，从qemu观察到不断抛出异常

### debug 的过程
逐级检查回去，检查libmain中切换环境的代码，检查切换环境所利用到的系统调用的代码
检查系统调用的入口设置正确与否，以上检查均无问题之后，打算用kern/trap.c当中的print_trapframe来打印出抛出异常的时候异常的相关信息。  
print_trapframe打印出的trapno显示为trap fault,且页不存在，则怀疑是内存分配或者内存映射上出现了问题。使用gdb调试定位异常在内核初始化阶段肯定了这一假设。具体位于env_create当中调用load_icode时发生的错误。
```
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	void *addr, *eaddr;
	addr = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE);
}
```
考虑 va = n*PGSIZE - 1 len = 2
这种情况跨页应该分配两个页面的空间，而实际上只会以为只分配一个。
这种写法造成的corner case 直接导致了在后面load_icode中可能会出现memcpy写入尚未被分配的空间内。
```
if ( ph->p_type == ELF_PROG_LOAD ) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memcpy((void *)(ph->p_va), (void*)binary + ph->p_offset, ph->p_filesz);
		}
```
## user_mem_check fail
### bug描述
user_mem_check 总是返回失败，根据上一个bug联想到，首先检查memcheck的上下边界。
### debug过程
由于memcheck的最后一个字节开始于va+len-1,最后一次检查的地址肯定小于其。
修改了循环判断条件，其次，为了检查到每一页，检查了第一页之后将va向下对齐。  

