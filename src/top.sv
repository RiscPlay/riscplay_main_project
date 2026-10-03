`include "sdrc_defines.v"
//https://github.com/calint/tang-nano-20k--riscv--cache-sdram
module top (
    input              I_clk,
    output reg  [5:0]  led,
    inout       [3:0]  GPIO,
    input              I_rst           ,
    output             O_tmds_clk_p    ,
    output             O_tmds_clk_n    ,
    output      [2:0]  O_tmds_data_p   ,//{r,g,b}
    output      [2:0]  O_tmds_data_n   ,
    
    output            ds_clk2,
    input             ds_miso2,
    output            ds_mosi2,
    output            ds_cs2,

    output            ds_clk,
    input             ds_miso,
    output            ds_mosi,
    output            ds_cs,


    // "magic" port names that the Gowin EDA connects to the on-chip SDRAM
    output wire        O_sdram_clk,    // clock
    output wire        O_sdram_cke,    // clock enable
    output wire        O_sdram_cs_n,   // chip select
    output wire        O_sdram_cas_n,  // columns address select
    output wire        O_sdram_ras_n,  // row address select
    output wire        O_sdram_wen_n,  // write enable
    inout  wire [31:0] IO_sdram_dq,    // 32 bit bidirectional data bus
    output wire [10:0] O_sdram_addr,   // 11 bit multiplexed address bus
    output wire [ 1:0] O_sdram_ba,     // bank address
    output wire [ 3:0] O_sdram_dqm     // data mask (byte enable)
    
);
wire reset_cpu;
wire enable;

wire [31:0] debug_signal;
reg  [63:0] count_pulses_since_riscv_started;
always @(posedge clk) begin
    if(reset_cpu) begin
        count_pulses_since_riscv_started<=64'h0;
    end
    else if(enable) begin
            count_pulses_since_riscv_started<=count_pulses_since_riscv_started+64'h1;
    end
end

wire  [63:0] count_pulses_where_sdram_controller_is_idle;
wire  [63:0] count_pulses_where_ppu_is_idle;




wire clkout;
wire clk;
`ifdef SIM
reg lock_pll;
`endif
`ifndef SIM 
wire lock_pll;
`endif





reg n_reset_global=1'b0;
reg [3:0] count_for_reset_global=4'h0;
always @(posedge clk) begin
    if(lock_pll) begin
        if(count_for_reset_global==4'ha) begin
            n_reset_global<=1'b1;
        end
        else begin
            n_reset_global<=1'b0;
            count_for_reset_global<=count_for_reset_global+4'h1;
        end
    end
    else begin
        n_reset_global<=1'b0;
    end
end



`ifndef SIM 

wire serial_clk;

wire hdmi4_rst_n;

CLKDIV u_clkdiv
(.RESETN(hdmi4_rst_n)
,.HCLKIN(serial_clk) //clk  x5
,.CLKOUT(clk)    //clk  x1
,.CALIB (1'b1)
);
defparam u_clkdiv.DIV_MODE="5";
defparam u_clkdiv.GSREN="false";

TMDS_rPLL u_tmds_rpll
(.clkin     (I_clk     )     //input clk 
,.clkout    (serial_clk)     //output clk 
,.lock      (lock_pll  )     //output lock
);
wire        set_addr_to_frame_buffer;
wire [20:0] addr_to_frame_buffer;
wire        set_addr_to_frame_buffer__ack;
wire [20:0] fb_horizontal_offset;


wire [6:0]   n_32bits_words_processed_by_current_hdmi_request;
wire [21:0]  addr_sdram_manager__hdmi_controller;
wire [31:0]  din_sdram_manager__hdmi_controller;
wire [31:0]  dout_sdram_manager__hdmi_controller;
wire         wre_sdram_manager__hdmi_controller;
wire         processing_request_from__hdmi_controller;

wire         hdmi_ctrl_is_standby;
HDMI hdmi_inst(
    .I_clk(I_clk),
    .I_rst(I_rst),
    .O_tmds_clk_p(O_tmds_clk_p),
    .O_tmds_clk_n(O_tmds_clk_n),
    .O_tmds_data_p(O_tmds_data_p),
    .O_tmds_data_n(O_tmds_data_n),
    .pll_lock(lock_pll),
    .pix_clk(clk),
    .hdmi4_rst_n(hdmi4_rst_n),
    .serial_clk(serial_clk),
    .rst_n_paint(n_reset_global),
    .addr_sdram_manager__hdmi_controller(addr_sdram_manager__hdmi_controller),
    .din_sdram_manager__hdmi_controller(din_sdram_manager__hdmi_controller),
    .dout_sdram_manager__hdmi_controller(dout_sdram_manager__hdmi_controller),
    .wre_sdram_manager__hdmi_controller(wre_sdram_manager__hdmi_controller),
    .set_addr_to_frame_buffer(set_addr_to_frame_buffer),
    .addr_to_frame_buffer(addr_to_frame_buffer),
    .fb_horizontal_offset__input(fb_horizontal_offset),
    .set_addr_to_frame_buffer__ack(set_addr_to_frame_buffer__ack),
    .processing_request_from__hdmi_controller(processing_request_from__hdmi_controller),
    .n_32bits_words_processed_by_current_hdmi_request(n_32bits_words_processed_by_current_hdmi_request),
    .hdmi_ctrl_is_standby(hdmi_ctrl_is_standby)
);
`endif

`ifdef SIM
assign clkout=I_clk;
`endif



reg cs;
wire miso;
assign GPIO[2]=miso;
reg mosi = 1'b0;
reg sclk=1'b0;


always @(posedge clk) begin
	cs<=GPIO[0];
	mosi<=GPIO[3];
	sclk<=GPIO[1];
end




reg reset_ram=1'b1;
reg [3:0] count_for_reset=4'h0;
always @(posedge clk) begin
    if(lock_pll) begin
        if(count_for_reset==4'ha) begin
            reset_ram<=1'b0;
        end
        else begin
            reset_ram<=1'b1;
            count_for_reset<=count_for_reset+4'h1;
        end
    end
    else begin
        reset_ram<=1'b1;
    end
end





wire I_sdrc_rst_n =  !reset_ram && lock_pll;
wire I_sdrc_clk = clk;
wire I_sdram_clk = clk;
wire I_sdrc_cmd_en;
wire [2:0] I_sdrc_cmd;
wire I_sdrc_precharge_ctrl;
wire I_sdram_power_down;
wire [20:0] I_sdrc_addr;
wire [3:0] I_sdrc_dqm;
wire [31:0] I_sdrc_data;
wire [7:0] I_sdrc_data_len;
wire [31:0] O_sdrc_data;
wire O_sdrc_init_done;
wire O_sdrc_cmd_ack;

SDRAM_Controller_HS_Top sdram_controller (
    // inferred ports connecting SDRAM
    .O_sdram_clk(O_sdram_clk),
    .O_sdram_cke(O_sdram_cke),
    .O_sdram_cs_n(O_sdram_cs_n),
    .O_sdram_cas_n(O_sdram_cas_n),
    .O_sdram_ras_n(O_sdram_ras_n),
    .O_sdram_wen_n(O_sdram_wen_n),
    .O_sdram_dqm(O_sdram_dqm),
    .O_sdram_addr(O_sdram_addr),
    .O_sdram_ba(O_sdram_ba),
    .IO_sdram_dq(IO_sdram_dq),

    // interface
    .I_sdrc_rst_n(I_sdrc_rst_n),
    .I_sdrc_clk(I_sdrc_clk),
    .I_sdram_clk(I_sdram_clk),
    .I_sdrc_cmd_en(I_sdrc_cmd_en),
    .I_sdrc_cmd(I_sdrc_cmd),
    .I_sdrc_precharge_ctrl(I_sdrc_precharge_ctrl),
    .I_sdram_power_down(I_sdram_power_down),
    .I_sdram_selfrefresh(I_sdram_selfrefresh),
    .I_sdrc_addr(I_sdrc_addr),
    .I_sdrc_dqm(I_sdrc_dqm),
    .I_sdrc_data(I_sdrc_data),
    .I_sdrc_data_len(I_sdrc_data_len),
    .O_sdrc_data(O_sdrc_data),
    .O_sdrc_init_done(O_sdrc_init_done),
    .O_sdrc_cmd_ack(O_sdrc_cmd_ack)
);

wire [21:0]  addr_sdram_manager__mapper;
wire [31:0]  din_sdram_manager__mapper;
wire [31:0]  dout_sdram_manager__mapper;
wire         wre_sdram_manager__mapper;


wire  [21:0]  addr_sdram_manager__pixel_cpu;
wire  [31:0]  din_sdram_manager__pixel_cpu;
wire  [31:0]  dout_sdram_manager__pixel_cpu;
wire          wre_sdram_manager__pixel_cpu;


wire [21:0] addr_sdram_manager__pixel_ppu;
wire [31:0] din_sdram_manager__pixel_ppu;
wire [31:0] dout_sdram_manager__pixel_ppu;
wire        wre_sdram_manager__pixel_ppu;
wire        processing_request_from__pixel_ppu;
wire [6:0]  n_32bits_words_processed_by_current_pixel_ppu_request;
sdram_manager sdram_manager__ins(
    .clk(clk),
    .rst_n(n_reset_global),
    .addr_sdram_manager__mapper(addr_sdram_manager__mapper),
    .din_sdram_manager__mapper(din_sdram_manager__mapper),
    .dout_sdram_manager__mapper(dout_sdram_manager__mapper),
    .wre_sdram_manager__mapper(wre_sdram_manager__mapper),
    .addr_sdram_manager__hdmi_controller(addr_sdram_manager__hdmi_controller),
    .din_sdram_manager__hdmi_controller(din_sdram_manager__hdmi_controller),
    .dout_sdram_manager__hdmi_controller(dout_sdram_manager__hdmi_controller),
    .wre_sdram_manager__hdmi_controller(wre_sdram_manager__hdmi_controller),
    .processing_request_from__hdmi_controller(processing_request_from__hdmi_controller),
    .addr_sdram_manager__pixel_cpu(addr_sdram_manager__pixel_cpu),
    .din_sdram_manager__pixel_cpu(din_sdram_manager__pixel_cpu),
    .dout_sdram_manager__pixel_cpu(dout_sdram_manager__pixel_cpu),
    .wre_sdram_manager__pixel_cpu(wre_sdram_manager__pixel_cpu),
    .O_sdrc_init_done(O_sdrc_init_done),
    .O_sdrc_cmd_ack(O_sdrc_cmd_ack),
    .O_sdrc_data(O_sdrc_data),
    .I_sdrc_cmd_en(I_sdrc_cmd_en),
    .I_sdrc_cmd(I_sdrc_cmd),
    .I_sdrc_precharge_ctrl(I_sdrc_precharge_ctrl),
    .I_sdram_power_down(I_sdram_power_down),
    .I_sdram_selfrefresh(I_sdram_selfrefresh),
    .I_sdrc_addr(I_sdrc_addr),
    .I_sdrc_dqm(I_sdrc_dqm),
    .I_sdrc_data(I_sdrc_data),
    .I_sdrc_data_len(I_sdrc_data_len),
    .addr_sdram_manager__pixel_ppu(addr_sdram_manager__pixel_ppu),
    .din_sdram_manager__pixel_ppu(din_sdram_manager__pixel_ppu),
    .dout_sdram_manager__pixel_ppu(dout_sdram_manager__pixel_ppu),
    .wre_sdram_manager__pixel_ppu(wre_sdram_manager__pixel_ppu),
    .processing_request_from__pixel_ppu(processing_request_from__pixel_ppu),
    .hdmi_ctrl_is_standby(hdmi_ctrl_is_standby),
    //.debug_signal(debug_signal),
    .cpu_reseted(reset_cpu),
    .cpu_enabled(enable),
    .count_pulses_where_sdram_controller_is_idle(count_pulses_where_sdram_controller_is_idle),
    .n_32bits_words_processed_by_current_pixel_ppu_request(n_32bits_words_processed_by_current_pixel_ppu_request),
    .n_32bits_words_processed_by_current_hdmi_request(n_32bits_words_processed_by_current_hdmi_request)
);




wire [3:0] sel___main_memory;



wire wre_mapper;
wire [31:0] addr_mapper;
wire [31:0] din_mapper;
wire [31:0] dout_mapper;

wire          wre_led_memory;
wire [5:0]    addr_led_memory;
wire [31:0]   din_led_memory;
wire [31:0]   dout_led_memory;

wire          wre_control_cpu_memory;
wire [5:0]    addr_control_cpu_memory;
wire [31:0]   din_control_cpu_memory;
wire [31:0]   dout_control_cpu_memory;


wire [31:0] din_main_memory___recvdata0;
wire [31:0] din_main_memory___rv32im_cpu_inst;

wire wre_main_memory___rv32im_cpu_inst;
wire wre_main_memory___recvdata0;


wire [31:0] addr_main_memory___rv32im_cpu_inst;
wire [31:0] addr_main_memory___senddata0;
wire [31:0] addr_main_memory___recvdata0;

assign addr_mapper = 
    (sel___main_memory == 4'h0) ? addr_main_memory___rv32im_cpu_inst: 
    (sel___main_memory == 4'h3) ? addr_main_memory___senddata0:
    (sel___main_memory == 4'h2) ? addr_main_memory___recvdata0:
    addr_main_memory___rv32im_cpu_inst;

assign din_mapper = 
    (sel___main_memory == 4'h0) ? din_main_memory___rv32im_cpu_inst:
    (sel___main_memory == 4'h2) ? din_main_memory___recvdata0: 
    din_main_memory___rv32im_cpu_inst;

assign wre_mapper =
    (sel___main_memory == 4'h0) ?  wre_main_memory___rv32im_cpu_inst:
    (sel___main_memory == 4'h2) ?  wre_main_memory___recvdata0:
    wre_main_memory___rv32im_cpu_inst;

wire spi_comm_started;
wire spi_can_access_memory;
spi spi_ins (
    .clk(clk),
    .lock_pll(lock_pll),
    .sclk(sclk),
    .cs(cs),
    .mosi(mosi),
    .miso(miso),
    .sel___main_memory(sel___main_memory),
    .addr_main_memory___senddata0(addr_main_memory___senddata0),
    .addr_main_memory___recvdata0(addr_main_memory___recvdata0),
    .din_main_memory___recvdata0(din_main_memory___recvdata0),
    .wre_main_memory___recvdata0(wre_main_memory___recvdata0),
    .dout_mapper(dout_mapper),
    .spi_comm_started(spi_comm_started),
    .spi_can_access_memory(spi_can_access_memory)

);






wire [15:0] out___collision_stack_cpu;
wire        wre___collision_stack_cpu;
wire [15:0] input___collision_stack_cpu;
wire [9:0]  addr___collision_stack_cpu;

wire [7:0]  out_from_sprite_buffer__cpu;
wire        sprite_buffer_wre__cpu;
wire [7:0]  input_to_sprite_buffer__cpu;
wire [13:0] addr_to_sprite_buffer__cpu;


wire [63:0]  cmd_to_put_in_ppu_fifo;
wire         wr_cmd_for_ppu_fifo;
wire         processing_the_ppu_fifo_insert;

wire         ppu_cmd_fifo_is_empity;
wire [9:0]   collision_stack_size;
PPU ppu_ins(
    .clk(clk),
    .rst_n(n_reset_global),
    .addr_sdram_manager__pixel_ppu(addr_sdram_manager__pixel_ppu),
    .din_sdram_manager__pixel_ppu(din_sdram_manager__pixel_ppu),
    .dout_sdram_manager__pixel_ppu(dout_sdram_manager__pixel_ppu),
    .wre_sdram_manager__pixel_ppu(wre_sdram_manager__pixel_ppu),
    .sdram_manager_is_processing_request_from__pixel_ppu(processing_request_from__pixel_ppu),
    .n_32bits_words_processed_by_current_pixel_ppu_request(n_32bits_words_processed_by_current_pixel_ppu_request),
    .cmd_to_insert_in_fifo(cmd_to_put_in_ppu_fifo),
    .wr_cmd(wr_cmd_for_ppu_fifo),
    .processing_insert(processing_the_ppu_fifo_insert),
    .fifo_cmd_empty(ppu_cmd_fifo_is_empity),
    .addr___collision_stack_cpu(addr___collision_stack_cpu),
    .input___collision_stack_cpu(input___collision_stack_cpu),
    .out___collision_stack_cpu(out___collision_stack_cpu),
    .wre___collision_stack_cpu(wre___collision_stack_cpu),
    .out_from_sprite_buffer__cpu(out_from_sprite_buffer__cpu),
    .sprite_buffer_wre__cpu(sprite_buffer_wre__cpu),
    .input_to_sprite_buffer__cpu(input_to_sprite_buffer__cpu),
    .addr_to_sprite_buffer__cpu(addr_to_sprite_buffer__cpu),
    .collision_stack_size(collision_stack_size),
    .hdmi_ctrl_is_standby(hdmi_ctrl_is_standby),
    .debug_signal(debug_signal),
    .cpu_reseted(reset_cpu),
    .cpu_enabled(enable),
    .count_pulses_where_ppu_is_idle(count_pulses_where_ppu_is_idle)
);
wire wre_main_memory;
wire [12:0] addr_main_memory;
wire [31:0] din_main_memory;
wire [31:0] dout_main_memory;


MAIN_MEMORY main_memory_inst (
    .dout_wire(dout_main_memory), 
    .clk(clk), 
    .oce(1'b1),
    .ce(1'b1),
    .reset(1'b0),
    .wre(wre_main_memory),
    .ad(addr_main_memory[12:0]),
    .din(din_main_memory)
);
wire [15:0] ps2_buttons;
mapper mapper_ins(
    .clk(clk), 
    .addr_main_memory(addr_main_memory),
    .din_main_memory(din_main_memory),
    .dout_main_memory(dout_main_memory),
    .wre_main_memory(wre_main_memory),

    .addr_mapper(addr_mapper),
    .din_mapper(din_mapper),
    .dout_mapper(dout_mapper),
    .wre_mapper(wre_mapper),

    .addr_led_memory(addr_led_memory),
    .din_led_memory(din_led_memory),
    .dout_led_memory(dout_led_memory),
    .wre_led_memory(wre_led_memory),

    .addr_control_cpu_memory(addr_control_cpu_memory),
    .din_control_cpu_memory(din_control_cpu_memory),
    .dout_control_cpu_memory(dout_control_cpu_memory),
    .wre_control_cpu_memory(wre_control_cpu_memory),

    .addr_sdram_manager(addr_sdram_manager__mapper),
    .din_sdram_manager(din_sdram_manager__mapper),
    .dout_sdram_manager(dout_sdram_manager__mapper),
    .wre_sdram_manager(wre_sdram_manager__mapper),
    .debug_signal(debug_signal),

   


    .addr___collision_stack_cpu(addr___collision_stack_cpu),
    .input___collision_stack_cpu(input___collision_stack_cpu),
    .out___collision_stack_cpu(out___collision_stack_cpu),
    .wre___collision_stack_cpu(wre___collision_stack_cpu),
    .out_from_sprite_buffer__cpu(out_from_sprite_buffer__cpu),
    .sprite_buffer_wre__cpu(sprite_buffer_wre__cpu),
    .input_to_sprite_buffer__cpu(input_to_sprite_buffer__cpu),
    .addr_to_sprite_buffer__cpu(addr_to_sprite_buffer__cpu),
    .collision_stack_size(collision_stack_size),
    .ps2_buttons(ps2_buttons),
    .count_pulses_since_riscv_started(count_pulses_since_riscv_started),
    .count_pulses_where_sdram_controller_is_idle(count_pulses_where_sdram_controller_is_idle),
    .count_pulses_where_ppu_is_idle(count_pulses_where_ppu_is_idle)
);
rv32im_cpu___ppu rv32im_cpu_ppu_inst(
    .clk(clk),
    .reset(reset_cpu|(~lock_pll)),
    .mem_addr___external(addr_main_memory___rv32im_cpu_inst),
    .mem_wdata___external(din_main_memory___rv32im_cpu_inst),
    .mem_rdata___external(dout_mapper),
    .mem_we___external(wre_main_memory___rv32im_cpu_inst),
    .enable(enable),
    .cmd_to_put_in_ppu_fifo(cmd_to_put_in_ppu_fifo),
    .wr_cmd_for_ppu_fifo(wr_cmd_for_ppu_fifo),
    .processing_the_ppu_fifo_insert(processing_the_ppu_fifo_insert),
    .set_addr_to_frame_buffer(set_addr_to_frame_buffer),
    .addr_to_frame_buffer(addr_to_frame_buffer),
    .fb_horizontal_offset(fb_horizontal_offset),
    .set_addr_to_frame_buffer__ack(set_addr_to_frame_buffer__ack),
    .ppu_cmd_fifo_is_empity(ppu_cmd_fifo_is_empity),
    //.debug_signal(debug_signal),
    .leds(led)


);


/******
control_leds control_leds_ins(
    .clk(clk),
    .addr_led_memory(addr_led_memory),
    .din_led_memory(din_led_memory),
    .dout_led_memory(dout_led_memory),
    .wre_led_memory(wre_led_memory),
    .leds(led)
);
*******/
control_cpu control_cpu_ins(
    .clk(clk),
    .rst_n(n_reset_global),
    .addr_control_cpu_memory(addr_control_cpu_memory),
    .din_control_cpu_memory(din_control_cpu_memory),
    .dout_control_cpu_memory(dout_control_cpu_memory),
    .wre_control_cpu_memory(wre_control_cpu_memory),
    .reset_cpu(reset_cpu),
    .sel___main_memory(sel___main_memory),
    .enable_cpu(enable),
    .spi_comm_started(spi_comm_started),
    .spi_can_access_memory(spi_can_access_memory)
    //.clk_out(clk_cpu)
);


reg ps2_dat;
always @(posedge clk) begin
	ps2_dat<=ds_miso;
end


ps2_controller controller (
    .clk(clk),
    .rst_n(n_reset_global),

    // Interface com o controle PS2
    .ps2_att(ds_cs),
    .ps2_clk(ds_clk),
    .ps2_cmd(ds_mosi),
    .ps2_dat(ps2_dat),

    .buttons(ps2_buttons)
   // .debug_signal(debug_signal)

);









`ifdef SIM
lock_pll= 1'b0;
#120;
lock_pll=1'b1;
`endif


endmodule
