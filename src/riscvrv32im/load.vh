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
