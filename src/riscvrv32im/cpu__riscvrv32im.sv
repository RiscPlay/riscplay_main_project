module rv32im_cpu(
    input clk,
    input reset,

    output wire [31:0] mem_addr,
    output reg [31:0] mem_wdata,
    input      [31:0] mem_rdata,
    output reg mem_we,
    input wire enable
  );

  reg [3:0] time_that_stage_hold;

  reg [31:0] pc;
  reg [31:0] instr;

  (* ram_style = "distributed" *)
  reg [31:0] regfile [0:31];

  (* keep = "true" *) reg [31:0] rs1_val;
  (* keep = "true" *) reg [31:0] rs2_val;
  (* keep = "true" *) reg [31:0] alu_result;

  reg [4:0] rd;

  reg [3:0] state;
  reg [3:0] state_prev;

  localparam
    FETCH     = 4'h0,
    DECODE    = 4'h1,
    EXECUTE   = 4'h2,
    MEMORY    = 4'h3,
    WRITEBACK = 4'h4,
    STATE_RESET = 4'hf;

  wire [6:0] opcode = instr[6:0];
  wire [2:0] funct3 = instr[14:12];
  wire [6:0] funct7 = instr[31:25];

  wire [4:0] rs1 = instr[19:15];
  wire [4:0] rs2 = instr[24:20];

  wire [31:0] imm_i = {{20{instr[31]}},instr[31:20]};
  wire [31:0] imm_s = {{20{instr[31]}},instr[31:25],instr[11:7]};
  wire [31:0] imm_b = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
  wire [31:0] imm_u = {instr[31:12],12'b0};
  wire [31:0] imm_j = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
  wire [31:0] imm_i_unsigned = {{20{1'b0}}, instr[31:20]};
  reg branch_taken;
  reg write_in_register;

  wire sync__state=state_prev==state;
  reg [31:0] word_addr;
  assign mem_addr=word_addr>>2;

  `include "alu_defines.vh"
  always @(posedge clk) begin
    if(reset==1'b0) begin
        if(sync__state) begin
            if(time_that_stage_hold<4'hf) begin
                time_that_stage_hold<=time_that_stage_hold+4'h1;
            end
        end
        else begin
            time_that_stage_hold<=4'h0;
        end
        state_prev<=state;
    end
    else begin 
      time_that_stage_hold<=4'h0;
      state_prev<=STATE_RESET;
    end
  end
  always @(posedge clk)
  begin

    if(reset)
    begin
      pc <= 32'h80000000;
      state <= FETCH;
      branch_taken<=1'b0;
      write_in_register<=1'b0;
      mem_we   <= 0;
    end

    else if(enable) begin
      case(state)

        FETCH:begin
          word_addr <= pc;
          mem_we   <= 0;
          state <= DECODE;
        end

        DECODE: begin
          instr <= mem_rdata;

          rs1_val <= regfile[rs1];
          rs2_val <= regfile[rs2];
          rd <= instr[11:7];
          write_in_register<=1'b0;
          state <= EXECUTE;
        end

        EXECUTE: begin
          case(opcode)
            7'b0000011: begin
              word_addr <= rs1_val + imm_i;
              mem_we   <= 1'b0;
              state    <= MEMORY;
            end
            7'b0100011: begin
              `include "store.vh"
              state    <= MEMORY;
              mem_we<=1'b1;

            end
            7'b0010011: begin
              `include "alu_im.vh"
              state <= WRITEBACK;
              write_in_register<=1'b1;

            end
            7'b0110011: begin
              `include "alu.vh"
              state <= WRITEBACK;
              write_in_register<=1'b1;
            end
            7'b1100011: begin
              `include "branch.vh"
              state <= WRITEBACK;
            end
            7'b1100111: begin //JALR
              if(funct3==3'b000) begin
                alu_result<= pc+32'h00000004;
                write_in_register<=1'b1;
                state <= WRITEBACK;
              end
            end
            7'b1101111: begin // JAL
              alu_result <= pc+32'h00000004;
              write_in_register<=1'b1;
              state <= WRITEBACK;
            end
            7'b0110111: begin //LUI
              alu_result <= imm_u;
              write_in_register<=1'b1;
              state <= WRITEBACK;
            end
            7'b0010111: begin //AUIPC
              alu_result <= pc + imm_u;
              write_in_register<=1'b1;
              state <= WRITEBACK;
            end
            7'b0001111: begin // FENCE
              state <= WRITEBACK;
            end
            default: begin
              state <= WRITEBACK;
            end

          endcase

        end

        MEMORY: begin
          case(opcode)
            7'b0000011: begin 
              `include "load.vh"
              write_in_register<=1'b1;
            end
            7'b0100011: begin
              mem_we<=1'b0;
            end
          endcase
          if(sync__state & time_that_stage_hold>4'h1) begin
              state <= WRITEBACK;
          end
        end

        WRITEBACK: begin

          if((rd != 0) & write_in_register)
            regfile[rd] <= alu_result;
          case (opcode)
            7'b1100011: begin //branch
              if(branch_taken) 
                pc <= pc + imm_b;
              else
                pc <= pc + 32'h00000004;
            end

            7'b1100111: begin //JALR
              if(funct3==3'b000) 
                pc <= (rs1_val + imm_i) &  ~32'h3;
              else 
                pc <= pc + 32'h00000004;
            end
            7'b1101111: begin // JAL
                pc <=  pc+imm_j;
            end
            default: pc <= pc + 32'h00000004;
          endcase
          state <= FETCH;

        end

      endcase

    end

  end

endmodule


/****
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

****/


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