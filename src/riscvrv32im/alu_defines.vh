
parameter [6:0] alu_func7_for_SRLI = 7'b0000000;
parameter [6:0] alu_func7_for_SRAI = 7'b0100000;
parameter [6:0] alu_func7_for_SLLI = 7'b0000000;

wire [4:0] shamt = instr[24:20];