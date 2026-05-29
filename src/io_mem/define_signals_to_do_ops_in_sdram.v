module define_signals_to_do_ops_in_sdram(
    input   wire  [31:0]  din_sdram_manager,
    output  wire  [1:0]   op,
    output  wire          op_will_hapen_in_two_rows,
    output  wire  [5:0]   amount_of_data_in_first_row_minus_1,
    output  wire  [5:0]   amount_of_data_in_second_row_minus_1,
    output  wire   [20:0] addr_to_start_op_in_ram_first_row,
    output  wire   [20:0] addr_to_start_op_in_ram_second_row
);


assign      op=din_sdram_manager[1:0];
wire [6:0]  data_len=din_sdram_manager[8:2];
wire [20:0] addr_to_start_op_in_ram= din_sdram_manager[29:9];
wire [20:0] addr_to_end_op_in_ram=  data_len>7'b000000 ? 
                                    addr_to_start_op_in_ram+{14'b0,data_len}-21'd1: 
                                    addr_to_start_op_in_ram;
assign op_will_hapen_in_two_rows=addr_to_end_op_in_ram[8]!=addr_to_start_op_in_ram[8];

wire [6:0]  amount_of_data_to_proc_in_first_row= op_will_hapen_in_two_rows ? 
            ({addr_to_start_op_in_ram[20:8],8'hff}-addr_to_start_op_in_ram)+7'b0000001 :
            data_len;
wire [6:0]  amount_of_data_to_proc_in_second_row= op_will_hapen_in_two_rows ? 
            data_len-amount_of_data_to_proc_in_first_row :
            7'b000000;
assign amount_of_data_in_first_row_minus_1  =   amount_of_data_to_proc_in_first_row>7'b0 ?
                                                amount_of_data_to_proc_in_first_row-7'b0000001 :
                                                6'b000000;
assign amount_of_data_in_second_row_minus_1 =   amount_of_data_to_proc_in_first_row>7'b0 ? 
                                                amount_of_data_to_proc_in_second_row-7'b0000001:
                                                6'b000000;

assign addr_to_start_op_in_ram_first_row= addr_to_start_op_in_ram;
assign addr_to_start_op_in_ram_second_row={addr_to_end_op_in_ram[20:8],8'h00};

endmodule