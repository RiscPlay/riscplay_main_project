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

    // 4K words de 32 bits
    reg [31:0] mem [0:4095];

    reg [11:0] addr_reg;

    `ifdef SIM  // só em simulação (ex: iverilog -DSIM)
    reg [31:0] dout;
    assign dout_wire=dout;
    initial begin
        $display("Loading memory from mem.hex...");
        $readmemh("../tests/test_assembly/test_load_hw_sw.hex", mem);
    end


    
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