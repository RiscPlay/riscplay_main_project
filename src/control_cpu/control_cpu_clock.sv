module enable_or_pause_cpu (
    input   wire         clk,
    input   wire         rst_n,
    input   wire         wake,
    input   wire [1:0]   cmd,
    output  reg          enable_cpu,
    output  reg          stopped
);

localparam [1:0] CMD_ENABLE_CLOCK_FOR_ONE_PULSE  =  2'b00;
localparam [1:0] CMD_ENABLE_CLOCK_PULSE          =  2'b01;
localparam [1:0] CMD_DISABLE_CLOCK_PULSE         =  2'b10;

localparam [3:0] RESET_STATE                     =  4'hf;
localparam [3:0] STATE_INIT                      =  4'h0;
localparam [3:0] STATE_P0                        =  4'h1;

reg [3:0]  state;
always @(posedge clk) begin
    if(!rst_n) begin
        stopped<=1'b1;
        state<=RESET_STATE;
        enable_cpu<=1'b1;
    end
    else begin
        case (state)
            default: state<=RESET_STATE;
            STATE_INIT: begin
                if(cmd==CMD_DISABLE_CLOCK_PULSE) begin
                    enable_cpu<=1'b0;
                    state<=RESET_STATE;
                end
                else if(cmd==CMD_ENABLE_CLOCK_PULSE) begin
                    enable_cpu<=1'b1;
                    state<=RESET_STATE;
                end
                else if(cmd==CMD_ENABLE_CLOCK_FOR_ONE_PULSE) begin
                    enable_cpu<=1'b1;
                    state<=STATE_P0;
                end
            end
            STATE_P0: begin
                stopped<=1'b1;
                enable_cpu<=1'b0;
                state<=RESET_STATE;
            end
            RESET_STATE: begin
                if(wake==1'b1) begin
                    stopped<=1'b0;
                    state<=STATE_INIT;
                end
                else begin
                    stopped<=1'b1;
                end
            end
        endcase
    end
end
endmodule