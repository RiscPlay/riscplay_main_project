

module SDRAM_Controller_HS_Top__SIMULATION(
    input             I_sdrc_rst_n,
    input             I_sdrc_clk,
    input             I_sdram_clk,
    input             I_sdrc_cmd_en,
    input      [2:0]  I_sdrc_cmd,
    input             I_sdrc_precharge_ctrl,
    input             I_sdram_power_down,
    input             I_sdram_selfrefresh,
    input      [20:0] I_sdrc_addr,
    input      [3:0]  I_sdrc_dqm,
    input      [31:0] I_sdrc_data,
    input      [7:0]  I_sdrc_data_len,

    output            O_sdram_clk,

    output reg [31:0] O_sdrc_data,
    output reg        O_sdrc_init_done,
    output reg        O_sdrc_cmd_ack
);

    // =========================================================
    // Memoria comportamental:
    // 2^21 palavras de 32 bits = 8 MiB.
    // O array e sintetizavel como memoria comportamental, mas
    // a implementacao abaixo foi projetada para simulacao.
    // =========================================================

    reg [31:0] mem [0:2097151];

    // Comandos SDRAM: {RAS, CAS, WE}
    localparam [2:0] CMD_LOAD_MODE = 3'b000;
    localparam [2:0] CMD_REFRESH   = 3'b001;
    localparam [2:0] CMD_PRECHARGE = 3'b010;
    localparam [2:0] CMD_ACTIVE    = 3'b011;
    localparam [2:0] CMD_WRITE     = 3'b100;
    localparam [2:0] CMD_READ      = 3'b101;
    localparam [2:0] CMD_NOP       = 3'b111;

    localparam [1:0] ST_IDLE  = 2'd0;
    localparam [1:0] ST_READ  = 2'd1;
    localparam [1:0] ST_WRITE = 2'd2;

    reg [1:0] state;

    reg [20:0] burst_addr;
    reg [8:0]  burst_remaining;
    reg [5:0]  init_counter;

    integer i;

    // =========================================================
    // Interface fisica simplificada
    // =========================================================

    assign O_sdram_clk   = I_sdram_clk;



    reg [3:0] time_to_wait;
    // =========================================================
    // Controlador comportamental
    // =========================================================
    reg I_sdrc_cmd_en_prev;
    always @(posedge I_sdrc_clk) begin
        if (!I_sdrc_rst_n) begin
            state             <= ST_IDLE;
            burst_addr        <= 21'b0;
            burst_remaining   <= 9'b0;
            init_counter      <= 6'b0;

            O_sdrc_data       <= 32'b0;
            O_sdrc_init_done  <= 1'b0;
            O_sdrc_cmd_ack    <= 1'b0;
            time_to_wait      <= 4'h0;
        end
        else begin
            // ACK dura exatamente um ciclo.
            O_sdrc_cmd_ack <= 1'b0;

            // Inicializacao simulada.
            if (!O_sdrc_init_done) begin
                if (init_counter == 6'd31) begin
                    O_sdrc_init_done <= 1'b1;
                end
                else begin
                    init_counter <= init_counter + 1'b1;
                end
            end
            else begin
                case (state)

                    // -----------------------------------------
                    // Espera um comando de leitura ou escrita.
                    // -----------------------------------------
                    ST_IDLE: begin
                        I_sdrc_cmd_en_prev<=I_sdrc_cmd_en;
                        if ((I_sdrc_cmd_en_prev==1'b0 && I_sdrc_cmd_en==1'b1)|| time_to_wait>4'h0) begin
                            case (I_sdrc_cmd)

                                CMD_READ: begin
                                    if(time_to_wait==4'h0) begin
                                        burst_addr      <= I_sdrc_addr;
                                        burst_remaining <={1'b0, I_sdrc_data_len} + 9'd1;
                                    end
                                    if(time_to_wait<4'h2) begin
                                        time_to_wait<=time_to_wait+4'h1;
                                    end
                                    else begin
                                        state <= ST_READ;
                                    end
                                end

                                CMD_WRITE: begin
                                    burst_addr      <= I_sdrc_addr+ 21'd1;
                                    if (!I_sdrc_dqm[0])
                                        mem[I_sdrc_addr][7:0] <= I_sdrc_data[7:0];

                                    if (!I_sdrc_dqm[1])
                                        mem[I_sdrc_addr][15:8] <= I_sdrc_data[15:8];

                                    if (!I_sdrc_dqm[2])
                                        mem[I_sdrc_addr][23:16] <= I_sdrc_data[23:16];

                                    if (!I_sdrc_dqm[3])
                                        mem[I_sdrc_addr][31:24] <= I_sdrc_data[31:24];
                                    burst_remaining <=
                                        {1'b0, I_sdrc_data_len};
                                    state           <= ST_WRITE;
                                    time_to_wait      <= 4'h0;

                                end

                                CMD_PRECHARGE,
                                CMD_REFRESH,
                                CMD_ACTIVE,
                                CMD_LOAD_MODE: begin
                                    // Comandos de controle fisico
                                    // nao precisam alterar o array.
                                    O_sdrc_cmd_ack <= 1'b1;
                                    time_to_wait      <= 4'h0;

                                end

                                default: begin
                                    // Comando ignorado.
                                end
                            endcase
                        end
                    end

                    // -----------------------------------------
                    // Leitura em rajada.
                    // Uma palavra por ciclo de I_sdrc_clk.
                    // -----------------------------------------
                    ST_READ: begin
                        time_to_wait      <= 4'h0;
                        O_sdrc_data <= mem[burst_addr];

                        // Incrementa o endereco da palavra.
                        burst_addr <= burst_addr + 21'd1;

                        if (burst_remaining == 9'd1) begin
                            burst_remaining <= 9'd0;
                            state            <= ST_IDLE;
                            O_sdrc_cmd_ack   <= 1'b1;
                        end
                        else begin
                            burst_remaining <=
                                burst_remaining - 9'd1;
                        end
                    end

                    // -----------------------------------------
                    // Escrita em rajada com mascara por byte.
                    // DQM[n] = 1 impede a escrita do byte n.
                    // -----------------------------------------
                    ST_WRITE: begin
                        time_to_wait      <= 4'h0;
                        if (!I_sdrc_dqm[0])
                            mem[burst_addr][7:0] <= I_sdrc_data[7:0];

                        if (!I_sdrc_dqm[1])
                            mem[burst_addr][15:8] <= I_sdrc_data[15:8];

                        if (!I_sdrc_dqm[2])
                            mem[burst_addr][23:16] <= I_sdrc_data[23:16];

                        if (!I_sdrc_dqm[3])
                            mem[burst_addr][31:24] <= I_sdrc_data[31:24];

                        burst_addr <= burst_addr + 21'd1;

                        if (burst_remaining == 9'd1) begin
                            burst_remaining <= 9'd0;
                            state            <= ST_IDLE;
                            O_sdrc_cmd_ack   <= 1'b1;
                        end
                        else begin
                            burst_remaining <=
                                burst_remaining - 9'd1;
                        end
                    end

                    default: begin
                        state <= ST_IDLE;
                    end

                endcase
            end
        end
    end

endmodule
