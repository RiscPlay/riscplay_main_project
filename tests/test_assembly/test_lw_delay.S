.section .text
.globl _start

_start:

    li t0, 0x100

    li t1, 0x12345678
    sw t1, 0(t0)

    lw t2, 0(t0)

    # delay manual (simula espera de memória)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    addi t3, t2, 1

    li t4, 0x12345679

    bne t3, t4, fail

success:
    li t5, 0x100
    li t6, 0xf
    sw t6, 0(t5)
    j end

fail:
    li t5, 0x104
    li t6, 0xf0
    sw t6, 0(t5)

end:
    j end
