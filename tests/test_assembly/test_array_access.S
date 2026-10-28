.section .text
.globl _start

_start:

    # base = 0x8000300
    lui t0, 0x80003

    # escreve array [5,3,8,2,9]
    li t1, 5
    sw t1, 0(t0)

    li t1, 3
    sw t1, 4(t0)

    li t1, 8
    sw t1, 8(t0)

    li t1, 2
    sw t1, 12(t0)

    li t1, 9
    sw t1, 16(t0)

    # i = 2
    li t2, 2

    # offset = i << 2
    slli t3, t2, 2

    # addr = base + offset
    add t4, t0, t3

    # load arr[2]
    lw t5, 0(t4)

    # esperado = 8
    li t6, 8

    bne t5, t6, fail

success:
    li t0, 0x100
    li t1, 0xf
    sw t1, 0(t0)
    j end

fail:
    li t0, 0x104
    li t1, 0xf0
    sw t1, 0(t0)

end:
    j end
