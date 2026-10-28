module tb();
/********
cmd_type=0x20000000
sdram_addr=0x34
id=3
width=90
height=90
inittial__posix_in_screen=0
inittial_posiy_in_screen=70
rs1=cmd_type|(sdram_addr<<7)|(id<<3)|((width&0x70)>>4)
rs2=((width&0xf)<<28)|(height<<21)|(((inittial__posix_in_screen)&0x3ff)<<11) |(((inittial_posiy_in_screen)&0x1ff)<<2) 
bin(  rs1<<32 | rs2 )
*******/
reg [63:0]  cmd_to_process=64'b10101011010001010101111100111101;
wire [3:0]  cmd_type=cmd_to_process[63:60];
wire [20:0] addr_sdram_to_start=cmd_to_process[59:39];
wire [3:0]  sprit_id=cmd_to_process[38:35];
wire [31:0] color_argb_to_paint=cmd_to_process[31:0];
wire [13:0] start_addr_of_sprite_buffer=cmd_to_process[31:18];
wire [15:0] length_sprite_buffer=cmd_to_process[17:2];
wire [6:0] current_sprite_width=cmd_to_process[34:28];
wire [6:0] current_sprite_height=cmd_to_process[27:21];
wire signed [9:0] inittial__posix_in_screen= cmd_to_process[20:11];
wire signed [8:0] inittial__posiy_in_screen= cmd_to_process[10:2];

wire inv_x_during_render=cmd_to_process[1]; 
wire inv_y_during_render=cmd_to_process[0]; 

reg  [31:0] pallet [0:255];
reg signed [9:0] posix_in_screen;
reg signed [8:0] posiy_in_screen;
localparam [9:0] size_x_screen = 10'sd320;
localparam [8:0] size_y_screen = 9'sd180;
  
   initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    #80 $finish;
  end
endmodule