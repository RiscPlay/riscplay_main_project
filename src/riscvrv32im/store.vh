case(funct3)
    3'b000: begin
        mem_wdata <= rs2_val[7:0];        // SB: store byte
        word_addr <= rs1_val + imm_s;     // endereço = rs1 + imediato
    end
    3'b001: begin
        mem_wdata <= rs2_val[15:0];       // SH: store halfword
        word_addr <= rs1_val + imm_s;

    end
    3'b010: begin
        mem_wdata <= rs2_val[31:0];       // SW: store word
        word_addr <= rs1_val + imm_s;
    end
    default: begin
        mem_wdata <= 32'b0;            // default caso inválido
        word_addr <= 32'b0;
    end
endcase