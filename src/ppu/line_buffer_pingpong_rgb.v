module line_buffer_pingpong_rgb (
    input  wire       clk,
    input  wire       rd__buffer1,

    // RED
    input  wire       wrea_red,
    input  wire       wreb_red,
    input  wire [9:0] ada_red_write,
    input  wire [9:0] adb_red_write,
    input  wire [7:0] dina_red_write,
    input  wire [7:0] dinb_red_write,
    input  wire [9:0] ada_red_read,
    input  wire [9:0] adb_red_read,
    output wire [7:0] douta_red,
    output wire [7:0] doutb_red,

    // GREEN
    input  wire       wrea_green,
    input  wire       wreb_green,
    input  wire [9:0] ada_green_write,
    input  wire [9:0] adb_green_write,
    input  wire [7:0] dina_green_write,
    input  wire [7:0] dinb_green_write,
    input  wire [9:0] ada_green_read,
    input  wire [9:0] adb_green_read,
    output wire [7:0] douta_green,
    output wire [7:0] doutb_green,

    // BLUE
    input  wire       wrea_blue,
    input  wire       wreb_blue,
    input  wire [9:0] ada_blue_write,
    input  wire [9:0] adb_blue_write,
    input  wire [7:0] dina_blue_write,
    input  wire [7:0] dinb_blue_write,
    input  wire [9:0] ada_blue_read,
    input  wire [9:0] adb_blue_read,
    output wire [7:0] douta_blue,
    output wire [7:0] doutb_blue
);
    line_buffer_pingpong red (
        .clk(clk),
        .rd__buffer1(rd__buffer1),

        .wrea_write(wrea_red),
        .wreb_write(wreb_red),

        .ada_write(ada_red_write),
        .adb_write(adb_red_write),

        .dina_write(dina_red_write),
        .dinb_write(dinb_red_write),

        .ada_read(ada_red_read),
        .adb_read(adb_red_read),

        .douta_read(douta_red),
        .doutb_read(doutb_red)
    );

    line_buffer_pingpong green (
        .clk(clk),
        .rd__buffer1(rd__buffer1),

        .wrea_write(wrea_green),
        .wreb_write(wreb_green),

        .ada_write(ada_green_write),
        .adb_write(adb_green_write),

        .dina_write(dina_green_write),
        .dinb_write(dinb_green_write),

        .ada_read(ada_green_read),
        .adb_read(adb_green_read),

        .douta_read(douta_green),
        .doutb_read(doutb_green)
    );

    line_buffer_pingpong blue (
        .clk(clk),
        .rd__buffer1(rd__buffer1),

        .wrea_write(wrea_blue),
        .wreb_write(wreb_blue),

        .ada_write(ada_blue_write),
        .adb_write(adb_blue_write),

        .dina_write(dina_blue_write),
        .dinb_write(dinb_blue_write),

        .ada_read(ada_blue_read),
        .adb_read(adb_blue_read),

        .douta_read(douta_blue),
        .doutb_read(doutb_blue)
    );

endmodule