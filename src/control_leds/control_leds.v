module control_leds(
    input   wire           clk,
    input   wire   [5:0]   addr_led_memory,
    input   wire   [31:0]  din_led_memory,
    output  reg    [31:0]  dout_led_memory,
    input   wire           wre_led_memory,
    output  reg    [5:0]   leds
);
reg [31:0] mem [0:5];
always @(posedge clk) begin
    if(wre_led_memory==1'b1) begin
        if (addr_led_memory < 6)
            mem[addr_led_memory]<=din_led_memory;
    end
    else begin
        if (addr_led_memory < 6)
            dout_led_memory<=mem[addr_led_memory];
        else
            dout_led_memory<=32'h00000000;
    end

end
always @(posedge clk) begin
    if(mem[0]>32'h00000000) begin
        leds[0]<=1'b0;
    end
    else begin
        leds[0]<=1'b1;
    end
    if(mem[1]>32'h00000000) begin
        leds[1]<=1'b0;
    end
    else begin
        leds[1]<=1'b1;
    end
    if(mem[2]>32'h00000000) begin
        leds[2]<=1'b0;
    end
    else begin
        leds[2]<=1'b1;
    end
    if(mem[3]>32'h00000000) begin
        leds[3]<=1'b0;
    end
    else begin
        leds[3]<=1'b1;
    end
    if(mem[4]>32'h00000000) begin
        leds[4]<=1'b0;
    end
    else begin
        leds[4]<=1'b1;
    end
    if(mem[5]>32'h00000000) begin
        leds[5]<=1'b0;
    end
    else begin
        leds[5]<=1'b1;
    end

end
endmodule
