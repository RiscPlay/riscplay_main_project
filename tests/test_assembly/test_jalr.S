.section .text
.globl _start

_start:
    li   x10, 0x100

    # limpa memória
    sw   x0, 0(x10)
    sw   x0, 4(x10)

    la   x1, target

    # salva endereço esperado de retorno
    la   x6, after_call

    jalr x5, x1, 0

after_call:
    # verifica se link register está correto
    bne  x5, x6, fail

    # sucesso
    li   x2, 1
    sw   x2, 0(x10)
    j end

# -----------------------
target:
    jalr x0, x5, 0

# -----------------------
fail:
    li   x2, 1
    sw   x2, 4(x10)
    j end

# -----------------------
end:
    j end
