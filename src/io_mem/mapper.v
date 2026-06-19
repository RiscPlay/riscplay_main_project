module mapper(
    output wire [11:0] addr_main_memory,
    output wire [31:0] din_main_memory,
    input  wire [31:0] dout_main_memory,
    output wire        wre_main_memory,

    output wire [5:0]  addr_led_memory,
    output wire [31:0] din_led_memory,
    input  wire [31:0] dout_led_memory,
    output wire        wre_led_memory,

    output wire [5:0]  addr_control_cpu_memory,
    output wire [31:0] din_control_cpu_memory,
    input  wire [31:0] dout_control_cpu_memory,
    output wire        wre_control_cpu_memory,


    output wire [21:0]  addr_sdram_manager,
    output wire [31:0]  din_sdram_manager,
    input  wire [31:0]  dout_sdram_manager,
    output wire         wre_sdram_manager,


    input  wire [31:0] addr_mapper,
    input  wire [31:0] din_mapper,
    output wire [31:0] dout_mapper,
    input  wire        wre_mapper,

    input wire [31:0] debug_signal_draw
);

//
// Decodificação de regiões
//
wire sel_main    = addr_mapper[29];
wire sel_sdram   = ~sel_main && addr_mapper[22];
wire sel_control = ~sel_main && ~sel_sdram && addr_mapper[8];
wire sel_led     = ~sel_main && ~sel_sdram && ~sel_control && addr_mapper[6];
wire sel_draw    = ~sel_main && ~sel_sdram && ~sel_control  &&  ~sel_led && addr_mapper[1];


//
// MAIN MEMORY
//
assign addr_main_memory = addr_mapper[11:0];
assign din_main_memory  = din_mapper;
assign wre_main_memory  = sel_main ? wre_mapper : 1'b0;

//
// CONTROL CPU MEMORY
//
assign addr_control_cpu_memory = addr_mapper[5:0];
assign din_control_cpu_memory  = din_mapper;
assign wre_control_cpu_memory  = sel_control ? wre_mapper : 1'b0;

//
// LED MEMORY
//
assign addr_led_memory = addr_mapper[5:0];
assign din_led_memory  = din_mapper;
assign wre_led_memory  = sel_led ? wre_mapper : 1'b0;

assign addr_sdram_manager = addr_mapper[21:0];
assign din_sdram_manager  = din_mapper;
assign wre_sdram_manager  = sel_sdram ? wre_mapper : 1'b0;


//
// MUX de leitura
//
assign dout_mapper =
    sel_main    ? dout_main_memory :
    sel_control ? dout_control_cpu_memory :
    sel_led     ? dout_led_memory :
    sel_sdram   ? dout_sdram_manager :
    sel_draw    ? debug_signal_draw :
    32'h00000000;


endmodule