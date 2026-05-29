//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.03 Education 
//Created Time: 2026-04-04 23:49:04
//create_clock -name main_clock -period 11.111 -waveform {0 5.556} [get_nets {clk}]
//create_clock -name main_clock -period 13.468 -waveform {0 6.734} [get_nets {clkout}]
//create_clock -name main_clock -period 9.091 -waveform {0 4.545} [get_nets {clk}]
//create_clock -name main_clock -period 10.526 -waveform {0 5.263} [get_nets {clk}]
//create_clock -name main_clock2 -period 5.882 -waveform {0 2.941} [get_nets {clk_to_get_signals}]
//create_clock -name main_clock -period 13.468 -waveform {0 6.734} [get_nets {clkout}]
create_clock -name clock_send_data_hdmi -period 2.692 -waveform {0 1.346} [get_nets {hdmi_inst/serial_clk}]
create_clock -name pixel_clock -period 13.468 -waveform {0 6.734} [get_nets {clk}]
