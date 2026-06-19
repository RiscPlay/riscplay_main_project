module rv32im_cpu___ppu(
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

  memory_control___ppu memory_control_ins(
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
  integer i;

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
  `include "alu_defines___ppu.vh"
  `endif
  `ifdef SIM
  `include "ppu/riscv/alu_defines___ppu.vh"
  `endif
  

  `ifdef SIM
  reg print_rs1;
  reg print_rs2;
  reg print_rd;
  integer fp_with_data;
  `endif
  `ifdef SIM
  initial begin
    fp_with_data = $fopen("out.txt", "w");
    $fwrite(fp_with_data,"pc      ,rs1_val ,r1,rs2_val ,r2,rd_val  ,rd\n");
  end
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
  reg is_doing_div_op;
  reg is_doing_rem_op;


  wire pause_main_FSM_in_WRITEBACK_STAGE =is_doing_div_op|is_doing_rem_op;
  reg  signed [31:0] rs2_val_signed;
  reg  signed [31:0] rs1_val_signed;
  reg  signed [32:0] rs2_val_32bits_unsigned_in_a_reg_33bits_signed;
   
  wire signed [63:0] product_MUL_AND_MULH = rs1_val_signed * rs2_val_signed;
  wire signed [65:0] product_MULHSU=rs1_val_signed *rs2_val_32bits_unsigned_in_a_reg_33bits_signed;
  wire        [63:0] product_MULHU = rs1_val * rs2_val;




  reg           start_div32;
  wire [31:0]   quotient;
  wire [31:0]   remainder;
  wire          busy_div32;
  wire          done_div32;
  reg           signed_mode_div32;
  div32_fsm___ppu div32(
    .clk(clk),
    .rst(reset),
    .start(start_div32),
    .dividend(rs1_val),
    .divisor(rs2_val),
    .signed_mode(signed_mode_div32),
    .quotient(quotient),
    .remainder(remainder),

    .busy(busy),
    .done(done_div32)

  );

  always @(posedge clk) begin
    //pc_out<=pc;
    if(reset) begin
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
      is_doing_div_op<=1'b0;
      is_doing_rem_op<=1'b0;
      for (i = 0; i < 32; i = i + 1) begin
          regfile[i] <= 32'h0;
      end
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
            if(sync__state & time_that_stage_hold>8'h00) begin
              state <= DECODE;
              instr <= mem_rdata;
            end
            `ifdef SIM
            print_rs1<=1'b0;
            print_rs2<=1'b0;
            print_rd<=1'b0;
            `endif
        end
        DECODE: begin
          rs1_val_signed<=$signed(regfile[rs1]);
          rs2_val_signed<=$signed(regfile[rs2]);
          rs2_val_32bits_unsigned_in_a_reg_33bits_signed<=$signed({1'b0,regfile[rs2]});
          rs1_val <= regfile[rs1];
          rs2_val <= regfile[rs2];
          rd <= instr[11:7];
          write_in_register<=1'b0;
          state <= EXECUTE;
          
        end

        EXECUTE: begin
          case(opcode)
            7'b0000011: begin
              mem_addr <= rs1_val + imm_i;
              if(sync__state & time_that_stage_hold>8'h00 ) begin
                state    <= MEMORY;
              end
              `ifdef SIM
              print_rs1<=1'b1;
              `endif
            end
            7'b0100011: begin
              `ifndef SIM
              `include "store___ppu.vh"
              `endif
              `ifdef SIM
              `include "ppu/riscv/store___ppu.vh"
              `endif
              if(sync__state & time_that_stage_hold>8'h00 & (~memory_control___busy)) begin
                state<= MEMORY;
              end
              `ifdef SIM
              print_rs1<=1'b1;
              print_rs2<=1'b1;
              print_rd<=1'b0;
              `endif

            end
            7'b0010011: begin
              `ifndef SIM
              `include "alu_im___ppu.vh"
              `endif
              `ifdef SIM
              `include "ppu/riscv/alu_im___ppu.vh"
              `endif
              state <= WRITEBACK;
              write_in_register<=1'b1;
              `ifdef SIM
              print_rs1<=1'b1;
              print_rd<=1'b1;
              `endif

            end
            7'b0110011: begin
              `ifndef SIM
              `include "alu___ppu.vh"
              `endif
              `ifdef SIM
              `include "ppu/riscv/alu___ppu.vh"
              `endif
              state <= WRITEBACK;
              write_in_register<=1'b1;
              `ifdef SIM
              print_rs1<=1'b1;
              print_rs2<=1'b1;
              print_rd<=1'b1;
              `endif
            end
            7'b1100011: begin
              `ifndef SIM
              `include "branch___ppu.vh"
              `endif
              `ifdef SIM
              `include "ppu/riscv/branch___ppu.vh"
              `endif
              state <= WRITEBACK;
              `ifdef SIM
              print_rs1<=1'b1;
              print_rs2<=1'b1;
              `endif
            end
            7'b1100111: begin //JALR
              if(funct3==3'b000) begin
                alu_result<= pc+32'h00000004;
                write_in_register<=1'b1;
                state <= WRITEBACK;
                `ifdef SIM
                print_rd<=1'b1;
                `endif
              end
            end
            7'b1101111: begin // JAL
              alu_result <= pc+32'h00000004;
              write_in_register<=1'b1;
              state <= WRITEBACK;
              `ifdef SIM
              print_rd<=1'b1;
              `endif
            end
            7'b0110111: begin //LUI
              alu_result <= imm_u;
              write_in_register<=1'b1;
              state <= WRITEBACK;
              `ifdef SIM
              print_rd<=1'b1;
              `endif
            end
            7'b0010111: begin //AUIPC
              alu_result <= pc + imm_u;
              write_in_register<=1'b1;
              state <= WRITEBACK;
              `ifdef SIM
              print_rd<=1'b1;
              `endif
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
              `include "load___ppu.vh"
              `endif 
              `ifdef SIM
              `include "ppu/riscv/load___ppu.vh"
              `endif 
              `ifdef SIM
              print_rd<=1'b1;
              `endif
              write_in_register<=1'b1;
            end
          endcase
          
              mem_we<=1'b0;
              mem_we_byte<=1'b0;
              mem_we_half<=1'b0;
         
              state <= WRITEBACK;
        end

        WRITEBACK: begin
          if(pause_main_FSM_in_WRITEBACK_STAGE==1'b0) begin
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
            `ifdef SIM
            $fwrite(fp_with_data,"%08h,",pc);
            if(print_rs1) $fwrite(fp_with_data,"%08h,%02d,",rs1_val,rs1);
            else $fwrite(fp_with_data,"None    ,No,");
            if(print_rs2) $fwrite(fp_with_data,"%08h,%02d,",rs2_val,rs2);
            else $fwrite(fp_with_data,"None    ,No,");
            
            if(print_rd && rd!=0) $fwrite(fp_with_data,"%08h,%02d",alu_result,rd);
            else if(print_rd) $fwrite(fp_with_data,"00000000,%02d",rd);
            else $fwrite(fp_with_data,"None    ,No");
            $fwrite(fp_with_data,"\n");
            `endif
          end
          else begin
            if(sync__state && time_that_stage_hold>=8'h05) begin
              start_div32<=1'b0;
              if(done_div32) begin
                if(is_doing_div_op) alu_result<=quotient;
                else if(is_doing_rem_op) alu_result<=remainder;
                 is_doing_div_op<=1'b0;
                 is_doing_rem_op<=1'b0;
              end
            end
          end
        end

      endcase

    end

  end

endmodule
