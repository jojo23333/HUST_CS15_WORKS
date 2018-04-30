.text
 ###########################################################
 # lh
 ###########################################################
 
addi $t1,$zero,0     #init_addr 
addi $t3,$zero,16     #counter

#预先写入数据，实际是按字节顺序存入 0x81,82,84,86,87,88,89.......等差数列
ori $s1,$zero, 0x8483  #
addi $s2,$zero, 0x0404  #
sll $s1,$s1,16
sll $s2,$s2,16
ori $s1,$s1, 0x8281  #    注意一般情况下MIPS采用大端方式
addi $s2,$s2, 0x0404  #   init_data= 0x84838281 next_data=init_data+ 0x04040404

lh_store:
sw $s1,($t1)
add $s1,$s1,$s2   #data +1
addi $t1,$t1,4    # addr +4  
addi $t3,$t3,-1   #counter
bne $t3,$zero,lh_store

addi $t3,$zero,32
addi $t1,$zero,0    # addr  

lh_branch:
lh $s1,($t1)     #测试指令
add $a0,$0,$s1          
addi $v0,$zero,34         
syscall                  # print
addi $t1,$t1, 2    
addi $t3,$t3, -1    
bne $t3,$zero,lh_branch

addi   $v0,$zero,10         # system call for exit
syscall                  # we are out of here.   

 ###########################################################
 # stliu
 ###########################################################
#依次输出  0x00001997 0x00001996 0x00001995 0x00001994 0x00001993 0x00001992 0x00001991 0x00001990 0x0000198f 0x0000198e 0x0000198d 0x0000198c 0x0000198b 0x0000198a 0x00001989 0x00001988 0x00001987 0x00001986 0x00001985 0x00001984 0x00001983 0x00001982 0x00001981 0x00001980 0x0000197f 0x0000197e 0x0000197d 0x0000197c 0x0000197b 0x0000197a 0x00001979 0x00001978 0x00001977 0x00001976 0x00001975 0x00001974 0x00001973 0x00001972 0x00001971 0x00001970 0x0000196f 0x0000196e 0x0000196d 0x0000196c 0x0000196b 0x0000196a 0x00001969 0x00001968 0x00001967 0x00001966 0x00001965 0x00001964 0x00001963 0x00001962 0x00001961 0x00001960 0x0000195f 0x0000195e 0x0000195d 0x0000195c 0x0000195b 0x0000195a 0x00001959 0x00001958 0x00001957 0x00001956 0x00001955 0x00001954 0x00001953 0x00001952 0x00001951 0x00001950 0x0000194f 0x0000194e 0x0000194d 0x0000194c 0x0000194b 0x0000194a 0x00001949

addi $t0,$zero,-1    
addi $t1,$zero,0     
addi $s1,$zero, 0x1997  
sltiu_branch:
add $a0,$0,$s1          
addi $v0,$zero,34        # system call for print
syscall                  # print
add $s1,$s1,$t0     
sltiu $t1,$s1, 0x1949
beq $t1,$zero,sltiu_branch

addi   $v0,$zero,10         # system call for exit
syscall                  # we are out of here.   

 ###########################################################
 # bltz
 ###########################################################
#bltz 测试    小于0跳转   revise date:2018/3/12 tiger  
#依次输出0xfffffff1 0xfffffff2 0xfffffff3 0xfffffff4 0xfffffff5 0xfffffff6 0xfffffff7 0xfffffff8 0xfffffff9 0xfffffffa 0xfffffffb 0xfffffffc 0xfffffffd 0xfffffffe 0xffffffff
addi $s1,$zero,-15       #初始值
bltz_branch:
add $a0,$0,$s1          
addi $v0,$zero,34         
syscall                  #输出当前值
addi $s1,$s1,1 
bltz $s1,bltz_branch     #当前指令


addi   $v0,$zero,10    
syscall                  #暂停或退出


#xori测试    revise date:2018/3/12 tiger
# 0x00007777 xor   0xffffffff =  0x0000ff8888
# 0xffff8888  xor   0xffffffff =  0x77777777 
# 0x00007777 0x00008888 0x00007777 0x00008888 0x00007777 0x00008888 0x00007777 0x00008888 0x00007777 0x00008888 0x00007777 0x00008888 0x00007777 0x00008888 0x00007777 0x00008888 0x00007777


 ###########################################################
 # bltz
 ###########################################################

addi $t0,$zero,-1     #
addi $s1,$zero, 0x7777     #


add $a0,$0,$s1           
addi $v0,$zero,34         # system call for print
syscall                  # print

addi $t3,$zero, 0x10

xori_branch:
xori $s1,$s1, 0xffff     #先移1位
add $a0,$0,$s1          
addi $v0,$zero,34         # system call for print
syscall                  # print
addi $t3,$t3, -1    
bne $t3,$zero,xori_branch   #循环8次

addi   $v0,$zero,10         # system call for exit
syscall                  # we are out of here.   
