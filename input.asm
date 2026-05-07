# 1. I-format & Register Initializing
addi $t0, $zero, 5     
addi $t1, $zero, 10    

# 2. R-format & Arithmetic
add $t2, $t0, $t1      
sub $t3, $t1, $t0      

# 3. Memory Access (I-format)
sw $t2, 0($sp)        
lw $s0, 0($sp)        

# 4. Jump & Branch (J/I-format)
beq $t2, $t2, target   
target:
j exit                
exit:
