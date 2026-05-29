module memory_control(
    input   wire         clk,
    output  wire  [31:0] mem_addr___from_cpu,
    output  reg  [31:0]  mem_wdata___from_cpu,
    input   wire [31:0]  mem_rdata___from_cpu,
    output  reg          mem_we___from_cpu,
    
    input   wire  [31:0]  mem_addr,
    input   wire  [31:0]  mem_wdata,
    output  wire  [31:0]  mem_rdata,
    input   wire          mem_we,
    input   wire          mem_we_byte,
    input   wire          mem_we_half,

    output  wire   [7:0]   mem_rdata_byte,
    output  wire   [15:0]  mem_rdata_half,

    input   wire   [7:0]   mem_wdata_byte,
    input   wire   [15:0]  mem_wdata_half,
    input   wire          reset,

    output reg            busy
);
localparam
    STATE_P0    = 4'h0,
    STATE_P1    = 4'h1,
    STATE_P2    = 4'h2,
    STATE_P3    = 4'h3,
    STATE_RESET = 4'hf;

reg [3:0] state;
reg [3:0] state_prev;

wire [1:0] byte_sel;
assign byte_sel=mem_addr[1:0];

reg [3:0] time_that_stage_hold;

wire sync__state=state_prev==state;
always @(posedge clk) begin
    if(reset==1'b0) begin
        if(sync__state) begin
            if(time_that_stage_hold<4'hf) begin
                time_that_stage_hold<=time_that_stage_hold+4'h1;
            end
        end
        else begin
            time_that_stage_hold<=4'h0;
        end
        state_prev<=state;
    end
    else begin 
      time_that_stage_hold<=4'h0;
      state_prev<=STATE_RESET;
    end
end
  


reg mem_we_byte_prev;
reg mem_we_half_prev;
reg mem_we_prev;
reg mem_we_copy;
reg mem_we_half_copy;
reg mem_we_byte_copy;

always @(posedge clk) begin

    if(reset) begin
        state<=STATE_P0;
        
        busy<=1'b0;
        mem_we___from_cpu <= 0;
        mem_we_copy<=1'b0;
        mem_we_byte_copy<=1'b0;
        mem_we_half_copy<=1'b0;
    end
    else begin
        mem_we_byte_prev<=mem_we_byte;
        mem_we_half_prev<=mem_we_half;
        mem_we_prev<=mem_we;
        case(state)
            default: state<=STATE_P0;
            STATE_P0: begin

                if((~mem_we_byte_prev& mem_we_byte)  | ( ~mem_we_half_prev & mem_we_half)) begin
                    state<=STATE_P1;
                    busy<=1'b1;
                    if(mem_we_half)
                        mem_we_half_copy<=1'b1;
                    if(mem_we_byte)
                        mem_we_byte_copy<=1'b1;
                end
                else if(~mem_we_prev&mem_we) begin
                    state<=STATE_P1;
                    busy<=1'b1;
                    mem_we_copy<=1'b1;
                end
                else begin
                    busy<=1'b0;
                end

            end
            STATE_P1: begin
                if(sync__state & time_that_stage_hold>4'h3) begin
                    state<=STATE_P2;
                end
            end
            STATE_P2: begin
                if(mem_we_byte_copy) begin
                     case(byte_sel)
                        2'b00: begin
                            mem_wdata___from_cpu[31:24] <=mem_wdata_byte;
                            mem_wdata___from_cpu[23:0]<=mem_rdata___from_cpu[23:0];

                        end 
                        2'b01: begin 
                            mem_wdata___from_cpu[23:16] <=mem_wdata_byte;
                            mem_wdata___from_cpu[31:24]<=mem_rdata___from_cpu[31:24];
                            mem_wdata___from_cpu[15:0]<=mem_rdata___from_cpu[15:0];
                        end
                        2'b10: begin
                            mem_wdata___from_cpu[15:8]<=mem_wdata_byte;
                            mem_wdata___from_cpu[31:16]<=mem_rdata___from_cpu[31:16];
                            mem_wdata___from_cpu[7:0]<=mem_rdata___from_cpu[7:0];
                        end 
                        2'b11: begin 
                            mem_wdata___from_cpu[7:0]<=mem_wdata_byte;
                            mem_wdata___from_cpu[31:8]<=mem_rdata___from_cpu[31:8];
                        end
                    endcase
                end
                else if(mem_we_half_copy) begin
                     case(byte_sel[1])
                       1'b0: begin
                            mem_wdata___from_cpu[23:16]  <=mem_wdata_half[15:8];
                            mem_wdata___from_cpu[31:24]  <=mem_wdata_half[7:0];
                            mem_wdata___from_cpu[15:0]<=mem_rdata___from_cpu[15:0];
                        end
                        1'b1: begin
                            mem_wdata___from_cpu[7:0]  <=mem_wdata_half[15:8];
                            mem_wdata___from_cpu[15:8] <=mem_wdata_half[7:0];
                            mem_wdata___from_cpu[31:16]<=mem_rdata___from_cpu[31:16];
                        end 
                    endcase
                end
                else if(mem_we_copy) begin
                    mem_wdata___from_cpu<={mem_wdata[7:0],mem_wdata[15:8],mem_wdata[23:16],mem_wdata[31:24]};
                end
                state<=STATE_P3;
                mem_we___from_cpu<=1'b1;
            end
            STATE_P3: begin
                if(sync__state & time_that_stage_hold>4'h0) begin
                   mem_we_copy<=1'b0;
                   mem_we_byte_copy<=1'b0;
                   mem_we_half_copy<=1'b0;
                end
                if(sync__state & time_that_stage_hold>4'h0) begin
                    mem_we___from_cpu<=1'b0;
                    state<=STATE_P0;
                    busy<=1'b0;     
                end
            end
        endcase
    end
end

assign  mem_addr___from_cpu={2'b00,mem_addr[31:2]};


    assign mem_rdata_byte =
        (byte_sel==2'b00)? mem_rdata___from_cpu[31:24] :
        (byte_sel==2'b01)? mem_rdata___from_cpu[23:16] :
        (byte_sel==2'b10)? mem_rdata___from_cpu[15:8]  :
                        mem_rdata___from_cpu[7:0];

    assign mem_rdata_half =
        byte_sel[1] ?
        {mem_rdata___from_cpu[7:0],mem_rdata___from_cpu[15:8]} :
        {mem_rdata___from_cpu[23:16],mem_rdata___from_cpu[31:24]};

    assign mem_rdata = {
        mem_rdata___from_cpu[7:0],
        mem_rdata___from_cpu[15:8],
        mem_rdata___from_cpu[23:16],
        mem_rdata___from_cpu[31:24]
    };
endmodule
