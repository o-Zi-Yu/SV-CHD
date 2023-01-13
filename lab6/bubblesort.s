main:
j arrayinit

arrayinit: #initialize array
addi s0, zero, -15
addi s1, zero, 42
addi s2, zero, 73
addi s3, zero, 19
addi s4, zero, -8
addi s5, zero, 24
addi s6, zero, 16
addi s7, zero, -2
addi s8, zero, 99
addi s9, zero, -78

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

addi s5, zero, 21
addi s6, zero, 23
addi s7, zero, -88
addi s8, zero, 49
addi s9, zero, 101

sw s5, 0x428(zero)
sw s6, 0x42c(zero)
sw s7, 0x430(zero)
sw s8, 0x434(zero)
sw s9, 0x438(zero)

addi s0, zero, 0 #counter for len(array)
addi s1, zero, 0 #counter for element in array
addi s2, zero, 56
addi s3, zero, 15
jal sortcount

sortcount:
addi s1, zero, 0
addi s0, s0, 1
beq s0, s3, finish # if the sort has gone 14 times
j bubblesort # start bubblesort

bubblesort: 
lw t0, 0x400(s1)
lw t1, 0x404(s1)
bge t0, t1, swap # if front element is larger than behind, swap these two
addi s1, s1, 4 # go to next word
beq s1, s2, sortcount # if 15 words are go through
j bubblesort # bubble sort again

afterswap:
addi s1, s1, 4 # go to next word
beq s1, s2, sortcount # if 15 words are go through
j bubblesort

swap: # swap front and behind element
sw t1, 0x400(s1)
sw t0, 0x404(s1)
j afterswap

finish:
