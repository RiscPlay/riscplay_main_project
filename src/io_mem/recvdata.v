module recvdata (
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
    output reg    [31:0] din_main_memory,
    output reg           wre_main_memory

);

localparam [3:0] RESET_STATE                                =  4'hf;
localparam [3:0] STATE_RECV_DATA                            =  4'h0;
localparam [3:0] STATE_WAIT_DATA                            =  4'h1;
localparam [3:0] STATE_CHECK_IF_CRC_IS_NEAR_TO_FINISH_AND_STORE_DATA_IN_EXTERNAL_MEMORY       =  4'h2;
localparam [3:0] STATE_WAIT_CRC_FINISH_P0                   =  4'h3;
localparam [3:0] STATE_WAIT_CRC_FINISH_P1                   =  4'h4;
localparam [3:0] STATE_INC_MEM_ADDR                         =  4'h5;

localparam [3:0] STATE_FINISH =  4'h9;

reg [3:0] time_that_stage_hold;

reg [3:0] state;
reg [3:0] state_prev;
reg [15:0] n_elements_computed;
reg crc_started;
wire [15:0] n_elements_to_compute=op_args[15:0];
wire sync__state=state_prev==state;
reg [1:0] n_bytes_recv_after_last_write;
reg [31:0] four_lasts_bytes_recv_after_last_write;
reg [31:0] addr_main_memory__intern;
always @(posedge clk) begin
    if(!rst_n) begin
        n_elements_computed<=16'h0000;
        state<=STATE_RECV_DATA;
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
        n_bytes_recv_after_last_write<=4'h0;
        wre_main_memory<=1'b0;
        addr_main_memory__intern<=op_args[47:16];
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
            default: state<=STATE_RECV_DATA;
            STATE_RECV_DATA: begin
                stopped<=1'b0;
                if(~busy_from_read_fifo & ~empty_fifo) begin
                    rd_req_fifo<=1'b1;
                    if(~crc_started) begin
                        start_crc32<=1'b1;
                        crc_started<=1'b1;
                    end
                    wre_main_memory<=1'b0;
                    din_main_memory<=32'h00000000;
                    n_bytes_recv_after_last_write<=n_bytes_recv_after_last_write+2'b01;
                    state<=STATE_WAIT_DATA;
                end
            end
            STATE_WAIT_DATA: begin
                if(sync__state & (time_that_stage_hold>4'h2)) begin
                    rd_req_fifo<=1'b0;
                end
                if(sync__state & rd_ready_fifo & (time_that_stage_hold>4'h2)) begin
                    if(ready_for_recv_data) begin
                        data_line_to_write_in_crc32<=data_line_from_read_fifo;
                        process_new_data_in_crc32_module<=1'b1;
                        state<=STATE_CHECK_IF_CRC_IS_NEAR_TO_FINISH_AND_STORE_DATA_IN_EXTERNAL_MEMORY;
                        n_elements_computed<=n_elements_computed+16'h0001;
                        four_lasts_bytes_recv_after_last_write<={four_lasts_bytes_recv_after_last_write[23:0],data_line_from_read_fifo};
                    end
                end
            end
            STATE_CHECK_IF_CRC_IS_NEAR_TO_FINISH_AND_STORE_DATA_IN_EXTERNAL_MEMORY: begin
                start_crc32<=1'b0;
                process_new_data_in_crc32_module<=1'b0;
                if(n_bytes_recv_after_last_write==2'b00) begin
                    din_main_memory<=four_lasts_bytes_recv_after_last_write;
                    wre_main_memory<=1'b1;
                    addr_main_memory<=addr_main_memory__intern;
                end
                if(n_elements_computed==n_elements_to_compute) begin
                    state<=STATE_WAIT_CRC_FINISH_P0;
                end
                else if(n_bytes_recv_after_last_write==2'b00) begin
                    state<=STATE_INC_MEM_ADDR;
                end
                else begin
                    state<=STATE_RECV_DATA;
                end
            end
            STATE_INC_MEM_ADDR: begin
                if(sync__state) begin
                    addr_main_memory__intern<=addr_main_memory__intern+32'h00000001;
                    state<=STATE_RECV_DATA;
                end
            end
            STATE_WAIT_CRC_FINISH_P0: begin
                addr_main_memory<=32'h00000000;
                wre_main_memory<=1'b0;
                din_main_memory<=32'h00000000;
                if(ready_for_recv_data) begin
                    finish_calc_crc<=1'b1;
                    state<=STATE_WAIT_CRC_FINISH_P1;
                end
            end
            STATE_WAIT_CRC_FINISH_P1: begin
                if(crc_done) begin
                    finish_calc_crc<=1'b0;
                     stopped<=1'b1;
                end
            end
       endcase
    end
end

endmodule