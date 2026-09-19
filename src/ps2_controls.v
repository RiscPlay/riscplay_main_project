module ps2_digital_controller (
    input  wire        clk,        // Clock principal de 74.25 MHz
    input  wire        rst_n,      // Reset ativo em nível baixo
    
    // Interface física com o controle PS2
    output reg         ps2_clk,    // Clock do PS2 (~250 kHz)
    output reg         ps2_cmd,    // Comando enviado ao controle (MOSI)
    input  wire        ps2_dat,    // Dado recebido do controle (MISO)
    output reg         ps2_att,    // Atenção / Select (CS)
    
    // Estado dos botões digitais (1 = Pressionado, 0 = Solto)
    output reg         btn_select,
    output reg         btn_l3,
    output reg         btn_r3,
    output reg         btn_start,
    output reg         btn_up,
    output reg         btn_right,
    output reg         btn_down,
    output reg         btn_left,
    output reg         btn_l2,
    output reg         btn_r2,
    output reg         btn_l1,
    output reg         btn_r1,
    output reg         btn_triangle,
    output reg         btn_circle,
    output reg         btn_cross,
    output reg         btn_square
);

    // --- Divisão de Clock (74.25 MHz -> ~250 kHz SPI Clock) ---
    reg [7:0] clk_div;
    reg       spi_tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div  <= 8'd0;
            spi_tick <= 1'b0;
        end else begin
            if (clk_div == 8'd148) begin // 74.25 MHz / 297 = 250 kHz
                clk_div  <= 8'd0;
                spi_tick <= 1'b1;
            end else begin
                clk_div  <= clk_div + 1'b1;
                spi_tick <= 1'b0;
            end
        end
    end

    // --- Máquina de Estados e Contadores ---
    localparam ST_IDLE     = 3'd0;
    localparam ST_START    = 3'd1;
    localparam ST_TX_RX    = 3'd2;
    localparam ST_BETWEEN  = 3'd3;
    localparam ST_DELAY    = 3'd4;

    reg [2:0] state;
    reg [2:0] byte_cnt; // Conta de 0 até 4 (5 bytes no modo digital)
    reg [2:0] bit_cnt;  // Conta de 0 até 7 bits
    reg [7:0] delay_cnt;
    reg       clk_phase;

    // Buffers de recepção SPI
    reg [7:0] rx_shift;
    reg [7:0] tmp_byte3;
    reg [7:0] tmp_byte4;

    // --- Lógica de Transmissão / Recepção ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= ST_IDLE;
            ps2_clk     <= 1'b1;
            ps2_cmd     <= 1'b1;
            ps2_att     <= 1'b1;
            byte_cnt    <= 3'd0;
            bit_cnt     <= 3'd0;
            delay_cnt   <= 8'd0;
            clk_phase   <= 1'b0;
            rx_shift    <= 8'd0;
            tmp_byte3   <= 8'hFF;
            tmp_byte4   <= 8'hFF;
            
            // Zera todas as saídas no reset
            {btn_select, btn_l3, btn_r3, btn_start, btn_up, btn_right, btn_down, btn_left} <= 8'd0;
            {btn_l2, btn_r2, btn_l1, btn_r1, btn_triangle, btn_circle, btn_cross, btn_square} <= 8'd0;
        end else if (spi_tick) begin
            case (state)
                
                ST_IDLE: begin
                    ps2_clk   <= 1'b1;
                    ps2_cmd   <= 1'b1;
                    ps2_att   <= 1'b1;
                    byte_cnt  <= 3'd0;
                    bit_cnt   <= 3'd0;
                    delay_cnt <= 8'd0;
                    state     <= ST_START;
                end

                ST_START: begin
                    ps2_att   <= 1'b0; // Ativa CS (Atenção)
                    delay_cnt <= delay_cnt + 1'b1;
                    if (delay_cnt == 8'd10) begin
                        delay_cnt <= 8'd0;
                        state     <= ST_TX_RX;
                        clk_phase <= 1'b0;
                    end
                end

                ST_TX_RX: begin
                    if (!clk_phase) begin
                        // SPI Modo 3: Borda de descida atualiza MOSI (Cmd)
                        ps2_clk   <= 1'b0;
                        clk_phase <= 1'b1;
                        
                        case (byte_cnt)
                            3'd0: ps2_cmd <= (8'h01 >> bit_cnt) & 1'b1; // Start
                            3'd1: ps2_cmd <= (8'h42 >> bit_cnt) & 1'b1; // Request Data
                            default: ps2_cmd <= 1'b0;                   // Idle
                        endcase
                    end else begin
                        // Borda de subida captura MISO (Dat)
                        ps2_clk   <= 1'b1;
                        clk_phase <= 1'b0;
                        
                        rx_shift[bit_cnt] <= ps2_dat;
                        
                        if (bit_cnt == 3'd7) begin
                            bit_cnt <= 3'd0;
                            state   <= ST_BETWEEN;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                end

                ST_BETWEEN: begin
                    // Captura os bytes de dados estruturados
                    case (byte_cnt)
                        3'd3: tmp_byte3 <= rx_shift; // Primeiro byte de botões
                        3'd4: tmp_byte4 <= rx_shift; // Segundo byte de botões
                    endcase

                    if (byte_cnt == 3'd4) begin
                        // Fim do frame digital (5 bytes). Atualiza saídas com lógica invertida (~).
                        btn_select   <= ~tmp_byte3[0];
                        btn_l3       <= ~tmp_byte3[1];
                        btn_r3       <= ~tmp_byte3[2];
                        btn_start    <= ~tmp_byte3[3];
                        btn_up       <= ~tmp_byte3[4];
                        btn_right    <= ~tmp_byte3[5];
                        btn_down     <= ~tmp_byte3[6];
                        btn_left     <= ~tmp_byte3[7];
                        
                        btn_l2       <= ~tmp_byte4[0];
                        btn_r2       <= ~tmp_byte4[1];
                        btn_l1       <= ~tmp_byte4[2];
                        btn_r1       <= ~tmp_byte4[3];
                        btn_triangle <= ~tmp_byte4[4];
                        btn_circle   <= ~tmp_byte4[5];
                        btn_cross    <= ~tmp_byte4[6];
                        btn_square   <= ~tmp_byte4[7];
                        
                        ps2_att      <= 1'b1; // Libera o controle
                        state        <= ST_DELAY;
                    end else begin
                        byte_cnt  <= byte_cnt + 1'b1;
                        delay_cnt <= 8'd0;
                        state     <= ST_START;
                    end
                end

                ST_DELAY: begin
                    // Taxa de atualização estável entre varreduras (~20ms)
                    if (delay_cnt == 8'd200) begin
                        state <= ST_IDLE;
                    end else begin
                        delay_cnt <= delay_cnt + 1'b1;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule