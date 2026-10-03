case(funct7)
    7'b0000000: case(funct3)
        3'b000: begin 
            if(sync__state==1'b0) begin
                cmd_to_put_in_ppu_fifo<= {rs1_val,rs2_val};
                wr_cmd_for_ppu_fifo<=1'b1;
            end
            else if(time_that_stage_hold>=8'h02 && processing_the_ppu_fifo_insert==1'b0) begin
                wr_cmd_for_ppu_fifo<=1'b0;
                state <= WRITEBACK;
            end
        end
        3'b001: begin
            if(ppu_cmd_fifo_is_empity && near_to_be_full__fb==1'b0 ) begin
                state <= WRITEBACK;
            end
        end
        3'b010: begin
            if(ppu_cmd_fifo_is_empity && near_to_be_full__fb==1'b0) begin
                state <= WRITEBACK;
            end
        end
    endcase
    7'b0000001: case(funct3)
        3'b000: begin 
            if(sync__state==1'b0) begin
                addr_to_frame_buffer<= rs1_val[20:0];
                fb_horizontal_offset<= rs2_val[20:0];
                set_addr_to_frame_buffer<=1'b1;
                
                /*********
                wr_en__fb<=1'b1;
                wr_data__fb<=rs1_val[20:0];
                *******/
                
            end
            else if(time_that_stage_hold>8'h01) begin
                set_addr_to_frame_buffer<=1'b0;
                if(set_addr_to_frame_buffer__ack)
                    state <= WRITEBACK;

                /******
                wr_en__fb<=1'b0;
                if(processing_insert__fb==1'b0) begin
                    state <= WRITEBACK;
                end
                ******/
            end
        end
    endcase  
endcase