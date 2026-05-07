# Test Case

# 1. 
addi $t0, $zero, 5     
addi $t1, $zero, 10    

# 2. 
add $t2, $t0, $t1     
sub $s0, $t1, $t0      

# 3.
and $t3, $t0, $t1      
sll $t4, $t0, 2        

# 4.
sw $t2, 0($sp)         
lw $s1, 0($sp)         

# 5.
loop:                  
addi $s0, $s0, -1     
bne $s0, $zero, loop   

j exit                 
exit:                  
