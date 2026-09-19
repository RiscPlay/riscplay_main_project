`timescale 1ns/1ps
module tb_test___recvdata;
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
                        if (crc[0]) begin
                            crc = (crc >> 1) ^ 32'hEDB88320;
                        end
                        else begin
                            crc = crc >> 1;
                        end
                end
                crc32_byte = crc;
        end
endfunction

always #20 clk = ~clk; // clock 25mhz

reg [7:0] data [0:8];

reg [7:0] data_temp;
reg [7:0] data_temp2;

reg [7:0] data_out [0:65535];

reg [31:0] crc;
reg [31:0] crc_out;
reg rst_n;
reg cs;
reg mosi;
wire miso;
integer j;
integer i;


initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb_test___recvdata);
    mosi=1'b0;

    // exemplo de dados
    data[0] = 8'h02;
    data[1] = 8'h00;
    data[2] = 8'h00;
    data[3] = 8'h00;
    data[4] = 8'h00;
    data[5] = 8'h00;
    data[6] = 8'h00;
    data[7] = 8'h00;
    data[8] = 8'h0a;

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
    $display("crc = %h", crc);




    #400000;
    for (i=0;i<data[8]+(data[7]<<8);i++) begin
        data_temp=8'h00;
        data_temp2=i;
        //$display("Finished %d",i);

        for (j = 0; j < 8; j = j + 1) begin
            mosi=data_temp2[7-j];  sclk=1'b1; #250; sclk=1'b0; #250; data_temp[7-j]=mosi;
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





    $finish;
end


spi spi_ins (
    .clk(clk),
    .sclk(sclk),
    .cs(cs),
    .mosi(mosi),
    .miso(miso)
    //.sel___main_memory(sel___main_memory),
    //.addr_main_memory___senddata0(addr_main_memory___senddata0),
    //.addr_main_memory___recvdata0(addr_main_memory___recvdata0),
    //.din_main_memory___recvdata0(din_main_memory___recvdata0),
    //.dout_mapper(dout_mapper)
);


endmodule