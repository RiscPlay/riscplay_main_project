module ps2_controller (
    input  wire        clk,       // clock do FPGA
    input  wire        rst_n,

    // Interface com o controle PS2
    output reg         ps2_att,
    output reg         ps2_clk,
    output reg         ps2_cmd,
    input  wire        ps2_dat,

    // Estado dos botões
    output reg [15:0]  buttons,

    output reg [31:0] debug_signal
);


    localparam IDLE       = 4'd0;
    localparam GENERATE_CLOCK  = 4'd1;

    localparam RECV_AND_SEND_BYTE  = 4'd2;
    localparam WAIT_CONTROLLER_PROC_BYTE  = 4'd3;

    localparam FINISH  = 4'd4;
    localparam STATE_INVALID =4'hf;



    reg [3:0] state;

    wire sync__state=state==state_prev;
    reg [3:0] state_prev;
    reg [23:0] time_that_stage_hold;
    always @(posedge clk) begin
        if(rst_n==1'b1) begin
            if(sync__state) begin
                if(time_that_stage_hold<23'hffffff ) begin
                    time_that_stage_hold<=time_that_stage_hold+24'h01;
                end
            end
            else begin
                time_that_stage_hold<=24'h00;
            end
            state_prev<=state;
        end
        else begin 
            time_that_stage_hold<=24'h00;
            state_prev<=STATE_INVALID;
        end
    end



    localparam CLK_DIV = 247;

    reg [7:0] clk_counter;




    reg [7:0] tx_data;
    reg [7:0] rx_data;

    reg [2:0] bit_count;
    reg [3:0] byte_count;


    reg [7:0] command [0:2];

    wire [3:0] byte_count_plus_1=byte_count + 4'h1;

    wire tick = (clk_counter == CLK_DIV);
    
    reg reset_clk_counter;
    always @(posedge clk) begin
        if (tick || reset_clk_counter==1'b1)
            clk_counter <= 8'b0;
        else
            clk_counter <= clk_counter + 8'b1;
    end
    always @(posedge clk) begin

        if (rst_n==1'b0) begin

            reset_clk_counter <= 1'b1;

            ps2_att <= 1'b1;
            ps2_clk <= 1'b1;
            ps2_cmd <= 1'b1;

            buttons <= 16'hFFFF;

            state <= IDLE;

            bit_count  <= 3'b0;
            byte_count <= 4'h0;

            tx_data <= 0;
            rx_data <= 0;
            command[0] <= 8'h01;
            command[1] <= 8'h42;
            command[2] <= 8'h00;
            debug_signal<=32'h00000000;

        end 
        else begin


            case (state)

                IDLE: begin
                    ps2_att <= 1'b0;
                    byte_count <= 4'h0;
                    bit_count <= 3'b0;
                    tx_data <= command[0];
                    state <= GENERATE_CLOCK;
                    rx_data <= 8'h0;
                    reset_clk_counter<=1'b1;
                end

                GENERATE_CLOCK: begin
                    reset_clk_counter<=1'b0;
                    if (tick) begin
                        if (ps2_clk == 1'b1) begin
                            ps2_cmd <= tx_data[bit_count];
                            ps2_clk <= 1'b0;
                        end 
                        else begin
                            ps2_clk <= 1'b1;
                            state<=RECV_AND_SEND_BYTE;
                        end
                    end
                end
                RECV_AND_SEND_BYTE: begin
                    if(sync__state && time_that_stage_hold==24'h40) begin
                        rx_data[bit_count] <= ps2_dat;
                        bit_count <= bit_count + 3'b1;

                        if (bit_count == 3'd7) begin
                            state<=WAIT_CONTROLLER_PROC_BYTE;
                        end
                        else  begin
                            state <= GENERATE_CLOCK;
                        end
                        
                    end
                end
                WAIT_CONTROLLER_PROC_BYTE: begin
                    if(sync__state && time_that_stage_hold==24'd1480) begin
                        byte_count <= byte_count + 4'h1;
                        if (byte_count == 4'h4) begin
                            state <= FINISH;
                        end 
                        else if(byte_count==4'h2) begin
                            debug_signal[7:0]<={ps2_dat,rx_data[6:0]};
                            state <= GENERATE_CLOCK;
                            /*
                            if({ps2_dat,rx_data[6:0]}!=8'h5a)
                                state <= FINISH;
                            else begin
                                state <= GENERATE_CLOCK;
                            end
                            */
                        end
                        else begin
                            state <= GENERATE_CLOCK;
                        end

                        if(byte_count<4'h2) begin
                            tx_data <= command[byte_count_plus_1[1:0]];
                        end
                        if(byte_count==4'h3) begin
                            debug_signal[15:8]<={ps2_dat,rx_data[6:0]};
                            buttons[15:8]<={ps2_dat,rx_data[6:0]};
                        end
                        else if(byte_count==4'h4) begin
                            debug_signal[23:16]<={ps2_dat,rx_data[6:0]};
                            buttons[7:0]<={ps2_dat,rx_data[6:0]};
                        end
                    end
                end
                FINISH: begin
                    if(sync__state  && time_that_stage_hold==24'h40) begin
                        reset_clk_counter<=1'b1;

                        ps2_att <= 1'b1;
                        ps2_clk <= 1'b1;
                        ps2_cmd <= 1'b1;
                    end
                    if(sync__state  && time_that_stage_hold==24'd1184000)
                        state <= IDLE;
                end
                default:
                    state <= IDLE;
            endcase
        end
    end
endmodule