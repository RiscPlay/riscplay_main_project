.section .text
.global _start

_start:
    li t0, 0x100   # endereço base de resultado

    # -------------------------
    # TESTE 1: 0xFFFFFFFF >= 1 (unsigned) → TRUE
    # -------------------------
    li t1, -1
    li t2, 1
    bgeu t1, t2, ok1
    j fail

ok1:
    # -------------------------
    # TESTE 2: 1 >= 0xFFFFFFFF → FALSE
    # -------------------------
    li t1, 1
    li t2, -1
    bgeu t1, t2, fail

success:
    li t4, 0xF
    sw t4, 0(t0)     # escreve 0xF em 0x100
    j end

fail:
    li t4, 0xF0
    sw t4, 4(t0)     # escreve 0xF0 em 0x104

end:
    j end
