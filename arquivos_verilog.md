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
wire wre_pulse_from_pixel_hdmi_controller;

control_sdram_access control_sdram_access_ins(
    .clk(clk),
    .rst_n(rst_n),
    .wre_control_sdram__mapper(wre_control_sdram__mapper),
    .wre_control_sdram__pixel_ppu(wre_control_sdram__pixel_ppu),
    .wre_control_sdram__hdmi_controller(wre_control_sdram__hdmi_controller),
    .mapper_in_control(mapper_in_control),
    .hdmi_controller_in_control(hdmi_controller_in_control),
    .pixel_ppu_in_control(pixel_ppu_in_control),
    .wre_pulse(wre_pulse),
    .wre_pulse_from_mapper_out(wre_pulse_from_mapper),
    .wre_pulse_from_pixel_ppu_out(wre_pulse_from_pixel_ppu),
    .wre_pulse_from_pixel_hdmi_controller_out(wre_pulse_from_pixel_hdmi_controller)
);

reg busy_intern;


reg  [3:0]  state;
reg  [3:0]  state_prev;
reg  [7:0]  time_that_stage_hold;



wire  [31:0] din_control_sdram___latched;
wire  [1:0]  op_latched;
wire  [5:0]  amount_of_data_in_first_row___latched;
wire  [5:0]  amount_of_data_in_second_row___latched;
wire         op_will_hapen_in_two_rows__latched;
wire         request_op_in_ram; 
wire  [20:0] addr_to_start_op_in_ram_first_row___latched;
wire  [20:0] addr_to_start_op_in_ram_second_row___latched;
reg         request_op_in_ram_received;
define_signals_to_do_ops_in_sdram define_signals_to_do_ops_in_sdram_ins(
    .clk(clk),
    .rst_n(rst_n),
    .wre_pulse(wre_pulse),
    .addr_control_sdram(addr_control_sdram),
    .din_control_sdram(din_control_sdram),
    .op_latched(op_latched),
    .op_will_hapen_in_two_rows__latched(op_will_hapen_in_two_rows__latched),
    .amount_of_data_in_first_row___latched(amount_of_data_in_first_row___latched),
    .amount_of_data_in_second_row___latched(amount_of_data_in_second_row___latched),
    .request_op_in_ram(request_op_in_ram),
    .request_op_in_ram_received(request_op_in_ram_received),
    .addr_to_start_op_in_ram_first_row___latched(addr_to_start_op_in_ram_first_row___latched),
    .addr_to_start_op_in_ram_second_row___latched(addr_to_start_op_in_ram_second_row___latched)
);


reg [11:0] count_to_refresh_ram;





assign busy=busy_intern |request_op_in_ram;
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
        dout_control_sdram__mapper<=busy_intern |request_op_in_ram;
    end
    else if (addr_control_sdram__mapper==get_op_happen_in_two_rows) begin
        dout_control_sdram__mapper<=op_will_hapen_in_two_rows__latched;
    end
    else if (addr_control_sdram__mapper ==get_amount_of_data_in_first_r) begin
        dout_control_sdram__mapper<=amount_of_data_in_first_row___latched;
    end
    else if (addr_control_sdram__mapper ==get_amount_of_data_in_secon_r) begin
        dout_control_sdram__mapper<=amount_of_data_in_second_row___latched;
    end
    else begin
        dout_control_sdram__mapper<=32'h00000000;
    end
end





wire [1:0]  w_bank;
wire [10:0] w_line;
wire [7:0]  w_col;
reg  processing_first_row;
assign w_col  = processing_first_row ? 
                addr_to_start_op_in_ram_first_row___latched[7:0] : addr_to_start_op_in_ram_second_row___latched[7:0];   
assign w_line = processing_first_row ? 
                addr_to_start_op_in_ram_first_row___latched[18:8]:  addr_to_start_op_in_ram_second_row___latched[18:8];  
assign w_bank = processing_first_row ? 
                addr_to_start_op_in_ram_first_row___latched[20:19] : addr_to_start_op_in_ram_second_row___latched[20:19];
reg         first_write_finished_in_burst;
reg  [5:0]  amount_of_data_processed_in_the_row;
wire [5:0]  amount_of_data_to_process_in_the_row=  processing_first_row?
     amount_of_data_in_first_row___latched: amount_of_data_in_second_row___latched;

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
        request_op_in_ram_received<=1'b0;
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
                request_op_in_ram_received<=1'b0;
            end
            STATE_IDLE: begin     
                if(request_op_in_ram) begin
                    point_to___rd_data_r<=6'b000000;
                    point_to___wr_data_r<=6'b000000;
                    I_sdrc_addr <= {w_bank,w_line,8'h0};
                    I_sdrc_data_len <= {2'b00,amount_of_data_to_process_in_the_row};
                    I_sdrc_cmd <= CMD_ACTIVATE;
                    I_sdrc_cmd_en <= 1'b1;
                    if(op_latched==op_read_burst) begin
                        state<=STATE_PREPARE_READ;
                    end
                    else if(op_latched==op_write_burst) begin
                        state<=STATE_PREPATE_WRITE;
                    end
                    busy_intern<=1'b1; 
                    amount_of_data_processed_in_the_row<=6'b000000;
                    processing_first_row<=1'b1;
                    first_write_finished_in_burst<=1'b0;
                    request_op_in_ram_received<=1'b1;
                end
                else begin
                    busy_intern<=1'b0;
                    if(count_to_refresh_ram>=12'h39b)begin
                        state<=STATE_REFRESH_P1;
                    end
                    request_op_in_ram_received<=1'b0;
                end
            end
            STATE_PREPARE_READ: begin
                request_op_in_ram_received<=1'b0;
                if(O_sdrc_cmd_ack) begin
                    I_sdrc_cmd <= CMD_READ;
                    I_sdrc_cmd_en <= 1'b1;
                    I_sdrc_addr <={w_bank,w_line,w_col};
                    I_sdrc_data_len <=  {2'b00,amount_of_data_to_process_in_the_row};
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
                    if(amount_of_data_processed_in_the_row==amount_of_data_to_process_in_the_row)
                        state<=STATE_FINISHING_OP_IN_ROW;
                end
            end
            STATE_PREPATE_WRITE: begin
                request_op_in_ram_received<=1'b0;
                if(O_sdrc_cmd_ack) begin
                    I_sdrc_addr <= {w_bank,w_line,w_col};
                    I_sdrc_data_len <= {2'b00,amount_of_data_to_process_in_the_row};
                    if(mapper_in_control)               I_sdrc_data<= wr_data_r__mapper[point_to___wr_data_r];
                    else if(hdmi_controller_in_control) I_sdrc_data<= wr_data_r__hdmi_controller[point_to___wr_data_r];
                    else                                I_sdrc_data<= wr_data_r__pixel_ppu[point_to___wr_data_r];
                    point_to___wr_data_r <= point_to___wr_data_r + 6'b000001;
                    I_sdrc_cmd_en <= 1'b1;
                    I_sdrc_cmd <= CMD_WRITE;
                    amount_of_data_processed_in_the_row<=amount_of_data_processed_in_the_row+ 6'b000001;
                    if(amount_of_data_processed_in_the_row==amount_of_data_to_process_in_the_row) 
                        state<=STATE_FINISHING_OP_IN_ROW;
                    else
                        state<=STATE_WRITING_DATA;
                    first_write_finished_in_burst<=1'b0;
                end
                else begin
                    I_sdrc_cmd_en <= 0;
                end
            end
            STATE_WRITING_DATA: begin
                I_sdrc_cmd_en <= 1'b0;
                first_write_finished_in_burst<=1'b1;                    
                if(mapper_in_control)               I_sdrc_data<= wr_data_r__mapper[point_to___wr_data_r];
                else if(hdmi_controller_in_control) I_sdrc_data<= wr_data_r__hdmi_controller[point_to___wr_data_r];
                else                                I_sdrc_data<= wr_data_r__pixel_ppu[point_to___wr_data_r];
                point_to___wr_data_r <= point_to___wr_data_r + 6'b000001;
                amount_of_data_processed_in_the_row<=amount_of_data_processed_in_the_row+ 6'b000001;
                if(amount_of_data_processed_in_the_row== amount_of_data_to_process_in_the_row)
                    state<=STATE_FINISHING_OP_IN_ROW;
            end
            STATE_FINISHING_OP_IN_ROW: begin
                if(op_will_hapen_in_two_rows__latched && processing_first_row) begin
                    if(time_that_stage_hold==8'h05 && sync__state)begin
                        processing_first_row<=1'b0;
                        amount_of_data_processed_in_the_row<=6'b000000;
                        I_sdrc_addr <= addr_to_start_op_in_ram_second_row___latched;
                        I_sdrc_data_len <= {2'b00,amount_of_data_in_second_row___latched};
                        I_sdrc_cmd_en <= 1'b1;
                        I_sdrc_cmd <= CMD_ACTIVATE;
                        first_write_finished_in_burst<=1'b0;
                        if(op_latched==op_read_burst) begin
                            state <= STATE_PREPARE_READ;
                        end
                        else if(op_latched==op_write_burst) begin
                            //if(addr_to_start_op_in_ram_first_row___latched[7:0]==8'hff)
                            //point_to___wr_data_r <= point_to___wr_data_r - 6'b000010;
                            state <= STATE_PREPATE_WRITE;
                        end
                    end
                    else begin
                        I_sdrc_cmd_en<=1'b0;
                    end
                end
                else  begin 
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

    input   wire          wre_control_sdram__mapper,
    input   wire          wre_control_sdram__pixel_ppu,
    input   wire          wre_control_sdram__hdmi_controller,
    output  reg           mapper_in_control,
    output  reg           hdmi_controller_in_control,
    output  reg           pixel_ppu_in_control,
    output  reg           wre_pulse,
    output  wire          wre_pulse_from_mapper_out,
    output  wire          wre_pulse_from_pixel_ppu_out,
    output  wire          wre_pulse_from_pixel_hdmi_controller_out

);

//`include "io_mem/control_sdram__define_special_addrs.vh"
localparam addr_to_set_op                =   22'b1000000000000000000000;

wire  wre_pulse_from_mapper;
wire  wre_pulse_from_pixel_ppu;
wire  wre_pulse_from_pixel_hdmi_controller;
assign wre_pulse_from_mapper_out=wre_pulse_from_mapper;
assign wre_pulse_from_pixel_ppu_out=wre_pulse_from_pixel_ppu;
assign wre_pulse_from_pixel_hdmi_controller_out=wre_pulse_from_pixel_hdmi_controller;
wire wre_control_sdram;
assign wre_control_sdram=wre_control_sdram__mapper| wre_control_sdram__pixel_ppu | wre_control_sdram__hdmi_controller;
reg wre_control_sdram__mapper__prev;
reg wre_control_sdram__pixel_ppu__prev;
reg wre_control_sdram__hdmi_controller__prev;


assign wre_pulse_from_mapper=!wre_control_sdram__mapper__prev&wre_control_sdram__mapper;
assign wre_pulse_from_pixel_ppu=!wre_control_sdram__pixel_ppu__prev&wre_control_sdram__pixel_ppu;
assign wre_pulse_from_pixel_hdmi_controller=!wre_control_sdram__hdmi_controller__prev&wre_control_sdram__hdmi_controller;
reg [31:0] count_debug;
reg wre_control_sdram_prev;
always @(posedge clk) begin
     if(!rst_n) begin
        wre_control_sdram_prev<=1'b0;
        wre_control_sdram__hdmi_controller__prev<=1'b0;
        wre_control_sdram__pixel_ppu__prev<=1'b0;
        wre_control_sdram__mapper__prev<=1'b0;
     end
     else begin
        wre_control_sdram_prev<=wre_control_sdram;
        wre_control_sdram__pixel_ppu__prev<=wre_control_sdram__pixel_ppu;
        wre_control_sdram__mapper__prev<=wre_control_sdram__mapper;
        wre_control_sdram__hdmi_controller__prev<=wre_control_sdram__hdmi_controller;
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
assign request_op___from__pixel_ppu      = addr_to_set_op==addr_control_sdram__pixel_ppu;
assign request_op___from__mapper         = addr_to_set_op==addr_control_sdram__mapper;
assign request_op___from__hdmi_controller= addr_to_set_op==addr_control_sdram__hdmi_controller;

assign wres={wre_pulse_from_mapper&request_op___from__mapper,wre_pulse_from_pixel_ppu&request_op___from__pixel_ppu, wre_pulse_from_pixel_hdmi_controller&request_op___from__hdmi_controller}; 
always @(posedge clk) begin
    if(!rst_n) begin
        mapper_in_control<=1'b0;
        hdmi_controller_in_control<=1'b0;
        pixel_ppu_in_control<=1'b0;
        wre_pulse<=1'b0;
    end
    else if(wre_control_sdram==1'b1 & wre_control_sdram_prev==1'b0) begin
        if(wres != 3'b000) begin
            wre_pulse<=1'b1;
        end
        case(wres)
            3'b000: begin
                mapper_in_control<=1'b0;
                pixel_ppu_in_control<=1'b0;
                hdmi_controller_in_control<=1'b0;
            end
            3'b001: begin
                mapper_in_control<=1'b0;
                pixel_ppu_in_control<=1'b0;
                hdmi_controller_in_control<=1'b1;
            end
            3'b010: begin
                mapper_in_control<=1'b0;
                pixel_ppu_in_control<=1'b1;
                hdmi_controller_in_control<=1'b0;
            end
            3'b011: begin
                mapper_in_control<=1'b0;
                if(ret_rnd1[0]) begin
                    pixel_ppu_in_control<=1'b1;
                    hdmi_controller_in_control<=1'b0;
                end
                else begin
                    pixel_ppu_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b1;
                end
            end
            3'b100: begin
                mapper_in_control<=1'b1;
                pixel_ppu_in_control<=1'b0;
                hdmi_controller_in_control<=1'b0;
            end
            3'b101: begin
                pixel_ppu_in_control<=1'b0;
                if(ret_rnd1[0]) begin
                    mapper_in_control<=1'b1;
                    hdmi_controller_in_control<=1'b0;
                end
                else begin
                    mapper_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b1;
                end
            end
            3'b110: begin
                if(ret_rnd1[0]) begin
                    mapper_in_control<=1'b1;
                    pixel_ppu_in_control<=1'b0;
                end
                else begin
                    mapper_in_control<=1'b0;
                    pixel_ppu_in_control<=1'b1;
                end
                hdmi_controller_in_control<=1'b0;
            end
            3'b111: begin
                if(ret_rnd1[1:0]==2'b00) begin
                    if(ret_rnd1[2]==1'b0) begin
                        mapper_in_control<=1'b0;
                        pixel_ppu_in_control<=1'b0;
                        hdmi_controller_in_control<=1'b1;
                    end
                    else begin
                        mapper_in_control<=1'b0;
                        pixel_ppu_in_control<=1'b1;
                        hdmi_controller_in_control<=1'b0;
                    end 
                end
                else if(ret_rnd1[1:0]==2'b01) begin
                    mapper_in_control<=1'b0;
                    pixel_ppu_in_control<=1'b1;
                    hdmi_controller_in_control<=1'b0;
                end
                else if(ret_rnd1[1:0]==2'b10) begin
                    mapper_in_control<=1'b0;
                    pixel_ppu_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b1;
                end
                else begin
                    mapper_in_control<=1'b1;
                    pixel_ppu_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b0;
                end
            end
        endcase
    end
    else begin
        wre_pulse<=1'b0;
    end
end
endmodule
```
###control_sdram__access_signals.vh
```verilog



always @(posedge clk) begin
    if(addr_control_sdram__mapper[21]==1'b0) begin
        dout_control_sdram<= rd_data_r[addr_control_sdram__mapper[5:0]]; 
    end
    else if(addr_control_sdram__mapper==addr_to_get_busy) begin
        dout_control_sdram<=busy_intern |access_ram;
    end
    else if (addr_control_sdram__mapper==get_op_happen_in_two_rows) begin
        dout_control_sdram<=op_will_hapen_in_two_rows__latched;
    end
    else if (addr_control_sdram__mapper ==get_amount_of_data_in_first_r) begin
        dout_control_sdram<=amount_of_data_in_first_row___latched;
    end
    else if (addr_control_sdram__mapper ==get_amount_of_data_in_secon_r) begin
        dout_control_sdram<=amount_of_data_in_second_row___latched;
    end
    else begin
        dout_control_sdram<=32'h00000000;
    end
end

```
###control_sdram__define_special_addrs.vh
```verilog
`ifndef control_sdram__access_signals
`define control_sdram__access_signals
localparam addr_to_set_op                =   22'b1000000000000000000000;



localparam addr_to_get_busy              =   22'b1000000000000000000001;
localparam how_many_to_write             =   22'b1000000000000000000011;
localparam addr_to_get_datalen           =   22'b1000000000000000001010;
localparam get_din                       =   22'b1000000000000000001100;
localparam get_op_happen_in_two_rows     =   22'b1000000000000000001101;
localparam get_end_op                    =   22'b1000000000000000001111;
localparam get_amount_of_data_in_first_r =   22'b1000000000000000010000;
localparam get_amount_of_data_in_secon_r =   22'b1000000000000000010001;


`endif
```
###define_signals_to_do_ops_in_sdram.v
```verilog
module define_signals_to_do_ops_in_sdram(
    input   wire          clk,
    input   wire          rst_n,
    input   wire          wre_pulse,
    input   wire  [21:0]  addr_control_sdram,
    input   wire  [31:0]  din_control_sdram,
    output  reg   [1:0]   op_latched,
    output  reg           op_will_hapen_in_two_rows__latched,
    output  reg   [5:0]   amount_of_data_in_first_row___latched,
    output  reg   [5:0]   amount_of_data_in_second_row___latched,
    output  reg           request_op_in_ram,
    output  reg   [21:0]  addr_to_start_op_in_ram_first_row___latched,
    output  reg   [21:0]  addr_to_start_op_in_ram_second_row___latched,
    input   wire          request_op_in_ram_received
);
`include "io_mem/control_sdram__define_special_addrs.vh"

wire [1:0]  op=din_control_sdram[1:0];
wire [6:0]  data_len=din_control_sdram[8:2];
wire [20:0] addr_to_start_op_in_ram= din_control_sdram[29:9];
wire [20:0] addr_to_end_op_in_ram=addr_to_start_op_in_ram+{14'b0,data_len}-1'b1;
wire op_will_hapen_in_two_rows=addr_to_end_op_in_ram[8]!=addr_to_start_op_in_ram[8];
wire [6:0]  amount_of_data_to_proc_in_first_row= op_will_hapen_in_two_rows ? 
            ({addr_to_start_op_in_ram[20:8],8'hff}-addr_to_start_op_in_ram)+1'b1 :
            data_len;
wire [6:0]  amount_of_data_to_proc_in_second_row= op_will_hapen_in_two_rows ? 
            data_len-amount_of_data_to_proc_in_first_row :
            7'b000000;


always @(posedge clk) begin
    if(!rst_n) begin
        addr_to_start_op_in_ram_first_row___latched<=21'b0;
        op_latched<=2'b0;
        op_will_hapen_in_two_rows__latched<=1'b0;
        amount_of_data_in_first_row___latched<=6'b0;
        amount_of_data_in_second_row___latched<=6'b0;
        request_op_in_ram<=1'b0;
    end
    else if(wre_pulse) begin
        if(addr_control_sdram[21:0]==addr_to_set_op && amount_of_data_to_proc_in_first_row>7'b0000000) begin
            addr_to_start_op_in_ram_first_row___latched<=addr_to_start_op_in_ram;
            addr_to_start_op_in_ram_second_row___latched<={addr_to_end_op_in_ram[20:8],8'h00};
            op_latched<=op;
            op_will_hapen_in_two_rows__latched      <=op_will_hapen_in_two_rows;
            amount_of_data_in_first_row___latched   <=(amount_of_data_to_proc_in_first_row-7'b0000001);
            amount_of_data_in_second_row___latched  <=(amount_of_data_to_proc_in_second_row-7'b0000001);
            request_op_in_ram<=1'b1;
        end
        else begin
            if(request_op_in_ram_received) begin
                request_op_in_ram<=1'b0;
            end          
        end
    end
    else if(request_op_in_ram_received) begin
        request_op_in_ram<=1'b0;
    end

end
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

