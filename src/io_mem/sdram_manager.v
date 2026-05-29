module sdram_manager(
    input   wire          clk,
    input   wire          rst_n,
    input   wire  [21:0]  addr_sdram_manager__mapper,
    input   wire  [31:0]  din_sdram_manager__mapper,
    output  reg   [31:0]  dout_sdram_manager__mapper,
    input   wire  [21:0]  addr_sdram_manager__pixel_ppu,
    input   wire  [31:0]  din_sdram_manager__pixel_ppu,
    output  reg   [31:0]  dout_sdram_manager__pixel_ppu,
    input   wire  [21:0]  addr_sdram_manager__hdmi_controller,
    input   wire  [31:0]  din_sdram_manager__hdmi_controller,
    output  reg   [31:0]  dout_sdram_manager__hdmi_controller,
    input   wire          wre_sdram_manager__mapper,
    input   wire          wre_sdram_manager__hdmi_controller,
    input   wire          wre_sdram_manager__pixel_ppu,
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
    output wire        busy,
    output wire        processing_request_from__pixel_ppu,
    output wire        processing_request_from__hdmi_controller,
    output wire        processing_request_from__mapper
);
wire mapper_in_control;
wire hdmi_controller_in_control;
wire pixel_ppu_in_control;

assign mapper_in_control__out=mapper_in_control;
assign hdmi_controller_in_control__out=hdmi_controller_in_control;
assign pixel_ppu_in_control__out=pixel_ppu_in_control;
wire  [21:0]  addr_sdram_manager = mapper_in_control          ? addr_sdram_manager__mapper :
                                   hdmi_controller_in_control ? addr_sdram_manager__hdmi_controller  :
                                   addr_sdram_manager__pixel_ppu     ;
wire  [31:0]  din_sdram_manager  = mapper_in_control          ? din_sdram_manager__mapper :
                                   hdmi_controller_in_control ? din_sdram_manager__hdmi_controller  :
                                   din_sdram_manager__pixel_ppu;




localparam
    op_read_burst  = 2'b00,
    op_write_burst = 2'b01,
    op_read        = 2'b10,
    op_write       = 2'b11;





localparam [3:0] STATE_BOOTING                              =  4'hf;
localparam [3:0] STATE_IDLE                                 =  4'h0;
localparam [3:0] STATE_PREPARE_READ                         =  4'h1;
localparam [3:0] STATE_PREPARE_WRITE                        =  4'h2;
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
wire [31:0] addr_sdram_manager_to_process;
wire [31:0] din_sdram_manager_to_process;
sdram_arbiter sdram_arbiter_ins(
    .clk(clk),
    .rst_n(rst_n),
    .addr_sdram_manager__pixel_ppu(addr_sdram_manager__pixel_ppu),
    .addr_sdram_manager__mapper(addr_sdram_manager__mapper),
    .addr_sdram_manager__hdmi_controller(addr_sdram_manager__hdmi_controller),
    .din_sdram_manager__pixel_ppu(din_sdram_manager__pixel_ppu),
    .din_sdram_manager__mapper(din_sdram_manager__mapper),
    .din_sdram_manager__hdmi_controller(din_sdram_manager__hdmi_controller),
    .wre_sdram_manager__mapper(wre_sdram_manager__mapper),
    .wre_sdram_manager__pixel_ppu(wre_sdram_manager__pixel_ppu),
    .wre_sdram_manager__hdmi_controller(wre_sdram_manager__hdmi_controller),
    .mapper_in_control(mapper_in_control),
    .hdmi_controller_in_control(hdmi_controller_in_control),
    .pixel_ppu_in_control(pixel_ppu_in_control),
    .wre_pulse_from_mapper(wre_pulse_from_mapper),
    .wre_pulse_from_pixel_ppu(wre_pulse_from_pixel_ppu),
    .wre_pulse_from_hdmi_controller(wre_pulse_from_hdmi_controller),
    .request_to_do_op_in_sdram(req__op_in_sdram),
    .request_to_do_op_in_sdram_ack(req_op_in_sdram_ack),
    .addr_sdram_manager_to_process(addr_sdram_manager_to_process),
    .din_sdram_manager_to_process(din_sdram_manager_to_process),
    .processing_request_from__pixel_ppu(processing_request_from__pixel_ppu),
    .processing_request_from__hdmi_controller(processing_request_from__hdmi_controller),
    .processing_request_from__mapper(processing_request_from__mapper)
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

    .din_sdram_manager(din_sdram_manager_to_process),
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


wire addr_sdram_manager__mapper____in_region_to_write_in__wr_data_r;
assign addr_sdram_manager__mapper____in_region_to_write_in__wr_data_r           = addr_sdram_manager__mapper[21:13]==9'b100000001;
wire addr_sdram_manager__pixel_ppu____in_region_to_write_in__wr_data_r;
assign addr_sdram_manager__pixel_ppu____in_region_to_write_in__wr_data_r        = addr_sdram_manager__pixel_ppu[21:13]==9'b100000001;
wire addr_sdram_manager__hdmi_controller____in_region_to_write_in__wr_data_r;
assign addr_sdram_manager__hdmi_controller____in_region_to_write_in__wr_data_r  = addr_sdram_manager__hdmi_controller[21:13]==9'b100000001;

always @(posedge clk) begin
    if(addr_sdram_manager__mapper____in_region_to_write_in__wr_data_r && wre_pulse_from_mapper) begin
        wr_data_r__mapper[addr_sdram_manager__mapper[5:0]]<=din_sdram_manager__mapper;
    end
    if(addr_sdram_manager__pixel_ppu____in_region_to_write_in__wr_data_r && wre_pulse_from_pixel_ppu) begin
        wr_data_r__pixel_ppu[addr_sdram_manager__pixel_ppu[5:0]]<=din_sdram_manager__pixel_ppu;
    end
    if(addr_sdram_manager__hdmi_controller____in_region_to_write_in__wr_data_r && wre_pulse_from_hdmi_controller) begin
        wr_data_r__hdmi_controller[addr_sdram_manager__hdmi_controller[5:0]]<=din_sdram_manager__hdmi_controller;
    end
end

reg processing_request_from__mapper__latch;
always @(posedge clk) begin
    if(!rst_n)
        processing_request_from__mapper__latch <=1'b0;
    else if(processing_request_from__mapper)
        processing_request_from__mapper__latch<=1'b1;
end

localparam addr_to_get_busy              =   22'b1000000000000000000001;
localparam how_many_to_write             =   22'b1000000000000000000011;
localparam addr_to_get_datalen           =   22'b1000000000000000001010;
localparam get_din                       =   22'b1000000000000000001100;
localparam get_op_happen_in_two_rows     =   22'b1000000000000000001101;
localparam get_end_op                    =   22'b1000000000000000001111;
localparam get_amount_of_data_in_first_r =   22'b1000000000000000010000;
localparam get_amount_of_data_in_secon_r =   22'b1000000000000000010001;
localparam get_proc_req_from__mapper     =   22'b1000000000000000010010;
localparam ger_proc_req_from__hdmi_ctrl  =   22'b1000000000000000010011;
localparam get_proc_req_from__pixel_ppu  =   22'b1000000000000000010100;
always @(posedge clk) begin
    if(addr_sdram_manager__pixel_ppu[21]==1'b0) begin
        dout_sdram_manager__pixel_ppu<= rd_data_r__pixel_ppu[addr_sdram_manager__pixel_ppu[5:0]]; 
    end
    if(addr_sdram_manager__hdmi_controller[21]==1'b0) begin
        dout_sdram_manager__hdmi_controller<= rd_data_r__hdmi_controller[addr_sdram_manager__hdmi_controller[5:0]]; 
    end
    if(addr_sdram_manager__mapper[21]==1'b0) begin
        dout_sdram_manager__mapper<= rd_data_r__mapper[addr_sdram_manager__mapper[5:0]]; 
    end
    else if(addr_sdram_manager__mapper==addr_to_get_busy) begin
        dout_sdram_manager__mapper<=busy_intern; //|req__op_in_sdram;
    end
    else if (addr_sdram_manager__mapper==get_op_happen_in_two_rows) begin
        dout_sdram_manager__mapper<={31'b0,op_will_hapen_in_two_rows}; ;
    end
    else if (addr_sdram_manager__mapper ==get_amount_of_data_in_first_r) begin
        dout_sdram_manager__mapper<={26'b0,amount_of_data_in_first_row_minus_1};
    end
    else if (addr_sdram_manager__mapper ==get_amount_of_data_in_secon_r) begin
        dout_sdram_manager__mapper<={26'b0,amount_of_data_in_second_row_minus_1};
    end
    else if(addr_sdram_manager__mapper==get_proc_req_from__mapper) begin
        dout_sdram_manager__mapper<={31'b0,processing_request_from__mapper__latch};
    end
    else if(addr_sdram_manager__mapper==ger_proc_req_from__hdmi_ctrl) begin
        dout_sdram_manager__mapper<={31'b0,processing_request_from__hdmi_controller};
    end
    else if(addr_sdram_manager__mapper==get_proc_req_from__pixel_ppu) begin
        dout_sdram_manager__mapper<={31'b0,processing_request_from__pixel_ppu};
    end
    else begin
        dout_sdram_manager__mapper<=32'h00000000;
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
                        state<=STATE_PREPARE_WRITE;
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
            STATE_PREPARE_WRITE: begin
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
                            state <= STATE_PREPARE_WRITE;
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