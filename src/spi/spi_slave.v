module spi_slave
(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sclk,
    input  wire       cs,
    input  wire       mosi,
    output reg        miso,
    input  wire [7:0] data_line_from_read_fifo,
    output reg        rd_req_fifo,
    input  wire       rd_ready_fifo,
    input  wire       empty_fifo,
    output reg [7:0]  data_line_from_write_fifo,
    output reg        wr_req_fifo,
    input  wire       wr_ready_fifo,
    input  wire       full_fifo,
    input  wire       busy_from_write_fifo,
    input  wire       busy_from_read_fifo
);

wire fifo_spi_is_busy;
wire fifo_spi_finished_read_op;
wire fifo_spi_finished_write_op;





localparam [1:0] IDLE                 = 2'b00;
localparam [1:0] WAIT                 = 2'b01;
localparam [1:0] COMMUNICATION        = 2'b10;
localparam [1:0] SEND_DATA_TO_BUFFER  = 2'b11;


reg activate_fifos_to_read_and_write;

reg [3:0] bit_count_write;
reg [7:0] shift_reg_in;
reg write_fifo;
reg write_fifo_processed;
reg [2:0] state_spi_comm_write;
reg previous_slck_write;
reg spi_posedge_write;
always @(posedge clk) begin
    if(!rst_n) begin
        spi_posedge_write<=1'b0;
        bit_count_write<=4'b0000;
        shift_reg_in<=8'h00;
        state_spi_comm_write<=WAIT;
        previous_slck_write<=1'b0;
        write_fifo<=1'b0;
    end
    else begin
        case(state_spi_comm_write)
            default: state_spi_comm_write<=IDLE;
            IDLE:
            begin
                bit_count_write<=4'b0000;
                shift_reg_in<=8'h00;
                state_spi_comm_write<=WAIT;
                previous_slck_write<=1'b0;
            end
            WAIT:
            begin
                bit_count_write<=4'b0000;
                if(!cs) begin
                    state_spi_comm_write<=COMMUNICATION;
                end
            end
            COMMUNICATION:
            begin
					 spi_posedge_write<= !previous_slck_write&sclk;
                previous_slck_write<=sclk;
                if((~previous_slck_write)&sclk) begin
                    bit_count_write    <=  bit_count_write+4'b0001;
                    shift_reg_in <= {shift_reg_in[6:0], mosi};
                    write_fifo<=1'b0;
                end
                else if(bit_count_write==4'b1000) begin
                    bit_count_write<=4'b0000;
                    data_line_from_write_fifo<=shift_reg_in;
                    write_fifo<=1'b1;
                end
                else if(cs) begin
                    state_spi_comm_write<=WAIT;
                    write_fifo<=1'b0;
                end
                else begin
                    write_fifo<=1'b0;
                end
            end
        endcase
    end
end


reg write_fifo_posedge;
reg [1:0] state_write_fifo;
reg [1:0] state_write_fifo_prev;
wire sync__state_write_fifo=state_write_fifo_prev==state_write_fifo;
always @(posedge clk) begin
    if(!rst_n) begin
        write_fifo_posedge<=1'b0;
        state_write_fifo<=2'b00;
        state_write_fifo_prev<=2'b00;
        wr_req_fifo<=1'b0;
        write_fifo_processed<=1'b0;

    end
    else begin
        state_write_fifo_prev<=state_write_fifo;
        case(state_write_fifo)
            default: state_write_fifo<=2'b00;
            2'b00:
            begin
                if(write_fifo) begin
                    state_write_fifo<=2'b01;
                    write_fifo_processed<=1'b0;
                end
            end
            2'b01:
            begin
                if(busy_from_write_fifo==1'b0) begin
                    wr_req_fifo<=1'b1;
                    state_write_fifo<=2'b10;
                end
            end
            2'b10:
            begin
                if(sync__state_write_fifo & wr_ready_fifo) begin
                    wr_req_fifo<=1'b0;
                    state_write_fifo<=2'b00;
                    write_fifo_processed<=1'b1;
                end
            end

        endcase
    end
end





reg [2:0] state_spi_comm_read;
reg [3:0] bit_count_read;

reg read_fifo;
reg read_fifo_processed;
reg previous_slck_read;
reg spi_negedge_read;
always @(posedge clk) begin
    if(!rst_n) begin
        bit_count_read<=4'b0000;
        state_spi_comm_read<=WAIT;
        previous_slck_read<=1'b0;
        read_fifo<=1'b0;
        miso<=1'b0;
    end
    else begin
        case(state_spi_comm_read)
            default: state_spi_comm_read<=IDLE;
            IDLE:
            begin
                bit_count_read<=4'b0111;
                state_spi_comm_read<=WAIT;
                previous_slck_read<=1'b0;
            end
            WAIT:
            begin
                bit_count_read<=4'b0111;
                if(!cs) begin
                    state_spi_comm_read<=COMMUNICATION;
                    read_fifo<=1'b1;
                end
            end
            COMMUNICATION:
            begin
                spi_negedge_read<= previous_slck_read&(~sclk);
                previous_slck_read<=sclk;
                if(~previous_slck_read&(sclk)) begin
                    bit_count_read    <=  bit_count_read-4'b0001;
                    miso <=data_line_from_read_fifo[bit_count_read[2:0]];
                    read_fifo<=1'b0;
                end
                else if(bit_count_read==4'b1111) begin
                    bit_count_read<=4'b0111;
                    //data_line_from_write_fifo<=shift_reg_in;
                    read_fifo<=1'b1;
                end
                else if(cs) begin
                    state_spi_comm_read<=WAIT;
                    read_fifo<=1'b0;
                end
                else begin
                    read_fifo<=1'b0;
                end
            end
        endcase
    end
end

reg read_fifo_posedge;
reg [1:0] state_read_fifo;
reg [1:0] state_read_fifo_prev;
wire sync__state_read_fifo=state_read_fifo_prev==state_read_fifo;
always @(posedge clk) begin
    if(!rst_n ) begin
        read_fifo_posedge<=1'b0;
        state_read_fifo<=2'b00;
        state_read_fifo_prev<=2'b00;
        read_fifo_processed<=1'b0;
        rd_req_fifo<=1'b0;
    end
    else begin
        state_read_fifo_prev<=state_read_fifo;
        case(state_read_fifo)
            default: state_read_fifo<=2'b00;
            2'b00:
            begin
                if(read_fifo) begin
                    state_read_fifo<=2'b01;
                    read_fifo_processed<=1'b0;
                end
            end
            2'b01:
            begin
                if(busy_from_read_fifo==1'b0 &(~empty_fifo)) begin
                    rd_req_fifo<=1'b1;
                    state_read_fifo<=2'b10;
                end
            end
            2'b10:
            begin
                if(sync__state_read_fifo & rd_ready_fifo) begin
                    rd_req_fifo<=1'b0;
                    state_read_fifo<=2'b00;
                    read_fifo_processed<=1'b1;
                end
            end

        endcase
    end
end


endmodule