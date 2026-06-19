module TestPattern
(
	input              I_pxl_clk   ,//pixel clock
    input              I_rst_n     ,//low active 
    input      [2:0]   I_mode      ,//data select
    input      [7:0]   I_single_r  ,
    input      [7:0]   I_single_g  ,
    input      [7:0]   I_single_b  ,
    input      [11:0]  I_h_total   ,//hor total time 
    input      [11:0]  I_h_sync    ,//hor sync time
    input      [11:0]  I_h_bporch  ,//hor back porch
    input      [11:0]  I_h_res     ,//hor resolution
    input      [11:0]  I_v_total   ,//ver total time 
    input      [11:0]  I_v_sync    ,//ver sync time  
    input      [11:0]  I_v_bporch  ,//ver back porch  
    input      [11:0]  I_v_res     ,//ver resolution 
    input              I_hs_pol    ,//HS polarity 
    input              I_vs_pol    ,//VS polarity 
    output             O_de        ,   
    output reg         O_hs        ,
    output reg         O_vs        ,
    output      [7:0]  O_data_r    ,    
    output      [7:0]  O_data_g    ,
    output      [7:0]  O_data_b    ,
	output reg  [21:0] addr_sdram_manager__hdmi_controller,
    output reg  [31:0] din_sdram_manager__hdmi_controller,
    input  wire [31:0] dout_sdram_manager__hdmi_controller,
    output reg         wre_sdram_manager__hdmi_controller,
    input  wire        processing_request_from__hdmi_controller,
	input  wire        rst_n_paint,
	output reg  [31:0] debug_signal_draw
); 

localparam N = 5;
reg  [11:0]   V_cnt     ;
reg  [11:0]   H_cnt     ;
              
wire          Pout_de_w    ;                          
wire          Pout_hs_w    ;
wire          Pout_vs_w    ;

reg  [N-1:0]  Pout_de_dn   ;                          
reg  [N-1:0]  Pout_hs_dn   ;
reg  [N-1:0]  Pout_vs_dn   ;

//----------------------------
wire 		  De_pos;
wire 		  De_neg;
wire 		  Vs_pos;
	
reg  [11:0]   De_vcnt     ;
reg  [11:0]   De_hcnt     ;
reg  [11:0]   De_hcnt_d1  ;
reg  [11:0]   De_hcnt_d2  ;


//-------------------------------
reg  [23:0]   Data_tmp/*synthesis syn_keep=1*/;

//==============================================================================
//Generate HS, VS, DE signals
always@(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		V_cnt <= 12'd0;
	else     
		begin
			if((V_cnt >= (I_v_total-1'b1)) && (H_cnt >= (I_h_total-1'b1)))
				V_cnt <= 12'd0;
			else if(H_cnt >= (I_h_total-1'b1))
				V_cnt <=  V_cnt + 1'b1;
			else
				V_cnt <= V_cnt;
		end
end

//-------------------------------------------------------------    
always @(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		H_cnt <=  12'd0; 
	else if(H_cnt >= (I_h_total-1'b1))
		H_cnt <=  12'd0 ; 
	else 
		H_cnt <=  H_cnt + 1'b1 ;           
end

//-------------------------------------------------------------
assign  Pout_de_w = ((H_cnt>=(I_h_sync+I_h_bporch))&(H_cnt<=(I_h_sync+I_h_bporch+I_h_res-1'b1)))&
                    ((V_cnt>=(I_v_sync+I_v_bporch))&(V_cnt<=(I_v_sync+I_v_bporch+I_v_res-1'b1))) ;
assign  Pout_hs_w =  ~((H_cnt>=12'd0) & (H_cnt<=(I_h_sync-1'b1))) ;
assign  Pout_vs_w =  ~((V_cnt>=12'd0) & (V_cnt<=(I_v_sync-1'b1))) ;  

//-------------------------------------------------------------
always@(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		begin
			Pout_de_dn  <= {N{1'b0}};                          
			Pout_hs_dn  <= {N{1'b1}};
			Pout_vs_dn  <= {N{1'b1}}; 
		end
	else 
		begin
			Pout_de_dn  <= {Pout_de_dn[N-2:0],Pout_de_w};                          
			Pout_hs_dn  <= {Pout_hs_dn[N-2:0],Pout_hs_w};
			Pout_vs_dn  <= {Pout_vs_dn[N-2:0],Pout_vs_w}; 
		end
end

assign O_de = Pout_de_dn[4];

always@(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		begin                        
			O_hs  <= 1'b1;
			O_vs  <= 1'b1; 
		end
	else 
		begin                         
			O_hs  <= I_hs_pol ? ~Pout_hs_dn[3] : Pout_hs_dn[3] ;
			O_vs  <= I_vs_pol ? ~Pout_vs_dn[3] : Pout_vs_dn[3] ;
		end
end

//=================================================================================
//Test Pattern
assign De_pos	= !Pout_de_dn[1] & Pout_de_dn[0]; //de rising edge
assign De_neg	= Pout_de_dn[1] && !Pout_de_dn[0];//de falling edge
assign Vs_pos	= !Pout_vs_dn[1] && Pout_vs_dn[0];//vs rising edge

always @(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		De_hcnt <= 12'd0;
	else if (De_pos == 1'b1)
		De_hcnt <= 12'd0;
	else if (Pout_de_dn[1] == 1'b1)
		De_hcnt <= De_hcnt + 1'b1;
	else
		De_hcnt <= De_hcnt;
end

always @(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n) 
		De_vcnt <= 12'd0;
	else if (Vs_pos == 1'b1)
		De_vcnt <= 12'd0;
	else if (De_neg == 1'b1)
		De_vcnt <= De_vcnt + 1'b1;
	else
		De_vcnt <= De_vcnt;
end











// =====================================================
// RED
// =====================================================

reg         wrea___line_buffer__write__red;
reg         wreb___line_buffer__write__red;

wire  [9:0]  ada___line_buffer__write__red;
wire  [9:0]  adb___line_buffer__write__red;

reg  [7:0]  dina___line_buffer__write__red;
reg  [7:0]  dinb___line_buffer__write__red;

reg  [9:0]  ada___line_buffer__read__red;
reg  [9:0]  adb___line_buffer__read__red;

wire [7:0]  douta___line_buffer__read__red;
wire [7:0]  doutb___line_buffer__read__red;


// =====================================================
// GREEN
// =====================================================

reg         wrea___line_buffer__write__green;
reg         wreb___line_buffer__write__green;

wire  [9:0]  ada___line_buffer__write__green;
wire  [9:0]  adb___line_buffer__write__green;

reg  [7:0]  dina___line_buffer__write__green;
reg  [7:0]  dinb___line_buffer__write__green;

reg  [9:0]  ada___line_buffer__read__green;
reg  [9:0]  adb___line_buffer__read__green;

wire [7:0]  douta___line_buffer__read__green;
wire [7:0]  doutb___line_buffer__read__green;


// =====================================================
// BLUE
// =====================================================

reg         wrea___line_buffer__write__blue;
reg         wreb___line_buffer__write__blue;

wire  [9:0]  ada___line_buffer__write__blue;
wire  [9:0]  adb___line_buffer__write__blue;

reg  [7:0]  dina___line_buffer__write__blue;
reg  [7:0]  dinb___line_buffer__write__blue;

reg  [9:0]  ada___line_buffer__read__blue;
reg  [9:0]  adb___line_buffer__read__blue;

wire [7:0]  douta___line_buffer__read__blue;
wire [7:0]  doutb___line_buffer__read__blue;

reg [9:0] ad___line_buffer__write;
reg [9:0] ad___line_buffer__write_delay;
assign ada___line_buffer__write__red=ad___line_buffer__write;
assign adb___line_buffer__write__red=ad___line_buffer__write+10'b1;
assign ada___line_buffer__write__green=ad___line_buffer__write;
assign adb___line_buffer__write__green=ad___line_buffer__write+10'b1;
assign ada___line_buffer__write__blue=ad___line_buffer__write;
assign adb___line_buffer__write__blue=ad___line_buffer__write+10'b1;
// =====================================================
// PING-PONG CONTROL
// =====================================================

reg rd__buffer1;
reg rd__buffer1_prev;
reg rd__buffer1___changed;
reg rd__buffer1___changed__reset;

line_buffer_pingpong_rgb line_buffers (
    .clk(I_pxl_clk),
    .rd__buffer1(rd__buffer1),

    // RED
    .wrea_red(wrea___line_buffer__write__red),
    .wreb_red(wreb___line_buffer__write__red),
    .ada_red_write(ada___line_buffer__write__red),
    .adb_red_write(adb___line_buffer__write__red),
    .dina_red_write(dina___line_buffer__write__red),
    .dinb_red_write(dinb___line_buffer__write__red),
    .ada_red_read(ada___line_buffer__read__red),
    .adb_red_read(adb___line_buffer__read__red),
    .douta_red(douta___line_buffer__read__red),
    .doutb_red(doutb___line_buffer__read__red),

    // GREEN
    .wrea_green(wrea___line_buffer__write__green),
    .wreb_green(wreb___line_buffer__write__green),
    .ada_green_write(ada___line_buffer__write__green),
    .adb_green_write(adb___line_buffer__write__green),
    .dina_green_write(dina___line_buffer__write__green),
    .dinb_green_write(dinb___line_buffer__write__green),
    .ada_green_read(ada___line_buffer__read__green),
    .adb_green_read(adb___line_buffer__read__green),
    .douta_green(douta___line_buffer__read__green),
    .doutb_green(doutb___line_buffer__read__green),

    // BLUE
    .wrea_blue(wrea___line_buffer__write__blue),
    .wreb_blue(wreb___line_buffer__write__blue),
    .ada_blue_write(ada___line_buffer__write__blue),
    .adb_blue_write(adb___line_buffer__write__blue),
    .dina_blue_write(dina___line_buffer__write__blue),
    .dinb_blue_write(dinb___line_buffer__write__blue),
    .ada_blue_read(ada___line_buffer__read__blue),
    .adb_blue_read(adb___line_buffer__read__blue),
    .douta_blue(douta___line_buffer__read__blue),
    .doutb_blue(doutb___line_buffer__read__blue)
);


reg  [20:0] pointer_to_get_next_64_32bits_words;
wire [20:0] addr_to_first_line_of_fb_in_sdram=21'h0;
reg  [11:0] n_line_being_obtained;
reg  [11:0] n_32bits_word_being_obtained_from_the_line;
wire [6:0] n_32bits_word_to_get_in_every_sdram_request=7'b1000000;
reg  [21:0] pointer_to_read_sdram_buffer;

reg  [3:0] st_rd_img_lines;
reg  [3:0] st_rd_img_lines___prev;
reg  [7:0] time_that___st_rd_img_lines___hold;
reg  [3:0]  position_to_write_rgb_pixel;
wire sync__st_rd_img_lines=st_rd_img_lines==st_rd_img_lines___prev;

always @(posedge I_pxl_clk) begin
    if(!rst_n_paint) begin 
        time_that___st_rd_img_lines___hold<=8'h00;
        st_rd_img_lines___prev<=ST_RD_IMG_LINES___IDLE;
    end
    else begin
        if(sync__st_rd_img_lines) begin
            if(time_that___st_rd_img_lines___hold<8'hff) begin
                time_that___st_rd_img_lines___hold<=time_that___st_rd_img_lines___hold+8'h01;
            end
        end
        else begin
            time_that___st_rd_img_lines___hold<=8'h00;
        end
        st_rd_img_lines___prev<=st_rd_img_lines;
    end
end


localparam [3:0] ST_RD_IMG_LINES___IDLE             =  4'h0;
localparam [3:0] ST_RD_IMG_LINES___WAIT_RAM_READ    =  4'h2;
localparam [3:0] ST_RD_IMG_LINES___READ_RAM_BUFFER  =  4'h3;
localparam [3:0] ST_RD_IMG_LINES___WAIT_WRITE_READY =  4'h4;

always @(posedge I_pxl_clk ) begin
	if(!rst_n_paint) begin
		pointer_to_get_next_64_32bits_words<=addr_to_first_line_of_fb_in_sdram;
		n_line_being_obtained<=12'h000;
		addr_sdram_manager__hdmi_controller<=22'b1000000000000000000000;
		n_32bits_word_being_obtained_from_the_line<=12'h000;
		din_sdram_manager__hdmi_controller<={2'b00,addr_to_first_line_of_fb_in_sdram,n_32bits_word_to_get_in_every_sdram_request,2'b00};
		st_rd_img_lines<=ST_RD_IMG_LINES___IDLE;
		pointer_to_read_sdram_buffer<=22'b0;
		wrea___line_buffer__write__red    <=1'b0;
		wrea___line_buffer__write__green  <=1'b0;
		wrea___line_buffer__write__blue   <=1'b0;
		wreb___line_buffer__write__red    <=1'b0;
		wreb___line_buffer__write__green  <=1'b0;
		wreb___line_buffer__write__blue   <=1'b0;
		rd__buffer1_prev<=1'b1;
		rd__buffer1___changed<=1'b1;
		rd__buffer1___changed__reset<=1'b0;
		wre_sdram_manager__hdmi_controller<=1'b0;
		position_to_write_rgb_pixel<=4'h0;
		ad___line_buffer__write_delay<=10'b0;
	end
	else begin
		rd__buffer1_prev<=rd__buffer1;
		if(rd__buffer1___changed__reset) begin
			rd__buffer1___changed<=1'b0;
		end
		else if(rd__buffer1_prev!=rd__buffer1) begin
			rd__buffer1___changed<=1'b1;
		end
		case(st_rd_img_lines)
            default: st_rd_img_lines<=ST_RD_IMG_LINES___IDLE;
			ST_RD_IMG_LINES___IDLE: begin
				pointer_to_get_next_64_32bits_words<=addr_to_first_line_of_fb_in_sdram;
				n_line_being_obtained<=12'h000;

				if(rd__buffer1___changed) begin
					st_rd_img_lines<=ST_RD_IMG_LINES___WAIT_RAM_READ;
					rd__buffer1___changed__reset<=1'b1;
					addr_sdram_manager__hdmi_controller<=22'b1000000000000000000000;
					wre_sdram_manager__hdmi_controller<=1'b1;
					n_32bits_word_being_obtained_from_the_line<=12'h000;
					din_sdram_manager__hdmi_controller<={
						2'b00,
						addr_to_first_line_of_fb_in_sdram,
						n_32bits_word_to_get_in_every_sdram_request,
						2'b00
					};
				end
				wrea___line_buffer__write__red    <=1'b0;
				wrea___line_buffer__write__green  <=1'b0;
				wrea___line_buffer__write__blue   <=1'b0;
				wreb___line_buffer__write__red    <=1'b0;
				wreb___line_buffer__write__green  <=1'b0;
				wreb___line_buffer__write__blue   <=1'b0;
			end
			ST_RD_IMG_LINES___WAIT_RAM_READ: begin
				rd__buffer1___changed__reset<=1'b0;

				position_to_write_rgb_pixel<=4'h0;
				wre_sdram_manager__hdmi_controller<=1'b0;
				ad___line_buffer__write_delay<=10'b0;

				if(sync__st_rd_img_lines && time_that___st_rd_img_lines___hold>8'h02) begin
					if(processing_request_from__hdmi_controller==1'b0) begin
						st_rd_img_lines<=ST_RD_IMG_LINES___READ_RAM_BUFFER;
						addr_sdram_manager__hdmi_controller<=22'b0;
					end
				end
				wrea___line_buffer__write__red    <=1'b0;
				wrea___line_buffer__write__green  <=1'b0;
				wrea___line_buffer__write__blue   <=1'b0;
				wreb___line_buffer__write__red    <=1'b0;
				wreb___line_buffer__write__green  <=1'b0;
				wreb___line_buffer__write__blue   <=1'b0;
			end
			ST_RD_IMG_LINES___READ_RAM_BUFFER: begin
				if(addr_sdram_manager__hdmi_controller[5:0]==6'b0) 
					pointer_to_get_next_64_32bits_words<=pointer_to_get_next_64_32bits_words+21'b1;
				if(addr_sdram_manager__hdmi_controller[5:0]==6'b111111 && n_32bits_word_being_obtained_from_the_line<12'd479)begin
					
					din_sdram_manager__hdmi_controller<={
						2'b00,
						pointer_to_get_next_64_32bits_words,
						n_32bits_word_to_get_in_every_sdram_request,
						2'b00
					};
					wre_sdram_manager__hdmi_controller<=1'b1;
					st_rd_img_lines<=ST_RD_IMG_LINES___WAIT_RAM_READ;
				end
				else if (addr_sdram_manager__hdmi_controller[5:0]==6'b111111 && n_line_being_obtained<12'd360) begin
					st_rd_img_lines<=ST_RD_IMG_LINES___WAIT_WRITE_READY;
					wre_sdram_manager__hdmi_controller<=1'b0;
				end
				else if(addr_sdram_manager__hdmi_controller[5:0]==6'b111111) begin
					st_rd_img_lines<=ST_RD_IMG_LINES___IDLE;
					wre_sdram_manager__hdmi_controller<=1'b0;
				end
				addr_sdram_manager__hdmi_controller<=addr_sdram_manager__hdmi_controller+22'b1;
				n_32bits_word_being_obtained_from_the_line<=n_32bits_word_being_obtained_from_the_line+12'h001;
				case (position_to_write_rgb_pixel) 
					4'h0: begin
						dina___line_buffer__write__red<=dout_sdram_manager__hdmi_controller[31:24];
						dina___line_buffer__write__green<=dout_sdram_manager__hdmi_controller[23:16];
						dina___line_buffer__write__blue<=dout_sdram_manager__hdmi_controller[15:8];
						dinb___line_buffer__write__red<=dout_sdram_manager__hdmi_controller[7:0];
						wrea___line_buffer__write__red    <=1'b1;
						wrea___line_buffer__write__green  <=1'b1;
						wrea___line_buffer__write__blue   <=1'b1;
						wreb___line_buffer__write__red    <=1'b1;
						wreb___line_buffer__write__green  <=1'b0;
						wreb___line_buffer__write__blue   <=1'b0;
						ad___line_buffer__write<=ad___line_buffer__write_delay;
						ad___line_buffer__write_delay<=ad___line_buffer__write_delay+10'b0000000001;
						position_to_write_rgb_pixel<=4'h1;
					end
					4'h1: begin
						dina___line_buffer__write__green<=dout_sdram_manager__hdmi_controller[31:24];
						dina___line_buffer__write__blue<=dout_sdram_manager__hdmi_controller[23:16];
						dinb___line_buffer__write__red<=dout_sdram_manager__hdmi_controller[15:8];
						dinb___line_buffer__write__green<=dout_sdram_manager__hdmi_controller[7:0];
						wrea___line_buffer__write__red    <=1'b0;
						wrea___line_buffer__write__green  <=1'b1;
						wrea___line_buffer__write__blue   <=1'b1;
						wreb___line_buffer__write__red    <=1'b1;
						wreb___line_buffer__write__green  <=1'b1;
						wreb___line_buffer__write__blue   <=1'b0;
						ad___line_buffer__write<=ad___line_buffer__write_delay;
						ad___line_buffer__write_delay<=ad___line_buffer__write_delay+10'b0000000001;
						position_to_write_rgb_pixel<=4'h2;
					end
					4'h2: begin
						dina___line_buffer__write__blue<=dout_sdram_manager__hdmi_controller[31:24];
						dinb___line_buffer__write__red<=dout_sdram_manager__hdmi_controller[23:16];
						dinb___line_buffer__write__green<=dout_sdram_manager__hdmi_controller[15:8];
						dinb___line_buffer__write__blue<=dout_sdram_manager__hdmi_controller[7:0];
						wrea___line_buffer__write__red    <=1'b0;
						wrea___line_buffer__write__green  <=1'b0;
						wrea___line_buffer__write__blue   <=1'b1;
						wreb___line_buffer__write__red    <=1'b1;
						wreb___line_buffer__write__green  <=1'b1;
						wreb___line_buffer__write__blue   <=1'b1;
						ad___line_buffer__write<=ad___line_buffer__write_delay;
						ad___line_buffer__write_delay<=ad___line_buffer__write_delay+10'b0000000010;
						position_to_write_rgb_pixel<=4'h0;
					end

				endcase	
			end
			ST_RD_IMG_LINES___WAIT_WRITE_READY: begin
				if(rd__buffer1___changed) begin

					rd__buffer1___changed__reset<=1'b1;

					din_sdram_manager__hdmi_controller<={
						2'b00,
						pointer_to_get_next_64_32bits_words,
						n_32bits_word_to_get_in_every_sdram_request,
						2'b00
					};
					wre_sdram_manager__hdmi_controller<=1'b1;
					st_rd_img_lines<=ST_RD_IMG_LINES___WAIT_RAM_READ;
					addr_sdram_manager__hdmi_controller<=22'b1000000000000000000000;
					n_line_being_obtained<=n_line_being_obtained+12'h001;
					n_32bits_word_being_obtained_from_the_line<=12'h000;


					wrea___line_buffer__write__red    <=1'b0;
					wrea___line_buffer__write__green  <=1'b0;
					wrea___line_buffer__write__blue   <=1'b0;
					wreb___line_buffer__write__red    <=1'b0;
					wreb___line_buffer__write__green  <=1'b0;
					wreb___line_buffer__write__blue   <=1'b0;
				end
			end

		endcase
		
	end
end

reg [11:0] V_cnt_prev;
reg [31:0] count_debug;
reg [3:0]  count_debug_2;

always @(posedge I_pxl_clk)
begin
	
	if(!rst_n_paint) begin
		
		rd__buffer1<=1'b1;
		Data_tmp <= 24'd0;
		V_cnt_prev<=12'h000;
		De_hcnt_d1<=12'h000;
		De_hcnt_d2<=12'h000;
		count_debug<=32'h00000000;
		count_debug_2<=4'h0;
		debug_signal_draw<=32'h00000000;

	end
	else begin
		De_hcnt_d1<=De_hcnt;
		De_hcnt_d2<=De_hcnt_d1;
		V_cnt_prev<=V_cnt;
		if(V_cnt>=12'h017 && V_cnt<=12'h2e7 && V_cnt_prev!=V_cnt) begin
			if( ((V_cnt - 12'h017) & 12'h001) == 0 && (V_cnt != 12'h017)) begin
				rd__buffer1<=!rd__buffer1;
				debug_signal_draw<=rd__buffer1;
			end
		end
		if(Pout_de_dn[3]) begin
			ada___line_buffer__read__blue <= De_hcnt_d2>>1;
			ada___line_buffer__read__red  <= De_hcnt_d2>>1;
			ada___line_buffer__read__green<= De_hcnt_d2>>1;
			if(count_debug==32'h000f0000) begin
				Data_tmp<=24'h00ff00;
				debug_signal_draw<={douta___line_buffer__read__blue,douta___line_buffer__read__green,douta___line_buffer__read__red};
				Data_tmp<={douta___line_buffer__read__blue,douta___line_buffer__read__green,douta___line_buffer__read__red};
			end
			if(count_debug>32'h0000f000 && count_debug<32'h000f0000) begin
				Data_tmp<=24'h0000ff;
			end
			else if(count_debug<32'h0000f000) begin
				Data_tmp<=24'hff0000;
			end
			if(count_debug<32'h000f0000) begin
				count_debug<=count_debug+32'h00000001;
			end
			else begin
				if(count_debug_2<4'hf) begin
					count_debug<=32'h00000000;
					count_debug_2<=count_debug_2+4'h1;
				end
				
			end
		end
		else begin
            Data_tmp <= 24'h000000; // Borda preta fora do DE
        end
	end
end
/*
reg [31:0] count_debug;
always @(posedge I_pxl_clk or negedge I_rst_n) begin
	if(!I_rst_n) begin
		Data_tmp<=24'h00ff00;
		count_debug<=32'h00000000;
	end
	else begin
		if(count_debug>32'h000f0000 && count_debug<32'h00f00000) begin
			Data_tmp<=24'h0000ff;
		end
		else if(count_debug<32'h000f0000) begin
			Data_tmp<=24'hff0000;
		end
		if(count_debug<32'h00f00000) begin
			count_debug<=count_debug+32'h00000001;
		end
		else begin
			count_debug<=32'h00000000;
		end
	end
end
*/
assign O_data_r = Data_tmp[ 7: 0];
assign O_data_g = Data_tmp[15: 8];
assign O_data_b = Data_tmp[23:16];

endmodule       
              