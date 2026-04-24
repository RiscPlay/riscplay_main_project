`timescale 1ns/1ps

module pll (
    input  wire clkin,
    output wire  clkout,
    output wire  lock,
    output wire  clkoutp
);
`ifndef SIM 
wire clk_from_pll;
wire clk_from_pll_90d;
wire lock;
wire clk;
`ifdef use_clock_of_72mhz
Gowin_rPLL__72mhz main_clock_used(
     .clkout(clkout), //output clkout
     .clkoutp(clkoutp),
     .clkin(clkin) //input clkin
);
assign lock=1'b1;
`endif


`ifdef use_clock_of_90mhz
Gowin_rPLL___90mhz main_clock_used(
     .clkout(clkout), //output clkout
     .clkoutp(clkoutp),
     .lock(lock),
     .clkin(clkin) //input clkin
);
`endif

`ifdef use_clock_of_144mhz_to_get_log_from_proc
wire clock_debug_to_use_in_devices_low_speed; 
gowin_rpll___clkout_162mhz___clkoutd_5mhz gowin_rpll___clkout_162mhz___clkoutd_5mhz_inst(
    .clkout(clkout),
    .lock(lock), 
    .clkoutp(clkoutp), 
    .clkoutd(clock_debug_to_use_in_devices_low_speed), 
    .clkin(clkin)
);
`endif
`endif
`ifdef SIM 

    real half_period = 5.555;   // 90 MHz
    real phase_90    = 2.777;   // 90°
    reg lock_reg=1'b0;
    reg clck0=1'b0;
    reg clk90=1'b0;
    assign clkout=clck0;
    assign lock=lock_reg;
    assign clkoutp=clk90;
    initial begin
        lock_reg = 0;
        #100;
        lock_reg = 1;
    end

    // clock 0°
    always begin
        #(half_period) clck0 = ~clck0;
    end

    // clock 90° (defasado)
    initial begin
        #(phase_90);
        forever begin
            #(half_period) clk90 = ~clk90;
        end
    end


`endif

endmodule