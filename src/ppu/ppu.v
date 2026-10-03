module PPU(
    input   wire        clk,
    input   wire        rst_n,
    output  reg  [21:0] addr_sdram_manager__pixel_ppu,
    output  reg  [31:0] din_sdram_manager__pixel_ppu,
    input   wire [31:0] dout_sdram_manager__pixel_ppu,
    output  reg         wre_sdram_manager__pixel_ppu,
    input   wire        sdram_manager_is_processing_request_from__pixel_ppu,
    input   wire [6:0]  n_32bits_words_processed_by_current_pixel_ppu_request,
    input   wire [63:0] cmd_to_insert_in_fifo,
    input   wire        wr_cmd,
    output  wire        fifo_cmd_empty,
    output  wire        processing_insert,
    output  wire [15:0] out___collision_stack_cpu,
    input   wire        wre___collision_stack_cpu,
    input   wire [15:0] input___collision_stack_cpu,
    input   wire [9:0]  addr___collision_stack_cpu,
    output  wire [9:0]  collision_stack_size,

    output  wire [7:0]  out_from_sprite_buffer__cpu,
    input   wire        sprite_buffer_wre__cpu,
    input   wire [7:0]  input_to_sprite_buffer__cpu,
    input   wire [13:0] addr_to_sprite_buffer__cpu,
    input   wire        hdmi_ctrl_is_standby,
    output  reg  [31:0] debug_signal,
    output  reg  [63:0] count_pulses_where_ppu_is_idle,
    input   wire        cpu_reseted,
    input   wire        cpu_enabled

);
`define  __LOW_RESOLUTION__
`ifndef __LOW_RESOLUTION__
    `define __N_PIXELS_IN_FRAME_BUFFER 20'd230400
`else
    `define __N_PIXELS_IN_FRAME_BUFFER 20'd57600
`endif
wire [63:0] cmd_to_process;
reg pop_signal;
wire processing_pop;
fifo_cmd_ppu fifo_cmd_ppu__01(
    .clk(clk),
    .rst_n(rst_n),
    .wr_data(cmd_to_insert_in_fifo),
    .wr_en(wr_cmd),
    .rd_data(cmd_to_process),
    .rd_en(pop_signal),
    .empty(fifo_cmd_empty),
    .processing_insert(processing_insert),
    .processing_pop(processing_pop)
);
integer i;
integer i2;
integer i3;
assign collision_stack_size=addr___collision_stack_ppu;
reg wr_cmd___prev;


reg waiting_cmd;




wire [7:0] out_from_sprite_buffer;
reg        sprite_buffer_wre;
reg [7:0]  input_to_sprite_buffer;
reg [13:0] addr_to_sprite_buffer;



Gowin_DPB__Sprite_BUFFER your_instance_name(
        .clka(clk), //input clka
        .ada(addr_to_sprite_buffer), //input [13:0] ada
        .dina(input_to_sprite_buffer), //input [7:0] dina
        .douta(out_from_sprite_buffer), //output [7:0] douta
        .wrea(sprite_buffer_wre), //input wrea
        .clkb(clk), //input clkb
        .adb(addr_to_sprite_buffer__cpu), //input [13:0] adb
        .dinb(input_to_sprite_buffer__cpu), //input [7:0] dinb
        .wreb(sprite_buffer_wre__cpu), //input wreb
        .doutb(out_from_sprite_buffer__cpu),
        .ocea(1'b1), //input ocea
        .cea(1'b1), //input cea
        .reseta(1'b0), //input reseta
        .oceb(1'b1), //input oceb
        .ceb(1'b1), //input ceb
        .resetb(1'b0) //input resetb
);


wire [15:0] out___collision_stack_ppu;
reg         wre___collision_stack_ppu;
reg [15:0]  input___collision_stack_ppu;
reg [9:0]   addr___collision_stack_ppu;

Gowin_DPB_Collision_STACK collision_stack(
    .clka(clk), //input clka
    .ada(addr___collision_stack_ppu), //input [9:0] ada

    
    .dina(input___collision_stack_ppu), //input [15:0] dina
    .douta(out___collision_stack_ppu), //output [15:0] douta
    .wrea(wre___collision_stack_ppu), //input wrea

    .clkb(clk), //input clkb
    .adb(addr___collision_stack_cpu), 

    .dinb(input___collision_stack_cpu), 
    .doutb(out___collision_stack_cpu),
    .wreb(wre___collision_stack_cpu), 

    .ocea(1'b1), //input ocea
    .cea(1'b1), //input cea
    .oceb(1'b1), //input oceb
    .ceb(1'b1), //input ceb
    .resetb(1'b0), //input resetb
    .reseta(1'b0) //input reseta

);

wire [3:0]  cmd_type=cmd_to_process[63:60];
wire [20:0] addr_sdram_to_start=cmd_to_process[59:39];
wire [6:0]  sprit_id=cmd_to_process[38:32];
wire [31:0] color_argb_to_paint=cmd_to_process[31:0];
wire [13:0] start_addr_of_sprite_buffer=cmd_to_process[31:18];
wire [15:0] length_sprite_buffer=cmd_to_process[17:2];
wire [7:0] current_sprite_width=cmd_to_process[31:24];
wire [7:0] current_sprite_height=cmd_to_process[23:16];

wire inv_x_during_render=cmd_to_process[1]; 
wire inv_y_during_render=cmd_to_process[0]; 

reg  [31:0] pallet [0:255];
reg  [15:0] current_sprite_width__latch;
reg  [15:0] current_sprite_height__latch;

localparam cmd_type__load_pallet  = 4'h0;




localparam STATE_IDLE_P0  = 8'h00;
localparam STATE_IDLE_P1  = 8'h40;

localparam STATE_SDRAM_TO_PALLET_P0  = 8'h01;
localparam STATE_SDRAM_TO_PALLET_P1  = 8'h02;
localparam STATE_SDRAM_TO_PALLET_P2  = 8'h03;
localparam STATE_SDRAM_TO_PALLET_P3  = 8'h04;
localparam STATE_SDRAM_TO_BUFFER_P0  = 8'h05;
localparam STATE_SDRAM_TO_BUFFER_P1  = 8'h06;
localparam STATE_SDRAM_TO_BUFFER_P2  = 8'h07;
localparam STATE_SDRAM_TO_BUFFER_P3  = 8'h08;
localparam STATE_SDRAM_TO_BUFFER_P4  = 8'h09;

localparam STATE_RENDER_SPRITE_TO_SDRAM_P0  = 8'h0a;
localparam STATE_RENDER_SPRITE_TO_SDRAM_P1  = 8'h0b;
localparam STATE_RENDER_SPRITE_TO_SDRAM_P2  = 8'h0c;
localparam STATE_RENDER_SPRITE_TO_SDRAM_P3  = 8'h0d;
localparam STATE_RENDER_SPRITE_TO_SDRAM_P4  = 8'h0e;
localparam STATE_RENDER_SPRITE_TO_SDRAM_P5  = 8'h0f;

localparam STATE_CLEAN_FB_P0  = 8'h10;
localparam STATE_CLEAN_FB_P1  = 8'h11;
localparam STATE_CLEAN_FB_P2  = 8'h12;
localparam STATE_CLEAN_FB_P3  = 8'h13;
localparam STATE_CLEAN_FB_P4  = 8'h14;
localparam STATE_CLEAN_FB_P5  = 8'h15;

localparam STATE_CLEAN_COLISION_STACK  = 8'h16;


localparam STATE_INVALID  = 8'hff;

wire sync__state=state==state_prev;
reg [7:0] state;
reg [7:0] state_prev;
reg [7:0] time_that_stage_hold;
always @(posedge clk) begin
    if(rst_n==1'b1) begin
        if(sync__state) begin
            if(time_that_stage_hold<8'hff) begin
                time_that_stage_hold<=time_that_stage_hold+8'h01;
            end
        end
        else begin
            time_that_stage_hold<=8'h00;
        end
        state_prev<=state;
    end
    else begin 
        time_that_stage_hold<=8'h00;
        state_prev<=STATE_INVALID;
    end
end

always @(posedge clk) begin
    if(cpu_reseted) begin
        count_pulses_where_ppu_is_idle<=64'h0;
    end
    else if(fifo_cmd_empty) begin
        if(cpu_enabled)
            count_pulses_where_ppu_is_idle<=count_pulses_where_ppu_is_idle+64'h1;
    end
end

localparam CMD_TYPE__DATA_FROM_SDRAM_TO_BUFFER  = 4'h0;
localparam CMD_TYPE__DATA_FROM_SDRAM_TO_PALLET  = 4'h1;
localparam CMD_TYPE__RENDER_SPRITE = 4'h2;
localparam CMD_TYPE__CLEAN_FRAME_BUFFER = 4'h3;
localparam CMD_TYPE__CLEAN_COLISION_STACK=4'h4;
localparam CMD_TYPE__SET_CURRENT_SPRITE_WIDTH=4'h5;

reg [7:0]  pointer_to_write_in_pallet;
reg [6:0]  pointer_to_write_in_sdram;
reg [19:0] n_pixel_wrote_in_sdram;
reg [19:0] n_pixel_send_to_write_in_sdram;

reg [21:0] pointer_to_get_data_from_sdram;
reg [20:0] addr_sdram;
reg [20:0] addr_sdram_prev;
reg [20:0] addr_sdram_to_start_current_line;
reg [15:0] n_bytes_stored_in_sprite_buffer;
reg [15:0] n_pixels_stored_in_sdram;
reg [1:0]  pointer_get_byte_from__dout_sdram;
reg collision_happened;
reg [7:0] n_pixels_written_to_frame_buffer_line;
reg [20:0] last_n_pixels_written_to_sdram;
reg [15:0] length_sprite_buffer__latch;
always @(posedge clk) begin
    if(!rst_n) begin
        for (i2 = 0; i2 < 256; i2 = i2 + 1) begin
          pallet[i2] <= 32'h0;
        end
        state<=STATE_INVALID;
        pointer_to_write_in_pallet<=8'h0;
        pointer_to_get_data_from_sdram<=22'h0;
        addr_sdram<=21'h0;
        n_bytes_stored_in_sprite_buffer<=16'h0000;
        addr_to_sprite_buffer<=13'h0;
        pointer_get_byte_from__dout_sdram<=2'b00;
        sprite_buffer_wre<=1'b0;
        addr___collision_stack_ppu<=16'h0000;
        wre___collision_stack_ppu<=1'b0;
        input___collision_stack_ppu<=16'h0000;
        collision_happened<=1'b0;
        waiting_cmd<=1'b0;
        debug_signal<=32'hf0000000;
        length_sprite_buffer__latch<=16'h0;
    end
    else begin
        //debug_signal[14:8]<=n_32bits_words_processed_by_current_pixel_ppu_request;
        //debug_signal[16]<=sdram_manager_is_processing_request_from__pixel_ppu;
        //debug_signal[20:0]<=n_pixel_wrote_in_sdram;
        case(state)
            default: state<=STATE_IDLE_P0;
            STATE_IDLE_P0: begin
                if(sync__state==1'b0) begin
                    pop_signal<=1'b1;
                end
                else begin
                    pop_signal<=1'b0;
                    state<=STATE_IDLE_P1;
                end

            end
            STATE_IDLE_P1: begin
                if(processing_pop==1'b0) begin
                    case (cmd_type)
                        CMD_TYPE__DATA_FROM_SDRAM_TO_BUFFER: begin
                            state<=STATE_SDRAM_TO_BUFFER_P0;
                            addr_sdram<=addr_sdram_to_start;
                            addr_to_sprite_buffer<=start_addr_of_sprite_buffer;
                            n_bytes_stored_in_sprite_buffer<=16'h0000;
                        end
                        CMD_TYPE__RENDER_SPRITE: begin
                            state<=STATE_RENDER_SPRITE_TO_SDRAM_P0;
                            addr_sdram<=addr_sdram_to_start;
                            if(inv_y_during_render) begin
                                addr_to_sprite_buffer<=((current_sprite_width*current_sprite_height)-current_sprite_width);
                            end
                            else if(inv_x_during_render) begin
                                addr_to_sprite_buffer<=(current_sprite_width)-16'h1;
                            end
                            else begin
                                addr_to_sprite_buffer<=14'h0;
                            end
                            addr_sdram_to_start_current_line<=addr_sdram_to_start;
                            n_pixels_stored_in_sdram<=16'h0000;
                            input___collision_stack_ppu<=16'h0000;
                            n_pixels_written_to_frame_buffer_line<=8'h00;
                        end
                        CMD_TYPE__DATA_FROM_SDRAM_TO_PALLET: begin
                            state<=STATE_SDRAM_TO_PALLET_P0;
                            pointer_to_write_in_pallet<=8'h0;
                            addr_sdram<=addr_sdram_to_start;
                        end
                        CMD_TYPE__CLEAN_FRAME_BUFFER: begin
                            state<=STATE_CLEAN_FB_P0;
                            addr_sdram<=addr_sdram_to_start;
                            addr_sdram_prev<=addr_sdram_to_start;
                            addr_sdram_manager__pixel_ppu<=22'h0;
                            pointer_to_write_in_sdram<=7'b0000000;
                            n_pixel_wrote_in_sdram<=20'h000;
                        end
                        CMD_TYPE__CLEAN_COLISION_STACK: begin
                            state<=STATE_CLEAN_COLISION_STACK;
                        end
                        CMD_TYPE__SET_CURRENT_SPRITE_WIDTH: begin
                            current_sprite_width__latch[7:0]<=current_sprite_width;
                            current_sprite_height__latch[7:0]<=current_sprite_height;
                            state<=STATE_IDLE_P0;
                        end
                    endcase
                end
            end
            STATE_CLEAN_COLISION_STACK: begin
                addr___collision_stack_ppu<=10'b0;
                state<=STATE_IDLE_P0;
            end
            STATE_CLEAN_FB_P0: begin
                addr_sdram_manager__pixel_ppu[21:13]<=9'b100000001;
                addr_sdram_manager__pixel_ppu[5:0]<=pointer_to_write_in_sdram[5:0];
                n_pixel_send_to_write_in_sdram<=n_pixel_send_to_write_in_sdram+20'h1;
                din_sdram_manager__pixel_ppu<=color_argb_to_paint; 
                wre_sdram_manager__pixel_ppu<=1'b1;
                pointer_to_write_in_sdram<=pointer_to_write_in_sdram+7'b0000001;
                state<=STATE_CLEAN_FB_P1;
            end
            STATE_CLEAN_FB_P1: begin 
                if(sync__state==1'b1 && time_that_stage_hold==8'h00) begin
                    wre_sdram_manager__pixel_ppu<=1'b0;
                    if( pointer_to_write_in_sdram==7'b1000000) begin
                        state<=STATE_CLEAN_FB_P2;
                    end
                    else begin
                        state<=STATE_CLEAN_FB_P0;
                    end
                end
            end
            STATE_CLEAN_FB_P2: begin       
                addr_sdram_manager__pixel_ppu<= 22'b1000000000000000000000;
                din_sdram_manager__pixel_ppu <= {2'b00, addr_sdram, pointer_to_write_in_sdram, 2'b01};
                wre_sdram_manager__pixel_ppu<=1'b1;
                n_pixel_wrote_in_sdram<=n_pixel_wrote_in_sdram+20'd64;
                state<=STATE_CLEAN_FB_P3;
            end
            STATE_CLEAN_FB_P3: begin

                if(sync__state && time_that_stage_hold>8'h04) begin
                    wre_sdram_manager__pixel_ppu<=1'b0;
                    if( sdram_manager_is_processing_request_from__pixel_ppu==1'b0) begin
                        if(n_pixel_wrote_in_sdram!=`__N_PIXELS_IN_FRAME_BUFFER) begin
                            addr_sdram<=addr_sdram+20'd64;
                            state<=STATE_CLEAN_FB_P2;
                        end
                        else begin
                            state<=STATE_IDLE_P0;
                        end
                    end
                end
            end
            STATE_SDRAM_TO_BUFFER_P0: begin
                length_sprite_buffer__latch<=length_sprite_buffer;
                din_sdram_manager__pixel_ppu <= {2'b00, addr_sdram, 7'b1000000, 2'b00};
                addr_sdram_manager__pixel_ppu<= 22'b1000000000000000000000;
                wre_sdram_manager__pixel_ppu<=1'b1;
                state<=STATE_SDRAM_TO_BUFFER_P1;
            end

            STATE_SDRAM_TO_BUFFER_P1: begin
                 if(sync__state && time_that_stage_hold>8'h01) begin
                    wre_sdram_manager__pixel_ppu<=1'b0;
                end
                if(sync__state && time_that_stage_hold> 8'h08) begin
                    if(sdram_manager_is_processing_request_from__pixel_ppu==1'b0) begin
                        state<=STATE_SDRAM_TO_BUFFER_P2;
                        pointer_to_get_data_from_sdram<=22'h0;
                    end
                end
            end
            STATE_SDRAM_TO_BUFFER_P2: begin
                addr_sdram_manager__pixel_ppu<=pointer_to_get_data_from_sdram;
                pointer_to_get_data_from_sdram<=pointer_to_get_data_from_sdram+22'h1;
                if(pointer_to_get_data_from_sdram[6:0]==7'b1000000) begin
                    state<=STATE_SDRAM_TO_BUFFER_P0; 
                    addr_sdram<=addr_sdram+21'd64;
                end
                else begin 
                    state<=STATE_SDRAM_TO_BUFFER_P3;
                end
                pointer_get_byte_from__dout_sdram<=2'b00;
            end
            STATE_SDRAM_TO_BUFFER_P3: begin
                
                if(pointer_get_byte_from__dout_sdram==2'b11)
                    input_to_sprite_buffer<=dout_sdram_manager__pixel_ppu[7:0];
                else if(pointer_get_byte_from__dout_sdram==2'b10)  
                    input_to_sprite_buffer<=dout_sdram_manager__pixel_ppu[15:8];
                else if(pointer_get_byte_from__dout_sdram==2'b01)  
                    input_to_sprite_buffer<=dout_sdram_manager__pixel_ppu[23:16];
                else
                    input_to_sprite_buffer<=dout_sdram_manager__pixel_ppu[31:24];
                
                if(sync__state && time_that_stage_hold>8'h03) begin    
                    pointer_get_byte_from__dout_sdram<=pointer_get_byte_from__dout_sdram+2'b01;
                    sprite_buffer_wre<=1'b1;
                    n_bytes_stored_in_sprite_buffer<=n_bytes_stored_in_sprite_buffer+16'h1;
                    state<=STATE_SDRAM_TO_BUFFER_P4;
                end
            end
            STATE_SDRAM_TO_BUFFER_P4: begin
                if(sync__state && time_that_stage_hold>8'h03) begin    
                    sprite_buffer_wre<=1'b0;

                    addr_to_sprite_buffer<=addr_to_sprite_buffer+14'h1;
                    if(n_bytes_stored_in_sprite_buffer==length_sprite_buffer__latch) begin
                        state<=STATE_IDLE_P0;
                    end
                    else if(pointer_get_byte_from__dout_sdram==2'b00) begin
                        state<=STATE_SDRAM_TO_BUFFER_P2;
                    end
                    else begin
                        state<=STATE_SDRAM_TO_BUFFER_P3;
                    end
                end
            end
            STATE_RENDER_SPRITE_TO_SDRAM_P0: begin
                addr_sdram_prev<=addr_sdram;
                din_sdram_manager__pixel_ppu <= {2'b00, addr_sdram, 7'b1000000, 2'b00};
                addr_sdram_manager__pixel_ppu<= 22'b1000000000000000000000;
                wre_sdram_manager__pixel_ppu<=1'b1;
                state<=STATE_RENDER_SPRITE_TO_SDRAM_P1;
            end
            STATE_RENDER_SPRITE_TO_SDRAM_P1: begin
                if(sync__state && time_that_stage_hold>8'h01) begin
                    wre_sdram_manager__pixel_ppu<=1'b0;
                end
                if(sync__state && time_that_stage_hold> 8'h04) begin
                    if(sdram_manager_is_processing_request_from__pixel_ppu==1'b1) begin
                        state<=STATE_RENDER_SPRITE_TO_SDRAM_P2;
                        pointer_to_get_data_from_sdram<=22'h0;
                    end
                end
            end
            STATE_RENDER_SPRITE_TO_SDRAM_P2: begin
                if((pointer_to_get_data_from_sdram[6:0]+7'b1)<n_32bits_words_processed_by_current_pixel_ppu_request || sdram_manager_is_processing_request_from__pixel_ppu==1'b0) begin
                    addr_sdram_manager__pixel_ppu<=pointer_to_get_data_from_sdram;
                    pointer_to_get_data_from_sdram<=pointer_to_get_data_from_sdram+22'h1;
                    state<=STATE_RENDER_SPRITE_TO_SDRAM_P3;
                    debug_signal[6:0]<=n_32bits_words_processed_by_current_pixel_ppu_request;
                end
            end
            STATE_RENDER_SPRITE_TO_SDRAM_P3: begin
                if(sync__state) begin
                    addr_sdram<=addr_sdram+21'h1;
                    n_pixels_written_to_frame_buffer_line<=n_pixels_written_to_frame_buffer_line+8'h01;
                    addr_sdram_manager__pixel_ppu[21:13]<=9'b100000001;
                    if(n_pixels_stored_in_sdram<length_sprite_buffer__latch)  begin
                        if(dout_sdram_manager__pixel_ppu[30:24]!=7'b0000000) begin
                            `ifdef ___COLISSION___ 
                            if(input___collision_stack_ppu[15:8]!=dout_sdram_manager__pixel_ppu[31:24] || input___collision_stack_ppu[6:0]!=sprit_id) begin
                                if(out_from_sprite_buffer==8'hff) begin
                                    input___collision_stack_ppu<={dout_sdram_manager__pixel_ppu[31:24],1'b1,sprit_id};
                                end
                                else begin
                                    input___collision_stack_ppu<={dout_sdram_manager__pixel_ppu[31:24],1'b0,sprit_id};
                                end
                                wre___collision_stack_ppu<=1'b1;
                                collision_happened<=1'b1;
                            end

                            else collision_happened<=1'b0;
                            `endif
                        end
                        if(out_from_sprite_buffer==8'hff) begin
                            din_sdram_manager__pixel_ppu<={1'b1,sprit_id,dout_sdram_manager__pixel_ppu[23:0]};
                        end
                        else begin
                            din_sdram_manager__pixel_ppu<={1'b0,sprit_id,pallet[out_from_sprite_buffer][23:0]};
                        end
                    end
                    else begin
                        din_sdram_manager__pixel_ppu<=dout_sdram_manager__pixel_ppu;
                    end
                    wre_sdram_manager__pixel_ppu<=1'b1;
                    state<=STATE_RENDER_SPRITE_TO_SDRAM_P4;
                end
            end
            STATE_RENDER_SPRITE_TO_SDRAM_P4: begin
                wre___collision_stack_ppu<=1'b0;
                wre_sdram_manager__pixel_ppu<=1'b0;

                if(sync__state) begin 
                    if(
                        pointer_to_get_data_from_sdram[6:0]==7'b1000000 || (n_pixels_stored_in_sdram==length_sprite_buffer__latch) ||
                        (n_pixels_written_to_frame_buffer_line==current_sprite_width)
                    ) begin
                        if(sdram_manager_is_processing_request_from__pixel_ppu==1'b0) begin
                            din_sdram_manager__pixel_ppu <= {2'b00, addr_sdram_prev, pointer_to_get_data_from_sdram[6:0], 2'b01};
                            addr_sdram_manager__pixel_ppu<= 22'b1000000000000000000000;
                            wre_sdram_manager__pixel_ppu<=1'b1;
                            last_n_pixels_written_to_sdram[6:0]<=pointer_to_get_data_from_sdram[6:0];
                            state<=STATE_RENDER_SPRITE_TO_SDRAM_P5;
                        end
                    end
                    else begin 
                        state<=STATE_RENDER_SPRITE_TO_SDRAM_P2;
                    end                    
                end
                else begin
                    if(n_pixels_written_to_frame_buffer_line<current_sprite_width || (inv_y_during_render==1'b0 && inv_x_during_render==1'b0)) begin
                        if(inv_x_during_render==1'b0) begin
                            addr_to_sprite_buffer<=addr_to_sprite_buffer+14'b1;
                        end
                        else begin
                            addr_to_sprite_buffer<=addr_to_sprite_buffer-14'b1;
                        end
                    end
                    else begin
                        if(inv_y_during_render) begin
                            addr_to_sprite_buffer<=addr_to_sprite_buffer-(current_sprite_width<<1)+16'h1;
                        end
                        else if(inv_x_during_render) begin
                            addr_to_sprite_buffer<=n_pixels_stored_in_sdram;
                        end
                        
                        
                    end
                   
                    if(collision_happened) begin
                        addr___collision_stack_ppu<=addr___collision_stack_ppu+10'b0000000001;
                    end
                    if(n_pixels_stored_in_sdram<length_sprite_buffer__latch) 
                        n_pixels_stored_in_sdram<=n_pixels_stored_in_sdram+16'h0001;
                end
            end
            STATE_RENDER_SPRITE_TO_SDRAM_P5: begin
                if(sync__state==1'b0) begin
                    if(n_pixels_written_to_frame_buffer_line==current_sprite_width) begin
                        n_pixels_written_to_frame_buffer_line<=8'h00;
                        `ifndef __LOW_RESOLUTION__
                        addr_sdram<=addr_sdram_to_start_current_line+21'd640;
                        addr_sdram_to_start_current_line<=addr_sdram_to_start_current_line+21'd640;
                        `else 
                        addr_sdram<=addr_sdram_to_start_current_line+21'd320;
                        addr_sdram_to_start_current_line<=addr_sdram_to_start_current_line+21'd320;
                        `endif
                    end
                    else begin
                        addr_sdram<=addr_sdram_prev+last_n_pixels_written_to_sdram;
                    end
                end
                if(sync__state && time_that_stage_hold>8'h01) begin
                    wre_sdram_manager__pixel_ppu<=1'b0;
                    
                end
                if(sync__state && time_that_stage_hold> 8'h04) begin
                    if(sdram_manager_is_processing_request_from__pixel_ppu==1'b0) begin
                        if(n_pixels_stored_in_sdram<length_sprite_buffer__latch)
                            state<=STATE_RENDER_SPRITE_TO_SDRAM_P0;
                        else begin
                            state <= STATE_IDLE_P0;
                        end
                    end
                end
            end
            STATE_SDRAM_TO_PALLET_P0: begin
                din_sdram_manager__pixel_ppu <= {2'b00, addr_sdram, 7'b1000000, 2'b00};
                addr_sdram_manager__pixel_ppu<= 22'b1000000000000000000000;
                wre_sdram_manager__pixel_ppu<=1'b1;
                state<=STATE_SDRAM_TO_PALLET_P1;
                
            end
            STATE_SDRAM_TO_PALLET_P1: begin
                if(sync__state && time_that_stage_hold>8'h01) begin
                    wre_sdram_manager__pixel_ppu<=1'b0;
                end
                if(sync__state && time_that_stage_hold> 8'h02) begin
                    if(sdram_manager_is_processing_request_from__pixel_ppu==1'b0) begin
                        state<=STATE_SDRAM_TO_PALLET_P2;
                        pointer_to_get_data_from_sdram<=22'h0;
                    end
                end
            end
            STATE_SDRAM_TO_PALLET_P2: begin
                addr_sdram_manager__pixel_ppu<=pointer_to_get_data_from_sdram;
                pointer_to_get_data_from_sdram<=pointer_to_get_data_from_sdram+22'h1;
                state<=STATE_SDRAM_TO_PALLET_P3;
            end
            STATE_SDRAM_TO_PALLET_P3: begin
                if(sync__state && time_that_stage_hold> 8'h01) begin
                    addr_sdram<=addr_sdram+21'h1;
                    pallet[pointer_to_write_in_pallet]<=dout_sdram_manager__pixel_ppu;
                    pointer_to_write_in_pallet<=pointer_to_write_in_pallet+8'h01;
                    if(pointer_to_write_in_pallet==8'hff) begin
                        state<=STATE_IDLE_P0;
                    end
                    else if(pointer_to_get_data_from_sdram[6:0]==7'b1000000 ) begin
                        state<=STATE_SDRAM_TO_PALLET_P0;
                    end
                    else begin
                        state<=STATE_SDRAM_TO_PALLET_P2;
                    end
                end
            end
        endcase
        
    end
end
endmodule