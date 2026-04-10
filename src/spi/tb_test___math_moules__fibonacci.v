`timescale 1ns/1ps
module tb;
reg clk=1'b0;
reg sclk=1'b0;


function [31:0] crc32_byte;
        input [31:0] crc_in;
        input [7:0] data;
        integer j;
        reg [31:0] crc;
        begin
                crc = crc_in ^ data;
                for (j = 0; j < 8; j = j + 1) begin
                        if (crc[0])
                        crc = (crc >> 1) ^ 32'hEDB88320;
                        else
                        crc = crc >> 1;
                end
                crc32_byte = crc;
        end
endfunction

always #20 clk = ~clk; // clock 25mhz

reg [7:0] data [0:8];

reg [7:0] data_temp;
reg [7:0] data_out [0:65535];

reg [31:0] crc;
reg [31:0] crc_out;
reg rst_n;
reg cs;
reg mosi;
wire miso;
integer j;
integer i;

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

wire reset_fifos=(~cs)&rst_n;
wire [7:0]  data_in_crc32____for_consumer_spi_mods;
wire [31:0] crc_out____for_consumer_spi_mods;
wire crc_done____for_consumer_spi_mods;
wire [31:0] crc_bytes_processed____for_consumer_spi_mods;
wire start_crc32____for_consumer_spi_mods;
wire process_new_data_in_crc32_module____for_consumer_spi_mods;

wire [63:0] op_args;
`include "../defines_to_a_module_connect_to__consumer_spi_0__of_top_level/define_mux.vh"

initial begin
    //$dumpfile("tb.vcd");
    //$dumpvars(0, tb);
    mosi=1'b0;

    // exemplo de dados
    data[0] = 8'h01;
    data[1] = 8'h00;
    data[2] = 8'h00;
    data[3] = 8'h00;
    data[4] = 8'h00;
    data[5] = 8'h00;
    data[6] = 8'h00;
    data[7] = 8'h04;
    data[8] = 8'h00;

    crc = 32'hFFFFFFFF;

    for (i = 0; i < 9; i = i + 1) begin
        crc = crc32_byte(crc, data[i]);
    end
    crc = ~crc;


    cs=1'b1;#3005;
    cs=1'b0;#8000;

    for (i = 0; i < 9; i = i + 1) begin
        data_temp= data[i];
        for (j = 0; j < 8; j = j + 1) begin
                mosi=data_temp[7-j]; sclk=1'b1; #250; sclk=1'b0; #250;
        end
    end


     #8000;

    for (j = 0; j < 32; j = j + 1) begin
        mosi=crc[31-j]; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    
    #1000;
    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b0; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b1; sclk=1'b1; #250; sclk=1'b0; #250;
    end




    #400000;
    for (i=0;i<data[8]+(data[7]<<8);i++) begin
        data_temp=8'h00;

        for (j = 0; j < 8; j = j + 1) begin
            mosi=0;  sclk=1'b1; #250; sclk=1'b0; #250; data_temp[7-j]=miso;
        end
        data_out[i]=data_temp;

    end


    #8000;
    crc = 32'hFFFFFFFF;

    for (i = 0; i < (data[8]+(data[7]<<8)); i = i + 1) begin
        crc = crc32_byte(crc, data_out[i]);
        //$display("data_temp[%d] = %d", i,data_out[i]);

    end
    crc = ~crc;
    for (j = 0; j < 32; j = j + 1) begin
        mosi=crc[31-j]; sclk=1'b1; #250; sclk=1'b0; #250;
    end


    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b0; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b1; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    $display("crc = %h", crc);

    #30000 $display("Finished");




    #4005;
    cs=1'b1;
    #2005
    cs=1'b0;
    #4000;




























    mosi=1'b0;

    // exemplo de dados
    data[0] = 8'h01;
    data[1] = 8'h00;
    data[2] = 8'h00;
    data[3] = 8'h00;
    data[4] = 8'h00;
    data[5] = 8'h00;
    data[6] = 8'h00;
    data[7] = 8'h02;
    data[8] = 8'hff;

    crc = 32'hFFFFFFFF;

    for (i = 0; i < 9; i = i + 1) begin
        crc = crc32_byte(crc, data[i]);
    end
    crc = ~crc;


    cs=1'b1;#3005;
    cs=1'b0;#8000;

    for (i = 0; i < 9; i = i + 1) begin
        data_temp= data[i];
        for (j = 0; j < 8; j = j + 1) begin
                mosi=data_temp[7-j]; sclk=1'b1; #250; sclk=1'b0; #250;
        end
    end


     #8000;

    for (j = 0; j < 32; j = j + 1) begin
        mosi=crc[31-j]; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    
    #1000;
    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b0; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b1; sclk=1'b1; #250; sclk=1'b0; #250;
    end





    #400000;
    for (i=0;i<data[8]+(data[7]<<8);i++) begin
        data_temp=8'h00;

        for (j = 0; j < 8; j = j + 1) begin
            mosi=0;  sclk=1'b1; #250; sclk=1'b0; #250; data_temp[7-j]=miso;
        end
        data_out[i]=data_temp;

    end


    #8000;
    crc = 32'hFFFFFFFF;

    for (i = 0; i < data[8]+(data[7]<<8); i = i + 1) begin
        crc = crc32_byte(crc, data_out[i]);
        $display("data_temp[%d] = %d", i,data_out[i]);

    end
    crc = ~crc;
    for (j = 0; j < 32; j = j + 1) begin
        mosi=crc[31-j]; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    $display("crc = %h", crc);


    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b0; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    for (j = 0; j < 4; j = j + 1) begin
        mosi=1'b1; sclk=1'b1; #250; sclk=1'b0; #250;
    end
    #30000 $display("Finished");




    #4005;
    cs=1'b1;
    #2005
    cs=1'b0;
    #4000;


    $finish;
end

fibonacci fibonacci0 (
    .clk(clk),
    .rst_n(awake_module[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .data_line_from_read_fifo(mux__din__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .rd_req_fifo(mux__rd_req__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .rd_ready_fifo(mux__rd_ready__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .empty_fifo(mux__empty__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .data_line_from_write_fifo(mux__dout__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .wr_req_fifo(mux__wr_req__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .wr_ready_fifo(mux__wr_ready__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .full_fifo(mux__full__consumer_spi[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .busy_from_write_fifo(mux__busy___fifo_spi_slave_read__and__fifo_spi_consumer_write[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .busy_from_read_fifo(mux__busy___fifo_spi_slave_write__and__fifo_spi_consumer_read[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .stopped(module_stopped[ID_MODULE____MATH_MODULES____FIBONACCI]),

    .start_crc32(mux__start_crc32____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .data_line_to_write_in_crc32(mux__data_in_crc32____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .process_new_data_in_crc32_module(mux__process_new_data_in_crc32_module____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .finish_calc_crc(mux__finish_calc_crc____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .crc_out(mux__crc_out____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .crc_done(mux__crc_done____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .crc_bytes_processed(mux__crc_bytes_processed____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .ready_for_recv_data(mux__crc32_module_is_ready_for_recv_data____for_consumer_spi_mods[ID_MODULE____MATH_MODULES____FIBONACCI]),
    .op_args(op_args)
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
    .op_args(op_args)
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
    .op_args(op_args)

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