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








wire [31:0] dout_buffer;
reg         wre_buffer;
reg  [10:0] ad_buffer_write;
reg  [10:0] ad_buffer_read;
reg  [31:0] din_buffer;

Gowin_DPB__LINE_BUFFER buffer (
    .ada(ad_buffer_read),
    .adb(ad_buffer_write),
	.dina(32'h0),
	.dinb(din_buffer),
	.wrea(1'b0),
    .wreb(wre_buffer),
	.douta(dout_buffer),

    .ocea(1'b1),
    .cea(1'b1),
    .reseta(1'b0),
    .oceb(1'b1),
    .ceb(1'b1),
    .resetb(1'b0),
    .clka(I_pxl_clk),
    .clkb(I_pxl_clk)
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


localparam [3:0] ST_RD_IMG_LINES___IDLE                         =  4'h0;
localparam [3:0] ST_RD_IMG_LINES___WAIT_RAM_READ                =  4'h2;
localparam [3:0] ST_RD_IMG_LINES___READ_RAM_BUFFER              =  4'h3;
localparam [3:0] ST_RD_IMG_LINES___INC_BUFFER_POINT_TO_WR       =  4'h4;

reg get_buffer;
reg res___get_buffer;
reg get_buffer_op_accept;
reg [10:0] begin_write_buffer;
reg [10:0] begin_write_buffer_latch;
reg [10:0] end_write_buffer_latch;
reg first_ite;
always @(posedge I_pxl_clk ) begin
    if(!rst_n_paint) begin
        pointer_to_get_next_64_32bits_words         <= 21'd640;
        n_line_being_obtained                       <= 12'd1;
        addr_sdram_manager__hdmi_controller         <= 22'b1000000000000000000000;
        n_32bits_word_being_obtained_from_the_line <= 12'h000;
        din_sdram_manager__hdmi_controller          <= {2'b00,addr_to_first_line_of_fb_in_sdram,n_32bits_word_to_get_in_every_sdram_request,2'b00};
        st_rd_img_lines                             <= ST_RD_IMG_LINES___IDLE;
        pointer_to_read_sdram_buffer                <= 22'b0;

        wre_sdram_manager__hdmi_controller          <= 1'b0;
        wre_buffer                                  <= 1'b0;
        ad_buffer_write                             <= 11'b0;
        debug_signal_draw                           <= 32'h00000000;
        get_buffer_op_accept                        <= 1'b0;
        res___get_buffer                            <= 1'b0;
        begin_write_buffer_latch                    <= 11'b0;
        end_write_buffer_latch                      <= 11'd639;
        first_ite<=1'b1;
    end
    else begin
        if(get_buffer) begin
            get_buffer_op_accept <= 1'b1;
            res___get_buffer     <= 1'b1;
        end
        else begin
            res___get_buffer     <= 1'b0;
        end

        case(st_rd_img_lines)
            default: st_rd_img_lines <= ST_RD_IMG_LINES___IDLE;
            
            ST_RD_IMG_LINES___IDLE: begin
                if(n_line_being_obtained == 12'h000) 
                    pointer_to_get_next_64_32bits_words <= addr_to_first_line_of_fb_in_sdram;

                if(get_buffer_op_accept || n_32bits_word_being_obtained_from_the_line > 12'h000 || first_ite) begin
                    if(get_buffer_op_accept) begin
                        begin_write_buffer_latch <= begin_write_buffer;
                        if(begin_write_buffer == 11'd640) begin
                            end_write_buffer_latch <= 11'd1279;
                        end
                        else begin
                            end_write_buffer_latch <= 11'd639;
                        end
                        
                        ad_buffer_write <= begin_write_buffer;
                    end
                    first_ite<=1'b0;
                    get_buffer_op_accept               <= 1'b0;
                    st_rd_img_lines                    <= ST_RD_IMG_LINES___WAIT_RAM_READ;
                    addr_sdram_manager__hdmi_controller<= 22'b1000000000000000000000;
                    wre_sdram_manager__hdmi_controller <= 1'b1;
                    
                    if(n_line_being_obtained == 12'h000) begin
                        din_sdram_manager__hdmi_controller <= {2'b00, addr_to_first_line_of_fb_in_sdram, n_32bits_word_to_get_in_every_sdram_request, 2'b00};
                    end
                    else begin
                        din_sdram_manager__hdmi_controller <= {2'b00, pointer_to_get_next_64_32bits_words, n_32bits_word_to_get_in_every_sdram_request, 2'b00};
                    end
                end
                wre_buffer <= 1'b0;
            end

            ST_RD_IMG_LINES___WAIT_RAM_READ: begin
                if(sync__st_rd_img_lines) begin
                    wre_sdram_manager__hdmi_controller <= 1'b0;
                end

                if(sync__st_rd_img_lines && time_that___st_rd_img_lines___hold > 8'h16) begin
                    if(processing_request_from__hdmi_controller == 1'b0) begin
                        st_rd_img_lines                     <= ST_RD_IMG_LINES___READ_RAM_BUFFER;
                        addr_sdram_manager__hdmi_controller <= 22'b0;
                    end
                end
                wre_buffer <= 1'b0;
            end

            // Estado onde o dado vindo da SDRAM é de fato capturado
            ST_RD_IMG_LINES___READ_RAM_BUFFER: begin
                pointer_to_get_next_64_32bits_words <= pointer_to_get_next_64_32bits_words + 21'b1;
                st_rd_img_lines                     <= ST_RD_IMG_LINES___INC_BUFFER_POINT_TO_WR;
                wre_buffer                          <= 1'b1; // Habilita a escrita na BRAM
                din_buffer                          <= dout_sdram_manager__hdmi_controller;
                debug_signal_draw                   <= dout_sdram_manager__hdmi_controller;
            end

            ST_RD_IMG_LINES___INC_BUFFER_POINT_TO_WR: begin
                wre_buffer                          <= 1'b0; // Força a descida IMEDIATA para não duplicar escrita
                addr_sdram_manager__hdmi_controller <= addr_sdram_manager__hdmi_controller + 22'b1;

                // 1. Atualiza com precisão o ponteiro de escrita da BRAM
                if(ad_buffer_write == end_write_buffer_latch) begin
                    ad_buffer_write <= begin_write_buffer_latch;
                end
                else begin
                    ad_buffer_write <= ad_buffer_write + 11'h001;
                end

                // 2. Avalia o encerramento baseado no contador de palavras da linha atual
                if (n_32bits_word_being_obtained_from_the_line == 12'd639) begin
                    n_32bits_word_being_obtained_from_the_line <= 12'h000;
                    st_rd_img_lines <= ST_RD_IMG_LINES___IDLE;
                    
                    if(n_line_being_obtained == 12'd359)
                        n_line_being_obtained <= 12'h000;
                    else 
                        n_line_being_obtained <= n_line_being_obtained + 12'h001;
                end
                else begin
                    n_32bits_word_being_obtained_from_the_line <= n_32bits_word_being_obtained_from_the_line + 12'h001;
                    
                    // Se terminamos uma rajada de 64 e NÃO é o fim da linha (múltiplos de 64: 63, 127, 191...)
                    if (n_32bits_word_being_obtained_from_the_line[5:0] == 6'b111111) begin
                        addr_sdram_manager__hdmi_controller <= 22'b1000000000000000000000;
                        din_sdram_manager__hdmi_controller  <= {
                            2'b00,
                            pointer_to_get_next_64_32bits_words,
                            n_32bits_word_to_get_in_every_sdram_request,
                            2'b00
                        };
                        wre_sdram_manager__hdmi_controller <= 1'b1;
                        st_rd_img_lines                     <= ST_RD_IMG_LINES___WAIT_RAM_READ;
                    end
                    else begin               
                        st_rd_img_lines <= ST_RD_IMG_LINES___READ_RAM_BUFFER;
                    end
                end
            end
        endcase
    end
end

reg [11:0] V_cnt_prev;
reg [31:0] count_debug;
reg [3:0]  count_debug_2;
reg [11:0] count_rows;
reg [3:0] line;
always @(posedge I_pxl_clk)
begin
	
	if(!rst_n_paint) begin
		
		Data_tmp <= 24'd0;
		V_cnt_prev<=12'h000;
		De_hcnt_d1<=12'h000;
		De_hcnt_d2<=12'h000;
		count_debug<=32'h00000000;
		count_debug_2<=4'h0;
		count_rows<=12'd0;
		ad_buffer_read<=11'd640;
		begin_write_buffer<=11'd0;
		line<=4'h0;
		get_buffer<=1'b0;
	end
	else begin
		De_hcnt_d1<=De_hcnt;
		De_hcnt_d2<=De_hcnt_d1;
		V_cnt_prev<=V_cnt;
		if(De_neg) begin
			if(line==4'h3)
				line<=4'h0;
			else 
				line<=line+4'h1;
			if(line==4'h1) begin
				get_buffer<=1'b1;
				begin_write_buffer<=11'd640;
			end
			else if(line==4'h3) begin
				begin_write_buffer<=11'd0;
				get_buffer<=1'b1;
			end
		end
		else begin
			if(res___get_buffer) begin
				get_buffer<=1'b0;
			end
		end
		
		if(Pout_de_dn[2]==1'b0) begin
			count_rows<=12'h000;
			Data_tmp <= 24'h000000;
			if(line==4'h0 || line==4'h1) begin
				ad_buffer_read<=11'd640;
			end
			else begin
				ad_buffer_read<=11'd0;
			end
		end
		else  begin
			count_rows<=count_rows+12'h001;
			if(count_rows[0]==1'b1) begin
				ad_buffer_read<=ad_buffer_read+11'b1;
			end
			else begin
			//debug_signal_draw<={douta___line_buffer__read__blue,douta___line_buffer__read__green,douta___line_buffer__read__red};

                    Data_tmp<=dout_buffer[23:0];
            end
		end
	end
end
assign O_data_r = Data_tmp[23:16] ;
assign O_data_g = Data_tmp[15: 8];
assign O_data_b = Data_tmp[ 7: 0];

endmodule       
              