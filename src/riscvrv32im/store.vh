case(funct3)
    3'b000: begin
        mem_wdata_byte <= rs2_val[7:0];        // SB: store byte
        mem_addr       <= rs1_val + imm_s;     // endereço = rs1 + imediato
        mem_we_byte    <=1'b1;
    end
    3'b001: begin
        mem_wdata_half <= rs2_val[15:0];       // SH: store halfword
        mem_addr       <= rs1_val + imm_s;
        mem_we_half    <= 1'b1;
    end
    3'b010: begin
        mem_wdata      <= rs2_val[31:0];       // SW: store word
        mem_addr       <= rs1_val + imm_s;
        mem_we         <= 1'b1;
    end
    default: begin
        mem_wdata <= 32'b0;            // default caso inválido
        mem_addr  <= 32'b0;
        mem_we         <= 1'b0;
        mem_we_half    <= 1'b0;
        mem_we_byte    <= 1'b0;
    end
endcase