// fifo256_fsm.v
module fifo_debug #(
        parameter [7:0] SIZE = 8'h20
    )(
        input  wire clk,
        input  wire rst_n,
        input  wire cs,
        input  wire wr_req,
        input  wire rd_req,
        input  wire [7:0] din,
        output reg  [7:0] dout,
        output reg  wr_ready,
        output reg  rd_ready,
        output reg  empty,
        output reg  full,
        output reg  busy
    );

    reg [7:0] mem [0:(SIZE-8'h01)];
    reg [7:0] wr_ptr, rd_ptr;
    reg [8:0] count;
    reg last_op_was_write;

    localparam [2:0] IDLE     = 3'b000;
    localparam [2:0] WRITE_P0 = 3'b001;
    localparam [2:0] WRITE_P1 = 3'b010;
    localparam [2:0] READ_P0  = 3'b011;
    localparam [2:0] READ_P1  = 3'b100;
    localparam [2:0] WAIT     = 3'b101;

    reg [2:0] state;
    reg [2:0] state_delay;
    wire sync_state=state==state_delay;
    reg poseedge_rd_req_happened;
    reg poseedge_wr_req_happened;
    reg clear_poseedge_rd_req_happened;
    reg clear_poseedge_wr_req_happened;
    always @(posedge clk)
    begin
        if (cs) begin
            state    <= IDLE;
            wr_ptr   <= 8'h00;
            rd_ptr   <= 8'h00;
            count    <= 8'h00;
            dout     <= 8'h00;
            empty    <= 1'b1;
            full     <= 1'b0;
            wr_ready <= 1'b0;
            rd_ready <= 1'b0;
            last_op_was_write <= 1'b0;
            clear_poseedge_rd_req_happened<=1'b0;
            clear_poseedge_wr_req_happened<=1'b0;

        end else begin
            state_delay<=state;
            case(state)
                default: state<=IDLE;
                IDLE:
                begin
                    if(last_op_was_write)
                    begin
                        if(!empty && poseedge_rd_req_happened) begin
                            state<=READ_P0;
                            last_op_was_write <= 1'b0;
                            rd_ready <= 1'b0;
                            busy<=1'b1;
                            clear_poseedge_rd_req_happened<=1'b1;

                        end
                        else if(!full && poseedge_wr_req_happened) begin
                            state<=WRITE_P0;
                            last_op_was_write <= 1'b1;
                            wr_ready <= 1'b0;
                            busy<=1'b1;
                            clear_poseedge_wr_req_happened<=1'b1;
                        end
                        else begin
                            busy<=1'b0;
                        end
                    end
                    else begin
                        if(!full && poseedge_wr_req_happened) begin
                            state<=WRITE_P0;
                            last_op_was_write <= 1'b1;
                            wr_ready <= 1'b0;
                            busy<=1'b1;
                            clear_poseedge_wr_req_happened<=1'b1;
                            
                        end
                        else if(!empty && poseedge_rd_req_happened) begin
                            state<=READ_P0;
                            last_op_was_write <= 1'b0;
                            rd_ready <= 1'b0;
                            busy<=1'b1;
                            clear_poseedge_rd_req_happened<=1'b1;
                        end
                        else begin
                            busy<=1'b0;
                        end
                    end
                    
                    full  <= (count== SIZE);
                    empty <= (count==0);
                end
                WRITE_P0:
                begin
                    $display("din = %d", din);

                    mem[wr_ptr] <= din;
                    wr_ptr <= wr_ptr +  8'h01;
                    count <= count +  9'b000000001;
                    state<=WRITE_P1;
                    clear_poseedge_wr_req_happened<=1'b0;
                end
                READ_P0:
                begin
                    //$display("dout = %d", dout);
                    dout <= mem[rd_ptr];
                    rd_ptr <= rd_ptr + 8'h01;
                    count <= count - 9'b000000001;
                    state<=READ_P1;
                    clear_poseedge_rd_req_happened<=1'b0;
                end
                READ_P1:
                begin
                    if(rd_ptr==SIZE) begin
                        rd_ptr<=8'h00;
                    end
                    rd_ready <= 1'b1;
                    state<=IDLE;
                end
                WRITE_P1:
                begin
                    if(wr_ptr==SIZE) begin
                        wr_ptr<=8'h00;
                    end
                    wr_ready <= 1'b1;
                    state<=IDLE;
                end
            endcase
        end
    end

    reg rd_req_prev;
    reg wr_req_prev;
    always @(posedge clk)
    begin
        if (!rst_n) begin
            poseedge_rd_req_happened<=1'b0;
            poseedge_wr_req_happened<=1'b0;
        end
        else begin
            rd_req_prev<=rd_req;
            wr_req_prev<=wr_req;
            if(~rd_req_prev&rd_req) begin
                poseedge_rd_req_happened<=1'b1;
            end
            else if(clear_poseedge_rd_req_happened) begin
                poseedge_rd_req_happened<=1'b0;
            end
            if(~wr_req_prev&wr_req) begin
                poseedge_wr_req_happened<=1'b1;
            end
            else if(clear_poseedge_wr_req_happened) begin
                poseedge_wr_req_happened<=1'b0;
            end
        end
    end
endmodule
