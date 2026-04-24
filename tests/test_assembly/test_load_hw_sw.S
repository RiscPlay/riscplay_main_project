.section .text
.globl _start

_start:

    li t0, 0x8000300

    li t1, 111
    sw t1, 0(t0)

    li t1, 222
    sw t1, 4(t0)

    # carrega primeiro valor
    lw t2, 0(t0)

    # IMEDIATAMENTE muda endereço
    addi t0, t0, 4

    # usa valor carregado
    addi t3, t2, 0

    li t4, 111

    bne t3, t4, fail

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
