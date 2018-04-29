
# Lab2

## Part 1 Physical Page Management  

### 背景知识
jos内核虚拟地址分布结构如下所示
```
/*
 * Virtual memory map:                                Permissions
 *                                                    kernel/user
 *
 *    4 Gig -------->  +------------------------------+
 *                     |                              | RW/--
 *                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                     :              .               :
 *                     :              .               :
 *                     :              .               :
 *                     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~| RW/--
 *                     |                              | RW/--
 *                     |   Remapped Physical Memory   | RW/--
 *                     |                              | RW/--
 *    KERNBASE, ---->  +------------------------------+ 0xf0000000      --+
 *    KSTACKTOP        |     CPU0's Kernel Stack      | RW/--  KSTKSIZE   |
 *                     | - - - - - - - - - - - - - - -|                   |
 *                     |      Invalid Memory (*)      | --/--  KSTKGAP    |
 *                     +------------------------------+                   |
 *                     |     CPU1's Kernel Stack      | RW/--  KSTKSIZE   |
 *                     | - - - - - - - - - - - - - - -|                 PTSIZE
 *                     |      Invalid Memory (*)      | --/--  KSTKGAP    |
 *                     +------------------------------+                   |
 *                     :              .               :                   |
 *                     :              .               :                   |
 *    MMIOLIM ------>  +------------------------------+ 0xefc00000      --+
 *                     |       Memory-mapped I/O      | RW/--  PTSIZE
 * ULIM, MMIOBASE -->  +------------------------------+ 0xef800000
 *                     |  Cur. Page Table (User R-)   | R-/R-  PTSIZE
 *    UVPT      ---->  +------------------------------+ 0xef400000
 *                     |          RO PAGES            | R-/R-  PTSIZE
 *    UPAGES    ---->  +------------------------------+ 0xef000000
 *                     |           RO ENVS            | R-/R-  PTSIZE
 * UTOP,UENVS ------>  +------------------------------+ 0xeec00000
 * UXSTACKTOP -/       |     User Exception Stack     | RW/RW  PGSIZE
 *                     +------------------------------+ 0xeebff000
 *                     |       Empty Memory (*)       | --/--  PGSIZE
 *    USTACKTOP  --->  +------------------------------+ 0xeebfe000
 *                     |      Normal User Stack       | RW/RW  PGSIZE
 *                     +------------------------------+ 0xeebfd000
 *                     |                              |
 *                     |                              |
 *                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                     .                              .
 *                     .                              .
 *                     .                              .
 *                     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
 *                     |     Program Data & Heap      |
 *    UTEXT -------->  +------------------------------+ 0x00800000
 *    PFTEMP ------->  |       Empty Memory (*)       |        PTSIZE
 *                     |                              |
 *    UTEMP -------->  +------------------------------+ 0x00400000      --+
 *                     |       Empty Memory (*)       |                   |
 *                     | - - - - - - - - - - - - - - -|                   |
 *                     |  User STAB Data (optional)   |                 PTSIZE
 *    USTABDATA ---->  +------------------------------+ 0x00200000        |
 *                     |       Empty Memory (*)       |                   |
 *    0 ------------>  +------------------------------+                 --+
 *
 * (*) Note: The kernel ensures that "Invalid Memory" is *never* mapped.
 *     "Empty Memory" is normally unmapped, but user programs may map pages
 *     there if desired.  JOS user programs map pages temporarily at UTEMP.
 */
```
在实验1中，已经将线性地址0-4M映射到了虚拟地址0-4M和KERNBASE-KERNBASE+4M。在本实验中，要将物理内存的低256M映射到从KERNBASE开始的虚拟地址。  

### Exercise 1
这一部分练习是让我们实现一组函数对物理页进行直接的操作,对空闲页的管理通过管理Page Info空闲链表完成。
```c
//in boot_alloc
//Wrong code:
//nextfree = ROUNDUP(nextfree+n,PGSIZE);
//if ((uint32_t)nextfree > KERNBASE + PGSIZE*npages)
//	panic("out of memory!");
//else
//	return nextfree;

//Right code:
```
由于nextfree为静态指针，每次分配的时候将其指向下一页的首部地址即可。  
上述代码中注释部分是错误的，这个错误虽然在实验2当中没有体现出来，但是造成了最后一个实验的问题，具体分析见最后一次实验，正确代码。
```c
//in mem_init
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo)*npages);
	memset(pages, 0, sizeof(struct PageInfo)*npages);
```

在mem_init当中，for循环一页一页的插入知道把管理物理页的结构体组映射到UPAGES开始的虚拟地址处  
boot_map_region 则把内核栈映射到KSTACKTOP-KSTKSIZE处，同时注意这里的权限设置，内核栈用户不能进行任何操作。而pages对用户是只读的。
```c
//in page_init
void
page_init(void)
{
	uint32_t paddr,kernelsize;
	kernelsize = (uint32_t)(boot_alloc(0)-KERNBASE);
	cprintf("kernel: %u bytes\n",kernelsize);
	pages[0].pp_ref = 1;
	for ( int i=1; i<npages; i++) {
		paddr = i*PGSIZE;
		//in case of in iohole or in kernel
		if ( paddr >= IOPHYSMEM && paddr < EXTPHYSMEM + kernelsize)
			continue;
		else {
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
```
在初始化物理页面信息时，注意如下已被占有的物理页面不能加入空闲链表
* IDT存放的位置，即第0个页面
* IO映射内存，即0xA0000到0x100000
* 用于存放物理页面信息的内存，即pages到pages+npages
```c
//in page_alloc
struct PageInfo *
page_alloc(int alloc_flags)
{
	struct PageInfo * nxtpg, *spa;
	if (!page_free_list)	return NULL;	//outof memory
	else {
		nxtpg = page_free_list->pp_link;
		page_free_list->pp_link = NULL;
		if (alloc_flags & ALLOC_ZERO) {
			memset(page2kva(page_free_list),0,PGSIZE);
		}
		spa = page_free_list;
		page_free_list = nxtpg;
		return spa;
	}
	return 0;
}
```
这里注意不要增加引用计数，并需要判断没用空闲界面的情况  
```c
//page free
void
page_free(struct PageInfo *pp)
{
	if ( pp->pp_ref != 0 )
		panic("pp_ref:%d nonezero!\n",pp->pp_ref);
	else if( pp->pp_link != NULL )
		panic("pp_link nonezero!\n");
	else {
		pp->pp_link = page_free_list;
		page_free_list = pp;
	}
}
```
只有当引用计数为0的时候才能调用这个函数，因此需要进行判断。

## PART2
### 相关知识

### Exercise 4
要求我们实现管理页表项的一组函数

```c
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	uint32_t pgdir_id,pgtb_id;
	pde_t pgtb;

	pgdir_id = PDX(va);
	pgtb_id = PTX(va);

	pgtb = pgdir[pgdir_id];
	if ( (!(pgtb & PTE_P)) && create == 0 ) {
		return NULL;
	}
	// allocte page table for a certain PDE
	if ( !(pgtb & PTE_P) ) {
		struct PageInfo *npg = page_alloc(ALLOC_ZERO);
		if ( !npg ) return NULL;		//Out of memory
		npg->pp_ref++;
		pgdir[pgdir_id] = page2pa(npg) | PTE_P |PTE_W | PTE_U;
	}
	pgtb = PTE_ADDR(pgdir[pgdir_id]);
	return KADDR((physaddr_t)pgtb_id*sizeof(physaddr_t)+pgtb); //
}
```
当一级页表内不存在va对应的表项时，需要根据create判断是否要为其分配一个物理页面用作二级页表 
这里需要设置权限，由于一级页表和二级页表都有权限控制，所以一般的做法是，放宽一级页表的权限，主要由二级页表来控制权限，不过这里对权限均做了控制
还要注意，一级页表中存放的地址是物理地址，而返回的必须是虚拟地址且必须去掉权限位
所以返回值前面加上KADDR

```c
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pde_t * pte;
	while (size) {
		pte = pgdir_walk(pgdir, (const void*)va, 1);
		if ( !pte ) return ;
		*pte = pa|perm|PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
		size -= PGSIZE;
	}
}
```
映射一整个虚拟地址到物理地址

```c
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir,va,0);
	if ( !pte || !(*pte & PTE_P ) )  // the pagetable is not yet allocated or no page mapped at va
		return NULL;
	else {
		*pte_store = pte;
		return pa2page(PTE_ADDR(*pte)+PGOFF(va));
	} 
}
```
当耳机页表项或者一级页表不存在时返回null，否则找到的页表项会被保存到pte_store当中

```c
void
page_remove(pde_t *pgdir, void *va)
{
	// Fill this function in
	pte_t *pte_store;
	struct PageInfo *pg;
	pg = page_lookup(pgdir, va, &pte_store);
	if ( pg ) {
		*pte_store = 0;
		page_decref(pg);
		tlb_invalidate(pgdir,va);
	}
}
```
通过page_lookup找va对应的页，注意页表项内容清0，

```c
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte;
	pte = pgdir_walk(pgdir, va, 1);
	// cprintf("pte = %08x\n",pte);
	if ( !pte )	
		return -E_NO_MEM;
	else {
		pp->pp_ref++;	// add pp_ref in advance to avoid mistakely free of page
		if ( *pte & PTE_P )  {
			tlb_invalidate(pgdir,va);
			page_remove(pgdir, va);
		}
		*pte = page2pa(pp);
		*pte = PTE_ADDR(*pte) | perm |PTE_P;
		// cprintf("insert %08x %08x\n",pte,*pte);
	}	
	return 0;
}
```
分配页面失败时返回-E_NO_MEM，插入时分三种情况

* 插入位置不存在页面，直接插入即可
* 插入位置存在不相同的页面，先移除该页面再插入
* 插入位置存在相同页面，设置权限即可

### 调试过程与结果分析
1. 关于分页二级页表机制不够了解。   
（Chapter4 图4-5）
断言错误
返回值中忘记加上offset组成实际的物理地址
2. 类型导致的地址错误     
出现如下断言错误
```c
assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2))
```
debug 过程：
检查check_va2pa(kern_pgdir, PGSIZE) 和 page2pa(pp2)对应的值
发现前者值为0xffffffff 仔细阅读函数
```
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
```
发现出现这种情况可能是标志位没有设置好
经过debug发现第一个条件分支判断失败 在pgwalk_up申请新页表的时候没有设置好目录项的标志位
改正之后仍然错误  
此时错误在第二个条件分支判断  
将p[PTX(va)]的值和在上一句断言中调用的page_insert中的值比较。  
	  		pte's addr
insert      f03ff001 
check_va2pa f03ff004 
发现在insert中赋值pte的时候地址是错误的，debug错误定位到pgwalk_up返回值
```c
return KADDR((physaddr_t)pgtb_id+pgtb);
```
这里由于是physaddr_t因而页表项的地址错误的变成了页表基地址+页表id  
应该是页表项的偏移+基地址

3. 指令顺序导致的错误释放了页表的错误
出现如下断言错误
```c
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
	assert(pp2->pp_ref == 1);

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
```
根据注释提示，发现错误的确是在上一个insert操作时映射的地址对应page和要映射的page是同一个时造成错误的remove掉原来的page导致其pp_ref为0,被释放。  
注释中提到有一种优雅的解决方法，其实就是先将pp_ref++,再进行remove，这样就避免了错误施放掉我们的目的页面。

## Part 3 Kernel Address Space
### Exercise 5
练习5要求我们使用之前定义的内存映射的函数来初始化系统内存  
这里也可以使用page_insert代替boot_map_region来一个个插入。
```c
// Map 'pages' read-only by the user at linear address UPAGES
boot_map_region(kern_pgdir, UPAGES, ROUNDUP(sizeof(struct PageInfo)*npages, PGSIZE), PADDR(pages), PTE_U | PTE_P);

// Use the physical memory that 'bootstack' refers to as the kernel stack. 
boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE,PGSIZE), PADDR(bootstack), PTE_W | PTE_P);

// Map all of physical memory at KERNBASE.
uint32_t msize = ~KERNBASE + 1;
boot_map_region(kern_pgdir, KERNBASE, msize, 0, PTE_W | PTE_P);
```

## Quesions
1.Assuming that the following JOS kernel code is correct, what type should variable x have, uintptr_t or physaddr_t?   
```c
    mystery_t x;
	char* value = return_a_pointer();
	*value = 10;
	x = (mystery_t) value; //mystery_t = uintptr_t
```

2. What entries (rows) in the page directory have been filled in at this point? What addresses do they map and where do they point? In other words, fill out this table as much as possible
0x3BD号页目录项，指向的是kern_pgdir
0x3BC号页目录项，指向的是pages数组
0x3BF号页目录项，指向的是bootstack
3C0~3FF号页目录项，指向的是kernel

3. We have placed the kernel and user environment in the same address space. Why will user programs not be able to read or write the kernel's memory? What specific mechanisms protect the kernel memory?  
主要通过页表项中的PTEW位来维护

4.  What is the maximum amount of physical memory that this operating system can support? Why?  
2GB 使用4MB的page来存储页的pageinfo 
4*1024kbytes / 8bytes = 512k
512k * 4bytes(perpage) = 2G

5. How much space overhead is there for managing memory, if we actually had the maximum amount of physical memory? How is this overhead broken down?  
4M + 4k + 512k*4byte = 6M+4k

6. Revisit the page table setup in kern/entry.S and kern/entrypgdir.c. Immediately after we turn on paging, EIP is still a low number (a little over 1MB). At what point do we transition to running at an EIP above KERNBASE? What makes it possible for us to continue executing at a low EIP between when we enable paging and when we begin running at an EIP above KERNBASE? Why is this transition necessary?  
jmp *%eax  
