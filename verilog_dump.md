# Verilog Project Dump

## 📄 alu.vh

```verilog
case(funct3)
    3'b000: begin
        case(funct7)
            7'b0000000: alu_result <= rs1_val + rs2_val;                            // ADD
            7'b0100000: alu_result <= rs1_val - rs2_val;                            // SUB
            default: alu_result <= 32'h00000000;
        endcase
    end
    3'b001: alu_result <= rs1_val << rs2_val[4:0];                                  // SLL
    3'b010: alu_result <= ($signed(rs1_val) < $signed(rs2_val)) ? 32'd1 : 32'd0;    // SLT
    3'b011: alu_result <= (rs1_val < rs2_val) ? 32'd1 : 32'd0;                      // SLTU
    3'b100: alu_result <= rs1_val ^ rs2_val;                                        // XOR
    3'b101: begin
        case(funct7)
            7'b0000000: alu_result <= rs1_val >> rs2_val[4:0];                      // SRL
            7'b0100000: alu_result <= rs1_val >>> rs2_val[4:0];                     // SRA
            default: alu_result <= 32'h00000000;
        endcase
    end
    3'b110: alu_result <= rs1_val | rs2_val;                                         // OR
    3'b111: alu_result <= rs1_val & rs2_val;                                         // AND
endcase

```

## 📄 alu_defines.vh

```verilog

parameter [6:0] alu_func7_for_SRLI = 7'b0000000;
parameter [6:0] alu_func7_for_SRAI = 7'b0100000;
parameter [6:0] alu_func7_for_SLLI = 7'b0000000;

wire [4:0] shamt =imm_i[4:0];
```

## 📄 alu_im.vh

```verilog
case(funct3)
    3'b000: alu_result <= rs1_val + imm_i;                       // ADDI
    3'b001:
        case(funct7)
             alu_func7_for_SLLI: alu_result <= rs1_val<<shamt;       // SLLI
        endcase
    3'b010:alu_result <=($signed(rs1_val) < $signed(imm_i)) ? 32'd1 : 32'd0;             // SLTI
    3'b011:alu_result <= (rs1_val < imm_i_unsigned) ? 32'd1 : 32'd0;            // SLTIU
    3'b100:alu_result <= (rs1_val ^ imm_i);                            // XORI
    3'b101: begin
        case(funct7) 
            alu_func7_for_SRLI:  alu_result <= rs1_val>>shamt;       // SRLI
            alu_func7_for_SRAI:  alu_result <= rs1_val>>>shamt;      // SRAI
        endcase
    end
    3'b110:    alu_result <= (rs1_val | imm_i);                        // ORI
    3'b111:    alu_result <= (rs1_val & imm_i);                        // ANDI
endcase
```

## 📄 branch.vh

```verilog
case(funct3)
    3'b000: branch_taken = (rs1_val == rs2_val);               // BEQ
    3'b001: branch_taken = (rs1_val != rs2_val);               // BNE
    3'b100: branch_taken = ($signed(rs1_val) < $signed(rs2_val));  // BLT
    3'b101: branch_taken = ($signed(rs1_val) >= $signed(rs2_val)); // BGE
    3'b110: branch_taken = (rs1_val < rs2_val);                // BLTU
    3'b111: branch_taken = (rs1_val >= rs2_val);               // BGEU
    default: branch_taken = 1'b0;
endcase

```

## 📄 load.vh

```verilog
case(funct3)
    3'b000: begin
        // LB: load byte signed
        alu_result <= {{24{mem_rdata[7]}}, mem_rdata[7:0]};      
    end
    3'b001: begin
        // LH: load halfword signed
        alu_result <= {{16{mem_rdata[15]}}, mem_rdata[15:0]};
    end
    3'b010: begin
        // LW: load word
        alu_result <= mem_rdata[31:0];               
    end
    3'b100: begin
        // LBU: load byte unsigned
        alu_result <= {24'b0, mem_rdata[7:0]};       
    end
    3'b101: begin
        // LHU: load halfword unsigned
        alu_result <= {16'b0, mem_rdata[15:0]};      
    end
    default: begin
        alu_result <= 32'b0;                        
    end
endcase

```

## 📄 store.vh

```verilog
case(funct3)
    3'b000: begin
        mem_wdata <= rs2_val[7:0];        // SB: store byte
        mem_addr <= rs1_val + imm_s;     // endereço = rs1 + imediato
    end
    3'b001: begin
        mem_wdata <= rs2_val[15:0];       // SH: store halfword
    end
    3'b010: begin
        mem_wdata <= rs2_val[31:0];       // SW: store word
        mem_addr <= rs1_val + imm_s;
    end
    default: begin
        mem_wdata <= 32'b0;            // default caso inválido
        mem_addr <= 32'b0;
    end
endcase
```

