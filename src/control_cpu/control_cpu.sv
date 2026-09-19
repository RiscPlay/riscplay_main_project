module control_cpu(
    input   wire           clk,
    input   wire           rst_n,
    input   wire   [5:0]   addr_control_cpu_memory,
    input   wire   [31:0]  din_control_cpu_memory,
    input   wire   [31:0]  dout_control_cpu_memory,
    input   wire           wre_control_cpu_memory,
    output  reg            reset_cpu,
    input   wire   [3:0]   sel___main_memory,
    output  wire            clk_out,
    output  reg    [5:0]   leds,
    input   wire           spi_comm_started,
    output  reg            enable_cpu,
    output  reg            spi_can_access_memory

);
reg [7:0] mem [0:63];
reg use_raw_clk;

always @(posedge clk) begin
    if(!rst_n) begin
        reset_cpu<=1'b1;
    end
    else begin
        if(wre_control_cpu_memory) begin
            mem[addr_control_cpu_memory[5:0]]<=din_control_cpu_memory[7:0];
        end
        if(~(mem[0][0]) ) begin
            reset_cpu<=1'b1;
        end
        else begin
            reset_cpu<=1'b0;
        end
    end
end

reg       spi_comm_started_prev;
reg [3:0] state_control_mem_access;
reg [3:0] count_to_allow_the_spi_use_mem;
reg [3:0] count_to_allow_the_cpu_use_mem;

localparam [4:0] STATE__IDLE   = 4'h0;
localparam [4:0] STATE__WAIT_CPU_TO_COMPLETE_OPS_IN_MEM   = 4'h1;

localparam [4:0] STATE__WAIT_CPU_RESTORE_OPS_IN_MEM   = 4'h2;

always @(posedge clk) begin
    if(!rst_n) begin
        spi_comm_started_prev<=1'b0;
        count_to_allow_the_spi_use_mem<=4'h0;
        spi_can_access_memory<=1'b0;
        count_to_allow_the_cpu_use_mem<=4'h0;
        enable_cpu<=1'b1;
    end
    else begin
        spi_comm_started_prev<=spi_comm_started;
        case(state_control_mem_access)
            default: state_control_mem_access<=STATE__IDLE;
            STATE__IDLE: begin
                count_to_allow_the_spi_use_mem<=4'h0;
                count_to_allow_the_cpu_use_mem<=4'h0f;
                if(spi_comm_started_prev==1'b0 && spi_comm_started==1'b1) begin
                    state_control_mem_access<=STATE__WAIT_CPU_TO_COMPLETE_OPS_IN_MEM;
                    enable_cpu<=1'b0;
                end
                else if(spi_comm_started_prev==1'b1 && spi_comm_started==1'b0) begin
                    state_control_mem_access<=STATE__WAIT_CPU_RESTORE_OPS_IN_MEM;
                    spi_can_access_memory<=1'b0;
                end
            end
            STATE__WAIT_CPU_TO_COMPLETE_OPS_IN_MEM: begin
                if(count_to_allow_the_spi_use_mem==4'hf) begin
                    spi_can_access_memory<=1'b1;
                    state_control_mem_access<=STATE__IDLE;
                end
                else begin
                    count_to_allow_the_spi_use_mem<=count_to_allow_the_spi_use_mem+4'h1;
                end
            end
            STATE__WAIT_CPU_RESTORE_OPS_IN_MEM: begin
                if(count_to_allow_the_cpu_use_mem==4'hf) begin
                    enable_cpu<=1'b1;
                    state_control_mem_access<=STATE__IDLE;
                end
                else begin
                    count_to_allow_the_cpu_use_mem<=count_to_allow_the_cpu_use_mem+4'h1;
                end
            end
        endcase
    end
end

endmodule