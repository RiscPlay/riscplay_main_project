.section .text
.globl _start

_start:
    # base = 0x80000300
    lui   t0, 0x80000
    addi  t0, t0, 0x300

    # escreve bytes
    li    t1, 0xAA
    sb    t1, 0(t0)

    li    t1, 0xBB
    sb    t1, 1(t0)

    li    t1, 0xCC
    sb    t1, 2(t0)

    li    t1, 0xDD
    sb    t1, 3(t0)

    # lê palavra
    lw    t2, 0(t0)

    # esperado: 0xDDCCBBAA (little endian)
    li    t3, 0xDDCCBBAA
    bne   t2, t3, fail

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
