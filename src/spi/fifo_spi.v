module fifo_spi
(
    input  wire clk,
    input  wire rst_n,
    input  wire cs,
    input  wire [7:0] data_line_from_read_fifo,
    output reg  rd_req_fifo,
    input  wire rd_ready_fifo,
    input  wire empty_fifo,
    output reg  [7:0] data_line_from_write_fifo,
    output reg  wr_req_fifo,
    input  wire wr_ready_fifo,
    input  wire activate_fifos_to_read_and_write,
    input  wire [7:0] data_in_from__fifo_spi,
    output reg  [7:0] data_out_from__fifo_spi,
    input  wire  busy_from_write_fifo,
    input  wire  busy_from_read_fifo,
    output reg   fifo_spi_is_busy,
    output reg   fifo_spi_finished_read_op,
    output reg   fifo_spi_finished_write_op
);

localparam [3:0] IDLE              = 4'b0000;
localparam [3:0] NEW_DATA_RW_P0    = 4'b0001;
localparam [3:0] NEW_DATA_RW_P1    = 4'b0010;
localparam [3:0] WAIT_R_OR_W       = 4'b0011;
localparam [3:0] WAIT_R            = 4'b0100;
localparam [3:0] WAIT_W            = 4'b0101;

reg [3:0] state_buffer;
reg [3:0] state_buffer_delay;
reg [3:0] time_that_stage_hold;

wire sync__state_buffer;

assign sync__state_buffer=state_buffer==state_buffer_delay;
always @(posedge clk) begin
    if ((!rst_n) |cs) begin
        state_buffer<=IDLE;
        state_buffer_delay<=IDLE;
        rd_req_fifo<=1'b0;
        wr_req_fifo<=1'b0;
        data_line_from_write_fifo<=8'h00;
        fifo_spi_is_busy<=1'b0;
        data_out_from__fifo_spi<=8'h00;
        fifo_spi_finished_read_op<=1'b0;
        fifo_spi_finished_write_op<=1'b0;
        time_that_stage_hold<=4'h0;
    end
    else begin
        state_buffer_delay<=state_buffer;
        if(sync__state_buffer) begin
            if(time_that_stage_hold<4'hf) begin
                time_that_stage_hold<=time_that_stage_hold+4'h1;
            end
        end
        else begin
            time_that_stage_hold<=4'h0;
        end
        case(state_buffer)
            default:
            begin
                state_buffer <= IDLE;
            end
            IDLE:
            begin
                if(activate_fifos_to_read_and_write) begin
                    state_buffer<=NEW_DATA_RW_P1;
                    data_line_from_write_fifo<=data_in_from__fifo_spi;
                    fifo_spi_is_busy<=1'b1;
                    fifo_spi_finished_read_op<=1'b0;
                    fifo_spi_finished_write_op<=1'b0;
                    data_out_from__fifo_spi<=8'h00;
                end
                else begin
                    fifo_spi_is_busy<=1'b0;
                end
            end

            NEW_DATA_RW_P1:
            begin
                if((~busy_from_read_fifo)&(~busy_from_write_fifo) ) begin
                    wr_req_fifo<=1'b1;
                    if(~empty_fifo)
                        rd_req_fifo<=1'b1;
                    state_buffer<=WAIT_R_OR_W;
                end
            end
            WAIT_R_OR_W:
            begin
                if((wr_ready_fifo | rd_ready_fifo) &sync__state_buffer& (time_that_stage_hold>4'h2))
                begin
                    if(rd_ready_fifo) begin
                        data_out_from__fifo_spi<=data_line_from_read_fifo;
                        rd_req_fifo<=1'b0;
                        fifo_spi_finished_read_op<=1'b1;
                    end
                    if(wr_ready_fifo) begin
                        wr_req_fifo<=1'b0;
                        fifo_spi_finished_write_op<=1'b1;
                    end
                    if(wr_ready_fifo & rd_ready_fifo) begin
                        state_buffer<=IDLE;
                    end
                    else if(~wr_req_fifo & rd_ready_fifo) begin
                        state_buffer<=WAIT_W;
                    end
                    else if(wr_req_fifo & ~rd_ready_fifo & rd_req_fifo) begin
                            state_buffer<=WAIT_R;
                    end
                    else if( ~rd_req_fifo) begin
                            state_buffer<=IDLE;
                    end
                end

            end

            WAIT_W:
            begin
                if(wr_ready_fifo) begin
                    wr_req_fifo<=1'b0;
                    state_buffer<=IDLE;
                    fifo_spi_finished_write_op<=1'b1;

                end

            end
            WAIT_R:
            begin
                if(rd_ready_fifo) begin
                    data_out_from__fifo_spi<=data_line_from_read_fifo;
                    rd_req_fifo<=1'b0;
                    state_buffer<=IDLE;
                    fifo_spi_finished_read_op<=1'b1;
                end
            end
        endcase
    end
end
endmodule