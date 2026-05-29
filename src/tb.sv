`timescale 1ns/1ps

module tb;

    reg clk=1'b0;
    reg rst;



    integer i;

    // geração de clock
    always #18.5 clk = ~clk;
    wire [3:0] GPIO;
    top top1 (
        .I_clk(clk),
        .GPIO(GPIO),
        .I_rst(1'b0)           
    );
    assign GPIO[0]=1'b1;
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        clk = 0;
        rst = 1;

        // inicializa memória com valores hexadecimais
        for (i = 0; i < 22744; i = i + 1) begin
            #20;
        end

  

        #20;
        rst = 0;

        // simulação simples de leitura
        #10;


        #50;
        $finish;
    end

endmodule