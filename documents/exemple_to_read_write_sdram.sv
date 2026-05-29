module sdram_burst_fsm (
    input  wire        clk,
    input  wire        rst_n,    
    
    input  wire        clk,
    input  wire        rst_n,

    input  wire        O_sdrc_init_done,
    input  wire        O_sdrc_cmd_ack,
    input  wire [31:0] O_sdrc_data,

    output reg         I_sdrc_cmd_en,
    output reg  [2:0]  I_sdrc_cmd,
    output reg         I_sdrc_precharge_ctrl,
    output reg         I_sdram_power_down,
    output reg         I_sdram_selfrefresh,
    output reg  [20:0] I_sdrc_addr,
    output reg  [3:0]  I_sdrc_dqm,
    output reg  [31:0] I_sdrc_data,
    output reg  [7:0]  I_sdrc_data_len
);

    localparam CMD_WRITE = 3'b001;
    localparam CMD_READ  = 3'b010;

    localparam ST_IDLE     = 3'd0;
    localparam ST_WR_CMD   = 3'd1;
    localparam ST_WR_DATA  = 3'd2;
    localparam ST_RD_CMD   = 3'd3;
    localparam ST_RD_DATA  = 3'd4;

    reg [2:0] state;
    reg [7:0] burst_cnt;
    reg [31:0] read_buffer [0:7];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            burst_cnt <= 0;

            I_sdrc_cmd_en <= 0;
            I_sdrc_cmd <= 0;
            I_sdrc_precharge_ctrl <= 0;
            I_sdram_power_down <= 0;
            I_sdram_selfrefresh <= 0;
            I_sdrc_addr <= 0;
            I_sdrc_dqm <= 4'b0000;
            I_sdrc_data <= 0;
            I_sdrc_data_len <= 0;

        end else begin
            case (state)

                ST_IDLE: begin
                    I_sdrc_cmd_en <= 1'b0;

                    if (O_sdrc_init_done) begin
                        I_sdrc_addr <= 21'h000100;
                        I_sdrc_data_len <= 8'd8;
                        I_sdrc_cmd <= CMD_WRITE;
                        I_sdrc_cmd_en <= 1'b1;
                        state <= ST_WR_CMD;
                    end
                end

                ST_WR_CMD: begin
                    if (O_sdrc_cmd_ack) begin
                        I_sdrc_cmd_en <= 1'b0;
                        burst_cnt <= 0;
                        state <= ST_WR_DATA;
                    end
                end

                ST_WR_DATA: begin
                    I_sdrc_data <= 32'h1000 + burst_cnt;
                    burst_cnt <= burst_cnt + 1'b1;

                    if (burst_cnt == 8'd7)
                        state <= ST_RD_CMD;
                end

                ST_RD_CMD: begin
                    I_sdrc_addr <= 21'h000100;
                    I_sdrc_data_len <= 8'd8;
                    I_sdrc_cmd <= CMD_READ;
                    I_sdrc_cmd_en <= 1'b1;

                    if (O_sdrc_cmd_ack) begin
                        I_sdrc_cmd_en <= 1'b0;
                        burst_cnt <= 0;
                        state <= ST_RD_DATA;
                    end
                end

                ST_RD_DATA: begin
                    read_buffer[burst_cnt] <= O_sdrc_data;
                    burst_cnt <= burst_cnt + 1'b1;

                    if (burst_cnt == 8'd7)
                        state <= ST_IDLE;
                end

                default: begin
                    state <= ST_IDLE;
                end

            endcase
        end
    end

endmodule