module mapper_ppu(
    output wire [11:0] addr_main_memory,
    output wire [31:0] din_main_memory,
    input  wire [31:0] dout_main_memory,
    output wire        wre_main_memory,

    output wire [21:0]  addr_sdram_manager,
    output wire [31:0]  din_sdram_manager,
    input  wire [31:0]  dout_sdram_manager,
    output wire         wre_sdram_manager,


    output wire [13:0]  addr_tile,
    output wire [7:0]   din_tile,
    input  wire [7:0]   dout_tile,
    output wire         wre_tile,


    output wire [9:0]  addr___collision_stack_cpu,
    output wire [15:0] input___collision_stack_cpu,
    input  wire [15:0] out___collision_stack_cpu,
    output wire        wre___collision_stack_cpu,



    input  wire [7:0]  out_from_sprite_buffer__cpu,
    output wire        sprite_buffer_wre__cpu,
    output wire [7:0]  input_to_sprite_buffer__cpu,
    output wire [13:0] addr_to_sprite_buffer__cpu,
    


    output  wire [9:0]  collision_stack_size,


    input  wire [31:0] addr_mapper,
    input  wire [31:0] din_mapper,
    output wire [31:0] dout_mapper,
    input  wire        wre_mapper,


    input wire [31:0] debug_signal_draw
);

//
// Decodificação de regiões
//
wire sel_main     = addr_mapper[31:29]==3'b001;
wire sel_sdram    = addr_mapper[31:22]==10'b1;
wire sel_tile     = addr_mapper[31:20]==12'b1;


wire sel_colision = addr_mapper[31:18]==14'b1;
wire sel_sprite   = addr_mapper[31:17]==15'b1;
wire sel_coll     = addr_mapper==32'h1;

wire sel_draw     = addr_mapper==32'h0;


//
// MAIN MEMORY
//
assign addr_main_memory = addr_mapper[11:0];
assign din_main_memory  = din_mapper;
assign wre_main_memory  = sel_main ? wre_mapper : 1'b0;



//
// SDRAM MEMORY
//
assign addr_sdram_manager = addr_mapper[21:0];
assign din_sdram_manager  = din_mapper;
assign wre_sdram_manager  = sel_sdram ? wre_mapper : 1'b0;



assign addr_tile = addr_mapper[13:0];
assign din_tile  = din_mapper[31:24] ;
assign wre_tile   = sel_tile ? wre_mapper : 1'b0;



assign addr_to_sprite_buffer = addr_mapper[13:0];
assign input_to_sprite_buffer__cpu  = din_mapper[31:24] ;
assign sprite_buffer_wre__cpu   = sel_sprite ? wre_mapper : 1'b0;


assign addr___collision_stack_cpu = addr_mapper[15:0];




//
// MUX de leitura
//
assign dout_mapper =
    sel_main     ? dout_main_memory :
    sel_sdram    ? dout_sdram_manager :
    sel_tile     ? {dout_tile,24'h0} :
    sel_colision ? {out___collision_stack_cpu,16'h0} :
    sel_sprite   ? {out_from_sprite_buffer__cpu,24'h0} :
    sel_coll     ? {22'b0,collision_stack_size}:
    sel_draw     ? debug_signal_draw:
    32'h00000000;


endmodule