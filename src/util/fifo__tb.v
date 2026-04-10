`timescale 1ns/1ps
module fifo__tb;

reg clk;
reg rst_n;
reg wr_req;
reg rd_req;
wire [7:0] dout;
reg [7:0] din;
wire empty;
wire full;
wire busy;


// Instancia o contador
fifo fifo1 (
        clk,
        rst_n,
        wr_req,
        rd_req,
        din,
        dout,
        wr_ready,
        rd_ready,
        empty,
        full,
        busy
);

// Clock 1 MHz → período 1000 ns
initial clk = 0;
always #20 clk = ~clk; // 500 ns meio período
integer i;
// Testbench
initial begin
    // Inicialização

    // Iniciar dump VCD
    $dumpfile("fifo__tb.vcd");
    $dumpvars(0, fifo__tb);
    rst_n = 0;

    // 10 ns de reset
    #50 rst_n = 1;
    #50;
    for (i = 0; i < 300; i = i + 1) begin

        wr_req = 1;
        din = i;
        #120;

        wr_req = 0;
        #40;
    end

    for (i = 0; i < 300; i = i + 1) begin
        rd_req = 1;
        #120;           // espera 10 ns
        wr_req = 0;
        #40;

    end
    // Simula até 300 ns
    #2040;
    
    $finish;
end

endmodule