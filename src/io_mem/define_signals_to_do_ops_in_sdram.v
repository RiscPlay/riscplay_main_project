module define_signals_to_do_ops_in_sdram(
    input   wire           clk,
    input   wire           rst_n,
    input   wire           req__op_in_sdram,
    output  reg            req__op_in_sdram_from_define_signals,
    input   wire           req_op_in_sdram_ack_to_external_signals,
    input   wire  [31:0]   din_sdram_manager_extern,
    output  wire   [1:0]   op,
    output  reg            op_will_hapen_in_two_rows,
    output  wire   [5:0]   amount_of_data_in_first_row_minus_1,
    output  wire   [5:0]   amount_of_data_in_second_row_minus_1,
    output  wire   [20:0]  addr_to_start_op_in_ram_first_row,
    output  wire   [20:0]  addr_to_start_op_in_ram_second_row
);

localparam IDLE                                   = 4'h0;
localparam DEFINE_OP_WILL_HAPPEN_IN_TWO_ROWS      = 4'h1;
localparam DEFINE_DATA_AMOUNT_IN_FIRST_ROW        = 4'h2;
localparam DEFINE_DATA_AMOUNT_IN_SECOND_ROW       = 4'h3;

reg        req__op_in_sdram_prev;
reg        req_op_in_sdram_ack_to_external_signals_prev;
reg [31:0] din_sdram_manager_latch;


wire [6:0]  data_len=din_sdram_manager_extern[8:2];
reg  [6:0]  data_len_latch;

wire [20:0] addr_to_start_op_in_ram= din_sdram_manager_extern[29:9];
reg  [20:0] addr_to_start_op_in_ram_latch;
reg  [20:0] addr_to_end_op_in_ram;

reg  [3:0] state;
reg  [6:0] amount_of_data_to_proc_in_first_row;
reg  [6:0] amount_of_data_to_proc_in_second_row;
always @(posedge clk) begin
    if(rst_n==1'b0) begin
        din_sdram_manager_latch<=32'h00000000;
        req__op_in_sdram_prev<=1'b0;
        req_op_in_sdram_ack_to_external_signals_prev<=1'b0;
        state<= IDLE;
        req__op_in_sdram_from_define_signals<=1'b0;

    end
    else begin 
        req__op_in_sdram_prev<=req__op_in_sdram;
        req_op_in_sdram_ack_to_external_signals_prev<=req_op_in_sdram_ack_to_external_signals;
        case(state)
            default: state<=IDLE;
            IDLE: begin
                if(req__op_in_sdram==1'b1 && req__op_in_sdram_prev==1'b0) begin
                    din_sdram_manager_latch<=din_sdram_manager_extern;
                    data_len_latch<=data_len;
                    addr_to_start_op_in_ram_latch<=addr_to_start_op_in_ram;
                    if(data_len>7'b0000000) 
                        addr_to_end_op_in_ram<=    addr_to_start_op_in_ram+{14'b0,data_len}-21'd1;
                    else 
                        addr_to_end_op_in_ram<=addr_to_start_op_in_ram;
                    state<=DEFINE_DATA_AMOUNT_IN_FIRST_ROW;
                end
                if(req_op_in_sdram_ack_to_external_signals==1'b1 && req_op_in_sdram_ack_to_external_signals_prev==1'b0) begin
                    req__op_in_sdram_from_define_signals<=1'b0;
                end
            end

            DEFINE_DATA_AMOUNT_IN_FIRST_ROW: begin
                op_will_hapen_in_two_rows<=addr_to_end_op_in_ram[8]!=addr_to_start_op_in_ram_latch[8];

                if(addr_to_end_op_in_ram[8]!=addr_to_start_op_in_ram_latch[8])
                    amount_of_data_to_proc_in_first_row<= ({addr_to_start_op_in_ram_latch[20:8],8'hff}-addr_to_start_op_in_ram_latch)+7'b0000001;
                else
                    amount_of_data_to_proc_in_first_row<=data_len_latch;
                state<= DEFINE_DATA_AMOUNT_IN_SECOND_ROW;
            end
            DEFINE_DATA_AMOUNT_IN_SECOND_ROW: begin
                if(op_will_hapen_in_two_rows) 
                    amount_of_data_to_proc_in_second_row<=data_len_latch-amount_of_data_to_proc_in_first_row;
                else
                    amount_of_data_to_proc_in_second_row<=7'b0000000;
                req__op_in_sdram_from_define_signals<=1'b1;
                state<= IDLE;

            end
        endcase
    end
end
assign op=din_sdram_manager_latch[1:0];

assign amount_of_data_in_first_row_minus_1  =   amount_of_data_to_proc_in_first_row>7'b0 ?
                                                amount_of_data_to_proc_in_first_row-7'b0000001 :
                                                6'b000000;
assign amount_of_data_in_second_row_minus_1 =   amount_of_data_to_proc_in_second_row>7'b0 ? 
                                                amount_of_data_to_proc_in_second_row-7'b0000001:
                                                6'b000000;

assign addr_to_start_op_in_ram_first_row= addr_to_start_op_in_ram_latch;
assign addr_to_start_op_in_ram_second_row={addr_to_end_op_in_ram[20:8],8'h00};

endmodule