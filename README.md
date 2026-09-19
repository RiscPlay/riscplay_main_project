# riscplay_main_project




#Opcodes do riscv

| opcode   | binário   | função                               |
| -------- | --------- | ------------------------------------ |
| LOAD     | `0000011` |load from memory                      |
| STORE    | `0100011` | escrever na memória                  |
| OP-IMM   | `0010011` | ALU com imediato                     |
| OP       | `0110011` | ALU entre registradores + extensão M |
| BRANCH   | `1100011` | desvios condicionais                 |
| JALR     | `1100111` | salto indireto                       |
| JAL      | `1101111` | salto                                |
| LUI      | `0110111` | carregar imediato alto               |
| AUIPC    | `0010111` | PC + imediato                        |
| SYSTEM   | `1110011` | ecall / ebreak                       |
| MISC-MEM | `0001111` | fence (opcional)                     |



/*****
Terminação dos imediatos e onde são usados em cada grupo de instruções
| formato | usado em           |
| ------- | ------------------ |
| I       | ALU imediato, LOAD |
| S       | STORE              |
| B       | BRANCH             |
| U       | LUI / AUIPC        |
| J       | JAL                |

*****/

/***
#LOAD
| funct3 | Instrução | Operação                                       |
| ------ | --------- | ---------------------------------------------- |
| 000    | LB        | rd = Mem[rs1 + imm][7:0]  (byte com sinal)     |
| 001    | LH        | rd = Mem[rs1 + imm][15:0] (halfword com sinal) |
| 010    | LW        | rd = Mem[rs1 + imm][31:0] (word)               |
| 100    | LBU       | rd = Mem[rs1 + imm][7:0]  (byte unsigned)      |
| 101    | LHU       | rd = Mem[rs1 + imm][15:0] (halfword unsigned)  |
***/

/***
#STORE
| funct3 | Instrução | Operação                                        |
| ------ | --------- | ----------------------------------------------- |
| 000    | SB        | Mem[rs1 + imm] = rs2[7:0]      (store byte)     |
| 001    | SH        | Mem[rs1 + imm] = rs2[15:0]     (store halfword) |
| 010    | SW        | Mem[rs1 + imm] = rs2[31:0]     (store word)     |

***/

/*****
#OP-IMM

| funct3 | funct7 / imm[11:5] | Instrução | Operação                            |
| ------ | ------------------ | --------- | ----------------------------------- |
| 000    | –                  | ADDI      | rd = rs1 + imm                      |
| 010    | –                  | SLTI      | rd = (rs1 < imm) ? 1 : 0 (signed)   |
| 011    | –                  | SLTIU     | rd = (rs1 < imm) ? 1 : 0 (unsigned) |
| 100    | –                  | XORI      | rd = rs1 ^ imm                      |
| 110    | –                  | ORI       | rd = rs1 | imm                      |
| 111    | –                  | ANDI      | rd = rs1 & imm                      |
| 001    | 0000000            | SLLI      | rd = rs1 << shamt                   |
| 101    | 0000000            | SRLI      | rd = rs1 >> shamt (lógico)          |
| 101    | 0100000            | SRAI      | rd = rs1 >>> shamt (aritmético)     |


/*****
#OP
| funct3 | funct7  | instrução | operação                         |
| ------ | ------- | --------- | -------------------------------- |
| 000    | 0000000 | ADD       | `rd = rs1 + rs2`                 |
| 000    | 0100000 | SUB       | `rd = rs1 - rs2`                 |
| 001    | 0000000 | SLL       | `rd = rs1 << rs2[4:0]`           |
| 010    | 0000000 | SLT       | `rd = (signed rs1 < signed rs2)` |
| 011    | 0000000 | SLTU      | `rd = (rs1 < rs2)` unsigned      |
| 100    | 0000000 | XOR       | `rd = rs1 ^ rs2`                 |
| 101    | 0000000 | SRL       | `rd = rs1 >> rs2[4:0]`           |
| 101    | 0100000 | SRA       | `rd = rs1 >>> rs2[4:0]`          |
| 110    | 0000000 | OR        | `rd = rs1 \| rs2`                |
| 111    | 0000000 | AND       | `rd = rs1 & rs2`                 |
***/

/***
#BRANCH
| funct3 | Instruction | Condition                         | What happens                                        |
| ------ | ----------- | --------------------------------- | --------------------------------------------------- |
| 000    | BEQ         | branch if `rs1 == rs2`            | If true: `pc = pc + imm_b`; if false: `pc = pc + 4` |
| 001    | BNE         | branch if `rs1 != rs2`            | If true: `pc = pc + imm_b`; if false: `pc = pc + 4` |
| 100    | BLT         | branch if `rs1 < rs2` (signed)    | If true: `pc = pc + imm_b`; if false: `pc = pc + 4` |
| 101    | BGE         | branch if `rs1 >= rs2` (signed)   | If true: `pc = pc + imm_b`; if false: `pc = pc + 4` |
| 110    | BLTU        | branch if `rs1 < rs2` (unsigned)  | If true: `pc = pc + imm_b`; if false: `pc = pc + 4` |
| 111    | BGEU        | branch if `rs1 >= rs2` (unsigned) | If true: `pc = pc + imm_b`; if false: `pc = pc + 4` |

***/
/***
#JALR
| funct3 | Instruction | Operation              | What happens                             |
| ------ | ----------- | ---------------------- | ---------------------------------------- |
| 000    | JALR        | Jump and link register | `rd = pc + 4`; `pc = (rs1 + imm_i) & ~1` |
***/

/***
#JAL
| funct3 | Instruction | Operation     | What happens                     |
| ------ | ----------- | ------------- | -------------------------------- |
| —      | JAL         | Jump and link | `rd = pc + 4`; `pc = pc + imm_j` |
***/

/***
#LUI
| funct3 | Instruction | Operation            | What happens |
| ------ | ----------- | -------------------- | ------------ |
| —      | LUI         | Load upper immediate | `rd = imm_u` |
***/


/***
#AUIPC
| funct3 | Instruction | Operation                 | What happens      |
| ------ | ----------- | ------------------------- | ----------------- |
| —      | AUIPC       | Add upper immediate to PC | `rd = pc + imm_u` |
***/

/***
riscv32-unknown-elf-gcc \
-march=rv32im \
-mabi=ilp32 \
-O2 \
-nostdlib \
-nostartfiles \
-Wl,--no-relax, --gc-sections \
-o program.elf program.c

riscv32-unknown-elf-objcopy -O binary program.elf program.bin
***/