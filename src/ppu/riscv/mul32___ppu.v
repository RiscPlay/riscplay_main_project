module mul32___ppu (
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire [1:0]  op,   // 00=MUL, 01=MULH, 10=MULHSU, 11=MULHU
    output reg  [31:0] rd
);

    // ============================================================
    // SINGLE DSP (Shared Multiplier Core)
    // ============================================================

    // rs1 is signed for MUL, MULH, and MULHSU (op != 2'b11).
    // If signed: sign-extend by replicating the MSB (rs1[31]). 
    // If unsigned (MULHU): zero-extend by prepending 1'b0.
    wire signed [32:0] a_s = (op == 2'b11) ? 
                                $signed({1'b0, rs1}) : $signed({rs1[31], rs1});
                                                         
    // rs2 is signed only for MUL and MULH (op == 2'b00 or 2'b01).
    // If signed: sign-extend by replicating the MSB (rs2[31]). 
    // If unsigned (MULHSU, MULHU): zero-extend by prepending 1'b0.
    wire signed [32:0] b_s = (op == 2'b00 || op == 2'b01) ? 
                                $signed({rs2[31], rs2}) : $signed({1'b0, rs2});                   

    // Pure 33-bit x 33-bit signed multiplication.
    // This yields a precise 66-bit result, avoiding any intermediate truncation bugs.
    wire signed [65:0] prod_ext = a_s * b_s; 

    // ============================================================
    // OUTPUT SELECTION
    // ============================================================

    always @(*) begin
        case (op)
            2'b00:   rd = prod_ext[31:0];  // MUL (lower 32 bits are identical for signed/unsigned)
            2'b01:   rd = prod_ext[63:32]; // MULH
            2'b10:   rd = prod_ext[63:32]; // MULHSU
            2'b11:   rd = prod_ext[63:32]; // MULHU
            default: rd = 32'b0;           // Default case to prevent accidental latch inference
        endcase
    end

endmodule