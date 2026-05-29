.section .text
.globl _start

_start:
    addi x10, x0, 0

    # -------------------------
    # ADD
    # -------------------------
    addi x1, x0, 5
    addi x2, x0, 10
    add  x3, x1, x2
    addi x4, x0, 15
    bne  x3, x4, FAIL

    # -------------------------
    # SUB
    # -------------------------
    addi x1, x0, 20
    addi x2, x0, 7
    sub  x3, x1, x2
    addi x4, x0, 13
    bne  x3, x4, FAIL

    # -------------------------
    # SLT
    # -------------------------
    addi x1, x0, -1
    addi x2, x0, 1
    slt  x3, x1, x2
    addi x4, x0, 1
    bne  x3, x4, FAIL

    # -------------------------
    # SLTU
    # -------------------------
    sltu x3, x1, x2
    addi x4, x0, 0
    bne  x3, x4, FAIL

    # -------------------------
    # XOR
    # -------------------------
    addi x1, x0, 0x0F
    addi x2, x0, 0xF0
    xor  x3, x1, x2
    addi x4, x0, 0xFF
    bne  x3, x4, FAIL

    # -------------------------
    # endereço fixo (CORRETO)
    # -------------------------
    lui  x6, 0x80000
    addi x6, x6, 0x200

    # -------------------------
    # STORE/LOAD
    # -------------------------
    lui  x1, 0x12345
    addi x1, x1, 0x678
    sw   x1, 0(x6)
    lw   x2, 0(x6)
    bne  x1, x2, FAIL
    

    # -------------------------
    # BYTE LOAD
    # -------------------------
    lb   x3, 0(x6)
    addi x4, x0, 0x78
    bne  x3, x4, FAIL

    lui  x5, 0xFFFF
    addi x5, x5, 0xFFF
    sw   x5, 0x100(x0)
    beq  x3,x4, _start

PASS:
    lui  x5, 0
    addi x5, x5, 0
    sw   x5, 0x100(x0)

HALT:
    j HALT

FAIL:
    lui  x5, 0xFFFFF
    addi x5, x5, -1
    sw   x5, 0x100(x0)

FAIL_LOOP:
    j FAIL_LOOP
    
