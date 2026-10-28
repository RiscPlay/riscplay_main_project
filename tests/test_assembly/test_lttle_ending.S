.section .text
.globl _start

_start:
    # endereço base de teste
    li t0, 0x100

    # valor conhecido
    li t1, 0x11223344

    # escreve palavra
    sw t1, 0(t0)

    # lê byte a byte
    lbu t2, 0(t0)   # esperado 0x44
    lbu t3, 1(t0)   # esperado 0x33
    lbu t4, 2(t0)   # esperado 0x22
    lbu t5, 3(t0)   # esperado 0x11

    # valores esperados
    li t6, 0x44
    bne t2, t6, fail

    li t6, 0x33
    bne t3, t6, fail

    li t6, 0x22
    bne t4, t6, fail

    li t6, 0x11
    bne t5, t6, fail

success:
    li t0, 0x100
    li t1, 0xF
    sw t1, 0(t0)
    j end

fail:
    li t0, 0x104
    li t1, 0xF0
    sw t1, 0(t0)

end:
    j end
