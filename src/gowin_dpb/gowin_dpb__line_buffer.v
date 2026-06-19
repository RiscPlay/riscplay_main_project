//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.11.01 Education (64-bit)
//Part Number: GW2AR-LV18QN88C8/I7
//Device: GW2AR-18
//Device Version: C
//Created Time: Wed Jun 10 16:49:12 2026

module Gowin_DPB__LINE_BUFFER (douta, doutb, clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb, ada, dina, adb, dinb);

output [31:0] douta;
output [31:0] doutb;
input clka;
input ocea;
input cea;
input reseta;
input wrea;
input clkb;
input oceb;
input ceb;
input resetb;
input wreb;
input [10:0] ada;
input [31:0] dina;
input [10:0] adb;
input [31:0] dinb;

wire [15:0] dpb_inst_0_douta;
wire [15:0] dpb_inst_0_doutb;
wire [15:0] dpb_inst_1_douta;
wire [15:0] dpb_inst_1_doutb;
wire [31:16] dpb_inst_2_douta;
wire [31:16] dpb_inst_2_doutb;
wire [31:16] dpb_inst_3_douta;
wire [31:16] dpb_inst_3_doutb;
wire dff_q_0;
wire dff_q_1;
wire cea_w;
wire ceb_w;
wire gw_vcc;
wire gw_gnd;

assign cea_w = ~wrea & cea;
assign ceb_w = ~wreb & ceb;
assign gw_vcc = 1'b1;
assign gw_gnd = 1'b0;

DPB dpb_inst_0 (
    .DOA(dpb_inst_0_douta[15:0]),
    .DOB(dpb_inst_0_doutb[15:0]),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[10]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[10]}),
    .ADA({ada[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIA(dina[15:0]),
    .ADB({adb[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB(dinb[15:0])
);

defparam dpb_inst_0.READ_MODE0 = 1'b0;
defparam dpb_inst_0.READ_MODE1 = 1'b0;
defparam dpb_inst_0.WRITE_MODE0 = 2'b00;
defparam dpb_inst_0.WRITE_MODE1 = 2'b00;
defparam dpb_inst_0.BIT_WIDTH_0 = 16;
defparam dpb_inst_0.BIT_WIDTH_1 = 16;
defparam dpb_inst_0.BLK_SEL_0 = 3'b000;
defparam dpb_inst_0.BLK_SEL_1 = 3'b000;
defparam dpb_inst_0.RESET_MODE = "SYNC";

DPB dpb_inst_1 (
    .DOA(dpb_inst_1_douta[15:0]),
    .DOB(dpb_inst_1_doutb[15:0]),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[10]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[10]}),
    .ADA({ada[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIA(dina[15:0]),
    .ADB({adb[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB(dinb[15:0])
);

defparam dpb_inst_1.READ_MODE0 = 1'b0;
defparam dpb_inst_1.READ_MODE1 = 1'b0;
defparam dpb_inst_1.WRITE_MODE0 = 2'b00;
defparam dpb_inst_1.WRITE_MODE1 = 2'b00;
defparam dpb_inst_1.BIT_WIDTH_0 = 16;
defparam dpb_inst_1.BIT_WIDTH_1 = 16;
defparam dpb_inst_1.BLK_SEL_0 = 3'b001;
defparam dpb_inst_1.BLK_SEL_1 = 3'b001;
defparam dpb_inst_1.RESET_MODE = "SYNC";

DPB dpb_inst_2 (
    .DOA(dpb_inst_2_douta[31:16]),
    .DOB(dpb_inst_2_doutb[31:16]),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[10]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[10]}),
    .ADA({ada[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIA(dina[31:16]),
    .ADB({adb[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB(dinb[31:16])
);

defparam dpb_inst_2.READ_MODE0 = 1'b0;
defparam dpb_inst_2.READ_MODE1 = 1'b0;
defparam dpb_inst_2.WRITE_MODE0 = 2'b00;
defparam dpb_inst_2.WRITE_MODE1 = 2'b00;
defparam dpb_inst_2.BIT_WIDTH_0 = 16;
defparam dpb_inst_2.BIT_WIDTH_1 = 16;
defparam dpb_inst_2.BLK_SEL_0 = 3'b000;
defparam dpb_inst_2.BLK_SEL_1 = 3'b000;
defparam dpb_inst_2.RESET_MODE = "SYNC";

DPB dpb_inst_3 (
    .DOA(dpb_inst_3_douta[31:16]),
    .DOB(dpb_inst_3_doutb[31:16]),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,ada[10]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[10]}),
    .ADA({ada[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIA(dina[31:16]),
    .ADB({adb[9:0],gw_gnd,gw_gnd,gw_vcc,gw_vcc}),
    .DIB(dinb[31:16])
);

defparam dpb_inst_3.READ_MODE0 = 1'b0;
defparam dpb_inst_3.READ_MODE1 = 1'b0;
defparam dpb_inst_3.WRITE_MODE0 = 2'b00;
defparam dpb_inst_3.WRITE_MODE1 = 2'b00;
defparam dpb_inst_3.BIT_WIDTH_0 = 16;
defparam dpb_inst_3.BIT_WIDTH_1 = 16;
defparam dpb_inst_3.BLK_SEL_0 = 3'b001;
defparam dpb_inst_3.BLK_SEL_1 = 3'b001;
defparam dpb_inst_3.RESET_MODE = "SYNC";

DFFE dff_inst_0 (
  .Q(dff_q_0),
  .D(ada[10]),
  .CLK(clka),
  .CE(cea_w)
);
DFFE dff_inst_1 (
  .Q(dff_q_1),
  .D(adb[10]),
  .CLK(clkb),
  .CE(ceb_w)
);
MUX2 mux_inst_0 (
  .O(douta[0]),
  .I0(dpb_inst_0_douta[0]),
  .I1(dpb_inst_1_douta[0]),
  .S0(dff_q_0)
);
MUX2 mux_inst_1 (
  .O(douta[1]),
  .I0(dpb_inst_0_douta[1]),
  .I1(dpb_inst_1_douta[1]),
  .S0(dff_q_0)
);
MUX2 mux_inst_2 (
  .O(douta[2]),
  .I0(dpb_inst_0_douta[2]),
  .I1(dpb_inst_1_douta[2]),
  .S0(dff_q_0)
);
MUX2 mux_inst_3 (
  .O(douta[3]),
  .I0(dpb_inst_0_douta[3]),
  .I1(dpb_inst_1_douta[3]),
  .S0(dff_q_0)
);
MUX2 mux_inst_4 (
  .O(douta[4]),
  .I0(dpb_inst_0_douta[4]),
  .I1(dpb_inst_1_douta[4]),
  .S0(dff_q_0)
);
MUX2 mux_inst_5 (
  .O(douta[5]),
  .I0(dpb_inst_0_douta[5]),
  .I1(dpb_inst_1_douta[5]),
  .S0(dff_q_0)
);
MUX2 mux_inst_6 (
  .O(douta[6]),
  .I0(dpb_inst_0_douta[6]),
  .I1(dpb_inst_1_douta[6]),
  .S0(dff_q_0)
);
MUX2 mux_inst_7 (
  .O(douta[7]),
  .I0(dpb_inst_0_douta[7]),
  .I1(dpb_inst_1_douta[7]),
  .S0(dff_q_0)
);
MUX2 mux_inst_8 (
  .O(douta[8]),
  .I0(dpb_inst_0_douta[8]),
  .I1(dpb_inst_1_douta[8]),
  .S0(dff_q_0)
);
MUX2 mux_inst_9 (
  .O(douta[9]),
  .I0(dpb_inst_0_douta[9]),
  .I1(dpb_inst_1_douta[9]),
  .S0(dff_q_0)
);
MUX2 mux_inst_10 (
  .O(douta[10]),
  .I0(dpb_inst_0_douta[10]),
  .I1(dpb_inst_1_douta[10]),
  .S0(dff_q_0)
);
MUX2 mux_inst_11 (
  .O(douta[11]),
  .I0(dpb_inst_0_douta[11]),
  .I1(dpb_inst_1_douta[11]),
  .S0(dff_q_0)
);
MUX2 mux_inst_12 (
  .O(douta[12]),
  .I0(dpb_inst_0_douta[12]),
  .I1(dpb_inst_1_douta[12]),
  .S0(dff_q_0)
);
MUX2 mux_inst_13 (
  .O(douta[13]),
  .I0(dpb_inst_0_douta[13]),
  .I1(dpb_inst_1_douta[13]),
  .S0(dff_q_0)
);
MUX2 mux_inst_14 (
  .O(douta[14]),
  .I0(dpb_inst_0_douta[14]),
  .I1(dpb_inst_1_douta[14]),
  .S0(dff_q_0)
);
MUX2 mux_inst_15 (
  .O(douta[15]),
  .I0(dpb_inst_0_douta[15]),
  .I1(dpb_inst_1_douta[15]),
  .S0(dff_q_0)
);
MUX2 mux_inst_16 (
  .O(douta[16]),
  .I0(dpb_inst_2_douta[16]),
  .I1(dpb_inst_3_douta[16]),
  .S0(dff_q_0)
);
MUX2 mux_inst_17 (
  .O(douta[17]),
  .I0(dpb_inst_2_douta[17]),
  .I1(dpb_inst_3_douta[17]),
  .S0(dff_q_0)
);
MUX2 mux_inst_18 (
  .O(douta[18]),
  .I0(dpb_inst_2_douta[18]),
  .I1(dpb_inst_3_douta[18]),
  .S0(dff_q_0)
);
MUX2 mux_inst_19 (
  .O(douta[19]),
  .I0(dpb_inst_2_douta[19]),
  .I1(dpb_inst_3_douta[19]),
  .S0(dff_q_0)
);
MUX2 mux_inst_20 (
  .O(douta[20]),
  .I0(dpb_inst_2_douta[20]),
  .I1(dpb_inst_3_douta[20]),
  .S0(dff_q_0)
);
MUX2 mux_inst_21 (
  .O(douta[21]),
  .I0(dpb_inst_2_douta[21]),
  .I1(dpb_inst_3_douta[21]),
  .S0(dff_q_0)
);
MUX2 mux_inst_22 (
  .O(douta[22]),
  .I0(dpb_inst_2_douta[22]),
  .I1(dpb_inst_3_douta[22]),
  .S0(dff_q_0)
);
MUX2 mux_inst_23 (
  .O(douta[23]),
  .I0(dpb_inst_2_douta[23]),
  .I1(dpb_inst_3_douta[23]),
  .S0(dff_q_0)
);
MUX2 mux_inst_24 (
  .O(douta[24]),
  .I0(dpb_inst_2_douta[24]),
  .I1(dpb_inst_3_douta[24]),
  .S0(dff_q_0)
);
MUX2 mux_inst_25 (
  .O(douta[25]),
  .I0(dpb_inst_2_douta[25]),
  .I1(dpb_inst_3_douta[25]),
  .S0(dff_q_0)
);
MUX2 mux_inst_26 (
  .O(douta[26]),
  .I0(dpb_inst_2_douta[26]),
  .I1(dpb_inst_3_douta[26]),
  .S0(dff_q_0)
);
MUX2 mux_inst_27 (
  .O(douta[27]),
  .I0(dpb_inst_2_douta[27]),
  .I1(dpb_inst_3_douta[27]),
  .S0(dff_q_0)
);
MUX2 mux_inst_28 (
  .O(douta[28]),
  .I0(dpb_inst_2_douta[28]),
  .I1(dpb_inst_3_douta[28]),
  .S0(dff_q_0)
);
MUX2 mux_inst_29 (
  .O(douta[29]),
  .I0(dpb_inst_2_douta[29]),
  .I1(dpb_inst_3_douta[29]),
  .S0(dff_q_0)
);
MUX2 mux_inst_30 (
  .O(douta[30]),
  .I0(dpb_inst_2_douta[30]),
  .I1(dpb_inst_3_douta[30]),
  .S0(dff_q_0)
);
MUX2 mux_inst_31 (
  .O(douta[31]),
  .I0(dpb_inst_2_douta[31]),
  .I1(dpb_inst_3_douta[31]),
  .S0(dff_q_0)
);
MUX2 mux_inst_32 (
  .O(doutb[0]),
  .I0(dpb_inst_0_doutb[0]),
  .I1(dpb_inst_1_doutb[0]),
  .S0(dff_q_1)
);
MUX2 mux_inst_33 (
  .O(doutb[1]),
  .I0(dpb_inst_0_doutb[1]),
  .I1(dpb_inst_1_doutb[1]),
  .S0(dff_q_1)
);
MUX2 mux_inst_34 (
  .O(doutb[2]),
  .I0(dpb_inst_0_doutb[2]),
  .I1(dpb_inst_1_doutb[2]),
  .S0(dff_q_1)
);
MUX2 mux_inst_35 (
  .O(doutb[3]),
  .I0(dpb_inst_0_doutb[3]),
  .I1(dpb_inst_1_doutb[3]),
  .S0(dff_q_1)
);
MUX2 mux_inst_36 (
  .O(doutb[4]),
  .I0(dpb_inst_0_doutb[4]),
  .I1(dpb_inst_1_doutb[4]),
  .S0(dff_q_1)
);
MUX2 mux_inst_37 (
  .O(doutb[5]),
  .I0(dpb_inst_0_doutb[5]),
  .I1(dpb_inst_1_doutb[5]),
  .S0(dff_q_1)
);
MUX2 mux_inst_38 (
  .O(doutb[6]),
  .I0(dpb_inst_0_doutb[6]),
  .I1(dpb_inst_1_doutb[6]),
  .S0(dff_q_1)
);
MUX2 mux_inst_39 (
  .O(doutb[7]),
  .I0(dpb_inst_0_doutb[7]),
  .I1(dpb_inst_1_doutb[7]),
  .S0(dff_q_1)
);
MUX2 mux_inst_40 (
  .O(doutb[8]),
  .I0(dpb_inst_0_doutb[8]),
  .I1(dpb_inst_1_doutb[8]),
  .S0(dff_q_1)
);
MUX2 mux_inst_41 (
  .O(doutb[9]),
  .I0(dpb_inst_0_doutb[9]),
  .I1(dpb_inst_1_doutb[9]),
  .S0(dff_q_1)
);
MUX2 mux_inst_42 (
  .O(doutb[10]),
  .I0(dpb_inst_0_doutb[10]),
  .I1(dpb_inst_1_doutb[10]),
  .S0(dff_q_1)
);
MUX2 mux_inst_43 (
  .O(doutb[11]),
  .I0(dpb_inst_0_doutb[11]),
  .I1(dpb_inst_1_doutb[11]),
  .S0(dff_q_1)
);
MUX2 mux_inst_44 (
  .O(doutb[12]),
  .I0(dpb_inst_0_doutb[12]),
  .I1(dpb_inst_1_doutb[12]),
  .S0(dff_q_1)
);
MUX2 mux_inst_45 (
  .O(doutb[13]),
  .I0(dpb_inst_0_doutb[13]),
  .I1(dpb_inst_1_doutb[13]),
  .S0(dff_q_1)
);
MUX2 mux_inst_46 (
  .O(doutb[14]),
  .I0(dpb_inst_0_doutb[14]),
  .I1(dpb_inst_1_doutb[14]),
  .S0(dff_q_1)
);
MUX2 mux_inst_47 (
  .O(doutb[15]),
  .I0(dpb_inst_0_doutb[15]),
  .I1(dpb_inst_1_doutb[15]),
  .S0(dff_q_1)
);
MUX2 mux_inst_48 (
  .O(doutb[16]),
  .I0(dpb_inst_2_doutb[16]),
  .I1(dpb_inst_3_doutb[16]),
  .S0(dff_q_1)
);
MUX2 mux_inst_49 (
  .O(doutb[17]),
  .I0(dpb_inst_2_doutb[17]),
  .I1(dpb_inst_3_doutb[17]),
  .S0(dff_q_1)
);
MUX2 mux_inst_50 (
  .O(doutb[18]),
  .I0(dpb_inst_2_doutb[18]),
  .I1(dpb_inst_3_doutb[18]),
  .S0(dff_q_1)
);
MUX2 mux_inst_51 (
  .O(doutb[19]),
  .I0(dpb_inst_2_doutb[19]),
  .I1(dpb_inst_3_doutb[19]),
  .S0(dff_q_1)
);
MUX2 mux_inst_52 (
  .O(doutb[20]),
  .I0(dpb_inst_2_doutb[20]),
  .I1(dpb_inst_3_doutb[20]),
  .S0(dff_q_1)
);
MUX2 mux_inst_53 (
  .O(doutb[21]),
  .I0(dpb_inst_2_doutb[21]),
  .I1(dpb_inst_3_doutb[21]),
  .S0(dff_q_1)
);
MUX2 mux_inst_54 (
  .O(doutb[22]),
  .I0(dpb_inst_2_doutb[22]),
  .I1(dpb_inst_3_doutb[22]),
  .S0(dff_q_1)
);
MUX2 mux_inst_55 (
  .O(doutb[23]),
  .I0(dpb_inst_2_doutb[23]),
  .I1(dpb_inst_3_doutb[23]),
  .S0(dff_q_1)
);
MUX2 mux_inst_56 (
  .O(doutb[24]),
  .I0(dpb_inst_2_doutb[24]),
  .I1(dpb_inst_3_doutb[24]),
  .S0(dff_q_1)
);
MUX2 mux_inst_57 (
  .O(doutb[25]),
  .I0(dpb_inst_2_doutb[25]),
  .I1(dpb_inst_3_doutb[25]),
  .S0(dff_q_1)
);
MUX2 mux_inst_58 (
  .O(doutb[26]),
  .I0(dpb_inst_2_doutb[26]),
  .I1(dpb_inst_3_doutb[26]),
  .S0(dff_q_1)
);
MUX2 mux_inst_59 (
  .O(doutb[27]),
  .I0(dpb_inst_2_doutb[27]),
  .I1(dpb_inst_3_doutb[27]),
  .S0(dff_q_1)
);
MUX2 mux_inst_60 (
  .O(doutb[28]),
  .I0(dpb_inst_2_doutb[28]),
  .I1(dpb_inst_3_doutb[28]),
  .S0(dff_q_1)
);
MUX2 mux_inst_61 (
  .O(doutb[29]),
  .I0(dpb_inst_2_doutb[29]),
  .I1(dpb_inst_3_doutb[29]),
  .S0(dff_q_1)
);
MUX2 mux_inst_62 (
  .O(doutb[30]),
  .I0(dpb_inst_2_doutb[30]),
  .I1(dpb_inst_3_doutb[30]),
  .S0(dff_q_1)
);
MUX2 mux_inst_63 (
  .O(doutb[31]),
  .I0(dpb_inst_2_doutb[31]),
  .I1(dpb_inst_3_doutb[31]),
  .S0(dff_q_1)
);
endmodule //Gowin_DPB__LINE_BUFFER
