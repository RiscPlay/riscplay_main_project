case(funct3)
    3'b000: begin
        case(funct7)
            7'b0000000: alu_result <= rs1_val + rs2_val;            // ADD
            7'b0100000: alu_result <= rs1_val - rs2_val;            // SUB
            7'b0000001: alu_result <= product_MUL_AND_MULH[31:0];  // MUL

            default: alu_result <= 32'h00000000;
        endcase
    end
    3'b001: begin
        case (funct7) 
            7'b0000000: alu_result <= rs1_val << rs2_val[4:0];      // SLL
            7'b0000001: alu_result <=product_MUL_AND_MULH[63:32];   // MULH                                               
        endcase
    end
    3'b010: begin
        case(funct7)
            7'b0000000: alu_result <= ($signed(rs1_val) < $signed(rs2_val)) ? 
                                        32'd1 : 32'd0;              // SLT
            7'b0000001: alu_result<=product_MULHSU[63:32];          //MULHSU                 
        endcase
    end
    3'b011: begin
        case(funct7) 
            7'b0000000: alu_result <= (rs1_val < rs2_val) ?
                                        32'd1 : 32'd0;              // SLTU
            7'b0000001: alu_result<=product_MULHU[63:32];           //MULHU
        endcase
    end
    3'b100: begin
        case(funct7)
            7'b0000000: alu_result <= rs1_val ^ rs2_val;            // XOR
            7'b0000001: 
                begin 
                    start_div32<=1'b1;                              // DIV
                    is_doing_div_op<=1'b1;
                    signed_mode_div32<=1'b1;
                end
        endcase
    end
    3'b101: begin
        case(funct7)
            7'b0000000: alu_result <= rs1_val >> rs2_val[4:0];      // SRL
            7'b0100000: alu_result <=  $signed(rs1_val) >>> rs2_val[4:0];     // SRA
            7'b0000001: 
                begin  
                    start_div32<=1'b1;                              // DIVU
                    is_doing_div_op<=1'b1;
                    signed_mode_div32<=1'b0;
                end
            default: alu_result <= 32'h00000000;
        endcase
    end
    3'b110: begin 
        case (funct7)
            7'b0000000: alu_result <= rs1_val | rs2_val;            // OR
            7'b0000001: begin
                start_div32<=1'b1;                                 // REM
                is_doing_rem_op<=1'b1;
                signed_mode_div32<=1'b1;
            end
        endcase 
    end
    3'b111: 
        case (funct7)
            7'b0000000: alu_result <= rs1_val & rs2_val;           // AND
            7'b0000001: begin
                start_div32<=1'b1;                                 // REMU
                is_doing_rem_op<=1'b1;
                signed_mode_div32<=1'b0;
            end

        endcase
    default:            alu_result <= 32'h00000000;

endcase
