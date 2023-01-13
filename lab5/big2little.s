lui s0, 0xABCDE # s0 = 0xABCDE000
addi s0, s0, 0x123 # s0 = 0xABCDE123
sw s0, 0x300(zero) # memory[300] = 0xABCDE123
addi t0, zero, 0
addi t1, zero, 0
addi t2, zero, 32


main:
j load

load:
sw s0, 0x300(t0)
lb a0, 0x300(t0)
lb a1, 0x301(t0)
lb a2, 0x302(t0)
lb a3, 0x303(t0)
addi t0, t0, 4
j swap

swap:
sb a3, 0x300(t1)
sb a2, 0x301(t1)
sb a1, 0x302(t1)
sb a0, 0x303(t1)
addi t1, t1, 4
j eightwords

eightwords:
beq t0, t2, finish
j load

finish:
