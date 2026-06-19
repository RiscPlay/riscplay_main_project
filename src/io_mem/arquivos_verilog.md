###control_sdram.v
```verilog
module control_sdram(
    input   wire          clk,
    input   wire          rst_n,
    input   wire  [21:0]  addr_control_sdram__mapper,
    input   wire  [31:0]  din_control_sdram__mapper,
    output  reg   [31:0]  dout_control_sdram__mapper,
    input   wire  [21:0]  addr_control_sdram__pixel_ppu,
    input   wire  [31:0]  din_control_sdram__pixel_ppu,
    output  reg   [31:0]  dout_control_sdram__pixel_ppu,
    input   wire  [21:0]  addr_control_sdram__hdmi_controller,
    input   wire  [31:0]  din_control_sdram__hdmi_controller,
    output  reg   [31:0]  dout_control_sdram__hdmi_controller,
    input   wire          wre_control_sdram__mapper,
    input   wire          wre_control_sdram__hdmi_controller,
    input   wire          wre_control_sdram__pixel_ppu,
    output  wire          mapper_in_control__out,
    output  wire          hdmi_controller_in_control__out,
    output  wire          pixel_ppu_in_control__out,


    input  wire        O_sdrc_init_done,
    input  wire        O_sdrc_cmd_ack,
    input  wire [31:0] O_sdrc_data,

    output reg         I_sdrc_cmd_en,
    output reg  [2:0]  I_sdrc_cmd,
    output reg         I_sdrc_precharge_ctrl,
    output reg         I_sdram_power_down,
    output reg         I_sdram_selfrefresh,
    output reg  [20:0] I_sdrc_addr,
    output reg  [3:0]  I_sdrc_dqm,
    output reg  [31:0] I_sdrc_data,
    output reg  [7:0]  I_sdrc_data_len,
    output wire        busy
);
wire mapper_in_control;
wire hdmi_controller_in_control;
wire pixel_ppu_in_control;

assign mapper_in_control__out=mapper_in_control;
assign hdmi_controller_in_control__out=hdmi_controller_in_control;
assign pixel_ppu_in_control__out=pixel_ppu_in_control;
wire  [21:0]  addr_control_sdram = mapper_in_control          ? addr_control_sdram__mapper :
                                   hdmi_controller_in_control ? addr_control_sdram__hdmi_controller  :
                                   addr_control_sdram__pixel_ppu     ;
wire  [31:0]  din_control_sdram  = mapper_in_control          ? din_control_sdram__mapper :
                                   hdmi_controller_in_control ? din_control_sdram__hdmi_controller  :
                                   din_control_sdram__pixel_ppu;




localparam
    op_read_burst  = 2'b00,
    op_write_burst = 2'b01,
    op_read        = 2'b10,
    op_write       = 2'b11;





localparam [3:0] STATE_BOOTING                              =  4'hf;
localparam [3:0] STATE_IDLE                                 =  4'h0;
localparam [3:0] STATE_PREPARE_READ                         =  4'h1;
localparam [3:0] STATE_PREPATE_WRITE                        =  4'h2;
localparam [3:0] STATE_WAIT_WRITE_BEGIN                     =  4'h3;
localparam [3:0] STATE_WAIT_READ_BEGIN                      =  4'h4;
localparam [3:0] STATE_READING_DATA                         =  4'h5;
localparam [3:0] STATE_WRITING_DATA                         =  4'h6;
localparam [3:0] STATE_FINISHING_OP_IN_ROW                  =  4'h7;
localparam [3:0] STATE_REFRESH_P1                           =  4'h8;

localparam CMD_WRITE     = 3'b100;
localparam CMD_READ      = 3'b101;
localparam CMD_REFRESH   = 3'b001;
localparam CMD_ACTIVATE  = 3'b011;
localparam CMD_PRECHARGE = 3'b010;
localparam CMD_NOP       = 3'b111;

wire wre_pulse;
wire wre_pulse_from_mapper;
wire wre_pulse_from_pixel_ppu;
wire wre_pulse_from_hdmi_controller;
wire req__op_in_sdram;
reg  req_op_in_sdram_ack; 
wire [31:0] addr_control_sdram_to_process;
wire [31:0] din_control_sdram_to_process;
control_sdram_access control_sdram_access_ins(
    .clk(clk),
    .rst_n(rst_n),
    .addr_control_sdram__pixel_ppu(addr_control_sdram__pixel_ppu),
    .addr_control_sdram__mapper(addr_control_sdram__mapper),
    .addr_control_sdram__hdmi_controller(addr_control_sdram__hdmi_controller),
    .din_control_sdram__pixel_ppu(din_control_sdram__pixel_ppu),
    .din_control_sdram__mapper(din_control_sdram__mapper),
    .din_control_sdram__hdmi_controller(din_control_sdram__hdmi_controller),
    .wre_control_sdram__mapper(wre_control_sdram__mapper),
    .wre_control_sdram__pixel_ppu(wre_control_sdram__pixel_ppu),
    .wre_control_sdram__hdmi_controller(wre_control_sdram__hdmi_controller),
    .mapper_in_control(mapper_in_control),
    .hdmi_controller_in_control(hdmi_controller_in_control),
    .pixel_ppu_in_control(pixel_ppu_in_control),
    .wre_pulse_from_mapper(wre_pulse_from_mapper),
    .wre_pulse_from_pixel_ppu(wre_pulse_from_pixel_ppu),
    .wre_pulse_from_hdmi_controller(wre_pulse_from_hdmi_controller),
    .request_to_do_op_in_sdram(req__op_in_sdram),
    .request_to_do_op_in_sdram_ack(req_op_in_sdram_ack),
    .addr_control_sdram_to_process(addr_control_sdram_to_process),
    .din_control_sdram_to_process(din_control_sdram_to_process)
);

reg busy_intern;


reg  [3:0]  state;
reg  [3:0]  state_prev;
reg  [7:0]  time_that_stage_hold;



wire  [1:0]  op;
wire  [5:0]  amount_of_data_in_first_row_minus_1;
wire  [5:0]  amount_of_data_in_second_row_minus_1;
wire         op_will_hapen_in_two_rows;
wire  [20:0] addr_to_start_op_in_ram_first_row;
wire  [20:0] addr_to_start_op_in_ram_second_row;
define_signals_to_do_ops_in_sdram define_signals_to_do_ops_in_sdram_ins(

    .din_control_sdram(din_control_sdram_to_process),
    .op(op),
    .op_will_hapen_in_two_rows(op_will_hapen_in_two_rows),
    .amount_of_data_in_first_row_minus_1(amount_of_data_in_first_row_minus_1),
    .amount_of_data_in_second_row_minus_1(amount_of_data_in_second_row_minus_1),
    .addr_to_start_op_in_ram_first_row(addr_to_start_op_in_ram_first_row),
    .addr_to_start_op_in_ram_second_row(addr_to_start_op_in_ram_second_row)
);







assign busy=busy_intern |req__op_in_sdram;
wire sync__state=state_prev==state;

always @(posedge clk) begin
    if(!rst_n) begin 
        time_that_stage_hold<=8'h00;
        state_prev<=STATE_BOOTING;
    end
    else begin
        if(sync__state) begin
            if(time_that_stage_hold<8'hff) begin
                time_that_stage_hold<=time_that_stage_hold+8'h01;
            end
        end
        else begin
            time_that_stage_hold<=8'h00;
        end
        state_prev<=state;
    end
end






reg  [31:0] rd_data_r__mapper [64];
reg  [31:0] rd_data_r__pixel_ppu [64];
reg  [31:0] rd_data_r__hdmi_controller [64];

reg  [5:0] point_to___rd_data_r;


reg  [31:0] wr_data_r__mapper [64];
reg  [31:0] wr_data_r__pixel_ppu [64];
reg  [31:0] wr_data_r__hdmi_controller [64];
reg  [5:0] point_to___wr_data_r;


wire addr_control_sdram__mapper____in_region_to_write_in__wr_data_r;
assign addr_control_sdram__mapper____in_region_to_write_in__wr_data_r           = addr_control_sdram__mapper[21:13]==9'b100000001;
wire addr_control_sdram__pixel_ppu____in_region_to_write_in__wr_data_r;
assign addr_control_sdram__pixel_ppu____in_region_to_write_in__wr_data_r        = addr_control_sdram__pixel_ppu[21:13]==9'b100000001;
wire addr_control_sdram__hdmi_controller____in_region_to_write_in__wr_data_r;
assign addr_control_sdram__hdmi_controller____in_region_to_write_in__wr_data_r  = addr_control_sdram__hdmi_controller[21:13]==9'b100000001;

always @(posedge clk) begin
    if(addr_control_sdram__mapper____in_region_to_write_in__wr_data_r && wre_pulse_from_mapper) begin
        wr_data_r__mapper[addr_control_sdram__mapper[5:0]]<=din_control_sdram__mapper;
    end
    if(addr_control_sdram__pixel_ppu____in_region_to_write_in__wr_data_r ) begin
        wr_data_r__pixel_ppu[addr_control_sdram__pixel_ppu[5:0]]<=din_control_sdram__pixel_ppu;
    end
    if(addr_control_sdram__hdmi_controller____in_region_to_write_in__wr_data_r ) begin
        wr_data_r__hdmi_controller[addr_control_sdram__hdmi_controller[5:0]]<=din_control_sdram__hdmi_controller;
    end
end



localparam addr_to_get_busy              =   22'b1000000000000000000001;
localparam how_many_to_write             =   22'b1000000000000000000011;
localparam addr_to_get_datalen           =   22'b1000000000000000001010;
localparam get_din                       =   22'b1000000000000000001100;
localparam get_op_happen_in_two_rows     =   22'b1000000000000000001101;
localparam get_end_op                    =   22'b1000000000000000001111;
localparam get_amount_of_data_in_first_r =   22'b1000000000000000010000;
localparam get_amount_of_data_in_secon_r =   22'b1000000000000000010001;

always @(posedge clk) begin
    if(addr_control_sdram__pixel_ppu[21]==1'b0) begin
        dout_control_sdram__pixel_ppu<= rd_data_r__pixel_ppu[addr_control_sdram__pixel_ppu[5:0]]; 
    end
    if(addr_control_sdram__hdmi_controller[21]==1'b0) begin
        dout_control_sdram__hdmi_controller<= rd_data_r__hdmi_controller[addr_control_sdram__hdmi_controller[5:0]]; 
    end
    if(addr_control_sdram__mapper[21]==1'b0) begin
        dout_control_sdram__mapper<= rd_data_r__mapper[addr_control_sdram__mapper[5:0]]; 
    end
    else if(addr_control_sdram__mapper==addr_to_get_busy) begin
        dout_control_sdram__mapper<=busy_intern |req__op_in_sdram;
    end
    else if (addr_control_sdram__mapper==get_op_happen_in_two_rows) begin
        dout_control_sdram__mapper<=op_will_hapen_in_two_rows;
    end
    else if (addr_control_sdram__mapper ==get_amount_of_data_in_first_r) begin
        dout_control_sdram__mapper<=amount_of_data_in_first_row_minus_1;
    end
    else if (addr_control_sdram__mapper ==get_amount_of_data_in_secon_r) begin
        dout_control_sdram__mapper<=amount_of_data_in_second_row_minus_1;
    end
    else begin
        dout_control_sdram__mapper<=32'h00000000;
    end
end




reg  [11:0] count_to_refresh_ram;
wire [1:0]  w_bank;
wire [10:0] w_line;
wire [7:0]  w_col;
reg  processing_first_row;
assign w_col  = processing_first_row ? 
                addr_to_start_op_in_ram_first_row[7:0] : addr_to_start_op_in_ram_second_row[7:0];   
assign w_line = processing_first_row ? 
                addr_to_start_op_in_ram_first_row[18:8]:  addr_to_start_op_in_ram_second_row[18:8];  
assign w_bank = processing_first_row ? 
                addr_to_start_op_in_ram_first_row[20:19] : addr_to_start_op_in_ram_second_row[20:19];

reg  [5:0]  amount_of_data_processed_in_the_row;
wire [5:0]  amount_of_data_to_process_in_the_row_minus_1=  processing_first_row?
     amount_of_data_in_first_row_minus_1: amount_of_data_in_second_row_minus_1;

     
wire [31:0] current_wr_data =
            mapper_in_control          ?    wr_data_r__mapper[point_to___wr_data_r] :
            hdmi_controller_in_control ?    wr_data_r__hdmi_controller[point_to___wr_data_r] :
                                            wr_data_r__pixel_ppu[point_to___wr_data_r];
always @(posedge clk) begin
    if(!rst_n) begin
        busy_intern<=1'b1;
        I_sdrc_cmd_en <= 1'b0;
        I_sdrc_cmd <= CMD_NOP;
        I_sdrc_precharge_ctrl <= 1'b1;
        I_sdram_power_down <= 0;
        I_sdram_selfrefresh <= 0;
        I_sdrc_addr <= 0;
        I_sdrc_dqm <= 4'b0000;
        I_sdrc_data <= 0;
        I_sdrc_data_len <= 8'h04;
        state<=STATE_BOOTING;
        processing_first_row<=1'b0;
        point_to___rd_data_r<=6'b000000;
        point_to___wr_data_r<=6'b000000;
        first_write_finished_in_burst<=1'b0;
        count_to_refresh_ram<=12'h000;
        req_op_in_sdram_ack<=1'b0;
    end
    else begin
        if(count_to_refresh_ram>=12'h39b && state==STATE_IDLE)
            count_to_refresh_ram<=12'h000;
        else
            count_to_refresh_ram<=count_to_refresh_ram+12'h001;
        case(state)
            default: state<=STATE_BOOTING;
            STATE_BOOTING: begin
                if (O_sdrc_init_done) begin
                    state<=STATE_IDLE;
                    busy_intern<=1'b0; 
                end
                else begin
                    busy_intern<=1'b1; 
                end
                req_op_in_sdram_ack<=1'b0;

            end
            STATE_IDLE: begin     
                req_op_in_sdram_ack<=1'b0;
                if(req__op_in_sdram) begin
                    point_to___rd_data_r<=6'b000000;
                    point_to___wr_data_r<=6'b000000;
                    I_sdrc_addr <= {w_bank,w_line,8'h0};
                    I_sdrc_data_len <= {2'b00,amount_of_data_to_process_in_the_row_minus_1};
                    I_sdrc_cmd <= CMD_ACTIVATE;
                    I_sdrc_cmd_en <= 1'b1;
                    if(op==op_read_burst) begin
                        state<=STATE_PREPARE_READ;
                    end
                    else if(op==op_write_burst) begin
                        state<=STATE_PREPATE_WRITE;
                    end
                    busy_intern<=1'b1; 
                    amount_of_data_processed_in_the_row<=6'b000000;
                    processing_first_row<=1'b1;
                end
                else begin
                    busy_intern<=1'b0;
                    if(count_to_refresh_ram>=12'h39b)begin
                        state<=STATE_REFRESH_P1;
                    end
                end
            end
            STATE_PREPARE_READ: begin
                if(O_sdrc_cmd_ack) begin
                    I_sdrc_cmd <= CMD_READ;
                    I_sdrc_cmd_en <= 1'b1;
                    I_sdrc_addr <={w_bank,w_line,w_col};
                    I_sdrc_data_len <=  {2'b00,amount_of_data_to_process_in_the_row_minus_1};
                    state<=STATE_READING_DATA;
                end
                else begin
                    I_sdrc_cmd_en <= 1'b0;
                end
            end
            STATE_WAIT_READ_BEGIN: begin
                state<=STATE_READING_DATA;
            end
            STATE_READING_DATA: begin
                I_sdrc_cmd_en<=1'b0;
                if(sync__state && time_that_stage_hold>=3) begin
                    if(mapper_in_control) rd_data_r__mapper[point_to___rd_data_r] <= O_sdrc_data;
                    else if(hdmi_controller_in_control) rd_data_r__hdmi_controller[point_to___rd_data_r] <= O_sdrc_data;
                    else rd_data_r__pixel_ppu[point_to___rd_data_r] <= O_sdrc_data;                        
                    point_to___rd_data_r <= point_to___rd_data_r + 6'b000001;
                    amount_of_data_processed_in_the_row<=amount_of_data_processed_in_the_row+ 6'b000001;
                    if(amount_of_data_processed_in_the_row==amount_of_data_to_process_in_the_row_minus_1)
                        state<=STATE_FINISHING_OP_IN_ROW;
                end
            end
            STATE_PREPATE_WRITE: begin
                if(O_sdrc_cmd_ack) begin
                    I_sdrc_addr <= {w_bank,w_line,w_col};
                    I_sdrc_data_len <= {2'b00,amount_of_data_to_process_in_the_row_minus_1};
                    I_sdrc_data<=current_wr_data;
                    point_to___wr_data_r <= point_to___wr_data_r + 6'b000001;
                    I_sdrc_cmd_en <= 1'b1;
                    I_sdrc_cmd <= CMD_WRITE;
                    amount_of_data_processed_in_the_row<=amount_of_data_processed_in_the_row+ 6'b000001;
                    if(amount_of_data_processed_in_the_row==amount_of_data_to_process_in_the_row_minus_1) 
                        state<=STATE_FINISHING_OP_IN_ROW;
                    else
                        state<=STATE_WRITING_DATA;
                end
                else begin
                    I_sdrc_cmd_en <= 0;
                end
            end
            STATE_WRITING_DATA: begin
                I_sdrc_cmd_en <= 1'b0;
                I_sdrc_data<=current_wr_data;
                point_to___wr_data_r <= point_to___wr_data_r + 6'b000001;
                amount_of_data_processed_in_the_row<=amount_of_data_processed_in_the_row+ 6'b000001;
                if(amount_of_data_processed_in_the_row== amount_of_data_to_process_in_the_row_minus_1)
                    state<=STATE_FINISHING_OP_IN_ROW;
            end
            STATE_FINISHING_OP_IN_ROW: begin
                if(op_will_hapen_in_two_rows && processing_first_row) begin
                    if(time_that_stage_hold==8'h05 && sync__state)begin
                        processing_first_row<=1'b0;
                        amount_of_data_processed_in_the_row<=6'b000000;
                        I_sdrc_addr <= addr_to_start_op_in_ram_second_row;
                        I_sdrc_data_len <= {2'b00,amount_of_data_in_second_row_minus_1};
                        I_sdrc_cmd_en <= 1'b1;
                        I_sdrc_cmd <= CMD_ACTIVATE;
                        if(op==op_read_burst) begin
                            state <= STATE_PREPARE_READ;
                        end
                        else if(op==op_write_burst) begin
                            state <= STATE_PREPATE_WRITE;
                        end
                    end
                    else begin
                        I_sdrc_cmd_en<=1'b0;
                    end
                end
                else  begin 
                    req_op_in_sdram_ack<=1'b1;
                    if(time_that_stage_hold==8'h05 && sync__state) begin
                        I_sdrc_cmd_en<=1'b0;
                        state <= STATE_IDLE;
                        busy_intern<=1'b0;
                        I_sdrc_cmd<=CMD_NOP;
                        processing_first_row<=1'b1;
                    end
                end
            end
            STATE_REFRESH_P1: begin
                if(sync__state==1'b0) begin
                    I_sdrc_cmd <= CMD_REFRESH;
                    I_sdrc_cmd_en<=1'b1;
                end
                else if(sync__state) begin
                    I_sdrc_cmd_en<=1'b0;
                end
                if(sync__state && O_sdrc_cmd_ack==1'b1) begin
                    state<=STATE_IDLE;
                    processing_first_row<=1'b1;
                end
            end
        endcase
    end
end
endmodule
```
###control_sdram_access.v
```verilog
module control_sdram_access(
    input   wire          clk,
    input   wire          rst_n,
    input   wire  [21:0]  addr_control_sdram__pixel_ppu,
    input   wire  [21:0]  addr_control_sdram__mapper,
    input   wire  [21:0]  addr_control_sdram__hdmi_controller,
    input   wire  [31:0]  din_control_sdram__pixel_ppu,
    input   wire  [31:0]  din_control_sdram__mapper,
    input   wire  [31:0]  din_control_sdram__hdmi_controller,
    input   wire          wre_control_sdram__mapper,
    input   wire          wre_control_sdram__pixel_ppu,
    input   wire          wre_control_sdram__hdmi_controller,
    output  reg   [21:0]  addr_control_sdram_to_process,
    output  reg   [31:0]  din_control_sdram_to_process,
    output  reg           mapper_in_control,
    output  reg           hdmi_controller_in_control,
    output  reg           pixel_ppu_in_control,
    output  reg           request_to_do_op_in_sdram,
    input   wire          request_to_do_op_in_sdram_ack,
    output  wire          wre_pulse_from_mapper,
    output  wire          wre_pulse_from_pixel_ppu,
    output  wire          wre_pulse_from_hdmi_controller,
    output  reg           processing_request_from__pixel_ppu,
    output  reg           processing_request_from__hdmi_controller,
    output  reg           processing_request_from__mapper
);

//`include "io_mem/control_sdram__define_special_addrs.vh"
localparam addr_to_set_op                =   22'b1000000000000000000000;


reg wre_control_sdram__mapper__prev;
reg wre_control_sdram__pixel_ppu__prev;
reg wre_control_sdram__hdmi_controller__prev;

assign wre_pulse_from_mapper=!wre_control_sdram__mapper__prev&wre_control_sdram__mapper;
assign wre_pulse_from_pixel_ppu=!wre_control_sdram__pixel_ppu__prev&wre_control_sdram__pixel_ppu;
assign wre_pulse_from_hdmi_controller=!wre_control_sdram__hdmi_controller__prev&wre_control_sdram__hdmi_controller;

reg request_to_do_op_in_sdram_ack_prev;
always @(posedge clk) begin
     if(!rst_n) begin
        wre_control_sdram__hdmi_controller__prev<=1'b0;
        wre_control_sdram__pixel_ppu__prev<=1'b0;
        wre_control_sdram__mapper__prev<=1'b0;
        request_to_do_op_in_sdram_ack_prev<=1'b0;
     end
     else begin
        wre_control_sdram__pixel_ppu__prev<=wre_control_sdram__pixel_ppu;
        wre_control_sdram__mapper__prev<=wre_control_sdram__mapper;
        wre_control_sdram__hdmi_controller__prev<=wre_control_sdram__hdmi_controller;
        request_to_do_op_in_sdram_ack_prev<=request_to_do_op_in_sdram_ack;
     end
end

reg[15:0] ret_rnd1;
rnd rnd1 ( 
    .clk(clk),
    .rst_n(rst_n),
    .seed(16'h0020),
    .ret(ret_rnd1)
);
wire [2:0] wres;
wire request_op___from__pixel_ppu;
wire request_op___from__mapper;
wire request_op___from__hdmi_controller;
assign request_op___from__pixel_ppu      = addr_to_set_op==addr_control_sdram__pixel_ppu[21:0];
assign request_op___from__mapper         = addr_to_set_op==addr_control_sdram__mapper[21:0];
assign request_op___from__hdmi_controller= addr_to_set_op==addr_control_sdram__hdmi_controller[21:0];


localparam invalid_order              = 2'b00;
localparam order_from_mapper          = 2'b01;
localparam order_from_pixel_ppu       = 2'b10;
localparam order_from_hdmi_controller = 2'b11;

assign wres={
    wre_pulse_from_mapper&request_op___from__mapper,
    wre_pulse_from_pixel_ppu&request_op___from__pixel_ppu,
    wre_pulse_from_hdmi_controller&request_op___from__hdmi_controller
}; 
reg [1:0] current_order_type_being_processed;
reg [3:0] pixel_ppu_pending_reqs;
reg [3:0] mapper_pending_reqs;
reg [3:0] hdmi_controller_pending_reqs;
wire request_to_do_op_in_sdram_ack_pulse=request_to_do_op_in_sdram_ack&& (!request_to_do_op_in_sdram_ack_prev);
always @(posedge clk) begin
    if(!rst_n) begin
        pixel_ppu_pending_reqs<=4'h0;
        mapper_pending_reqs<=4'h0;
        hdmi_controller_pending_reqs<=4'h0;
        processing_request_from__mapper<=1'b0;
        processing_request_from__pixel_ppu<=1'b0;
        processing_request_from__hdmi_controller<=1'b0;
    end
    else begin
        if(wres[2])begin
            processing_request_from__mapper<=1'b1;
            if(!(request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_mapper)) 
                mapper_pending_reqs<=mapper_pending_reqs+4'h1;
        end
        else if((request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_mapper)) begin
            mapper_pending_reqs<=mapper_pending_reqs-4'h1;
            if(mapper_pending_reqs==4'h1) begin
                processing_request_from__mapper<=1'b0;
            end
        end
        if(wres[1])begin
            processing_request_from__pixel_ppu<=1'b1;
            if(!(request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_pixel_ppu)) 
                pixel_ppu_pending_reqs<=pixel_ppu_pending_reqs+4'h1;
        end
        else if ((request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_pixel_ppu)) begin
            pixel_ppu_pending_reqs<=pixel_ppu_pending_reqs-4'h1;
            if(pixel_ppu_pending_reqs==4'h1) begin
                processing_request_from__pixel_ppu<=1'b0;
            end
        end

        if(wres[0])begin
            processing_request_from__hdmi_controller<=1'b1;
            if(!(request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_hdmi_controller)) 
                hdmi_controller_pending_reqs<=hdmi_controller_pending_reqs+4'h1;
        end
        else if((request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_hdmi_controller)) begin
            hdmi_controller_pending_reqs<=hdmi_controller_pending_reqs-4'h1;
            if(hdmi_controller_pending_reqs==4'h1) begin
                processing_request_from__hdmi_controller<=1'b0;
            end
        end
    end
end


reg  [2:0] wr_ptr_orders_req_fifo;
wire [2:0] wr_ptr_orders_req_fifo_next;
wire [2:0] wr_ptr_orders_req_fifo_next2;
assign wr_ptr_orders_req_fifo_next  = wr_ptr_orders_req_fifo + 1'b1;
assign wr_ptr_orders_req_fifo_next2 = wr_ptr_orders_req_fifo + 2'b10;
reg [2:0] rd_ptr_orders_req_fifo;

reg [1:0]  orders_req_ctrl_fifo    [0:7];
reg [31:0] din_from_orders_fifo    [0:7];
reg [21:0] addr_control_sdram_fifo [0:7];

reg [1:0] state;

always  @(posedge clk) begin
    if(!rst_n) begin
        rd_ptr_orders_req_fifo<=3'b000;
        state<=2'b00;
        current_order_type_being_processed<=invalid_order;
        mapper_in_control<=1'b0;
        hdmi_controller_in_control<=1'b0;
        pixel_ppu_in_control<=1'b0;
        request_to_do_op_in_sdram<=1'b0;
    end
    else begin
        case(state) 
        default: state<=2'b00;
        2'b00: begin
            if(rd_ptr_orders_req_fifo!=wr_ptr_orders_req_fifo) begin
                if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]==order_from_mapper) begin
                    mapper_in_control<=1'b1;
                    hdmi_controller_in_control<=1'b0;
                    pixel_ppu_in_control<=1'b0;
                end
                else if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]==order_from_pixel_ppu) begin
                    mapper_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b0;
                    pixel_ppu_in_control<=1'b1;
                end
                else if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]==order_from_hdmi_controller) begin
                    mapper_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b1;
                    pixel_ppu_in_control<=1'b0;
                end
                if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]!=invalid_order) begin
                    addr_control_sdram_to_process<=addr_control_sdram_fifo[rd_ptr_orders_req_fifo];
                    din_control_sdram_to_process <=din_from_orders_fifo[rd_ptr_orders_req_fifo];
                    state<=2'b01;
                    request_to_do_op_in_sdram<=1'b1;
                end
                current_order_type_being_processed<=orders_req_ctrl_fifo[rd_ptr_orders_req_fifo];
            end
        end
        2'b01:begin
            if(request_to_do_op_in_sdram_ack_pulse) begin
                state<=2'b00; 
                rd_ptr_orders_req_fifo<=rd_ptr_orders_req_fifo+3'b001;
                request_to_do_op_in_sdram<=1'b0;
                hdmi_controller_in_control<=1'b0;
                mapper_in_control<=1'b0;
                pixel_ppu_in_control<=1'b0;
            end
        end
        endcase
    end
end
integer i;
always @(posedge clk) begin
    if(!rst_n) begin

        wr_ptr_orders_req_fifo<=3'b000;
        for(i = 0; i < 8; i = i + 1)
            orders_req_ctrl_fifo[i] <= invalid_order;
    end
    else begin
        
        if(wres>3'b000) begin
            if(wres==3'b001 || wres==3'b010 || wres==3'b100 ) begin
                wr_ptr_orders_req_fifo<=wr_ptr_orders_req_fifo+3'b001;
            end
            else if(wres==3'b011 || wres==3'b110 || wres==3'b101 ) begin
                wr_ptr_orders_req_fifo<=wr_ptr_orders_req_fifo+3'b010;
            end
            else begin
                wr_ptr_orders_req_fifo<=wr_ptr_orders_req_fifo+3'b011;
            end
        end
        case(wres)
            3'b001: begin
                orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]    <=order_from_hdmi_controller;
                din_from_orders_fifo[wr_ptr_orders_req_fifo]    <=din_control_sdram__hdmi_controller;
                addr_control_sdram_fifo[wr_ptr_orders_req_fifo] <=addr_control_sdram__hdmi_controller;

            end
            3'b010: begin
                orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]    <=order_from_pixel_ppu;
                din_from_orders_fifo[wr_ptr_orders_req_fifo]    <=din_control_sdram__pixel_ppu;
                addr_control_sdram_fifo[wr_ptr_orders_req_fifo] <=addr_control_sdram__pixel_ppu;
            end
            3'b011: begin
                if(ret_rnd1[0]) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_control_sdram__pixel_ppu;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]       <=addr_control_sdram__pixel_ppu;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_control_sdram__hdmi_controller;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next]  <=addr_control_sdram__hdmi_controller;

                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_control_sdram__hdmi_controller;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]       <=addr_control_sdram__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_control_sdram__pixel_ppu;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next]  <=addr_control_sdram__pixel_ppu;
                end
            end
            3'b100: begin
                orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]    <=order_from_mapper;
                din_from_orders_fifo[wr_ptr_orders_req_fifo]    <=din_control_sdram__mapper;
                addr_control_sdram_fifo[wr_ptr_orders_req_fifo] <=addr_control_sdram__mapper;
            end
            3'b101: begin
                if(ret_rnd1[0]) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_control_sdram__mapper;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]       <=addr_control_sdram__mapper;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_control_sdram__hdmi_controller;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next]  <=addr_control_sdram__hdmi_controller;
                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]         <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_control_sdram__hdmi_controller;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]      <=addr_control_sdram__hdmi_controller;

                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_control_sdram__mapper;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next] <=addr_control_sdram__mapper;
                end
            end
            3'b110: begin
                if(ret_rnd1[0]) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]         <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_control_sdram__mapper;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]      <=addr_control_sdram__mapper;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_control_sdram__pixel_ppu;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next] <=addr_control_sdram__pixel_ppu;
                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu;                    
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_control_sdram__pixel_ppu;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]       <=addr_control_sdram__pixel_ppu;
                    
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_control_sdram__mapper;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next] <=addr_control_sdram__mapper;
                end
            end
            3'b111: begin
                if(ret_rnd1[1:0]==2'b00) begin
                    if(ret_rnd1[2]==1'b0) begin
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]<=order_from_hdmi_controller;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_control_sdram__hdmi_controller;
                        addr_control_sdram_fifo[wr_ptr_orders_req_fifo]      <=addr_control_sdram__hdmi_controller;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]<=order_from_pixel_ppu;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_control_sdram__pixel_ppu;
                        addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next] <=addr_control_sdram__pixel_ppu;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]   <=order_from_mapper;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]   <=din_control_sdram__mapper;
                        addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next2] <=addr_control_sdram__mapper;
                    end
                    else begin
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu; 
                        din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_control_sdram__pixel_ppu;
                        addr_control_sdram_fifo[wr_ptr_orders_req_fifo]       <=addr_control_sdram__pixel_ppu;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_control_sdram__hdmi_controller;
                        addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next]  <=addr_control_sdram__hdmi_controller;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]    <=order_from_mapper;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]    <=din_control_sdram__mapper;
                        addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next2] <=addr_control_sdram__mapper;

                    end 
                end
                else if(ret_rnd1[1:0]==2'b01) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_control_sdram__pixel_ppu;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]       <=addr_control_sdram__pixel_ppu;

                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_control_sdram__hdmi_controller;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next]  <=addr_control_sdram__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]    <=din_control_sdram__mapper;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next2] <=addr_control_sdram__mapper;
                end
                else if(ret_rnd1[1:0]==2'b10) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_control_sdram__hdmi_controller;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]       <=addr_control_sdram__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_control_sdram__pixel_ppu;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next]  <=addr_control_sdram__pixel_ppu;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]    <=din_control_sdram__mapper;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next2] <=addr_control_sdram__mapper;
                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]         <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_control_sdram__mapper;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo]      <=addr_control_sdram__mapper;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_control_sdram__hdmi_controller;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next] <=addr_control_sdram__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]   <= order_from_pixel_ppu ;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]   <=din_control_sdram__pixel_ppu;
                    addr_control_sdram_fifo[wr_ptr_orders_req_fifo_next2]<=addr_control_sdram__pixel_ppu;
                end
            end
        endcase
    end
end
endmodule
```
###define_signals_to_do_ops_in_sdram.v
```verilog
module define_signals_to_do_ops_in_sdram(
    input   wire  [31:0]  din_control_sdram,
    output  wire  [1:0]   op,
    output  wire          op_will_hapen_in_two_rows,
    output  wire  [5:0]   amount_of_data_in_first_row_minus_1,
    output  wire  [5:0]   amount_of_data_in_second_row_minus_1,
    output  wire   [20:0] addr_to_start_op_in_ram_first_row,
    output  wire   [20:0] addr_to_start_op_in_ram_second_row
);


assign      op=din_control_sdram[1:0];
wire [6:0]  data_len=din_control_sdram[8:2];
wire [20:0] addr_to_start_op_in_ram= din_control_sdram[29:9];
wire [20:0] addr_to_end_op_in_ram=addr_to_start_op_in_ram+{14'b0,data_len}-21'd1;
assign op_will_hapen_in_two_rows=addr_to_end_op_in_ram[8]!=addr_to_start_op_in_ram[8];

wire [6:0]  amount_of_data_to_proc_in_first_row= op_will_hapen_in_two_rows ? 
            ({addr_to_start_op_in_ram[20:8],8'hff}-addr_to_start_op_in_ram)+1'b1 :
            data_len;
wire [6:0]  amount_of_data_to_proc_in_second_row= op_will_hapen_in_two_rows ? 
            data_len-amount_of_data_to_proc_in_first_row :
            7'b000000;
assign amount_of_data_in_first_row_minus_1  = amount_of_data_to_proc_in_first_row-7'b0000001;
assign amount_of_data_in_second_row_minus_1 = amount_of_data_to_proc_in_second_row-7'b0000001;

assign addr_to_start_op_in_ram_first_row= addr_to_start_op_in_ram;
assign addr_to_start_op_in_ram_second_row={addr_to_end_op_in_ram[20:8],8'h00};

endmodule
```
###main_memory.v
```verilog
module MAIN_MEMORY (
    output wire [31:0] dout_wire,
    input  wire       clk,
    input  wire       oce,
    input  wire       ce,
    input  wire       reset,
    input  wire       wre,
    input  wire [11:0] ad,
    input  wire [31:0] din
);


    `ifdef SIM  
    reg [31:0] mem [0:4095];
    reg [11:0] addr_reg;
    reg [31:0] dout;
    assign dout_wire=dout;
    initial begin
        $display("Loading memory from mem.hex...");
        $readmemh("../tests/test_c/bubble_sort.hex", mem);
    end
    `endif

    `ifdef SIM 
    always @(posedge clk) begin
        if (reset) begin
            dout <= 32'b0;
        end else if (ce) begin

            // escrita
            if (wre) begin
                mem[ad] <= din;
            end

            // registra endereço (comportamento BRAM)
            addr_reg <= ad;

            // leitura registrada (1 ciclo de latência)
            if (oce) begin
                dout <= mem[addr_reg];
            end
        end
    end
    `endif

    `ifndef SIM 
    Gowin_SP_SRAM_MAIN_MEMORY main_memory (
        .dout(dout_wire), 
        .clk(clk), 
        .oce(oce),
        .ce(ce),
        .reset(reset),
        .wre(wre),
        .ad(ad),
        .din(din)
    );
    `endif

endmodule
```
###mapper.v
```verilog
module mapper(
    output wire [11:0] addr_main_memory,
    output wire [31:0] din_main_memory,
    input  wire [31:0] dout_main_memory,
    output wire        wre_main_memory,

    output wire [5:0]  addr_led_memory,
    output wire [31:0] din_led_memory,
    input  wire [31:0] dout_led_memory,
    output wire        wre_led_memory,

    output wire [5:0]  addr_control_cpu_memory,
    output wire [31:0] din_control_cpu_memory,
    input  wire [31:0] dout_control_cpu_memory,
    output wire        wre_control_cpu_memory,


    output wire [21:0]  addr_control_sdram,
    output wire [31:0]  din_control_sdram,
    input  wire [31:0]  dout_control_sdram,
    output wire         wre_control_sdram,


    input  wire [31:0] addr_mapper,
    input  wire [31:0] din_mapper,
    output wire [31:0] dout_mapper,
    input  wire        wre_mapper
);

//
// Decodificação de regiões
//
wire sel_main    = addr_mapper[29];
wire sel_sdram   = ~sel_main && addr_mapper[22];
wire sel_control = ~sel_main && ~sel_sdram && addr_mapper[8];
wire sel_led     = ~sel_main && ~sel_sdram && ~sel_control && addr_mapper[6];

//
// MAIN MEMORY
//
assign addr_main_memory = addr_mapper[11:0];
assign din_main_memory  = din_mapper;
assign wre_main_memory  = sel_main ? wre_mapper : 1'b0;

//
// CONTROL CPU MEMORY
//
assign addr_control_cpu_memory = addr_mapper[5:0];
assign din_control_cpu_memory  = din_mapper;
assign wre_control_cpu_memory  = sel_control ? wre_mapper : 1'b0;

//
// LED MEMORY
//
assign addr_led_memory = addr_mapper[5:0];
assign din_led_memory  = din_mapper;
assign wre_led_memory  = sel_led ? wre_mapper : 1'b0;

assign addr_control_sdram = addr_mapper[21:0];
assign din_control_sdram  = din_mapper;
assign wre_control_sdram  = sel_sdram ? wre_mapper : 1'b0;


//
// MUX de leitura
//
assign dout_mapper =
    sel_main    ? dout_main_memory :
    sel_control ? dout_control_cpu_memory :
    sel_led     ? dout_led_memory :
    sel_sdram   ? dout_control_sdram :
    32'h00000000;


endmodule
```
###recvdata.v
```verilog
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
```
###senddata.v
```verilog
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
```

