module rnd ( 
    input   wire        clk,
    input   wire        rst_n,
    input   wire [15:0] seed,
    output  wire [15:0] ret
);
reg [15:0] t1;
reg [15:0] t2;
reg [15:0] t3;
reg [15:0] count;
assign ret=t3;

always @(posedge clk) begin
    if(!rst_n) begin
        t1<=16'h1250;
        t2<=16'hfa00;
        t3<=seed;
        count<=seed;
    end
    else begin
        if(t3==16'h0000) begin
            t1 <= (seed ^ 16'h1250)^count;
            t2 <= (seed ^ 16'h11f5)^count;
            t3 <= (seed ^ 16'h02f0)^count;
        end
        else begin
            t1 <= t3 ^ (t3 << 7);
            t2 <= t1 ^ (t1 >> 9);
            t3 <= t2 ^ (t2 << 8);
        end
        count<=count+16'h0001;

    end
end
endmodule