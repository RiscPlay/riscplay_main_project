//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.11.03 Education
//Part Number: GW2AR-LV18QN88C8/I7
//Device: GW2AR-18
//Device Version: C
//Created Time: Tue Sep 22 18:00:59 2026

module Gowin_SP_SRAM_MAIN_MEMORY (dout, clk, oce, ce, reset, wre, ad, din);

output [31:0] dout;
input clk;
input oce;
input ce;
input reset;
input wre;
input [12:0] ad;
input [31:0] din;

wire [26:0] spx9_inst_0_dout_w;
wire [8:0] spx9_inst_0_dout;
wire [26:0] spx9_inst_1_dout_w;
wire [8:0] spx9_inst_1_dout;
wire [26:0] spx9_inst_2_dout_w;
wire [8:0] spx9_inst_2_dout;
wire [26:0] spx9_inst_3_dout_w;
wire [8:0] spx9_inst_3_dout;
wire [26:0] spx9_inst_4_dout_w;
wire [17:9] spx9_inst_4_dout;
wire [26:0] spx9_inst_5_dout_w;
wire [17:9] spx9_inst_5_dout;
wire [26:0] spx9_inst_6_dout_w;
wire [17:9] spx9_inst_6_dout;
wire [26:0] spx9_inst_7_dout_w;
wire [17:9] spx9_inst_7_dout;
wire [29:0] sp_inst_8_dout_w;
wire [29:0] sp_inst_9_dout_w;
wire [29:0] sp_inst_10_dout_w;
wire [29:0] sp_inst_11_dout_w;
wire [29:0] sp_inst_12_dout_w;
wire [29:0] sp_inst_13_dout_w;
wire [29:0] sp_inst_14_dout_w;
wire dff_q_0;
wire dff_q_1;
wire mux_o_0;
wire mux_o_1;
wire mux_o_3;
wire mux_o_4;
wire mux_o_6;
wire mux_o_7;
wire mux_o_9;
wire mux_o_10;
wire mux_o_12;
wire mux_o_13;
wire mux_o_15;
wire mux_o_16;
wire mux_o_18;
wire mux_o_19;
wire mux_o_21;
wire mux_o_22;
wire mux_o_24;
wire mux_o_25;
wire mux_o_27;
wire mux_o_28;
wire mux_o_30;
wire mux_o_31;
wire mux_o_33;
wire mux_o_34;
wire mux_o_36;
wire mux_o_37;
wire mux_o_39;
wire mux_o_40;
wire mux_o_42;
wire mux_o_43;
wire mux_o_45;
wire mux_o_46;
wire mux_o_48;
wire mux_o_49;
wire mux_o_51;
wire mux_o_52;
wire ce_w;
wire gw_gnd;

assign ce_w = ~wre & ce;
assign gw_gnd = 1'b0;

SPX9 spx9_inst_0 (
    .DO({spx9_inst_0_dout_w[26:0],spx9_inst_0_dout[8:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[8:0]})
);

defparam spx9_inst_0.READ_MODE = 1'b0;
defparam spx9_inst_0.WRITE_MODE = 2'b00;
defparam spx9_inst_0.BIT_WIDTH = 9;
defparam spx9_inst_0.BLK_SEL = 3'b000;
defparam spx9_inst_0.RESET_MODE = "SYNC";

SPX9 spx9_inst_1 (
    .DO({spx9_inst_1_dout_w[26:0],spx9_inst_1_dout[8:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[8:0]})
);

defparam spx9_inst_1.READ_MODE = 1'b0;
defparam spx9_inst_1.WRITE_MODE = 2'b00;
defparam spx9_inst_1.BIT_WIDTH = 9;
defparam spx9_inst_1.BLK_SEL = 3'b001;
defparam spx9_inst_1.RESET_MODE = "SYNC";

SPX9 spx9_inst_2 (
    .DO({spx9_inst_2_dout_w[26:0],spx9_inst_2_dout[8:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[8:0]})
);

defparam spx9_inst_2.READ_MODE = 1'b0;
defparam spx9_inst_2.WRITE_MODE = 2'b00;
defparam spx9_inst_2.BIT_WIDTH = 9;
defparam spx9_inst_2.BLK_SEL = 3'b010;
defparam spx9_inst_2.RESET_MODE = "SYNC";

SPX9 spx9_inst_3 (
    .DO({spx9_inst_3_dout_w[26:0],spx9_inst_3_dout[8:0]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[8:0]})
);

defparam spx9_inst_3.READ_MODE = 1'b0;
defparam spx9_inst_3.WRITE_MODE = 2'b00;
defparam spx9_inst_3.BIT_WIDTH = 9;
defparam spx9_inst_3.BLK_SEL = 3'b011;
defparam spx9_inst_3.RESET_MODE = "SYNC";

SPX9 spx9_inst_4 (
    .DO({spx9_inst_4_dout_w[26:0],spx9_inst_4_dout[17:9]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[17:9]})
);

defparam spx9_inst_4.READ_MODE = 1'b0;
defparam spx9_inst_4.WRITE_MODE = 2'b00;
defparam spx9_inst_4.BIT_WIDTH = 9;
defparam spx9_inst_4.BLK_SEL = 3'b000;
defparam spx9_inst_4.RESET_MODE = "SYNC";

SPX9 spx9_inst_5 (
    .DO({spx9_inst_5_dout_w[26:0],spx9_inst_5_dout[17:9]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[17:9]})
);

defparam spx9_inst_5.READ_MODE = 1'b0;
defparam spx9_inst_5.WRITE_MODE = 2'b00;
defparam spx9_inst_5.BIT_WIDTH = 9;
defparam spx9_inst_5.BLK_SEL = 3'b001;
defparam spx9_inst_5.RESET_MODE = "SYNC";

SPX9 spx9_inst_6 (
    .DO({spx9_inst_6_dout_w[26:0],spx9_inst_6_dout[17:9]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[17:9]})
);

defparam spx9_inst_6.READ_MODE = 1'b0;
defparam spx9_inst_6.WRITE_MODE = 2'b00;
defparam spx9_inst_6.BIT_WIDTH = 9;
defparam spx9_inst_6.BLK_SEL = 3'b010;
defparam spx9_inst_6.RESET_MODE = "SYNC";

SPX9 spx9_inst_7 (
    .DO({spx9_inst_7_dout_w[26:0],spx9_inst_7_dout[17:9]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,ad[12],ad[11]}),
    .AD({ad[10:0],gw_gnd,gw_gnd,gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[17:9]})
);

defparam spx9_inst_7.READ_MODE = 1'b0;
defparam spx9_inst_7.WRITE_MODE = 2'b00;
defparam spx9_inst_7.BIT_WIDTH = 9;
defparam spx9_inst_7.BLK_SEL = 3'b011;
defparam spx9_inst_7.RESET_MODE = "SYNC";

SP sp_inst_8 (
    .DO({sp_inst_8_dout_w[29:0],dout[19:18]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[19:18]})
);

defparam sp_inst_8.READ_MODE = 1'b0;
defparam sp_inst_8.WRITE_MODE = 2'b00;
defparam sp_inst_8.BIT_WIDTH = 2;
defparam sp_inst_8.BLK_SEL = 3'b000;
defparam sp_inst_8.RESET_MODE = "SYNC";

SP sp_inst_9 (
    .DO({sp_inst_9_dout_w[29:0],dout[21:20]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[21:20]})
);

defparam sp_inst_9.READ_MODE = 1'b0;
defparam sp_inst_9.WRITE_MODE = 2'b00;
defparam sp_inst_9.BIT_WIDTH = 2;
defparam sp_inst_9.BLK_SEL = 3'b000;
defparam sp_inst_9.RESET_MODE = "SYNC";

SP sp_inst_10 (
    .DO({sp_inst_10_dout_w[29:0],dout[23:22]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[23:22]})
);

defparam sp_inst_10.READ_MODE = 1'b0;
defparam sp_inst_10.WRITE_MODE = 2'b00;
defparam sp_inst_10.BIT_WIDTH = 2;
defparam sp_inst_10.BLK_SEL = 3'b000;
defparam sp_inst_10.RESET_MODE = "SYNC";

SP sp_inst_11 (
    .DO({sp_inst_11_dout_w[29:0],dout[25:24]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[25:24]})
);

defparam sp_inst_11.READ_MODE = 1'b0;
defparam sp_inst_11.WRITE_MODE = 2'b00;
defparam sp_inst_11.BIT_WIDTH = 2;
defparam sp_inst_11.BLK_SEL = 3'b000;
defparam sp_inst_11.RESET_MODE = "SYNC";

SP sp_inst_12 (
    .DO({sp_inst_12_dout_w[29:0],dout[27:26]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[27:26]})
);

defparam sp_inst_12.READ_MODE = 1'b0;
defparam sp_inst_12.WRITE_MODE = 2'b00;
defparam sp_inst_12.BIT_WIDTH = 2;
defparam sp_inst_12.BLK_SEL = 3'b000;
defparam sp_inst_12.RESET_MODE = "SYNC";

SP sp_inst_13 (
    .DO({sp_inst_13_dout_w[29:0],dout[29:28]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[29:28]})
);

defparam sp_inst_13.READ_MODE = 1'b0;
defparam sp_inst_13.WRITE_MODE = 2'b00;
defparam sp_inst_13.BIT_WIDTH = 2;
defparam sp_inst_13.BLK_SEL = 3'b000;
defparam sp_inst_13.RESET_MODE = "SYNC";

SP sp_inst_14 (
    .DO({sp_inst_14_dout_w[29:0],dout[31:30]}),
    .CLK(clk),
    .OCE(oce),
    .CE(ce),
    .RESET(reset),
    .WRE(wre),
    .BLKSEL({gw_gnd,gw_gnd,gw_gnd}),
    .AD({ad[12:0],gw_gnd}),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[31:30]})
);

defparam sp_inst_14.READ_MODE = 1'b0;
defparam sp_inst_14.WRITE_MODE = 2'b00;
defparam sp_inst_14.BIT_WIDTH = 2;
defparam sp_inst_14.BLK_SEL = 3'b000;
defparam sp_inst_14.RESET_MODE = "SYNC";

DFFE dff_inst_0 (
  .Q(dff_q_0),
  .D(ad[12]),
  .CLK(clk),
  .CE(ce_w)
);
DFFE dff_inst_1 (
  .Q(dff_q_1),
  .D(ad[11]),
  .CLK(clk),
  .CE(ce_w)
);
MUX2 mux_inst_0 (
  .O(mux_o_0),
  .I0(spx9_inst_0_dout[0]),
  .I1(spx9_inst_1_dout[0]),
  .S0(dff_q_1)
);
MUX2 mux_inst_1 (
  .O(mux_o_1),
  .I0(spx9_inst_2_dout[0]),
  .I1(spx9_inst_3_dout[0]),
  .S0(dff_q_1)
);
MUX2 mux_inst_2 (
  .O(dout[0]),
  .I0(mux_o_0),
  .I1(mux_o_1),
  .S0(dff_q_0)
);
MUX2 mux_inst_3 (
  .O(mux_o_3),
  .I0(spx9_inst_0_dout[1]),
  .I1(spx9_inst_1_dout[1]),
  .S0(dff_q_1)
);
MUX2 mux_inst_4 (
  .O(mux_o_4),
  .I0(spx9_inst_2_dout[1]),
  .I1(spx9_inst_3_dout[1]),
  .S0(dff_q_1)
);
MUX2 mux_inst_5 (
  .O(dout[1]),
  .I0(mux_o_3),
  .I1(mux_o_4),
  .S0(dff_q_0)
);
MUX2 mux_inst_6 (
  .O(mux_o_6),
  .I0(spx9_inst_0_dout[2]),
  .I1(spx9_inst_1_dout[2]),
  .S0(dff_q_1)
);
MUX2 mux_inst_7 (
  .O(mux_o_7),
  .I0(spx9_inst_2_dout[2]),
  .I1(spx9_inst_3_dout[2]),
  .S0(dff_q_1)
);
MUX2 mux_inst_8 (
  .O(dout[2]),
  .I0(mux_o_6),
  .I1(mux_o_7),
  .S0(dff_q_0)
);
MUX2 mux_inst_9 (
  .O(mux_o_9),
  .I0(spx9_inst_0_dout[3]),
  .I1(spx9_inst_1_dout[3]),
  .S0(dff_q_1)
);
MUX2 mux_inst_10 (
  .O(mux_o_10),
  .I0(spx9_inst_2_dout[3]),
  .I1(spx9_inst_3_dout[3]),
  .S0(dff_q_1)
);
MUX2 mux_inst_11 (
  .O(dout[3]),
  .I0(mux_o_9),
  .I1(mux_o_10),
  .S0(dff_q_0)
);
MUX2 mux_inst_12 (
  .O(mux_o_12),
  .I0(spx9_inst_0_dout[4]),
  .I1(spx9_inst_1_dout[4]),
  .S0(dff_q_1)
);
MUX2 mux_inst_13 (
  .O(mux_o_13),
  .I0(spx9_inst_2_dout[4]),
  .I1(spx9_inst_3_dout[4]),
  .S0(dff_q_1)
);
MUX2 mux_inst_14 (
  .O(dout[4]),
  .I0(mux_o_12),
  .I1(mux_o_13),
  .S0(dff_q_0)
);
MUX2 mux_inst_15 (
  .O(mux_o_15),
  .I0(spx9_inst_0_dout[5]),
  .I1(spx9_inst_1_dout[5]),
  .S0(dff_q_1)
);
MUX2 mux_inst_16 (
  .O(mux_o_16),
  .I0(spx9_inst_2_dout[5]),
  .I1(spx9_inst_3_dout[5]),
  .S0(dff_q_1)
);
MUX2 mux_inst_17 (
  .O(dout[5]),
  .I0(mux_o_15),
  .I1(mux_o_16),
  .S0(dff_q_0)
);
MUX2 mux_inst_18 (
  .O(mux_o_18),
  .I0(spx9_inst_0_dout[6]),
  .I1(spx9_inst_1_dout[6]),
  .S0(dff_q_1)
);
MUX2 mux_inst_19 (
  .O(mux_o_19),
  .I0(spx9_inst_2_dout[6]),
  .I1(spx9_inst_3_dout[6]),
  .S0(dff_q_1)
);
MUX2 mux_inst_20 (
  .O(dout[6]),
  .I0(mux_o_18),
  .I1(mux_o_19),
  .S0(dff_q_0)
);
MUX2 mux_inst_21 (
  .O(mux_o_21),
  .I0(spx9_inst_0_dout[7]),
  .I1(spx9_inst_1_dout[7]),
  .S0(dff_q_1)
);
MUX2 mux_inst_22 (
  .O(mux_o_22),
  .I0(spx9_inst_2_dout[7]),
  .I1(spx9_inst_3_dout[7]),
  .S0(dff_q_1)
);
MUX2 mux_inst_23 (
  .O(dout[7]),
  .I0(mux_o_21),
  .I1(mux_o_22),
  .S0(dff_q_0)
);
MUX2 mux_inst_24 (
  .O(mux_o_24),
  .I0(spx9_inst_0_dout[8]),
  .I1(spx9_inst_1_dout[8]),
  .S0(dff_q_1)
);
MUX2 mux_inst_25 (
  .O(mux_o_25),
  .I0(spx9_inst_2_dout[8]),
  .I1(spx9_inst_3_dout[8]),
  .S0(dff_q_1)
);
MUX2 mux_inst_26 (
  .O(dout[8]),
  .I0(mux_o_24),
  .I1(mux_o_25),
  .S0(dff_q_0)
);
MUX2 mux_inst_27 (
  .O(mux_o_27),
  .I0(spx9_inst_4_dout[9]),
  .I1(spx9_inst_5_dout[9]),
  .S0(dff_q_1)
);
MUX2 mux_inst_28 (
  .O(mux_o_28),
  .I0(spx9_inst_6_dout[9]),
  .I1(spx9_inst_7_dout[9]),
  .S0(dff_q_1)
);
MUX2 mux_inst_29 (
  .O(dout[9]),
  .I0(mux_o_27),
  .I1(mux_o_28),
  .S0(dff_q_0)
);
MUX2 mux_inst_30 (
  .O(mux_o_30),
  .I0(spx9_inst_4_dout[10]),
  .I1(spx9_inst_5_dout[10]),
  .S0(dff_q_1)
);
MUX2 mux_inst_31 (
  .O(mux_o_31),
  .I0(spx9_inst_6_dout[10]),
  .I1(spx9_inst_7_dout[10]),
  .S0(dff_q_1)
);
MUX2 mux_inst_32 (
  .O(dout[10]),
  .I0(mux_o_30),
  .I1(mux_o_31),
  .S0(dff_q_0)
);
MUX2 mux_inst_33 (
  .O(mux_o_33),
  .I0(spx9_inst_4_dout[11]),
  .I1(spx9_inst_5_dout[11]),
  .S0(dff_q_1)
);
MUX2 mux_inst_34 (
  .O(mux_o_34),
  .I0(spx9_inst_6_dout[11]),
  .I1(spx9_inst_7_dout[11]),
  .S0(dff_q_1)
);
MUX2 mux_inst_35 (
  .O(dout[11]),
  .I0(mux_o_33),
  .I1(mux_o_34),
  .S0(dff_q_0)
);
MUX2 mux_inst_36 (
  .O(mux_o_36),
  .I0(spx9_inst_4_dout[12]),
  .I1(spx9_inst_5_dout[12]),
  .S0(dff_q_1)
);
MUX2 mux_inst_37 (
  .O(mux_o_37),
  .I0(spx9_inst_6_dout[12]),
  .I1(spx9_inst_7_dout[12]),
  .S0(dff_q_1)
);
MUX2 mux_inst_38 (
  .O(dout[12]),
  .I0(mux_o_36),
  .I1(mux_o_37),
  .S0(dff_q_0)
);
MUX2 mux_inst_39 (
  .O(mux_o_39),
  .I0(spx9_inst_4_dout[13]),
  .I1(spx9_inst_5_dout[13]),
  .S0(dff_q_1)
);
MUX2 mux_inst_40 (
  .O(mux_o_40),
  .I0(spx9_inst_6_dout[13]),
  .I1(spx9_inst_7_dout[13]),
  .S0(dff_q_1)
);
MUX2 mux_inst_41 (
  .O(dout[13]),
  .I0(mux_o_39),
  .I1(mux_o_40),
  .S0(dff_q_0)
);
MUX2 mux_inst_42 (
  .O(mux_o_42),
  .I0(spx9_inst_4_dout[14]),
  .I1(spx9_inst_5_dout[14]),
  .S0(dff_q_1)
);
MUX2 mux_inst_43 (
  .O(mux_o_43),
  .I0(spx9_inst_6_dout[14]),
  .I1(spx9_inst_7_dout[14]),
  .S0(dff_q_1)
);
MUX2 mux_inst_44 (
  .O(dout[14]),
  .I0(mux_o_42),
  .I1(mux_o_43),
  .S0(dff_q_0)
);
MUX2 mux_inst_45 (
  .O(mux_o_45),
  .I0(spx9_inst_4_dout[15]),
  .I1(spx9_inst_5_dout[15]),
  .S0(dff_q_1)
);
MUX2 mux_inst_46 (
  .O(mux_o_46),
  .I0(spx9_inst_6_dout[15]),
  .I1(spx9_inst_7_dout[15]),
  .S0(dff_q_1)
);
MUX2 mux_inst_47 (
  .O(dout[15]),
  .I0(mux_o_45),
  .I1(mux_o_46),
  .S0(dff_q_0)
);
MUX2 mux_inst_48 (
  .O(mux_o_48),
  .I0(spx9_inst_4_dout[16]),
  .I1(spx9_inst_5_dout[16]),
  .S0(dff_q_1)
);
MUX2 mux_inst_49 (
  .O(mux_o_49),
  .I0(spx9_inst_6_dout[16]),
  .I1(spx9_inst_7_dout[16]),
  .S0(dff_q_1)
);
MUX2 mux_inst_50 (
  .O(dout[16]),
  .I0(mux_o_48),
  .I1(mux_o_49),
  .S0(dff_q_0)
);
MUX2 mux_inst_51 (
  .O(mux_o_51),
  .I0(spx9_inst_4_dout[17]),
  .I1(spx9_inst_5_dout[17]),
  .S0(dff_q_1)
);
MUX2 mux_inst_52 (
  .O(mux_o_52),
  .I0(spx9_inst_6_dout[17]),
  .I1(spx9_inst_7_dout[17]),
  .S0(dff_q_1)
);
MUX2 mux_inst_53 (
  .O(dout[17]),
  .I0(mux_o_51),
  .I1(mux_o_52),
  .S0(dff_q_0)
);
endmodule //Gowin_SP_SRAM_MAIN_MEMORY
