.section .text
.globl _start

_start:

    ########################################
    # TESTE AUIPC
    ########################################

    auipc x5, 0       # x5 = PC1
    auipc x6, 0       # x6 = PC2 = PC1 + 4

    addi  x5, x5, 4   # x5 = PC1 + 4

    # agora x5 deve ser igual a x6
    bne x5, x6, FAIL


    ########################################
    # TESTE COM OFFSET (mais forte)
    ########################################

    auipc x7, 1       # x7 = PC3 + 0x1000
    auipc x8, 1       # x8 = PC4 + 0x1000

    addi  x7, x7, 4   # x7 = PC3 + 4 + 0x1000

    bne x7, x8, FAIL


    ########################################
    # PASS
    ########################################

PASS:
    li   x10, 0xfff
    sw   x10, 0x100(x0)
    j PASS


########################################
# FAIL
########################################

FAIL:
    li   x10, 0xfff
    sw   x10, 0x104(x0)
    j FAIL
