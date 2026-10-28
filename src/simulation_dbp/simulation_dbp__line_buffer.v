
module Simulation_DPB__LINE_BUFFER (
    output reg  [31:0] douta,
    output reg  [31:0] doutb,

    input              clka,
    input              ocea,
    input              cea,
    input              reseta,
    input              wrea,

    input              clkb,
    input              oceb,
    input              ceb,
    input              resetb,
    input              wreb,

    input      [10:0]  ada,
    input      [31:0]  dina,
    input      [10:0]  adb,
    input      [31:0]  dinb
);

    // 2048 posições x 32 bits
    reg [31:0] mem [0:2047];

    // Porta A
    always @(posedge clka) begin
        if (reseta) begin
            douta <= 32'b0;
        end
        else if (cea) begin
            if (wrea) begin
                mem[ada] <= dina;
            end
            else if (ocea) begin
                douta <= mem[ada];
            end
        end
    end

    // Porta B
    always @(posedge clkb) begin
        if (resetb) begin
            doutb <= 32'b0;
        end
        else if (ceb) begin
            if (wreb) begin
                mem[adb] <= dinb;
            end
            else if (oceb) begin
                doutb <= mem[adb];
            end
        end
    end

endmodule
