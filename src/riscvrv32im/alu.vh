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
    default:            alu_result <= 32'h00000000;

endcase
