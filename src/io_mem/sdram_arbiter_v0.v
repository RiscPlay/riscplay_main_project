module sdram_arbiter(
    input   wire          clk,
    input   wire          rst_n,
    input   wire  [21:0]  addr_sdram_manager__pixel_ppu,
    input   wire  [21:0]  addr_sdram_manager__mapper,
    input   wire  [21:0]  addr_sdram_manager__hdmi_controller,
    input   wire  [31:0]  din_sdram_manager__pixel_ppu,
    input   wire  [31:0]  din_sdram_manager__mapper,
    input   wire  [31:0]  din_sdram_manager__hdmi_controller,
    input   wire          wre_sdram_manager__mapper,
    input   wire          wre_sdram_manager__pixel_ppu,
    input   wire          wre_sdram_manager__hdmi_controller,
    output  reg   [21:0]  addr_sdram_manager_to_process,
    output  reg   [31:0]  din_sdram_manager_to_process,
    output  reg           mapper_in_control,
    output  reg           hdmi_controller_in_control,
    output  reg           pixel_ppu_in_control,
    output  reg           request_to_do_op_in_sdram,
    input   wire          request_to_do_op_in_sdram_ack,
    output  wire          wre_pulse_from_mapper,
    output  wire          wre_pulse_from_pixel_ppu,
    output  wire          wre_pulse_from_hdmi_controller,
    output  reg           processing_request_from__pixel_ppu,
    output  reg           processing_request_from__hdmi_controller,
    output  reg           processing_request_from__mapper
);

localparam addr_to_set_op                =   22'b1000000000000000000000;


reg wre_sdram_manager__mapper__prev;
reg wre_sdram_manager__pixel_ppu__prev;
reg wre_sdram_manager__hdmi_controller__prev;

assign wre_pulse_from_mapper=!wre_sdram_manager__mapper__prev&wre_sdram_manager__mapper;
assign wre_pulse_from_pixel_ppu=!wre_sdram_manager__pixel_ppu__prev&wre_sdram_manager__pixel_ppu;
assign wre_pulse_from_hdmi_controller=!wre_sdram_manager__hdmi_controller__prev&wre_sdram_manager__hdmi_controller;

reg request_to_do_op_in_sdram_ack_prev;
always @(posedge clk) begin
     if(!rst_n) begin
        wre_sdram_manager__hdmi_controller__prev<=1'b0;
        wre_sdram_manager__pixel_ppu__prev<=1'b0;
        wre_sdram_manager__mapper__prev<=1'b0;
        request_to_do_op_in_sdram_ack_prev<=1'b0;
     end
     else begin
        wre_sdram_manager__pixel_ppu__prev<=wre_sdram_manager__pixel_ppu;
        wre_sdram_manager__mapper__prev<=wre_sdram_manager__mapper;
        wre_sdram_manager__hdmi_controller__prev<=wre_sdram_manager__hdmi_controller;
        request_to_do_op_in_sdram_ack_prev<=request_to_do_op_in_sdram_ack;
     end
end

reg[15:0] ret_rnd1;
rnd rnd1 ( 
    .clk(clk),
    .rst_n(rst_n),
    .seed(16'h0020),
    .ret(ret_rnd1)
);
wire [2:0] wres;
wire request_op___from__pixel_ppu;
wire request_op___from__mapper;
wire request_op___from__hdmi_controller;
assign request_op___from__pixel_ppu      = addr_to_set_op==addr_sdram_manager__pixel_ppu[21:0];
assign request_op___from__mapper         = addr_to_set_op==addr_sdram_manager__mapper[21:0];
assign request_op___from__hdmi_controller= addr_to_set_op==addr_sdram_manager__hdmi_controller[21:0];


localparam invalid_order              = 2'b00;
localparam order_from_mapper          = 2'b01;
localparam order_from_pixel_ppu       = 2'b10;
localparam order_from_hdmi_controller = 2'b11;

assign wres={
    wre_pulse_from_mapper&request_op___from__mapper,
    wre_pulse_from_pixel_ppu&request_op___from__pixel_ppu,
    wre_pulse_from_hdmi_controller&request_op___from__hdmi_controller
}; 
reg [1:0] current_order_type_being_processed;
reg [3:0] pixel_ppu_pending_reqs;
reg [3:0] mapper_pending_reqs;
reg [3:0] hdmi_controller_pending_reqs;
wire request_to_do_op_in_sdram_ack_pulse=request_to_do_op_in_sdram_ack&& (!request_to_do_op_in_sdram_ack_prev);
always @(posedge clk) begin
    if(!rst_n) begin
        pixel_ppu_pending_reqs<=4'h0;
        mapper_pending_reqs<=4'h0;
        hdmi_controller_pending_reqs<=4'h0;
        processing_request_from__mapper<=1'b0;
        processing_request_from__pixel_ppu<=1'b0;
        processing_request_from__hdmi_controller<=1'b0;
    end
    else begin
        if(wres[2])begin
            processing_request_from__mapper<=1'b1;
            if(!(request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_mapper)) 
                mapper_pending_reqs<=mapper_pending_reqs+4'h1;
        end
        else if((request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_mapper)) begin
            mapper_pending_reqs<=mapper_pending_reqs-4'h1;
            if(mapper_pending_reqs==4'h1) begin
                processing_request_from__mapper<=1'b0;
            end
        end
        if(wres[1])begin
            processing_request_from__pixel_ppu<=1'b1;
            if(!(request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_pixel_ppu)) 
                pixel_ppu_pending_reqs<=pixel_ppu_pending_reqs+4'h1;
        end
        else if ((request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_pixel_ppu)) begin
            pixel_ppu_pending_reqs<=pixel_ppu_pending_reqs-4'h1;
            if(pixel_ppu_pending_reqs==4'h1) begin
                processing_request_from__pixel_ppu<=1'b0;
            end
        end

        if(wres[0])begin
            processing_request_from__hdmi_controller<=1'b1;
            if(!(request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_hdmi_controller)) 
                hdmi_controller_pending_reqs<=hdmi_controller_pending_reqs+4'h1;
        end
        else if((request_to_do_op_in_sdram_ack_pulse && current_order_type_being_processed==order_from_hdmi_controller)) begin
            hdmi_controller_pending_reqs<=hdmi_controller_pending_reqs-4'h1;
            if(hdmi_controller_pending_reqs==4'h1) begin
                processing_request_from__hdmi_controller<=1'b0;
            end
        end
    end
end


reg  [2:0] wr_ptr_orders_req_fifo;
wire [2:0] wr_ptr_orders_req_fifo_next;
wire [2:0] wr_ptr_orders_req_fifo_next2;
assign wr_ptr_orders_req_fifo_next  = wr_ptr_orders_req_fifo + 1'b1;
assign wr_ptr_orders_req_fifo_next2 = wr_ptr_orders_req_fifo + 2'b10;
reg [2:0] rd_ptr_orders_req_fifo;

reg [1:0]  orders_req_ctrl_fifo    [0:7];
reg [31:0] din_from_orders_fifo    [0:7];
reg [21:0] addr_sdram_manager_fifo [0:7];

reg [1:0] state;

always  @(posedge clk) begin
    if(!rst_n) begin
        rd_ptr_orders_req_fifo<=3'b000;
        state<=2'b00;
        current_order_type_being_processed<=invalid_order;
        mapper_in_control<=1'b0;
        hdmi_controller_in_control<=1'b0;
        pixel_ppu_in_control<=1'b0;
        request_to_do_op_in_sdram<=1'b0;
        addr_sdram_manager_to_process<=21'b0;
        din_sdram_manager_to_process<=32'b0;
        
    end
    else begin
        case(state) 
        default: state<=2'b00;
        2'b00: begin
            if(rd_ptr_orders_req_fifo!=wr_ptr_orders_req_fifo) begin
                if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]==order_from_mapper) begin
                    mapper_in_control<=1'b1;
                    hdmi_controller_in_control<=1'b0;
                    pixel_ppu_in_control<=1'b0;
                end
                else if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]==order_from_pixel_ppu) begin
                    mapper_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b0;
                    pixel_ppu_in_control<=1'b1;
                end
                else if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]==order_from_hdmi_controller) begin
                    mapper_in_control<=1'b0;
                    hdmi_controller_in_control<=1'b1;
                    pixel_ppu_in_control<=1'b0;
                end
                if(orders_req_ctrl_fifo[rd_ptr_orders_req_fifo]!=invalid_order) begin
                    addr_sdram_manager_to_process<=addr_sdram_manager_fifo[rd_ptr_orders_req_fifo];
                    din_sdram_manager_to_process <=din_from_orders_fifo[rd_ptr_orders_req_fifo];
                    state<=2'b01;
                    request_to_do_op_in_sdram<=1'b1;
                end
                current_order_type_being_processed<=orders_req_ctrl_fifo[rd_ptr_orders_req_fifo];
            end
        end
        2'b01:begin
            if(request_to_do_op_in_sdram_ack_pulse) begin
                state<=2'b00; 
                rd_ptr_orders_req_fifo<=rd_ptr_orders_req_fifo+3'b001;
                request_to_do_op_in_sdram<=1'b0;
                hdmi_controller_in_control<=1'b0;
                mapper_in_control<=1'b0;
                pixel_ppu_in_control<=1'b0;
            end
        end
        endcase
    end
end
integer i;
always @(posedge clk) begin
    if(!rst_n) begin

        wr_ptr_orders_req_fifo<=3'b000;
        for(i = 0; i < 8; i = i + 1)
            orders_req_ctrl_fifo[i] <= invalid_order;
    end
    else begin
        if(wres!=3'b000) begin
            if(wres==3'b001 || wres==3'b010 || wres==3'b100 ) begin
                wr_ptr_orders_req_fifo<=wr_ptr_orders_req_fifo+3'b001;
            end
            else if(wres==3'b011 || wres==3'b110 || wres==3'b101 ) begin
                wr_ptr_orders_req_fifo<=wr_ptr_orders_req_fifo+3'b010;
            end
            else begin
                wr_ptr_orders_req_fifo<=wr_ptr_orders_req_fifo+3'b011;
            end
        end
        case(wres)
            3'b001: begin
                orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]    <=order_from_hdmi_controller;
                din_from_orders_fifo[wr_ptr_orders_req_fifo]    <=din_sdram_manager__hdmi_controller;
                addr_sdram_manager_fifo[wr_ptr_orders_req_fifo] <=addr_sdram_manager__hdmi_controller;

            end
            3'b010: begin
                orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]    <=order_from_pixel_ppu;
                din_from_orders_fifo[wr_ptr_orders_req_fifo]    <=din_sdram_manager__pixel_ppu;
                addr_sdram_manager_fifo[wr_ptr_orders_req_fifo] <=addr_sdram_manager__pixel_ppu;
            end
            3'b011: begin
                if(ret_rnd1[0]) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_sdram_manager__pixel_ppu;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]       <=addr_sdram_manager__pixel_ppu;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_sdram_manager__hdmi_controller;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next]  <=addr_sdram_manager__hdmi_controller;

                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_sdram_manager__hdmi_controller;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]       <=addr_sdram_manager__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_sdram_manager__pixel_ppu;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next]  <=addr_sdram_manager__pixel_ppu;
                end
            end
            3'b100: begin
                orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]    <=order_from_mapper;
                din_from_orders_fifo[wr_ptr_orders_req_fifo]    <=din_sdram_manager__mapper;
                addr_sdram_manager_fifo[wr_ptr_orders_req_fifo] <=addr_sdram_manager__mapper;
            end
            3'b101: begin
                if(ret_rnd1[0]) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_sdram_manager__mapper;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]       <=addr_sdram_manager__mapper;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_sdram_manager__hdmi_controller;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next]  <=addr_sdram_manager__hdmi_controller;
                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]         <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_sdram_manager__hdmi_controller;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]      <=addr_sdram_manager__hdmi_controller;

                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_sdram_manager__mapper;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next] <=addr_sdram_manager__mapper;
                end
            end
            3'b110: begin
                if(ret_rnd1[0]) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]         <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_sdram_manager__mapper;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]      <=addr_sdram_manager__mapper;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_sdram_manager__pixel_ppu;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next] <=addr_sdram_manager__pixel_ppu;
                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu;                    
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_sdram_manager__pixel_ppu;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]       <=addr_sdram_manager__pixel_ppu;
                    
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_sdram_manager__mapper;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next] <=addr_sdram_manager__mapper;
                end
            end
            3'b111: begin
                if(ret_rnd1[1:0]==2'b00) begin
                    if(ret_rnd1[2]==1'b0) begin
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]<=order_from_hdmi_controller;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_sdram_manager__hdmi_controller;
                        addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]      <=addr_sdram_manager__hdmi_controller;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]<=order_from_pixel_ppu;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_sdram_manager__pixel_ppu;
                        addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next] <=addr_sdram_manager__pixel_ppu;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]   <=order_from_mapper;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]   <=din_sdram_manager__mapper;
                        addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next2] <=addr_sdram_manager__mapper;
                    end
                    else begin
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu; 
                        din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_sdram_manager__pixel_ppu;
                        addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]       <=addr_sdram_manager__pixel_ppu;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_sdram_manager__hdmi_controller;
                        addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next]  <=addr_sdram_manager__hdmi_controller;
                        orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]    <=order_from_mapper;
                        din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]    <=din_sdram_manager__mapper;
                        addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next2] <=addr_sdram_manager__mapper;

                    end 
                end
                else if(ret_rnd1[1:0]==2'b01) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_sdram_manager__pixel_ppu;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]       <=addr_sdram_manager__pixel_ppu;

                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_sdram_manager__hdmi_controller;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next]  <=addr_sdram_manager__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]    <=din_sdram_manager__mapper;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next2] <=addr_sdram_manager__mapper;
                end
                else if(ret_rnd1[1:0]==2'b10) begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]          <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]          <=din_sdram_manager__hdmi_controller;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]       <=addr_sdram_manager__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]     <=order_from_pixel_ppu;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]     <=din_sdram_manager__pixel_ppu;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next]  <=addr_sdram_manager__pixel_ppu;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]    <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]    <=din_sdram_manager__mapper;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next2] <=addr_sdram_manager__mapper;
                end
                else begin
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo]         <=order_from_mapper;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo]         <=din_sdram_manager__mapper;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo]      <=addr_sdram_manager__mapper;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next]    <=order_from_hdmi_controller;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next]    <=din_sdram_manager__hdmi_controller;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next] <=addr_sdram_manager__hdmi_controller;
                    orders_req_ctrl_fifo[wr_ptr_orders_req_fifo_next2]   <= order_from_pixel_ppu ;
                    din_from_orders_fifo[wr_ptr_orders_req_fifo_next2]   <=din_sdram_manager__pixel_ppu;
                    addr_sdram_manager_fifo[wr_ptr_orders_req_fifo_next2]<=addr_sdram_manager__pixel_ppu;
                end
            end
        endcase
    end
end
endmodule