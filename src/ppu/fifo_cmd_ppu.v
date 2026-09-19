module fifo_cmd_ppu (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        wr_en,
    input  wire [63:0] wr_data,

    input  wire        rd_en,
    output reg  [63:0] rd_data,

    output wire        empty,
    output wire        full,
    output wire        processing_insert,
    output wire        processing_pop
);

    // 16 entries x 64 bits
    reg [63:0] fifo_cmd [0:31];

    // 5 bits because the extra bit helps distinguish
    // the pointer wrap-around.
    reg [5:0] wr_ptr;
    reg [5:0] rd_ptr;

    // Number of elements currently stored
    reg [5:0] count;

    reg do_write;
    reg do_read;
    assign processing_insert=do_write;
    assign processing_pop=do_read;
    assign empty = (count == 6'd0);
    assign full  = (count == 6'd32);
    reg wr_en__prev;
    reg rd_en__prev;
    wire write_happened_in_this_cycle=((wr_en__prev==1'b0 && wr_en==1'b1) || do_write)&& !full;
    wire read_happened_in_this_cycle=((rd_en__prev==1'b0 && rd_en==1'b1) || do_read)&& !empty;

    always @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr  <= 6'd0;
            rd_ptr  <= 6'd0;
            count   <= 6'd0;
            rd_data <= 64'd0;
            wr_en__prev<=1'b0;
            do_write<=1'b0;
            do_read<=1'b0;
            rd_en__prev<=1'b0;
        end
        else begin
            wr_en__prev<=wr_en;
            rd_en__prev<=rd_en;
            // Write
            if ((wr_en__prev==1'b0 && wr_en==1'b1) || do_write) begin
                if(!full) begin
                    fifo_cmd[wr_ptr[4:0]] <= wr_data;
                    wr_ptr <= wr_ptr + 6'b000001;
                    do_write<=1'b0;
                end
                else begin
                    do_write<=1'b1;
                end 
            end
           

            // Read
            if ((rd_en__prev==1'b0 && rd_en==1'b1) || do_read) begin
                if(!empty) begin
                    rd_data <= fifo_cmd[rd_ptr[4:0]];
                    rd_ptr <= rd_ptr + 6'b000001;
                    do_read<=1'b0;
                end
                else begin
                    do_read<=1'b1;
                end
            end

            // Update number of elements
            if (write_happened_in_this_cycle && !read_happened_in_this_cycle) begin
                count <= count + 6'b000001;
            end
            else if (read_happened_in_this_cycle && !write_happened_in_this_cycle) begin
                count <= count - 6'b000001;
            end

        end
    end

endmodule