module shutdown_and_start_cpu (
    input   wire         clk,
    input   wire         rst_n,
    input   wire         wake,
    input   wire         is_start,
    output  reg          reset_cpu,
    output  reg          stopped
);

always @(posedge clk) begin
    if(!rst_n) begin
        stopped<=1'b1;
        reset_cpu<=1'b0;
    end
    else begin
        if(wake) begin
            if(is_start==1'b0) begin
                reset_cpu<=1'b1;
            end
            else begin
                reset_cpu<=1'b0;
            end
        end
        stopped<=1'b1;
    end
end

endmodule