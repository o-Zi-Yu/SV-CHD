addi a0, zero, 71
addi a1, zero, 9
        
main:
jal bigsmall
j finish

bigsmall:
ble a0, a1, swap
j gcd

gcd:
addi sp, sp, -12
sw a0, 8(sp) # a0 = a
sw a1, 4(sp) # a1 = b
sw ra, 0(sp)
addi t0, zero, 0
bgt a0, t0, bothnotzero
addi sp, sp, 12
jr ra

bothnotzero:
bgt a1, t0, else
addi sp, sp, 12
jr ra


else:
add t2, zero, a1
rem a1, a0, a1 # b = a mod b
add a0, zero, t2 # a = b
jal bigsmall
lw t0, 8(sp)
lw t1, 4(sp)
lw ra, 0(sp)
addi sp, sp, 12
jr ra

swap: # swap front and behind element
add t0, zero, a0
add a0, zero a1
add a1, zero t0
j gcd

finish:
