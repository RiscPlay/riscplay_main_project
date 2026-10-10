module qdiv32_fsm(
    input  wire        clk,
    input  wire        rst,

    input  wire        start,
    input  wire [31:0] dividend,
    input  wire [31:0] divisor,

    output reg  [31:0] quotient,

    output reg         busy,
    output reg         done
);

localparam IDLE   = 2'b00;
localparam RUN    = 2'b01;
localparam FINISH = 2'b10;

reg [1:0] state;

reg [31:0] divisor_reg;

// Para 48 iterações, precisamos de 81 bits:
// [80:48] = Remainder (33 bits)
// [47:0]  = Registrador combinado Dividendo / Quociente
reg [80:0] shift_reg;

reg [5:0] bit_count;

reg sign_q;
reg prev_start;

wire [31:0] abs_dividend = dividend[31] ? (~dividend + 32'd1) : dividend;
wire [31:0] abs_divisor  = divisor[31]  ? (~divisor + 32'd1)  : divisor;

// 1. Primeiro passo do ciclo: Desloca o registrador inteiro 1 bit para a esquerda
wire [80:0] next_shift = {shift_reg[79:0], 1'b0};

// 2. Tenta subtrair o divisor do Remainder já deslocado
wire [32:0] rem_sub = next_shift[80:48] - {1'b0, divisor_reg};

always @(posedge clk) begin
    if (rst) begin
        state       <= IDLE;
        busy        <= 1'b0;
        done        <= 1'b0;
        quotient    <= 32'd0;
        divisor_reg <= 32'd0;
        shift_reg   <= 81'd0;
        bit_count   <= 6'd0;
        sign_q      <= 1'b0;
        prev_start  <= 1'b0;
    end
    else begin
        prev_start <= start;

        case(state)

        //--------------------------------------------------
        // IDLE
        //--------------------------------------------------
        IDLE: begin
            done <= 1'b0;
            busy <= 1'b0;

            if(start && !prev_start) begin
                if(divisor == 32'd0) begin
                    quotient <= 32'hFFFFFFFF; // Erro de divisão por zero
                    done     <= 1'b1;
                end
                else begin
                    busy        <= 1'b1;
                    sign_q      <= dividend[31] ^ divisor[31];
                    divisor_reg <= abs_divisor;

                    // Alinhamento Q16.16 para 48 iterações:
                    // Colocamos o dividendo no centro do registrador.
                    // Como ele vai rodar 48 vezes, ele vai ser deslocado para a esquerda 
                    // gerando 32 bits de parte inteira e 16 bits de fracionária adicionais.
                    shift_reg   <= {33'd0, abs_dividend, 16'd0};
                    
                    bit_count   <= 6'd48; // 48 ciclos necessários para o alinhamento fracionário
                    state       <= RUN;
                end
            end
        end

        //--------------------------------------------------
        // RUN
        //--------------------------------------------------
        RUN: begin
            bit_count <= bit_count - 6'd1;

            if(rem_sub[32] == 1'b0) begin
                // Subtração positiva: Armazena o resultado da subtração na parte alta
                // e injeta '1' no bit menos significativo do quociente.
                shift_reg <= {rem_sub, next_shift[47:1], 1'b1};
            end
            else begin
                // Subtração negativa: Mantém o valor do pré-deslocamento (next_shift)
                // e o bit menos significativo já entra como '0'.
                shift_reg <= next_shift;
            end

            if(bit_count == 6'd1)
                state <= FINISH;
        end

        //--------------------------------------------------
        // FINISH
        //--------------------------------------------------
        FINISH: begin
            busy <= 1'b0;
            done <= 1'b1;

            // Após exatamente 48 deslocamentos, o quociente Q16.16 final de 32 bits
            // estará localizado exatamente nos 32 bits inferiores do registrador.
            if(sign_q)
                quotient <= ~shift_reg[31:0] + 32'd1;
            else
                quotient <= shift_reg[31:0];

            state <= IDLE;
        end

        default:
            state <= IDLE;
        endcase
    end
end

endmodule