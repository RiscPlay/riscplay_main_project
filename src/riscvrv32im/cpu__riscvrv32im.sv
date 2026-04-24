module rv32im_cpu(
    input clk,
    input reset,

    output wire [31:0] mem_addr___external,
    output wire [31:0] mem_wdata___external,
    input  wire  [31:0] mem_rdata___external,
    output wire      mem_we___external,
    input wire enable,




    output  reg    [5:0]   leds,
    output  reg    [31:0]  pc_out  
  );
  

  reg  [31:0]  mem_addr;
  reg  [31:0]  mem_wdata;
  wire [31:0]  mem_rdata;
  reg          mem_we;
  reg          mem_we_byte;
  reg          mem_we_half;
  reg  [7:0]  mem_rdata_byte;
  reg  [15:0] mem_rdata_half;
  reg   [7:0]  mem_wdata_byte;
  reg   [15:0] mem_wdata_half;
  wire memory_control___busy;

  memory_control memory_control_ins(
    .clk(clk),
    .mem_addr___from_cpu(mem_addr___external),
    .mem_wdata___from_cpu(mem_wdata___external),
    .mem_rdata___from_cpu(mem_rdata___external),
    .mem_we___from_cpu(mem_we___external),
    
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    .mem_we(mem_we),
    .mem_we_byte(mem_we_byte),
    .mem_we_half(mem_we_half),

    .mem_rdata_byte(mem_rdata_byte),
    .mem_rdata_half(mem_rdata_half),

    .mem_wdata_byte(mem_wdata_byte),
    .mem_wdata_half(mem_wdata_half),
    .reset(reset),
    .busy(memory_control___busy)
);

  reg [7:0] time_that_stage_hold;

  reg [31:0] pc;
  reg [31:0] instr;

  (* ram_style = "distributed" *)
  reg [31:0] regfile [0:31];

  (* keep = "true" *) reg [31:0] rs1_val;
  (* keep = "true" *) reg [31:0] rs2_val;
  (* keep = "true" *) reg [31:0] alu_result;

  reg [4:0] rd;

  reg [3:0] state;
  reg [3:0] state_prev;

  localparam
    FETCH       = 4'h0,
    DECODE      = 4'h1,
    EXECUTE     = 4'h2,
    MEMORY      = 4'h3,
    WRITEBACK   = 4'h4,
    STATE_RESET = 4'hf;

  wire [6:0] opcode = instr[6:0];
  wire [2:0] funct3 = instr[14:12];
  wire [6:0] funct7 = instr[31:25];

  wire [4:0] rs1 = instr[19:15];
  wire [4:0] rs2 = instr[24:20];

  wire [31:0] imm_i = {{20{instr[31]}},instr[31:20]};
  wire [31:0] imm_s = {{20{instr[31]}},instr[31:25],instr[11:7]};
  wire [31:0] imm_b = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
  wire [31:0] imm_u = {instr[31:12],12'b0};
  wire [31:0] imm_j = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
  wire [31:0] imm_i_unsigned = {{20{1'b0}}, instr[31:20]};
  reg branch_taken;
  reg write_in_register;

  wire sync__state=state_prev==state;
  `ifndef SIM
  `include "alu_defines.vh"
  `endif
  `ifdef SIM
  `include "riscvrv32im/alu_defines.vh"
  `endif
  always @(posedge clk) begin
    if(reset==1'b0) begin
        if(sync__state) begin
            if(time_that_stage_hold<8'hff) begin
                time_that_stage_hold<=time_that_stage_hold+8'h01;
            end
        end
        else begin
            time_that_stage_hold<=8'h00;
        end
        state_prev<=state;
    end
    else begin 
      time_that_stage_hold<=8'h00;
      state_prev<=STATE_RESET;
    end
  end
  
  always @(posedge clk)
  begin
    //pc_out<=pc;
    if(reset)
    begin
      leds<=6'b000000;
      pc <= 32'h80000000;
      state <= FETCH;
      branch_taken<=1'b0;
      write_in_register<=1'b0;
      mem_we   <= 1'b0;
      mem_we_byte<= 1'b0;
      mem_we_half<=1'b0;
      mem_addr <= 32'h80000000;
      leds<=6'b111111;
    end

    else if(enable) begin
      case(state)

        FETCH:begin
          
            mem_addr <= pc;
            regfile[5'b00000]<=32'h00000000;
            mem_we   <= 0;
            mem_we_byte<=0;
            mem_we_half<=0;
            alu_result<=32'h00000000;
            branch_taken<=1'b0;
            if(sync__state & time_that_stage_hold>8'h07) begin
              state <= DECODE;
              instr <= mem_rdata;
            end
        end
        DECODE: begin
          rs1_val <= regfile[rs1];
          rs2_val <= regfile[rs2];
          rd <= instr[11:7];
          write_in_register<=1'b0;
          if(sync__state & time_that_stage_hold>8'h05) begin
            state <= EXECUTE;
          end
        end

        EXECUTE: begin
          case(opcode)
            7'b0000011: begin
              mem_addr <= rs1_val + imm_i;
              if(sync__state & time_that_stage_hold>8'h08 & (~memory_control___busy)) begin
                state    <= MEMORY;
              end
            end
            7'b0100011: begin
              `ifndef SIM
              `include "store.vh"
              `endif
              `ifdef SIM
              `include "riscvrv32im/store.vh"
              `endif
              if(sync__state & time_that_stage_hold>8'h08 & (~memory_control___busy)) begin
                state<= MEMORY;
              end

            end
            7'b0010011: begin
              `ifndef SIM
              `include "alu_im.vh"
              `endif
              `ifdef SIM
              `include "riscvrv32im/alu_im.vh"
              `endif
              state <= WRITEBACK;
              write_in_register<=1'b1;

            end
            7'b0110011: begin
              `ifndef SIM
              `include "alu.vh"
              `endif
              `ifdef SIM
              `include "riscvrv32im/alu.vh"
              `endif
              state <= WRITEBACK;
              write_in_register<=1'b1;
            end
            7'b1100011: begin
              `ifndef SIM
              `include "branch.vh"
              `endif
              `ifdef SIM
              `include "riscvrv32im/branch.vh"
              `endif

              state <= WRITEBACK;
            end
            7'b1100111: begin //JALR
              if(funct3==3'b000) begin
                alu_result<= pc+32'h00000004;
                write_in_register<=1'b1;
                state <= WRITEBACK;
              end
            end
            7'b1101111: begin // JAL
              alu_result <= pc+32'h00000004;
              write_in_register<=1'b1;
              state <= WRITEBACK;
            end
            7'b0110111: begin //LUI
              alu_result <= imm_u;
              write_in_register<=1'b1;
              state <= WRITEBACK;

            end
            7'b0010111: begin //AUIPC
              alu_result <= pc + imm_u;
              write_in_register<=1'b1;
              state <= WRITEBACK;
            end
            7'b0001111: begin // FENCE
              state <= WRITEBACK;
            end
            default: begin
              state <= WRITEBACK;
            end

          endcase

        end

        MEMORY: begin
          case(opcode)
            7'b0000011: begin
              `ifndef SIM
              `include "load.vh"
              `endif 
              `ifdef SIM
              `include "riscvrv32im/load.vh"
              `endif 
              write_in_register<=1'b1;
            end
          endcase
          if(sync__state & time_that_stage_hold>8'h01 ) begin
              mem_we<=1'b0;
              mem_we_byte<=1'b0;
              mem_we_half<=1'b0;
          end
          if(sync__state & time_that_stage_hold>8'h08 & (~memory_control___busy)) begin
              state <= WRITEBACK;
          end
        end

        WRITEBACK: begin
          if((rd != 0) & write_in_register)
            regfile[rd] <= alu_result;
          case (opcode)
            7'b1100011: begin //branch
              if(branch_taken) 
                pc <= pc + imm_b;
              else
                pc <= pc + 32'h00000004;
            end

            7'b1100111: begin //JALR
              if(funct3==3'b000) 
                pc <= (rs1_val + imm_i) &  ~32'h1;
              else 
                pc <= pc + 32'h00000004;
            end
            7'b1101111: begin // JAL
                pc <=  pc+imm_j;
            end
            default: pc <= pc + 32'h00000004;
          endcase
          state <= FETCH;

        end

      endcase

    end

  end

endmodule
