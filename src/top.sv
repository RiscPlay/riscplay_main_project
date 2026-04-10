`include "sdrc_defines.v"
module top (
    input             I_clk,
    output     [5:0]  led,
    inout      [3:0]  GPIO,
    input             I_rst           ,
    input             I_key           ,
    output            O_tmds_clk_p    ,
    output            O_tmds_clk_n    ,
    output     [2:0]  O_tmds_data_p   ,//{r,g,b}
    output     [2:0]  O_tmds_data_n   
/***
    input           I_selfrefresh,
    input           I_power_down,
    input           I_wrd,
    output          O_wrd_error_flag,
    output          O_sdram_clk,
    output          O_sdram_cke,
    output          O_sdram_cs_n,
    output          O_sdram_cas_n,
    output          O_sdram_ras_n,
    output          O_sdram_wen_n,
    output          O_sdrc_busy_n,
    inout  [`SDRAM_DATA_WIDTH-1:0] IO_sdram_dq,
    output [`SDRAM_ADDR_WIDTH-1:0] O_sdram_addr,
    output [`SDRAM_BANK_WIDTH-1:0] O_sdram_ba,
    output [`SDRAM_DQM_WIDTH-1:0]  O_sdram_dqm
***/
);

wire clk;
wire clk_90d;
reg lock_pll_90mhz=1'b0;
Gowin_rPLL___90mhz main_clock_used(
     .clkout(clk), //output clkout
     .clkoutp(clk_90d),
     .lock(lock_pll_90mhz),
     .clkin(I_clk) //input clkin
);



HDMI hdmi_inst(
    .I_clk(I_clk),
    .I_rst(I_rst),
    .O_tmds_clk_p(O_tmds_clk_p),
    .O_tmds_clk_n(O_tmds_clk_n),
    .O_tmds_data_p(O_tmds_data_p),
    .O_tmds_data_n(O_tmds_data_n)
);

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























wire wr_req__spi_slave;
wire rd_req__spi_slave;
wire [7:0] din__spi_slave;
wire [7:0] dout__spi_slave;
wire wr_ready__spi_slave;
wire rd_ready__spi_slave;
wire empty__spi_slave;
wire full__spi_slave;
wire busy_from_write_fifo__spi_slave;
wire busy_from_read_fifo__spi_slave;




wire wr_req__consumer_spi;
wire rd_req__consumer_spi;
wire [7:0] din__consumer_spi;
wire [7:0] dout__consumer_spi;
wire wr_ready__consumer_spi;
wire rd_ready__consumer_spi;
wire empty__consumer_spi;
wire full__consumer_spi;
wire busy_from_write_fifo__consumer_spi;
wire busy_from_read_fifo__consumer_spi;


wire busy___fifo_spi_slave_read__and__fifo_spi_consumer_write;
wire busy___fifo_spi_slave_write__and__fifo_spi_consumer_read;
assign busy_from_read_fifo__spi_slave = busy___fifo_spi_slave_read__and__fifo_spi_consumer_write;
assign busy_from_read_fifo__consumer_spi = busy___fifo_spi_slave_write__and__fifo_spi_consumer_read;

assign busy_from_write_fifo__consumer_spi = busy___fifo_spi_slave_read__and__fifo_spi_consumer_write;
assign busy_from_write_fifo__spi_slave =  busy___fifo_spi_slave_write__and__fifo_spi_consumer_read;

wire [7:0]  data_in_crc32____for_consumer_spi_mods;
wire [31:0] crc_out____for_consumer_spi_mods;
wire crc_done____for_consumer_spi_mods;
wire [31:0] crc_bytes_processed____for_consumer_spi_mods;
wire start_crc32____for_consumer_spi_mods;
wire process_new_data_in_crc32_module____for_consumer_spi_mods;
wire crc32_module_is_ready_for_recv_data____for_consumer_spi_mods;
wire [63:0] op_args;



wire finish_calc_crc____for_consumer_spi_mods;
`include "defines_to_a_module_connect_to__consumer_spi_0__of_top_level/define_ids.vh"
`include "defines_to_a_module_connect_to__consumer_spi_0__of_top_level/define_mux.vh"




reg n_reset_cpu;
reg [3:0] count_for_reset=4'h0;
always @(posedge clk) begin
    if(count_for_reset==4'ha) begin
        n_reset_cpu<=1'b1;
    end
    else begin
        n_reset_cpu<=1'b0;
        count_for_reset<=count_for_reset+4'h1;
    end
end

wire reset_cpu_from___shutdown_and_start_cpu;
wire reset_cpu;

wire [3:0] sel___main_memory;

wire wre_main_memory;
wire [11:0] addr_main_memory;
wire [31:0] din_main_memory;
wire [31:0] dout_main_memory;


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


Gowin_SP_SRAM_MAIN_MEMORY main_memory (
    .dout(dout_main_memory), 
    .clk(clk), 
    .oce(1'b1),
    .ce(1'b1),
    .reset(1'b0),
    .wre(wre_main_memory),
    .ad(addr_main_memory[11:0]),
    .din(din_main_memory)
);

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
    .wre_control_cpu_memory(wre_control_cpu_memory)
);
rv32im_cpu rv32im_cpu_inst(
    .clk(clk),
    .reset(reset_cpu),
    .mem_addr(addr_main_memory___rv32im_cpu_inst),
    .mem_wdata(din_main_memory___rv32im_cpu_inst),
    .mem_rdata(dout_mapper),
    .mem_we(wre_main_memory___rv32im_cpu_inst),
    .enable(1'b1)
);

control_leds control_leds_ins(
    .clk(clk),
    .addr_led_memory(addr_led_memory),
    .din_led_memory(din_led_memory),
    .dout_led_memory(dout_led_memory),
    .wre_led_memory(wre_led_memory)
//    .leds(led)
);
control_cpu control_cpu_ins(
    .clk(clk),
    .rst_n(n_reset_cpu),
    .addr_control_cpu_memory(addr_control_cpu_memory),
    .din_control_cpu_memory(din_control_cpu_memory),
    .dout_control_cpu_memory(dout_control_cpu_memory),
    .wre_control_cpu_memory(wre_control_cpu_memory),
    .reset_cpu(reset_cpu),
    .leds(led)
);
/*
shutdown_and_start_cpu shutdown_and_start_cpu_inst(
    .clk(clk),
    .rst_n(n_reset_cpu),
    .wake(awake_module[ID_MODULE____SHUTDOWN_AND_START_CPU]),
    .is_start(op_args[0]),
    .reset_cpu(reset_cpu_from___shutdown_and_start_cpu),
    .stopped(module_stopped[ID_MODULE____SHUTDOWN_AND_START_CPU])
);
*/
/*
enable_or_pause_cpu enable_or_pause_cpu_inst(
    .clk(clk),
    .rst_n(n_reset_cpu),
    .wake(awake_module[ID_MODULE____ENABLE_OR_PAUSE_CPU]),
    .cmd(op_args[1:0]),
    .enable_cpu(enable_cpu),
    .stopped(module_stopped[ID_MODULE____ENABLE_OR_PAUSE_CPU])
);
*/

senddata senddata0 (
    .clk(clk),
    .rst_n(awake_module[ID_MODULE____SEND_DATA]),
    .data_line_from_read_fifo(mux__din__consumer_spi[ID_MODULE____SEND_DATA]),
    .rd_req_fifo(mux__rd_req__consumer_spi[ID_MODULE____SEND_DATA]),
    .rd_ready_fifo(mux__rd_ready__consumer_spi[ID_MODULE____SEND_DATA]),
    .empty_fifo(mux__empty__consumer_spi[ID_MODULE____SEND_DATA]),
    .data_line_from_write_fifo(mux__dout__consumer_spi[ID_MODULE____SEND_DATA]),
    .wr_req_fifo(mux__wr_req__consumer_spi[ID_MODULE____SEND_DATA]),
    .wr_ready_fifo(mux__wr_ready__consumer_spi[ID_MODULE____SEND_DATA]),
    .full_fifo(mux__full__consumer_spi[ID_MODULE____SEND_DATA]),
    .busy_from_write_fifo(mux__busy___fifo_spi_slave_read__and__fifo_spi_consumer_write[ID_MODULE____SEND_DATA]),
    .busy_from_read_fifo(mux__busy___fifo_spi_slave_write__and__fifo_spi_consumer_read[ID_MODULE____SEND_DATA]),
    .stopped(module_stopped[ID_MODULE____SEND_DATA]),


    .start_crc32(mux__start_crc32____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .data_line_to_write_in_crc32(mux__data_in_crc32____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .process_new_data_in_crc32_module(mux__process_new_data_in_crc32_module____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .finish_calc_crc(mux__finish_calc_crc____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .crc_out(mux__crc_out____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .crc_done(mux__crc_done____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .crc_bytes_processed(mux__crc_bytes_processed____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .ready_for_recv_data(mux__crc32_module_is_ready_for_recv_data____for_consumer_spi_mods[ID_MODULE____SEND_DATA]),
    .op_args(op_args),

    .addr_main_memory(addr_main_memory___senddata0),
    .dout_main_memory(dout_mapper)
);

recvdata recvdata0 (
    .clk(clk),
    .rst_n(awake_module[ID_MODULE____RECV_DATA]),
    .data_line_from_read_fifo(mux__din__consumer_spi[ID_MODULE____RECV_DATA]),
    .rd_req_fifo(mux__rd_req__consumer_spi[ID_MODULE____RECV_DATA]),
    .rd_ready_fifo(mux__rd_ready__consumer_spi[ID_MODULE____RECV_DATA]),
    .empty_fifo(mux__empty__consumer_spi[ID_MODULE____RECV_DATA]),
    .data_line_from_write_fifo(mux__dout__consumer_spi[ID_MODULE____RECV_DATA]),
    .wr_req_fifo(mux__wr_req__consumer_spi[ID_MODULE____RECV_DATA]),
    .wr_ready_fifo(mux__wr_ready__consumer_spi[ID_MODULE____RECV_DATA]),
    .full_fifo(mux__full__consumer_spi[ID_MODULE____RECV_DATA]),
    .busy_from_write_fifo(mux__busy___fifo_spi_slave_read__and__fifo_spi_consumer_write[ID_MODULE____RECV_DATA]),
    .busy_from_read_fifo(mux__busy___fifo_spi_slave_write__and__fifo_spi_consumer_read[ID_MODULE____RECV_DATA]),
    .stopped(module_stopped[ID_MODULE____RECV_DATA]),


    .start_crc32(mux__start_crc32____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .data_line_to_write_in_crc32(mux__data_in_crc32____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .process_new_data_in_crc32_module(mux__process_new_data_in_crc32_module____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .finish_calc_crc(mux__finish_calc_crc____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .crc_out(mux__crc_out____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .crc_done(mux__crc_done____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .crc_bytes_processed(mux__crc_bytes_processed____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .ready_for_recv_data(mux__crc32_module_is_ready_for_recv_data____for_consumer_spi_mods[ID_MODULE____RECV_DATA]),
    .op_args(op_args),

    .addr_main_memory(addr_main_memory___recvdata0),
    .din_main_memory(din_main_memory___recvdata0),
    .wre_main_memory(wre_main_memory___recvdata0)
);



consumer_spi #(N_BITS_TO_ADDRESS_MODULES,N_MODULES) consumer_spi_0
(
    .clk(clk),
    .rst_n(~cs),
    .cs(cs),
    .data_line_from_read_fifo(mux__din__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .rd_req_fifo(mux__rd_req__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .rd_ready_fifo(mux__rd_ready__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .empty_fifo(mux__empty__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .data_line_from_write_fifo(mux__dout__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .wr_req_fifo(mux__wr_req__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .wr_ready_fifo(mux__wr_ready__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .full_fifo(mux__full__consumer_spi[ID_MODULE____SPI___CONSUMER_SPI]),
    .busy_from_write_fifo(mux__busy___fifo_spi_slave_read__and__fifo_spi_consumer_write[ID_MODULE____SPI___CONSUMER_SPI]),
    .busy_from_read_fifo(mux__busy___fifo_spi_slave_write__and__fifo_spi_consumer_read[ID_MODULE____SPI___CONSUMER_SPI]),
    .module_id_sel(module_id_sel),
    .awake_module(awake_module),
    .modules_stopped(module_stopped),
    .start_crc32(mux__start_crc32____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .data_line_to_write_in_crc32(mux__data_in_crc32____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .process_new_data_in_crc32_module(mux__process_new_data_in_crc32_module____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .finish_calc_crc(mux__finish_calc_crc____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .crc_out(mux__crc_out____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .crc_done(mux__crc_done____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .crc_bytes_processed(mux__crc_bytes_processed____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .ready_for_recv_data(mux__crc32_module_is_ready_for_recv_data____for_consumer_spi_mods[ID_MODULE____SPI___CONSUMER_SPI]),
    .op_args(op_args),
    .sel___main_memory(sel___main_memory)
);

spi_slave spi_slave_0(
    .clk(clk),
    .rst_n(~cs),
    .sclk(sclk),
    .cs(cs),
    .mosi(mosi),
    .miso(miso),
    .data_line_from_read_fifo(din__spi_slave),
    .rd_req_fifo(rd_req__spi_slave),
    .rd_ready_fifo(rd_ready__spi_slave),
    .empty_fifo(empty__spi_slave),
    .data_line_from_write_fifo(dout__spi_slave),
    .wr_req_fifo(wr_req__spi_slave),
    .wr_ready_fifo(wr_ready__spi_slave),
    .full_fifo(full__spi_slave),
    .busy_from_write_fifo(busy___fifo_spi_slave_write__and__fifo_spi_consumer_read),
    .busy_from_read_fifo(busy___fifo_spi_slave_read__and__fifo_spi_consumer_write)
);

crc32_fsm crc32__consumer_spi (
    .clk(clk),
    .rst_n(~cs),
    .cs(cs),
    .start(start_crc32____for_consumer_spi_mods),
    .data_in(data_in_crc32____for_consumer_spi_mods),
    .process_new_data(process_new_data_in_crc32_module____for_consumer_spi_mods),
    .ready_for_recv_data(crc32_module_is_ready_for_recv_data____for_consumer_spi_mods),
    .finish_calc_crc(finish_calc_crc____for_consumer_spi_mods),
    .crc_out(crc_out____for_consumer_spi_mods),
    .done(crc_done____for_consumer_spi_mods),
    .crc_bytes_processed(crc_bytes_processed____for_consumer_spi_mods)
);


fifo fifo_spi_slave_read__and__fifo_spi_consumer_write(
        .clk(clk),
        .rst_n(~cs),
        .cs(cs),
        .wr_req(wr_req__consumer_spi),
        .rd_req(rd_req__spi_slave),
        .din(dout__consumer_spi),
        .dout(din__spi_slave),
        .wr_ready(wr_ready__consumer_spi),
        .rd_ready(rd_ready__spi_slave),
        .empty(empty__spi_slave),
        .full(full__consumer_spi),
        .busy(busy___fifo_spi_slave_read__and__fifo_spi_consumer_write)
);

fifo fifo_spi_slave_write__and__fifo_spi_consumer_read(
        .clk(clk),
        .rst_n(~cs),
        .cs(cs),
        .wr_req(wr_req__spi_slave),
        .rd_req(rd_req__consumer_spi),
        .din(dout__spi_slave ),
        .dout(din__consumer_spi),
        .wr_ready(wr_ready__spi_slave),
        .rd_ready(rd_ready__consumer_spi),
        .empty(empty__consumer_spi),
        .full(full__spi_slave),
        .busy(busy___fifo_spi_slave_write__and__fifo_spi_consumer_read)
);






endmodule