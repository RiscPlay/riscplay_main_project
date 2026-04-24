.section .text
.globl _start

_start:

    lui  x5, 0xFFFFF
    addi x5, x5, 0xFF
    sw   x5, 0x200(x0)


PASS:
    lui  x5, 0xFFFFF
    addi x5, x5, -1
    sw   x5, 0x104(x0)

HALT:
    j HALT

FAIL:
    lui  x5, 0xFFFFF
    addi x5, x5, -1
    sw   x5, 0x100(x0)

FAIL_LOOP:
    j FAIL_LOOP
    
