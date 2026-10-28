.section .text
.globl _start

_start:
    # base = 0x80000300
    lui   t0, 0x80000
    addi  t0, t0, 0x300

    # escreve em posições desalinhadas
    li    t1, 0x11
    sb    t1, 1(t0)

    li    t1, 0x22
    sb    t1, 2(t0)

    li    t1, 0x33
    sb    t1, 3(t0)

    li    t1, 0x44
    sb    t1, 4(t0)

    # lê bytes individualmente
    lbu   t2, 1(t0)
    lbu   t3, 2(t0)
    lbu   t4, 3(t0)
    lbu   t5, 4(t0)

    li    t6, 0x11
    bne   t2, t6, fail

    li    t6, 0x22
    bne   t3, t6, fail

    li    t6, 0x33
    bne   t4, t6, fail

    li    t6, 0x44
    bne   t5, t6, fail

ok:
    li    t0, 0x100
    li    t1, 1
    sw    t1, 0(t0)
    j end

fail:
    li    t0, 0x104
    li    t1, 0
    sw    t1, 0(t0)

end:
    j end
