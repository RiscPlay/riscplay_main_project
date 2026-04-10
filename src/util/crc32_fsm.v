module crc32_fsm (
    input  wire clk,
    input  wire rst_n,
    input  wire cs,
    input  wire start,

    input  wire [7:0] data_in,
    input  wire process_new_data,
    output reg  ready_for_recv_data,
    input  wire finish_calc_crc,
    output reg [31:0] crc_out,
    output reg done,
    output reg [31:0] crc_bytes_processed
);

localparam [2:0] IDLE     = 3'b000;
localparam [2:0] LOAD_P0  = 3'b001;
localparam [2:0] LOAD_P1  = 3'b010;
localparam [2:0] SHIFT    = 3'b011;
localparam [2:0] NEXT     = 3'b100;

reg [2:0] state;
reg [2:0] delay_stage;
reg [3:0] time_that_stage_hold;
wire sync_stage=delay_stage==state;
reg [31:0] crc;
reg [2:0] bit_cnt;

wire mix;

reg rd_req_fifo;
wire [7:0] dout_fifo;
wire fifo_empty;
wire rd_ready_fifo;

always @(posedge clk) begin
    if (!rst_n) begin
        state   <= IDLE;
        crc     <= 32'hFFFFFFFF;
        done    <= 1'b1;
        rd_req_fifo<=1'b0;
        time_that_stage_hold<=4'h0;
        crc_bytes_processed<=32'h00000000;
    end else begin
        delay_stage<=state;
        if(sync_stage) begin
            if(time_that_stage_hold<4'hf) begin
                time_that_stage_hold<=time_that_stage_hold+4'h1;
            end
        end
        else begin
            time_that_stage_hold<=4'h0;
        end
        case(state)
        default: state <= IDLE;
        IDLE: begin
            if(start) begin
                crc <=  32'hFFFFFFFF;
                crc_bytes_processed<=32'h00000000;
                state <= LOAD_P0;
                done <= 1'b0;
            end
            else begin
                done <= 1'b1;
            end
            rd_req_fifo<=1'b0;
            time_that_stage_hold<=4'h0;
        end
        LOAD_P0: begin
            if((~fifo_empty) & (~fifo_crc32_is_busy)) begin
                rd_req_fifo <=1'b1;
                state       <=LOAD_P1;
            end
            else if(finish_calc_crc & fifo_empty ) begin
                crc_out <= crc ^ 32'hFFFFFFFF;
                done <= 1;
                state <= IDLE;
                $display("crc_int = %h", crc ^ 32'hFFFFFFFF);
            end
        end
        LOAD_P1: begin
            if(rd_ready_fifo & (sync_stage)& (time_that_stage_hold>4'h2)) begin
                bit_cnt      <= 3'b000;
                crc          <= crc^{24'b0,dout_fifo};
                state        <= SHIFT;
                rd_req_fifo  <= 1'b0;
            end
        end
        SHIFT: begin
            if(crc[0]) begin

                crc <= (crc >> 1) ^ 32'hEDB88320;
            end
            else begin
                crc <= (crc >> 1);
            end
            bit_cnt <= bit_cnt + 1;

            if(bit_cnt == 3'd7) begin
                crc_bytes_processed<=crc_bytes_processed+32'h00000001;
                state <= LOAD_P0;
            end
        end
        NEXT: begin
            if(finish_calc_crc) begin
                crc_out <= crc ^ 32'hFFFFFFFF;
                done <= 1;
                state <= IDLE;
            end
            else  begin
                state <= LOAD_P0;
            end
        end
        endcase
    end
end




reg wr_req_fifo;
wire [7:0] din_fifo=data_in;
wire wr_ready_fifo;
wire fifo_full;
wire  fifo_crc32_is_busy;



reg [1:0] state___write_fifo_crc32;
reg [1:0] state___write_fifo_crc32___delay;
reg [3:0] time_that_state___write_fifo_crc32__hold;

wire sync_stage__write_fifo_crc32=state___write_fifo_crc32==state___write_fifo_crc32___delay;
reg busy_to_recv_data;
localparam IDLE___TO_WRITE_FIFO_CRC32  = 2'b00;
localparam ADD_IN_BUFFER___TO_WRITE_FIFO_CRC32  = 2'b01;
localparam CHECK_IF_DATA_WAS_ADDED___TO_WRITE_FIFO_CRC32  = 2'b10;

always @(posedge clk) begin
    if (!rst_n) begin
        state___write_fifo_crc32<=IDLE___TO_WRITE_FIFO_CRC32;
        wr_req_fifo<=1'b0;
        ready_for_recv_data<=1'b1;
        time_that_state___write_fifo_crc32__hold<=4'h0;
    end
    else begin
        state___write_fifo_crc32___delay<=state___write_fifo_crc32;
        if(state___write_fifo_crc32___delay==state___write_fifo_crc32) begin
            time_that_state___write_fifo_crc32__hold<=time_that_state___write_fifo_crc32__hold+4'h1;
        end
        else begin
            time_that_state___write_fifo_crc32__hold<=4'h0;
        end
        case (state___write_fifo_crc32)
            default: state___write_fifo_crc32<=IDLE___TO_WRITE_FIFO_CRC32;
            IDLE___TO_WRITE_FIFO_CRC32: begin
                if(process_new_data) begin
                    state___write_fifo_crc32<=ADD_IN_BUFFER___TO_WRITE_FIFO_CRC32;
                    ready_for_recv_data<=1'b0;

                end
                else begin
                    ready_for_recv_data<=1'b1;
                end
            end
            ADD_IN_BUFFER___TO_WRITE_FIFO_CRC32: begin
                if((~fifo_full) & (~fifo_crc32_is_busy) ) begin
                    wr_req_fifo<=1'b1;
                    state___write_fifo_crc32<=CHECK_IF_DATA_WAS_ADDED___TO_WRITE_FIFO_CRC32;
                end
            end
            CHECK_IF_DATA_WAS_ADDED___TO_WRITE_FIFO_CRC32: begin
                if(wr_ready_fifo & sync_stage__write_fifo_crc32 & time_that_state___write_fifo_crc32__hold>4'h1) begin
                    //$display("din = %d", din_fifo);
                    wr_req_fifo<=1'b0;
                    ready_for_recv_data<=1'b1;
                    state___write_fifo_crc32<=IDLE___TO_WRITE_FIFO_CRC32;
                end
            end
        endcase
    end
end


fifo #(.SIZE(256)) fifo_crc32 (
        .clk(clk),
        .rst_n(rst_n),
        .cs(cs),
        .wr_req(wr_req_fifo),
        .rd_req(rd_req_fifo),
        .din(din_fifo),
        .dout(dout_fifo),
        .wr_ready(wr_ready_fifo),
        .rd_ready(rd_ready_fifo),
        .empty(fifo_empty),
        .full(fifo_full),
        .busy(fifo_crc32_is_busy)
    );
endmodule