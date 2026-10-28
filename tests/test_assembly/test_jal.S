.section .text
.globl _start

_start:
    li   x10, 0x100      # base da memória de status

    # limpa memória
    sw   x0, 0(x10)
    sw   x0, 4(x10)

    # salva endereço esperado de retorno
    la   x6, after_jal

    # executa jal
    jal  x5, target      # x5 = pc+4, PC = target

after_jal:
    # verifica se x5 recebeu o endereço correto
    bne  x5, x6, fail

    # sucesso
    li   x2, 1
    sw   x2, 0(x10)      # escreve em 0x100
    j end

# -----------------------
target:
    # retorna usando jalr
    jalr x0, x5, 0

# -----------------------
fail:
    li   x2, 1
    sw   x2, 4(x10)      # escreve em 0x104
    j end

# -----------------------
end:
    j end
