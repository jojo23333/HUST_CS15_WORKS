.text
	addi $sp,$zero,0x300
	addi $t0, $zero, 10
	j test
	j IR1
	j IR2
	j IR3

IR1:
# protect env
	addi	$sp, $sp, -4
	sw 	$t0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$t1, 0($sp)
	addi	$sp, $sp, -4
	sw 	$s0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$s1, 0($sp)
	addi	$sp, $sp, -4
	sw 	$a0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$v0, 0($sp)

	mfc0	$t0, $1
	addi    $sp, $sp, -4
	sw 	$t0, 0($sp)
	
	#Open Interrupt
	addi 	$t0, $zero, 0
	mtc0	$t0, $0
	
# IR1 program
addi $s1,$zero,1       #�жϺ�1,2,3   ��ͬ�жϺ���ʾֵ��һ��
add $s0,$zero,$s1   

IntLeftShift1:
sll    $s0, $s0, 4  
add    $a0,$0,$s0	  #display $s0
addi   $v0,$0,34         # display hex
syscall                 # we are out of here.   
bne $s0, $zero, IntLeftShift1
	
	#Close Interrupt
	addi	$t0, $zero, 1
	mtc0	$t0, $0

# restore env
	lw	$t0, 0($sp)
	addi	$sp, $sp, 4
	mtc0	$t0, $1		#restore epc

	lw 	$v0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$a0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$s1, 0($sp)
	addi	$sp, $sp, 4
	lw 	$s0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$t1, 0($sp)
	addi	$sp, $sp, 4
	lw 	$t0, 0($sp)
	addi	$sp, $sp, 4
	eret

IR2:
# protect env
	addi	$sp, $sp, -4
	sw 	$t0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$t1, 0($sp)
	addi	$sp, $sp, -4
	sw 	$s0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$s1, 0($sp)
	addi	$sp, $sp, -4
	sw 	$a0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$v0, 0($sp)

	mfc0	$t0, $1
	addi    $sp, $sp, -4
	sw 	$t0, 0($sp)
	
	#Open Interrupt
	addi 	$t0, $zero, 0
	mtc0	$t0, $0
	
# IR2 program
addi $s1,$zero,2       #�жϺ�1,2,3   ��ͬ�жϺ���ʾֵ��һ��:
add $s0,$zero,$s1   

IntLeftShift2:
sll    $s0, $s0, 4  
add    $a0,$0,$s0	  #display $s0
addi   $v0,$0,34         # display hex
syscall                 # we are out of here.   
bne $s0, $zero, IntLeftShift2
	
	#Close Interrupt
	addi	$t0, $zero, 1
	mtc0	$t0, $0

# restore env
	lw	$t0, 0($sp)
	addi	$sp, $sp, 4
	mtc0	$t0, $1		#restore epc

	lw 	$v0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$a0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$s1, 0($sp)
	addi	$sp, $sp, 4
	lw 	$s0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$t1, 0($sp)
	addi	$sp, $sp, 4
	lw 	$t0, 0($sp)
	addi	$sp, $sp, 4
	eret

IR3:
# protect env
	addi	$sp, $sp, -4
	sw 	$t0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$t1, 0($sp)
	addi	$sp, $sp, -4
	sw 	$s0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$s1, 0($sp)
	addi	$sp, $sp, -4
	sw 	$a0, 0($sp)
	addi	$sp, $sp, -4
	sw 	$v0, 0($sp)

	mfc0	$t0, $1
	addi    $sp, $sp, -4
	sw 	$t0, 0($sp)
	
	#Open Interrupt
	addi 	$t0, $zero, 0
	mtc0	$t0, $0
	
# IR3 program
addi $s1,$zero,3       #�жϺ�1,2,3   ��ͬ�жϺ���ʾֵ��һ��
add $s0,$zero,$s1   

IntLeftShift3:
sll    $s0, $s0, 4  
add    $a0,$0,$s0	  #display $s0
addi   $v0,$0,34         # display hex
syscall                 # we are out of here.   
bne $s0, $zero, IntLeftShift3
	
	#Close Interrupt
	addi	$t0, $zero, 1
	mtc0	$t0, $0

# restore env
	lw	$t0, 0($sp)
	addi	$sp, $sp, 4
	mtc0	$t0, $1		#restore epc

	lw 	$v0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$a0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$s1, 0($sp)
	addi	$sp, $sp, 4
	lw 	$s0, 0($sp)
	addi	$sp, $sp, 4
	lw 	$t1, 0($sp)
	addi	$sp, $sp, 4
	lw 	$t0, 0($sp)
	addi	$sp, $sp, 4
	eret


test:
addi $s6,$zero,3       #�жϺ�1,2,3   ��ͬ�жϺ���ʾֵ��һ��

addi $s4,$zero,6      #ѭ��������ʼֵ  
addi $s5,$zero,1       #�������ۼ�ֵ
###################################################################
#                �߼����ƣ�ÿ����λ4λ 
# ��ʾ����������ʾ0x00000016 0x00000106 0x00001006 0x00010006 ... 10000006  00000006 ����ѭ��6��
###################################################################
IntLoop:
add $s0,$zero,$s6   

IntLeftShift:       

sll $s0, $s0, 4  
or $s3,$s0,$s4
add    $a0,$0,$s3       #display $s0
addi   $v0,$0,34         # display hex
syscall                 # we are out of here.   

bne $s0, $zero, IntLeftShift
sub $s4,$s4,$s5      #ѭ�������ݼ�
bne $s4, $zero, IntLoop

addi   $v0,$zero,10         # system call for exit
syscall                  # we are out of here. 


