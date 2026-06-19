module div32_fsm___ppu (
    input  wire        clk,
    input  wire        rst,

    input  wire        start,
    input  wire        signed_mode,
    input  wire [31:0] dividend,
    input  wire [31:0] divisor,

    output reg  [31:0] quotient,
    output reg  [31:0] remainder,

    output reg         busy,
    output reg         done
);

localparam IDLE   = 2'b00;
localparam RUN    = 2'b10;
localparam FINISH = 2'b11;

reg [1:0] state;

reg [31:0] divisor_reg;
// Registrador combinado: [64:32] é o resto, [31:0] é o quociente
reg [64:0] shift_reg; 

reg [5:0] bit_count;
reg sign_q;
reg sign_r;
reg signed_mode_latch;
reg prev_start;

// Desloca o bloco combinado 1 bit para a esquerda e subtrai o divisor do topo
wire [32:0] rem_sub = shift_reg[63:31] - {1'b0, divisor_reg};

always @(posedge clk) begin
    if (rst) begin
        state        <= IDLE;
        busy         <= 1'b0;
        done         <= 1'b0;
        quotient     <= 32'b0;
        remainder    <= 32'b0;
        prev_start   <= 1'b0;
        shift_reg    <= 65'b0;
        divisor_reg  <= 32'b0;
    end
    else begin
        prev_start <= start;
        
        case(state)
            IDLE: begin
                done <= 1'b0;
                if (start && !prev_start) begin
                    signed_mode_latch <= signed_mode;
                    bit_count         <= 6'd32;

                    // Caso Especial: Overflow Assinado (INT_MIN / -1)
                    if (signed_mode && dividend == 32'h80000000 && divisor == 32'hFFFFFFFF) begin
                        quotient  <= 32'h80000000;
                        remainder <= 32'h00000000;
                        done      <= 1'b1;
                    end
                    // Caso Especial: Divisão por Zero
                    else if (divisor == 32'd0) begin
                        quotient  <= 32'hFFFFFFFF;
                        remainder <= dividend;
                        done      <= 1'b1;
                    end
                    // Operação Normal
                    else begin
                        busy <= 1'b1;
                        if (signed_mode) begin
                            sign_q <= dividend[31] ^ divisor[31];
                            sign_r <= dividend[31];
                            shift_reg   <= {33'b0, dividend[31] ? (~dividend + 32'd1) : dividend};
                            divisor_reg <= divisor[31]  ? (~divisor  + 32'd1) : divisor;
                        end
                        else begin
                            sign_q <= 1'b0;
                            sign_r <= 1'b0;
                            shift_reg   <= {33'b0, dividend};
                            divisor_reg <= divisor;
                        end
                        state <= RUN;
                    end
                end
                else begin
                    busy <= 1'b0;
                end
            end

            RUN: begin
                bit_count <= bit_count - 6'd1;
                
                // Avalia a subtração do bit deslocado
                if (rem_sub[32] == 1'b0) begin
                    // Subtração positiva: Resto atualiza e joga 1 no quociente
                    shift_reg <= {rem_sub[31:0], shift_reg[30:0], 1'b1};
                end
                else begin
                    // Subtração negativa: Mantém resto antigo (deslocado) e joga 0 no quociente
                    shift_reg <= {shift_reg[63:0], 1'b0};
                end

                if (bit_count == 6'd1) begin
                    state <= FINISH;
                end
            end

            FINISH: begin
                busy <= 1'b0;
                done <= 1'b1;
                
                if (signed_mode_latch) begin
                    quotient  <= sign_q ? (~shift_reg[31:0]  + 32'd1) : shift_reg[31:0];
                    remainder <= sign_r ? (~shift_reg[63:32] + 32'd1) : shift_reg[63:32];
                end
                else begin
                    quotient  <= shift_reg[31:0];
                    remainder <= shift_reg[63:32];
                end
                
                state <= IDLE;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
