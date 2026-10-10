module mapper(
    input  wire        clk,
    output wire [12:0] addr_main_memory,
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


    output  wire [11:0] ad_pixel_ppu__for_mapper_of_main_cpu,
    output  wire [31:0] din_pixel_ppu__for_mapper_of_main_cpu,
    input   wire [31:0] dout_pixel_ppu__for_mapper_of_main_cpu,
    output  wire        wre_pixel_ppu__for_mapper_of_main_cpu,




    input  wire [7:0]  out_from_sprite_buffer__cpu,
    output wire        sprite_buffer_wre__cpu,
    output wire [7:0]  input_to_sprite_buffer__cpu,
    output wire [13:0] addr_to_sprite_buffer__cpu,



    input wire [31:0] debug_signal,
    input wire [15:0] ps2_buttons,
    input wire [63:0] count_pulses_since_riscv_started,
    input wire [63:0] count_pulses_where_sdram_controller_is_idle,
    input wire [63:0] count_pulses_where_ppu_is_idle,



    input  wire [31:0] addr_mapper,
    input  wire [31:0] din_mapper,
    output wire [31:0] dout_mapper,
    input  wire        wre_mapper,

    input wire  [31:0] collision_in_group
    
);

//
// Decodificação de regiões
//

wire sel_main     = addr_mapper[31:29]==3'b001;
wire sel_sdram    = addr_mapper[31:28]==4'b1;

//wire sel_ppu     = ~sel_main && addr_mapper[24];

wire sel_colision            = addr_mapper[31:26]==6'b1;
wire sel_sprite              = addr_mapper[31:25]==7'b1;
wire sel_control             = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b1;
wire sel_col_size            = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b0000;
wire sel_ps2_buttons         = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b0011;
wire sel_count_pulses_cpu_p1 = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b0100;
wire sel_count_pulses_cpu_p2 = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b0101;
wire sel_count_pulses_ppu_p1 = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b0110;
wire sel_count_pulses_ppu_p2 = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b0111;
wire sel_count_pulses_ram_p1 = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b1000;
wire sel_count_pulses_ram_p2 = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b1001;
wire sel_debug               = addr_mapper[31:25]==7'b0 && addr_mapper[8]==1'b0 && addr_mapper[3:0]==4'b1011;

//
// MAIN MEMORY
//
assign addr_main_memory = addr_mapper[12:0];
assign din_main_memory  = din_mapper;
assign wre_main_memory  = sel_main ? wre_mapper : 1'b0;

//
// CONTROL CPU MEMORY
//
assign addr_control_cpu_memory = addr_mapper[5:0];
assign din_control_cpu_memory  = din_mapper;
assign wre_control_cpu_memory  = sel_control ? wre_mapper : 1'b0;




//
// SDRAM MEMORY
//
assign addr_sdram_manager = addr_mapper[21:0];
assign din_sdram_manager  = din_mapper;
assign wre_sdram_manager  = sel_sdram ? wre_mapper : 1'b0;






assign addr_to_sprite_buffer__cpu = addr_mapper[13:0];
assign input_to_sprite_buffer__cpu  = din_mapper[31:24] ;
assign sprite_buffer_wre__cpu   = sel_sprite ? wre_mapper : 1'b0;




//
// MUX de leitura
//
assign dout_mapper =
    sel_main                   ? dout_main_memory :
    sel_control                ? dout_control_cpu_memory :
    sel_colision               ? collision_in_group :
    sel_sdram                  ? dout_sdram_manager :
    sel_ps2_buttons            ? {16'h0,ps2_buttons}:
    data_out_buffer;

reg [31:0] data_out_buffer;
always @(posedge clk) begin
   if(sel_count_pulses_cpu_p1)
        data_out_buffer<=count_pulses_since_riscv_started[63:32];
    else if(sel_count_pulses_cpu_p2)
        data_out_buffer<=count_pulses_since_riscv_started[31:0];
    else if(sel_count_pulses_ppu_p1)
        data_out_buffer<=count_pulses_where_ppu_is_idle[63:32];
    else if(sel_count_pulses_ppu_p2)
        data_out_buffer<=count_pulses_where_ppu_is_idle[31:0];
    else if(sel_count_pulses_ram_p1)
        data_out_buffer<=count_pulses_where_sdram_controller_is_idle[63:32];
    else if(sel_count_pulses_ram_p2)
        data_out_buffer<=count_pulses_where_sdram_controller_is_idle[31:0];
    else if(sel_debug) 
        data_out_buffer<=debug_signal;
    else
        data_out_buffer <=32'h0;
end

endmodule