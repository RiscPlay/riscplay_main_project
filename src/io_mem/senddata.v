module senddata (
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
    input  wire  [63:0] op_args,

    output reg    [31:0] addr_main_memory,
    input  wire   [31:0] dout_main_memory
);

localparam [3:0] RESET_STATE                                =  4'hf;
localparam [3:0] STATE_START                                =  4'h1;
localparam [3:0] STATE_LOAD_DATA                            =  4'h2;
localparam [3:0] STATE_PUT_DATA_IN_FIFO                     =  4'h3;
localparam [3:0] STATE_WAIT_SEND                            =  4'h4;
localparam [3:0] STATE_CHECK_IF_CRC_IS_NEAR_TO_FINISH_AND_STORE_DATA_IN_EXTERNAL_MEMORY       =  4'h5;
localparam [3:0] STATE_WAIT_CRC_FINISH_P0                   =  4'h6;
localparam [3:0] STATE_WAIT_CRC_FINISH_P1                   =  4'h7;


localparam [3:0] STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P0 =  4'h8;
localparam [3:0] STATE_WAIT_TRANSFER_DATA_TO_EXTERNAL_WORLD_P1 =  4'h9;
localparam [3:0] STATE_FINISH =  4'ha;


reg [3:0] time_that_stage_hold;

reg [3:0] state;
reg [3:0] state_prev;
reg [15:0] n_elements_computed;

reg crc_started;
wire [15:0] n_elements_to_compute=op_args[15:0];
wire sync__state=state_prev==state;
reg [1:0]  n_bytes_send_after_last_read;
reg [31:0] four_lasts_bytes_to_send;
reg [31:0] addr_main_memory__intern;
reg [7:0] byte_to_send_to_crc;

reg [15:0] n_elements_sent_to_external_world;
always @(posedge clk) begin
    if(!rst_n) begin
        n_elements_computed<=16'h0000;
        state<=STATE_LOAD_DATA;
        state_prev<=RESET_STATE;
        stopped<=1'b1;
        finish_calc_crc<=1'b0;
        wr_req_fifo<=1'b0;
        rd_req_fifo<=1'b0;
        data_line_from_write_fifo<=8'h00;
        crc_started<=1'b0;
        start_crc32<=1'b0;
        process_new_data_in_crc32_module<=1'b0;
        time_that_stage_hold<=4'h0;
        n_bytes_send_after_last_read<=4'h0;
        addr_main_memory<=op_args[47:16];
        n_elements_sent_to_external_world<=16'h0000;
    end
    else begin
        if(sync__state) begin
            if(time_that_stage_hold<4'hf) begin
                time_that_stage_hold<=time_that_stage_hold+4'h1;
            end
        end
        else begin
            time_that_stage_hold<=4'h0;
        end
        state_prev<=state;
        case(state)
            default: state<=STATE_START;

            STATE_LOAD_DATA: begin
                if(sync__state & time_that_stage_hold>4'h1) begin
                    four_lasts_bytes_to_send<=dout_main_memory;
                    state<=STATE_PUT_DATA_IN_FIFO;
                end
                stopped<=1'b0;
            end
            STATE_PUT_DATA_IN_FIFO: begin
                if(~busy_from_write_fifo & ~full_fifo) begin
                    if(~crc_started) begin
                        start_crc32<=1'b1;
                        crc_started<=1'b1;
                    end
                    data_line_from_write_fifo<=four_lasts_bytes_to_send[31:24];
                    byte_to_send_to_crc<=four_lasts_bytes_to_send[31:24];
                    wr_req_fifo<=1'b1;
                    n_bytes_send_after_last_read<=n_bytes_send_after_last_read+2'b01;
                    state<=STATE_WAIT_SEND;
                end
            end
            STATE_WAIT_SEND: begin
                if(sync__state) begin
                    start_crc32<=1'b0;
                end
                if(sync__state & (time_that_stage_hold>4'h2)) begin
                    wr_req_fifo<=1'b0;
                end
                if(sync__state & wr_ready_fifo & (time_that_stage_hold>4'h2)) begin
                    if(ready_for_recv_data) begin
                        four_lasts_bytes_to_send<={four_lasts_bytes_to_send[23:0],8'h00};
                        data_line_to_write_in_crc32<=byte_to_send_to_crc;
                        process_new_data_in_crc32_module<=1'b1;
                        n_elements_computed<=n_elements_computed+16'h0001;
                        state<=STATE_CHECK_IF_CRC_IS_NEAR_TO_FINISH_AND_STORE_DATA_IN_EXTERNAL_MEMORY;
                    end
                end
            end
            STATE_CHECK_IF_CRC_IS_NEAR_TO_FINISH_AND_STORE_DATA_IN_EXTERNAL_MEMORY: begin
                if(sync__state) begin 
                    process_new_data_in_crc32_module<=1'b0;
                    if(n_elements_computed==n_elements_to_compute) begin
                        state<=STATE_WAIT_CRC_FINISH_P0;
                    end
                    else begin
                        if(n_bytes_send_after_last_read==2'b00) begin
                            state<=STATE_LOAD_DATA;
                            addr_main_memory<=addr_main_memory+32'h00000001;
                        end
                        else begin
                            state<=STATE_PUT_DATA_IN_FIFO;
                        end
                    end
                end
            end
            STATE_WAIT_CRC_FINISH_P0: begin
                if(ready_for_recv_data) begin
                    finish_calc_crc<=1'b1;
                    state<=STATE_WAIT_CRC_FINISH_P1;
                end
            end
            STATE_WAIT_CRC_FINISH_P1: begin
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
                    addr_main_memory<=32'h00000000;
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
