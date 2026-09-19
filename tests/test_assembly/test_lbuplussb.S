.section .text
.globl _start

_start:
    # base = 0x80000300
    lui   t0, 0x80000
    addi  t0, t0, 0x300

    # inicializa
    li    t1, 10
    sb    t1, 0(t0)

    li    t1, 20
    sb    t1, 1(t0)

    # swap usando lbu + sb
    lbu   t2, 0(t0)
    lbu   t3, 1(t0)

    sb    t3, 0(t0)
    sb    t2, 1(t0)

    # verifica
    lbu   t4, 0(t0)
    lbu   t5, 1(t0)

    li    t6, 20
    bne   t4, t6, fail

    li    t6, 10
    bne   t5, t6, fail

ok:
    li    t4, 0x100
    li    t5, 1
    sw    t5, 0(t4)
    j end

fail:
    li    t4, 0x104
    li    t5, 0
    sw    t5, 0(t4)

end:
    j end
