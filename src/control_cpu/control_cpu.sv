module control_cpu(
    input   wire           clk,
    input   wire           rst_n,
    input   wire   [5:0]   addr_control_cpu_memory,
    input   wire   [31:0]  din_control_cpu_memory,
    input   wire    [31:0]  dout_control_cpu_memory,
    output  reg            wre_control_cpu_memory,
    output  reg            reset_cpu,
    input   wire   [3:0]   sel___main_memory,
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
        if(~(mem[0][0]) | sel___main_memory!=4'h0) begin
            reset_cpu<=1'b1;
        end
        else begin
            reset_cpu<=1'b0;
        end
        leds[0]<=~(mem[0][0]);
        leds[1]<=~(mem[0][0]);
        leds[2]<=~(mem[0][0]);
        leds[3]<=~(mem[0][0]);
        leds[4]<=~(mem[0][0]);
        leds[5]<=~(mem[0][0]);
    end
end
endmodule