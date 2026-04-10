module control_cpu(
    input   wire           clk,
    input   wire           rst_n,
    input   wire   [7:0]   addr_control_cpu_memory,
    input   wire   [31:0]  din_control_cpu_memory,
    input   reg    [31:0]  dout_control_cpu_memory,
    output  reg            wre_control_cpu_memory,
    output  reg            reset_cpu,
    output  reg    [5:0]   leds

);
reg [7:0] mem [0:63];
always @(posedge clk) begin
    if(!rst_n) begin
        reset_cpu<=1'b1;
    end
    else begin
        if(wre_control_cpu_memory) begin
            mem[addr_control_cpu_memory[5:0]]<=din_control_cpu_memory;
        end
        reset_cpu<=(mem[0][0]);
        leds[0]<=~(mem[0][0]);
        leds[1]<=~(mem[0][0]);
        leds[2]<=~(mem[0][0]);
        leds[3]<=~(mem[0][0]);
        leds[4]<=~(mem[0][0]);
        leds[5]<=~(mem[0][0]);
    end
end
endmodule