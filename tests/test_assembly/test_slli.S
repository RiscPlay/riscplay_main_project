.section .text
.global _start

_start:
    li t0, 0x100   # endereço base de resultado

    # -------------------------
    # TESTE 1: 3 << 2 = 12
    # -------------------------
    li t1, 3
    slli t2, t1, 2
    li t3, 12
    bne t2, t3, fail

    # -------------------------
    # TESTE 2: 1 << 31 = 0x80000000
    # -------------------------
    li t1, 1
    slli t2, t1, 31
    li t3, 0x80000000
    bne t2, t3, fail

success:
    li t4, 0xF
    sw t4, 0(t0)     # escreve 0xF em 0x100
    j end

fail:
    li t4, 0xF0
    sw t4, 4(t0)     # escreve 0xF0 em 0x104

end:
    j end
