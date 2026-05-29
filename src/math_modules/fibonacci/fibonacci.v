module fibonacci (
    input wire          clk,
    input  wire         rst_n,
    input  wire [7:0]   data_line_from_read_fifo,
    output reg          rd_req_fifo,
    input  wire         rd_ready_fifo,
    input  wire         empty_fifo,
    output reg  [7:0]   data_line_from_write_fifo,
    output reg          wr_req_fifo,
    input  wire         wr_ready_fifo,
    input  wire         full_fifo,
    input  wire         busy_from_write_fifo,
    input  wire         busy_from_read_fifo,
    output reg          stopped,


    output reg          start_crc32,
    output reg  [7:0]   data_line_to_write_in_crc32,
    output reg          process_new_data_in_crc32_module,
    output reg          finish_calc_crc,
    input  wire [31:0]  crc_out,
    input  wire         crc_done,
    input  wire [31:0]  crc_bytes_processed,
    input  wire         ready_for_recv_data,
    input  wire  [63:0] op_args
);

localparam [3:0] RESET_STATE                                =  4'hf;
localparam [3:0] STATE_CALCP00                              =  4'h0;
localparam [3:0] STATE_CALCP01                              =  4'h1;
localparam [3:0] STATE_CALCP02                              =  4'h2;
localparam [3:0] STATE_CALCP03                              =  4'h3;
localparam [3:0] STATE_SEND_CALC_P0                         =  4'h4;
localparam [3:0] STATE_SEND_CALC_P1                         =  4'h5;

localparam [3:0] STATE_FINISHED__CRC_COMP                   =  4'h6;
localparam [3:0] STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P0 =  4'h7;
localparam [3:0] STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P1 =  4'h8;
localparam [3:0] STATE_FINISH =  4'h9;


reg [3:0] state;
reg [3:0] state_prev;
reg [7:0] f1;
reg [7:0] f2;
reg [7:0] f3;
reg [15:0] n_elements_computed;
reg [15:0] n_elements_sent_to_external_world;

wire [15:0] n_elements_to_compute=op_args[15:0];
wire sync__state=state_prev==state;
always @(posedge clk) begin
    if(!rst_n) begin
        f1<=8'h01;
        f2<=8'h01;
        n_elements_computed<=16'h0000;
        state<=STATE_CALCP00;
        state_prev<=RESET_STATE;
        stopped<=1'b1;
        finish_calc_crc<=1'b0;
        wr_req_fifo<=1'b0;
        rd_req_fifo<=1'b0;
        data_line_from_write_fifo<=8'h00;
        n_elements_sent_to_external_world<=16'h0000;
    end
    else begin
       state_prev<=state;
       case(state)
            default: state<=STATE_CALCP00;
            STATE_CALCP00: begin
                if(f2>=8'ha0) begin
                    f3<=8'h02;
                    f2<=8'h01;
                    f1<=8'h01;
                end
                else begin
                    f3<=f1+f2;
                end
                stopped<=1'b0;
                start_crc32<=1'b1;
                state<=STATE_CALCP01;
                n_elements_computed<=n_elements_computed+16'h0001;
            end
            STATE_CALCP01: begin
                f1<=f2;
                state<=STATE_CALCP02;
            end
            STATE_CALCP02: begin
                f2<=f3;
                state<=STATE_SEND_CALC_P0;

            end
            STATE_SEND_CALC_P0: begin

                if(~busy_from_write_fifo& ~full_fifo & ready_for_recv_data) begin
                    //$display("==== = %d", f1);
                    wr_req_fifo<=1'b1;
                    data_line_from_write_fifo<=f1;
                    state<=STATE_SEND_CALC_P1;
                    data_line_to_write_in_crc32<=f1;
                    process_new_data_in_crc32_module<=1'b1;
                end
            end
            STATE_SEND_CALC_P1: begin
                if(sync__state) begin
                    process_new_data_in_crc32_module<=1'b0;
                    if(wr_ready_fifo) begin
                        wr_req_fifo<=1'b0;
                        if(n_elements_computed==n_elements_to_compute) begin
                            finish_calc_crc<=1'b1;
                            start_crc32<=1'b0;
                            state<=STATE_FINISHED__CRC_COMP;
                        end
                        else begin
                            state<=STATE_CALCP00;
                        end
                    end
                end
            end
            STATE_FINISHED__CRC_COMP: begin
                if(crc_done) begin
                    finish_calc_crc<=1'b0;
                    state<=STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P0;
                end
            end
            STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P0: begin
                if(n_elements_sent_to_external_world<n_elements_to_compute) begin
                    if(~busy_from_read_fifo & empty_fifo==1'b0) begin
                        rd_req_fifo<=1'b1;
                        state<=STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P1;
                    end
                end
                else begin
                    state<=STATE_FINISH;
                end
            end
            STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P1: begin
                rd_req_fifo<=1'b0;
                if(sync__state) begin
                    if(rd_ready_fifo) begin
                        n_elements_sent_to_external_world<=n_elements_sent_to_external_world+16'h0001;
                        state<=STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P0;
                    end
                end
            end
            STATE_FINISH: begin
                stopped<=1'b1;
            end
       endcase
    end
end

endmodule