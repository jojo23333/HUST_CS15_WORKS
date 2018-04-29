# Lab1 Booting a PC
## Part 1: PC bootstrap
## Part 2: The boot loader
### Exercise3:
1. At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
```
  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc           # 加载全局描述符
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0        # enable 保护模式
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg   # ljmp执行之后从16位的实模式转化为32位保护模式
```

2. What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?

```
	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();
    7d63:	ff 15 18 00 01 00    	call   *0x10018 # last instruction

    movw $0x1234,0x472  # first instruction of kernel，warm boot
```
 kernel第一条指令显示往物理内存0x472（启动模式标志字）处写值0x1234，以设置热启动

3. Where is the first instruction of the kernel?   
    **0x10000c**

4. How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?  
**通过读取kernel的ELF文件头中的程序头表偏移找到程序头表位置，通过读取程序头表确定需要读多少个扇区**
```c
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum; //get info from elf header
	for (; ph < eph; ph++)
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
```

### Exercise 5:
在boot/Makefarg中这一句话指定了编译的地址
```makefile
$(OBJDIR)/boot/boot: $(BOOT_OBJS)
	@echo + ld boot/boot
	$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@.out $^
	$(V)$(OBJDUMP) -S $@.out >$@.asm
	$(V)$(OBJCOPY) -S -O binary -j .text $@.out $@
	$(V)perl boot/sign.pl $(OBJDIR)/boot/boot
```
修改地址会导致程序崩溃

### Exercise 6:
```bash
objdump -h obj/kern/kernel
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         0000178e  f0100000  00100000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
```
如上图可见.text段被加载到0x00100000处


### Exercise 7:
What is the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place? Comment out the movl %eax, %cr0 in kern/entry.S, trace into it, and see if you were right.  
如果不执行语句 movw %eax %cr0
则不会启用页表
会跳转到0xf010002c然后终止程序

执行之后[0xf0000000~0xf0400000]被映射到[0x000000~0x400000]

### Exercise 8:
```c
    case 'o':
        num = getuint(&ap, lflag);
        base = 8;
        goto number;
```

**Questions**
1. *Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?*    
    函数**void cputchar(int c)** 用于在光标处输出一个字符，printf.c用其来构造函数**static void putch(int ch, int *cnt)**

2. *Explain the following from console.c:*
```c
if (crt_pos >= CRT_SIZE) {
    int i;
    memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
    for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
                crt_buf[i] = 0x0700 | ' ';
    crt_pos -= CRT_COLS;
}
```
可以在console.h中找到CRT_SIZE的定义如下：
```c
#define CRT_ROWS	25
#define CRT_COLS	80
#define CRT_SIZE	(CRT_ROWS * CRT_COLS)
```
可以看出CRT_SIZE代表整个屏幕能输出的字符，当总的字符数超过这个数的时候需要将已输出的内容向上滚动
memmove完成这一工作。

3. *For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC's calling convention on the x86.*
*Trace the execution of the following code step-by-step:*
```c
    int x = 1, y = 3, z = 4;
    cprintf("x %d, y %x, z %d\n", x, y, z);
```

* *In the call to cprintf(), to what does fmt point? To what does ap point?*  
fmt指向字符串"x %d, y %x, z %d\n",ap指向变量x。

* *List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.* 
```
vcprintf(fmt,ap) // fmt 指向字符串 ap 指向地一个参数x
va_arg() // 每调用一次 ap 从 x 到 y 到 z
putch(int ch, int *cnt) -> cputchar(int c) -> cons_putc(int c);
``` 



4. *Run the following code.*
```c
    unsigned int i = 0x00646c72;
    cprintf("H%x Wo%s", 57616, &i);
```
*What is the output? Explain how this output is arrived at in the step-by-step manner of the previous exercise. Here's an ASCII table that maps bytes to characters.*
*(The output depends on that fact that the x86 is little-endian. If the x86 were instead big-endian what would you set i to in order to yield the same output? Would you need to change 57616 to a different value?)*
小端方式输出：  
Output **He110 World**
大端方式输出同样内容，57616不变，i的值变为0x726c6400



5. *In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?*
```c
    cprintf("x=%d y=%d", 3);
```
输出栈内的一个参数3高一个地址的位置的值


6. *Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?*
```c
cprintf(....,char *)
```

### Exercise 9:
*Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?*

```
#In entry.S
	# Set the stack pointer
	movl	$(bootstacktop),%esp
    ...
    .data
###################################################################
# boot stack
###################################################################
	.p2align	PGSHIFT		# force page alignment
	.globl		bootstack
bootstack:
	.space		KSTKSIZE
	.globl		bootstacktop   
bootstacktop:
```
通过数据段来为堆栈段保留空间
```c
//In memlayout.h
// Kernel stack.
#define KSTACKTOP	KERNBASE
#define KSTKSIZE	(8*PGSIZE)   		// size of a kernel stack
#define KSTKGAP		(8*PGSIZE)   		// size of a kernel stack guard
//In mmu.h
#define PGSIZE		4096		// bytes mapped by a page
```
可见该空间大小为32字节

### Exercise 10
4  + 4  +     20       + 4    =32 byte入栈   
ebp ebx 预留空间(包含参数) cs:ip

