module mapper(
    input   wire            clk,
    output  reg     [11:0]  addr_main_memory,
    output  reg     [31:0]  din_main_memory,
    input   wire    [31:0]  dout_main_memory,
    output  reg             wre_main_memory,

    output  reg     [5:0]   addr_led_memory,
    output  reg     [31:0]  din_led_memory,
    input   wire    [31:0]  dout_led_memory,
    output  reg             wre_led_memory,


    output  reg     [5:0]   addr_control_cpu_memory,
    output  reg     [31:0]  din_control_cpu_memory,
    input   wire    [31:0]  dout_control_cpu_memory,
    output  reg             wre_control_cpu_memory,
    

    input   wire    [31:0]  addr_mapper,
    input   wire    [31:0]  din_mapper,
    output  reg     [31:0]  dout_mapper,
    input   wire            wre_mapper,
    
    
    
    output  reg    [5:0]   leds,
    input   wire   [31:0]  pc
);
reg start=1'b0;
always @(posedge clk) begin
    if(addr_mapper[29]==1'b1) begin
        addr_main_memory <=addr_mapper[11:0];
        dout_mapper<=dout_main_memory;
        din_main_memory<=din_mapper;
        wre_main_memory<=wre_mapper;
        wre_control_cpu_memory<=1'b0;
        wre_led_memory<=1'b0;
    end
    else if(addr_mapper[8]==1'b1) begin
        addr_control_cpu_memory <=addr_mapper[5:0];
        dout_mapper<=dout_control_cpu_memory;
        din_control_cpu_memory<=din_mapper;
        wre_control_cpu_memory<=wre_mapper;
        wre_main_memory<=1'b0;
        wre_led_memory<=1'b0;
    end
    else if(addr_mapper[6]==1'b1) begin
        addr_led_memory <=addr_mapper[5:0];
        dout_mapper<=dout_led_memory;
        din_led_memory<=din_mapper;
        wre_led_memory<=wre_mapper;
        wre_main_memory<=1'b0;
        wre_control_cpu_memory<=1'b0;
    end
    else begin
        wre_main_memory<=1'b0;
        wre_control_cpu_memory<=1'b0;
        wre_led_memory<=1'b0;
    end
    
end

endmodule
