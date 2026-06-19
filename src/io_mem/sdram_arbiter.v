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


wire [2:0] wres;
wire request_op___from__pixel_ppu;
wire request_op___from__mapper;
wire request_op___from__hdmi_controller;
assign request_op___from__pixel_ppu      = addr_to_set_op==addr_sdram_manager__pixel_ppu[21:0];
assign request_op___from__mapper         = addr_to_set_op==addr_sdram_manager__mapper[21:0];
assign request_op___from__hdmi_controller= addr_to_set_op==addr_sdram_manager__hdmi_controller[21:0];




assign wres={
    wre_pulse_from_mapper&request_op___from__mapper,
    wre_pulse_from_pixel_ppu&request_op___from__pixel_ppu,
    wre_pulse_from_hdmi_controller&request_op___from__hdmi_controller
}; 

wire request_to_do_op_in_sdram_ack_pulse=request_to_do_op_in_sdram_ack&& (!request_to_do_op_in_sdram_ack_prev);


reg [21:0] addr_sdram_manager__pixel_ppu___latch;
reg [31:0] din_sdram_manager__pixel_ppu___latch;
reg [21:0] addr_sdram_manager__hdmi_controller___latch;
reg [31:0] din_sdram_manager__hdmi_controller___latch;
reg [21:0] addr_sdram_manager__mapper___latch;
reg [31:0] din_sdram_manager__mapper___latch;
always @(posedge clk) begin
    if(!rst_n) begin
        processing_request_from__mapper<=1'b0;
        processing_request_from__pixel_ppu<=1'b0;
        processing_request_from__hdmi_controller<=1'b0;
    end
    else begin
        if(wres[0]) begin
            processing_request_from__hdmi_controller<=1'b1;
            addr_sdram_manager__hdmi_controller___latch<=addr_sdram_manager__hdmi_controller;
            din_sdram_manager__hdmi_controller___latch<=din_sdram_manager__hdmi_controller;

        end
        else begin
            if(request_to_do_op_in_sdram_ack_pulse && hdmi_controller_in_control) begin
                processing_request_from__hdmi_controller<=1'b0;
            end    
        end
        if(wres[1]) begin
            processing_request_from__pixel_ppu<=1'b1;
            addr_sdram_manager__pixel_ppu___latch<=addr_sdram_manager__pixel_ppu;
            din_sdram_manager__pixel_ppu___latch<=din_sdram_manager__pixel_ppu;
        end
        else begin
            if(request_to_do_op_in_sdram_ack_pulse && pixel_ppu_in_control) begin
                processing_request_from__pixel_ppu<=1'b0;
            end    
        end
        if(wres[2])begin
            processing_request_from__mapper<=1'b1;
            addr_sdram_manager__mapper___latch<=addr_sdram_manager__mapper;
            din_sdram_manager__mapper___latch<=din_sdram_manager__mapper;
        end
        else begin
            if(request_to_do_op_in_sdram_ack_pulse && mapper_in_control) begin
                processing_request_from__mapper<=1'b0;
            end    
        end
    end
end

reg [15:0] ppu_req_proc_cycles;
reg [15:0] hdmi_req_proc_cycles;
reg [15:0] mapper_req_proc_cycles;

always @(posedge clk) begin
    if(!processing_request_from__mapper) begin
        mapper_req_proc_cycles<=16'h0;
    end
    else begin
        if(mapper_req_proc_cycles != 16'hFFFF)
            mapper_req_proc_cycles<=mapper_req_proc_cycles+16'h0001;
    end
    if(!processing_request_from__hdmi_controller) begin
        hdmi_req_proc_cycles<=16'h0;
    end
    else begin
        if(hdmi_req_proc_cycles != 16'hFFFF)
            hdmi_req_proc_cycles<=hdmi_req_proc_cycles+16'h0001;
    end

    if(!processing_request_from__pixel_ppu) begin
        ppu_req_proc_cycles<=16'h0;
    end
    else begin
        if(ppu_req_proc_cycles != 16'hFFFF)
            ppu_req_proc_cycles<=ppu_req_proc_cycles+16'h0001; 
    end
end


always @(posedge clk) begin
    if(!rst_n) begin
        mapper_in_control<=1'b0;
        pixel_ppu_in_control<=1'b0;
        hdmi_controller_in_control<=1'b0;
        request_to_do_op_in_sdram<=1'b0;
    end
    else begin
        if( hdmi_controller_in_control==1'b0 && pixel_ppu_in_control==1'b0 && mapper_in_control==1'b0 ) begin
            if( processing_request_from__hdmi_controller && 
                (hdmi_req_proc_cycles>=ppu_req_proc_cycles  || processing_request_from__pixel_ppu==1'b0 ) && 
                (hdmi_req_proc_cycles>=mapper_req_proc_cycles || processing_request_from__mapper==1'b0)  
                ) begin
                    hdmi_controller_in_control<=1'b1;
                    addr_sdram_manager_to_process<=addr_sdram_manager__hdmi_controller___latch;
                    din_sdram_manager_to_process<=din_sdram_manager__hdmi_controller___latch; 
            end
            else if (processing_request_from__pixel_ppu &&
                    (ppu_req_proc_cycles>=mapper_req_proc_cycles || processing_request_from__mapper==1'b0)
                    ) begin
                    pixel_ppu_in_control<=1'b1;
                    addr_sdram_manager_to_process<=addr_sdram_manager__pixel_ppu___latch;
                    din_sdram_manager_to_process<=din_sdram_manager__pixel_ppu___latch; 
            end
            else if(processing_request_from__mapper) begin
                mapper_in_control<=1'b1;
                addr_sdram_manager_to_process<=addr_sdram_manager__mapper___latch;
                din_sdram_manager_to_process<=din_sdram_manager__mapper___latch;
            
            end
            if(processing_request_from__mapper || processing_request_from__pixel_ppu  || processing_request_from__hdmi_controller)
                request_to_do_op_in_sdram<=1'b1;
        end

        else if(request_to_do_op_in_sdram_ack_pulse) begin
            request_to_do_op_in_sdram<=1'b0;
            if(hdmi_controller_in_control) begin
                hdmi_controller_in_control<=1'b0;
            end
            if(pixel_ppu_in_control) begin
                pixel_ppu_in_control<=1'b0;
            end
            if(mapper_in_control) begin
                mapper_in_control<=1'b0;
            end
        end
    end
end

endmodule