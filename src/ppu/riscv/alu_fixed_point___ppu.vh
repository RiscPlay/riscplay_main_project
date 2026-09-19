case(funct7)
    7'b0000000: case(funct3)
        3'b000: alu_result<= product_qdiv32;        //MULT q1*q2
        3'b001: begin                               //DIV  q1/q2
            start_div32<=1'b1;                           
            is_doing_qdiv32<=1'b1;
        end
    endcase
endcase