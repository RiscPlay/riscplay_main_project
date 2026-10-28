
module Simulation_DPB__Sprite_BUFFER (
    output reg  [7:0]  douta,
    output reg  [7:0]  doutb,

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

    input      [13:0]  ada,
    input      [7:0]   dina,
    input      [13:0]  adb,
    input      [7:0]   dinb
);

    // 16384 bytes = 16 KiB
    reg [7:0] mem [0:16383];

    // Porta A
    always @(posedge clka) begin
        if (reseta) begin
            douta <= 8'b0;
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
            doutb <= 8'b0;
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
