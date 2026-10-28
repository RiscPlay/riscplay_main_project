
module SIMULATION_SP_SRAM_MAIN_MEMORY (
    output reg  [31:0] dout,
    input              clk,
    input              oce,
    input              ce,
    input              reset,
    input              wre,
    input      [12:0]  ad,
    input      [31:0]  din
);

    reg [31:0] mem [0:8191];

    always @(posedge clk) begin
        if (reset) begin
            dout <= 32'b0;
        end
        else if (ce) begin
            if (wre) begin
                mem[ad] <= din;
            end
            else if (oce) begin
                dout <= mem[ad];
            end
        end
    end

endmodule
