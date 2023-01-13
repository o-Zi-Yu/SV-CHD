addi s0, zero, 89
addi s1, zero, 63
addi s2, zero, -55
addi s3, zero, -107
addi s4, zero, 42
addi s5, zero, 98
addi s6, zero, -425
addi s7, zero, 203
addi s8, zero, 0
addi s9, zero, 303

main:
jal arrayinit

arrayinit: #initialize array
sw s0, 0x400(zero) 
sw s1, 0x404(zero)
sw s2, 0x408(zero)
sw s3, 0x40c(zero)
sw s4, 0x410(zero)
sw s5, 0x414(zero)
sw s6, 0x418(zero)
sw s7, 0x41c(zero)
sw s8, 0x420(zero)
sw s9, 0x424(zero)

addi s0, zero, 0 #counter for len(array)
addi s1, zero, 0 #counter for element in array
addi s2, zero, 36
addi s3, zero, 10
j sortcount

sortcount:
addi s1, zero, 0
addi s0, s0, 1
beq s0, s3, finish # if the sort has gone 9 times
j bubblesort # start bubblesort

bubblesort: 
lw t0, 0x400(s1)
lw t1, 0x404(s1)
bge t0, t1, swap # if front element is larger than behind, swap these two
addi s1, s1, 4 # go to next word
beq s1, s2, sortcount # if 10 words are go through
j bubblesort # bubble sort again

afterswap:
addi s1, s1, 4 # go to next word
beq s1, s2, sortcount # if 10 words are go through
j bubblesort

swap: # swap front and behind element
sw t1, 0x400(s1)
sw t0, 0x404(s1)
j afterswap

finish:
