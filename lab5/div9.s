main:
addi t0, zero, 9  # t0 = 9
addi a1, zero, 3  # a1 = 3
add t1, zero, a0  # t1 = a0
addi t2, zero, 8  # t2 = 8
jal subtract # call function

subtract:
sub  t1, t1, t0   # t1 = a0 - 9
beq  t1, zero, equal   # t1 = h + i
ble  t1, t2, nequal # 9 > t1 nequal
j subtract # subtract again

equal:
addi a0, zero, 1
j end

nequal:
addi a0, zero, 0
j end

end:
#Finished