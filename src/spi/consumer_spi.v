
module consumer_spi
#(  
    parameter N_BITS_TO_ADDRESS_MODULES = 4,
    parameter N_MODULES = 8
)
(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         cs,
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
    output reg [N_BITS_TO_ADDRESS_MODULES-1:0]   module_id_sel,
    output reg [N_MODULES-1:0]  awake_module,
    input  wire   modules_stopped [N_MODULES],
    output reg         start_crc32,
    output reg  [7:0]  data_line_to_write_in_crc32,
    output reg         process_new_data_in_crc32_module,
    output reg         finish_calc_crc,
    input  wire [31:0] crc_out,
    input  wire        crc_done,
    input  wire [31:0] crc_bytes_processed,
    input  wire        ready_for_recv_data,
    output reg  [63:0] op_args,

    output reg [3:0] sel___main_memory
);




localparam       OP_BIT_TO_CHECK_IF_MODULE_DONT_NEED_CRC          = 3;
localparam [4:0] STATE__RESET                                     = 5'b00000;
localparam [4:0] STATE__IDLE                                      = 5'b00001;
localparam [4:0] STATE__RECEIVE_OP_AND_ARGS                       = 5'b00010;
localparam [4:0] STATE__CALC_CRC_FOR_HEADER                       = 5'b00011;
localparam [4:0] STATE__CHECK_IF_CRC_IS_NEAR_TO_FINISH            = 5'b00100;
localparam [4:0] STATE__WAIT_CRC_FOR_HEADER_FINISH                = 5'b00101;
localparam [4:0] STATE__SEND_CRC                                  = 5'b00110;
localparam [4:0] STATE__SEND_CRC_WAIT_TRANSFER_FOR_ONE_BYTE       = 5'b00111;
localparam [4:0] STATE__RECV_CRC                                  = 5'b01000;
localparam [4:0] STATE__RECV_CRC_WAIT_TRANSFER_FOR_ONE_BYTE       = 5'b01001;
localparam [4:0] STATE__CHECK_CRC_RECV                            = 5'b01010;
localparam [4:0] STATE__CHECK_CRC_RECV_P1                         = 5'b01011;
localparam [4:0] STATE__CHECK_CRC_RECV_P2                         = 5'b01100;
localparam [4:0] STATE__CHECK_CRC_RECV_P3                         = 5'b01101;
localparam [4:0] STATE__CALL_MODULE                               = 5'b01110;
localparam [4:0] STATE__WAIT_MODULE_STOP                          = 5'b01111;
localparam [4:0] STATE__GET_CRC_FROM_MODULE                       = 5'b10000;
localparam [7:0] CRC_IS_CORRECT = 8'h0f;
localparam [7:0] CRC_IS_WRONG   = 8'hf0;
reg [3:0] diff_of_msg_recv_about_crc_to__crc_is_correct;

reg cs_prev_prev;
reg cs_prev;
reg cs_negedge;
reg cs_posedge;
reg [4:0] state_delay;
reg [4:0] state;
wire sync__state_buffer=state==state_delay;


reg [7:0]  op;
reg op_defined;
reg [3:0] n_bytes_recv_from_fifo_to_define_of_op_args;



reg [31:0] crc_computed;
reg [31:0] crc_to_send;
reg [31:0] crc_recv;

reg  [31:0] n_bytes_sent_to_process_crc;

reg  [2:0]  bytes_crc_sent;
reg  [2:0]  bytes_crc_recv;

reg [3:0] time_that_stage_hold;

reg write_fifo;
reg write_fifo_processed;
reg read_fifo;
reg read_fifo_processed;


reg msg_for_when_crc_is_ok;
reg sending_crc_resulted_from_module_op;
wire [N_BITS_TO_ADDRESS_MODULES-1:0] op_selected= op[N_BITS_TO_ADDRESS_MODULES-1:0];
wire module_stopped =modules_stopped[op_selected];
always @(posedge clk) begin

    if(!rst_n) begin
        cs_posedge<=1'b0;
        cs_negedge<=1'b0;
        cs_prev<=1'b1;
        cs_prev_prev<=1'b1;
        op<=8'h00;
        op_defined<=1'b0;
        n_bytes_recv_from_fifo_to_define_of_op_args<=4'h0;
        start_crc32<=1'b0;
        process_new_data_in_crc32_module<=1'b0;
        finish_calc_crc<=1'b0;
        n_bytes_sent_to_process_crc<=32'h00000000;
        bytes_crc_sent<=3'b000;
        bytes_crc_recv<=3'b000;
        time_that_stage_hold<=4'h0;
        module_id_sel<=16'h00;
        awake_module<='0;
        sending_crc_resulted_from_module_op<=1'b0;
    end
    else begin
        cs_prev<=cs;
        cs_prev_prev<=cs_prev;
        state_delay<=state;
        cs_posedge <= ~cs_prev&(cs);
        cs_negedge<= cs_prev_prev&(~cs_prev)&(~cs);
        if(sync__state_buffer) begin
            if(time_that_stage_hold<4'hf) begin
                time_that_stage_hold<=time_that_stage_hold+4'h1;
            end
        end
        else begin
            time_that_stage_hold<=4'h0;
        end
        case(state)
            default: state<=STATE__RESET;
            STATE__RESET: begin
                if(~busy_from_read_fifo & ~busy_from_write_fifo & crc_done) begin
                    op<=8'h00;
                    op_defined<=1'b0;
                    n_bytes_recv_from_fifo_to_define_of_op_args<=4'h0;
                    start_crc32<=1'b0;
                    process_new_data_in_crc32_module<=1'b0;
                    finish_calc_crc<=1'b0;
                    n_bytes_sent_to_process_crc<=32'h00000000;
                    bytes_crc_sent<=3'b000;
                    bytes_crc_recv<=3'b000;
                    read_fifo<=1'b0;
                    write_fifo<=1'b0;
                    state<=STATE__IDLE;
                end
            end
            STATE__IDLE:
            begin
                if(~empty_fifo & ~busy_from_read_fifo) begin
                    read_fifo<=1'b1;
                    if(n_bytes_recv_from_fifo_to_define_of_op_args<4'h8) begin
                        state<=STATE__RECEIVE_OP_AND_ARGS;
                    end
                    if(crc_done ==1'b1) begin
                        start_crc32<=1'b1;
                    end
                end
                process_new_data_in_crc32_module<=1'b0;

            end
            STATE__RECEIVE_OP_AND_ARGS:
            begin
                read_fifo<=1'b0;
                start_crc32<=1'b0;
                if(read_fifo_processed & sync__state_buffer) begin
                    if(~op_defined) begin
                        op<=data_line_from_read_fifo;
                        op_defined<=1'b1;
                        data_line_to_write_in_crc32<=data_line_from_read_fifo;
                    end
                    else begin
                        op_args<={op_args[55:0],data_line_from_read_fifo};
                        n_bytes_recv_from_fifo_to_define_of_op_args<=n_bytes_recv_from_fifo_to_define_of_op_args+4'h1;
                        data_line_to_write_in_crc32<=data_line_from_read_fifo;
                    end
                    state<=STATE__CALC_CRC_FOR_HEADER;
                end

            end
            STATE__CALC_CRC_FOR_HEADER:
            begin
                if(ready_for_recv_data) begin
                    process_new_data_in_crc32_module<=1'b1;
                    data_line_to_write_in_crc32<=data_line_from_read_fifo;
                    n_bytes_sent_to_process_crc<=n_bytes_sent_to_process_crc+32'h00000001;
                    state<=STATE__CHECK_IF_CRC_IS_NEAR_TO_FINISH;
                end
            end
            STATE__CHECK_IF_CRC_IS_NEAR_TO_FINISH:
            begin
                process_new_data_in_crc32_module<=1'b0;
                if(n_bytes_sent_to_process_crc==32'h00000009) begin
                    if(crc_bytes_processed==32'h00000009) begin
                        finish_calc_crc<=1'b1;
                        state<=STATE__WAIT_CRC_FOR_HEADER_FINISH;
                    end
                end
                else begin
                    state<=STATE__IDLE;
                end
            end
            STATE__WAIT_CRC_FOR_HEADER_FINISH: begin
                if(crc_done&sync__state_buffer) begin
                    crc_computed<=crc_out;
                    crc_to_send<=crc_out;
                    crc_recv<=32'h00000000;
                    bytes_crc_sent<=3'b000;
                    bytes_crc_recv<=3'b000;
                    state<=STATE__SEND_CRC;
                    finish_calc_crc<=1'b0;
                end
            end
            STATE__SEND_CRC: begin
                if(bytes_crc_sent<3'b100) begin
                    if(~busy_from_write_fifo) begin
                        data_line_from_write_fifo<=crc_to_send[31:24];
                        write_fifo<=1'b1;
                        state<=STATE__SEND_CRC_WAIT_TRANSFER_FOR_ONE_BYTE;
                        crc_to_send<=crc_to_send<<8;
                    end
                end
                else begin
                    write_fifo<=1'b0;
                    state<=STATE__RECV_CRC;
                end
            end
            STATE__SEND_CRC_WAIT_TRANSFER_FOR_ONE_BYTE: begin
                write_fifo<=1'b0;
                if(sync__state_buffer) begin
                    if( write_fifo_processed) begin
                        state<=STATE__SEND_CRC;
                        bytes_crc_sent<=bytes_crc_sent+3'b001;
                    end
                end
            end
            STATE__RECV_CRC: begin
                if(bytes_crc_recv<3'b100) begin
                    if(~busy_from_read_fifo & empty_fifo==1'b0) begin
                        read_fifo<=1'b1;
                        state<=STATE__RECV_CRC_WAIT_TRANSFER_FOR_ONE_BYTE;
                    end
                    else begin
                        read_fifo<=1'b0;
                    end
                end


            end
            STATE__RECV_CRC_WAIT_TRANSFER_FOR_ONE_BYTE: begin
                read_fifo<=1'b0;
                if(sync__state_buffer) begin
                    if(read_fifo_processed) begin
                        crc_recv<={crc_recv[23:0],data_line_from_read_fifo};
                        bytes_crc_recv<=bytes_crc_recv+3'b001;
                        if(bytes_crc_recv==3'b011) begin
                            state<=STATE__CHECK_CRC_RECV;
                            finish_calc_crc<=1'b0;
                        end
                        else begin
                            state<=STATE__RECV_CRC;
                        end
                    end
                end
            end
            STATE__CHECK_CRC_RECV: begin
                read_fifo<=1'b0;
                if(~busy_from_write_fifo) begin
                    if(crc_recv==crc_computed) begin
                        data_line_from_write_fifo<=CRC_IS_CORRECT;
                    end
                    else begin
                        data_line_from_write_fifo<=CRC_IS_WRONG;
                    end
                    write_fifo<=1'b1;
                    state<=STATE__CHECK_CRC_RECV_P1;
                end
            end
            STATE__CHECK_CRC_RECV_P1: begin
                write_fifo<=1'b0;
                if(sync__state_buffer & write_fifo_processed) begin
                    if(~busy_from_read_fifo) begin
                        read_fifo<=1'b1;
                        state<=STATE__CHECK_CRC_RECV_P2;
                    end
                end
            end
            STATE__CHECK_CRC_RECV_P2: begin
                read_fifo<=1'b0;
                if(sync__state_buffer & read_fifo_processed) begin
                    diff_of_msg_recv_about_crc_to__crc_is_correct<=
                        {3'b000,~data_line_from_read_fifo[0]}+
                        {3'b000,~data_line_from_read_fifo[1]}+
                        {3'b000,~data_line_from_read_fifo[2]}+
                        {3'b000,~data_line_from_read_fifo[3]}+
                        {3'b000,data_line_from_read_fifo[4]}+
                        {3'b000,data_line_from_read_fifo[5]}+
                        {3'b000,data_line_from_read_fifo[6]}+
                        {3'b000,data_line_from_read_fifo[7]};
                    state<=STATE__CHECK_CRC_RECV_P3;
                end
            end
            STATE__CHECK_CRC_RECV_P3: begin
                if(~sending_crc_resulted_from_module_op &
                    diff_of_msg_recv_about_crc_to__crc_is_correct<4'h4) begin
                    state<=STATE__CALL_MODULE;
                end
                else begin
                    state<=STATE__RESET;
                end
            end
            STATE__CALL_MODULE: begin
                if(op[3]==1'b0) 
                    module_id_sel<=op[N_BITS_TO_ADDRESS_MODULES-1:0];
                awake_module[op[N_BITS_TO_ADDRESS_MODULES-1:0]]<=1'b1;
                state<=STATE__WAIT_MODULE_STOP;
                sel___main_memory<=op[N_BITS_TO_ADDRESS_MODULES-1:0];
            end
            STATE__WAIT_MODULE_STOP: begin
                if(sync__state_buffer) begin
                    if(module_stopped==1'b1) begin
                        awake_module[op[N_BITS_TO_ADDRESS_MODULES-1:0]]<=1'b0;
                        module_id_sel<='0;
                        if(op[3]==1'b1) 
                            state<=STATE__RESET;
                        else
                            state<=STATE__GET_CRC_FROM_MODULE;
                        sel___main_memory<=4'h0;
                    end
                end
            end
            STATE__GET_CRC_FROM_MODULE: begin
                crc_computed<=crc_out;
                crc_to_send<=crc_out;
                crc_recv<=32'h00000000;
                bytes_crc_sent<=3'b000;
                bytes_crc_recv<=3'b000;
                state<=STATE__SEND_CRC;
                finish_calc_crc<=1'b0;
                sending_crc_resulted_from_module_op<=1'b1;
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
                if(busy_from_write_fifo==1'b0 & ~full_fifo) begin
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
                if(busy_from_read_fifo==1'b0 & ~empty_fifo) begin
                    rd_req_fifo<=1'b1;
                    state_read_fifo<=2'b10;
                end
            end
            2'b10:
            begin
                if(sync__state_read_fifo & rd_ready_fifo) begin
                    rd_req_fifo<=1'b0;
                    state_read_fifo<=2'b11;
                end
            end
            2'b11:
            begin
                read_fifo_processed<=1'b1;
                state_read_fifo<=2'b00;

            end

        endcase
    end
end




endmodule