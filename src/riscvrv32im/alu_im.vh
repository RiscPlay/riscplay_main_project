case(funct3)
    3'b000: alu_result <= rs1_val + imm_i;                       // ADDI
    3'b001:
        case(funct7)
            alu_func7_for_SLLI: alu_result <= rs1_val<<shamt;       // SLLI
            default:            alu_result <= 32'h00000000;
        endcase
    3'b010:alu_result <=($signed(rs1_val) < $signed(imm_i)) ? 32'd1 : 32'd0;             // SLTI
    3'b011:alu_result <= (rs1_val < imm_i) ? 32'd1 : 32'd0;            // SLTIU
    3'b100:alu_result <= (rs1_val ^ imm_i);                            // XORI
    3'b101: begin
        case(funct7) 
            alu_func7_for_SRLI:  alu_result <= rs1_val>>shamt;       // SRLI
            alu_func7_for_SRAI:  alu_result <= $signed(rs1_val)>>>shamt;      // SRAI
            default:            alu_result <= 32'h00000000;
        endcase
    end
    3'b110:    alu_result <= (rs1_val | imm_i);                        // ORI
    3'b111:    alu_result <= (rs1_val & imm_i);                        // ANDI
    default:            alu_result <= 32'h00000000;
endcase