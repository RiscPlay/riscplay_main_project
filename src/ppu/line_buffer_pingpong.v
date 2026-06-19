module line_buffer_pingpong (
    input  wire       clk,
    input  wire       rd__buffer1,

    // WRITE
    input  wire       wrea_write,
    input  wire       wreb_write,
    input  wire [9:0] ada_write,
    input  wire [9:0] adb_write,
    input  wire [7:0] dina_write,
    input  wire [7:0] dinb_write,

    // READ
    input  wire [9:0] ada_read,
    input  wire [9:0] adb_read,

    output wire [7:0] douta_read,
    output wire [7:0] doutb_read
);

    // ==================================================
    // BUFFER 1
    // ==================================================

    wire [7:0] douta_buf1;
    wire [7:0] doutb_buf1;

    Gowin_DPB__LINE_BUFFER buffer1 (
        .ada(
            rd__buffer1 ?
            ada_read :
            ada_write 
        ),

        .adb(
            rd__buffer1 ?
            adb_read :
            adb_write 
        ),

        .dina(
            rd__buffer1 ?
            8'd0 :
            dina_write
        ),

        .dinb(
            rd__buffer1 ?
            8'd0 :
            dinb_write
        ),

        .wrea(
            rd__buffer1 ?
            1'b0 :
            wrea_write
        ),

        .wreb(
            rd__buffer1 ?
            1'b0 :
            wreb_write
        ),

        .douta(douta_buf1),
        .doutb(doutb_buf1),

        .ocea(1'b1),
        .cea(1'b1),
        .reseta(1'b0),

        .oceb(1'b1),
        .ceb(1'b1),
        .resetb(1'b0),

        .clka(clk),
        .clkb(clk)
    );

    // ==================================================
    // BUFFER 2
    // ==================================================

    wire [7:0] douta_buf2;
    wire [7:0] doutb_buf2;

    Gowin_DPB__LINE_BUFFER buffer2 (
        .ada(
            rd__buffer1 ?
            ada_write : 
            ada_read 
        ),

        .adb(
            rd__buffer1 ?
            adb_write: 
            adb_read 
        ),

        .dina(
            rd__buffer1 ?
            dina_write : 
            8'd0 
        ),

        .dinb(
            rd__buffer1 ?
            dinb_write : 
            8'd0 
        ),

        .wrea(
            rd__buffer1 ?
            wrea_write: 
            1'b0 
            
        ),

        .wreb(
            rd__buffer1 ?
            wreb_write : 
            1'b0 
        ),

        .douta(douta_buf2),
        .doutb(doutb_buf2),

        .ocea(1'b1),
        .cea(1'b1),
        .reseta(1'b0),

        .oceb(1'b1),
        .ceb(1'b1),
        .resetb(1'b0),

        .clka(clk),
        .clkb(clk)
    );

    // ==================================================
    // READ MUX
    // ==================================================

    assign douta_read =
        rd__buffer1 ?
        douta_buf1 : 
        douta_buf2 ;

    assign doutb_read =
        rd__buffer1 ?
        doutb_buf1 :
        doutb_buf2;

endmodule