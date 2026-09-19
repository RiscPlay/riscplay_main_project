//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.11.03 Education
//Part Number: GW2AR-LV18QN88C8/I7
//Device: GW2AR-18
//Device Version: C
//Created Time: Mon Jun 22 21:39:19 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_DPB_Collision_STACK your_instance_name(
        .douta(douta), //output [15:0] douta
        .doutb(doutb), //output [15:0] doutb
        .clka(clka), //input clka
        .ocea(ocea), //input ocea
        .cea(cea), //input cea
        .reseta(reseta), //input reseta
        .wrea(wrea), //input wrea
        .clkb(clkb), //input clkb
        .oceb(oceb), //input oceb
        .ceb(ceb), //input ceb
        .resetb(resetb), //input resetb
        .wreb(wreb), //input wreb
        .ada(ada), //input [9:0] ada
        .dina(dina), //input [15:0] dina
        .adb(adb), //input [9:0] adb
        .dinb(dinb) //input [15:0] dinb
    );

//--------Copy end-------------------
