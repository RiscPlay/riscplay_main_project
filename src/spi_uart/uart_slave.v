module uart_slave (
    input  wire clk,
    input  wire rst_n,
    
    input  wire [7:0] data_line_from_read_fifo,
    output reg        rd_req_fifo,
    input  wire       rd_ready_fifo,
    input  wire       empty_fifo,



    input  wire       uart_rxd,
    output reg [7:0]  data_line_from_write_fifo,
    output reg        wr_req_fifo,
    input  wire       wr_ready_fifo,
    input  wire       full_fifo,
    input  wire       busy_from_write_fifo,
    input  wire       busy_from_read_fifo,




    output wire uart_txd

);

    localparam integer CLOCK_MHZ = 74;
    localparam integer BAUD_RATE = 9600;



    reg  [7:0] last_byte;
    wire [7:0] rx_data;
    reg        rx_accept;
    wire       rx_valid;
    wire       rx_busy;
    reg uart_rxd_sync;
    reg uart_rxd_meta;
    always @(posedge clk ) begin
        if (!rst_n) begin
            uart_rxd_sync <= 1'b1;
            uart_rxd_meta <= 1'b1;
        end else begin
            uart_rxd_meta <= uart_rxd;
            uart_rxd_sync <= uart_rxd_meta;
        end
    end


    uart_rx #(
        .clk_frequency(CLOCK_MHZ),
        .baud_rate(BAUD_RATE)
    ) uart_rx_inst (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_byte_accept(rx_accept),
        .i_data_bit(uart_rxd_sync),
        .o_done(rx_valid),
        .o_data_byte(rx_data)
    );
    reg [2:0] state__rx;

    localparam WAIT_BYTE_RX             = 3'b000;
    localparam PUT_BYTE_IN_FIFO_RX      = 3'b001;
    localparam WAIT_FIFO_PROCESS_P0_RX  = 3'b010;
    localparam WAIT_FIFO_PROCESS_P1_RX  = 3'b011;
    localparam WAIT_RX_RELEASE          = 3'b100;
    always @(posedge clk ) begin
        if (!rst_n) begin
            state__rx     <= WAIT_BYTE_RX;
            last_byte     <= 8'd0;
            wr_req_fifo<=1'b0;
            rx_accept<=1'b0;
            data_line_from_write_fifo<=1'b0;
        end 
        else begin
            case (state__rx)
                WAIT_BYTE_RX: begin
                    rx_accept<=1'b0;
                    if (rx_valid) begin
                        state__rx <= PUT_BYTE_IN_FIFO_RX;
                        last_byte <= rx_data;
                    end
                end
                PUT_BYTE_IN_FIFO_RX: begin
                    if (busy_from_write_fifo==1'b0) begin
                        wr_req_fifo<=1'b1;
                        data_line_from_write_fifo <= last_byte;
                        state__rx <= WAIT_FIFO_PROCESS_P0_RX;
                    end
                end

                WAIT_FIFO_PROCESS_P0_RX: begin
                    wr_req_fifo<=1'b0;
                    if(wr_ready_fifo==1'b0) begin
                        state__rx <= WAIT_FIFO_PROCESS_P1_RX;
                    end
                end
                WAIT_FIFO_PROCESS_P1_RX: begin
                    if(wr_ready_fifo) begin
                        rx_accept<=1'b1;
                        state__rx <= WAIT_RX_RELEASE;
                    end
                end
                WAIT_RX_RELEASE: begin
                    rx_accept <= 1'b0;
                    if (!rx_valid) begin
                        state__rx <= WAIT_BYTE_RX;
                    end
                end
                

                default: state__rx <= WAIT_BYTE_RX;
            endcase
        end
    end


    reg [7:0]   tx_data;
    reg         tx_valid;
    wire        tx_ready;
    wire        tx_done;
    wire        tx_busy;


    uart_tx #(
        .clk_frequency(CLOCK_MHZ),
        .baud_rate(BAUD_RATE)
    ) uart_tx_inst (
        .i_clk    	 (clk),
        .i_rst_n   	 (rst_n),
        .data_send 	 (tx_data),
        .tx_valid  	 (tx_valid),
        .ready_tx  	 (tx_ready),
        .o_tx      	 (uart_txd)
    );
    reg [1:0] state__tx;
    localparam WAIT_FIFO_TX                = 2'b00;
    localparam RECV_BYTE_FROM_FIFO_TX_P0   = 2'b01;
    localparam RECV_BYTE_FROM_FIFO_TX_P1   = 2'b10;
    localparam RECV_BYTE_FROM_FIFO_TX_P2   = 2'b11;

    reg [7:0] count;
    always @(posedge clk) begin
        if (!rst_n) begin
            state__tx       <= WAIT_FIFO_TX;
            tx_data     <= 8'd0;
            tx_valid    <= 1'b0;
            rd_req_fifo<=1'b0;
            count<=8'd10;
        end else begin
            case (state__tx)

                WAIT_FIFO_TX: begin
                    tx_valid<=1'b0;
                    if (empty_fifo==1'b0 && busy_from_read_fifo==1'b0) begin
                        rd_req_fifo<=1'b1;
                        state__tx <= RECV_BYTE_FROM_FIFO_TX_P0;
                    end
                end

                RECV_BYTE_FROM_FIFO_TX_P0: begin
                    rd_req_fifo<=1'b0;
                    if (rd_ready_fifo==1'b0) begin
                        state__tx <= RECV_BYTE_FROM_FIFO_TX_P1;
                    end
                end
                RECV_BYTE_FROM_FIFO_TX_P1: begin
                    if(rd_ready_fifo==1'b1 ) begin
                        state__tx <= RECV_BYTE_FROM_FIFO_TX_P2;
                        tx_valid  <= 1'b1;
                        tx_data<=data_line_from_read_fifo;
                        count<=count+8'h01;
                    end
                end
                RECV_BYTE_FROM_FIFO_TX_P2: begin
                    if (tx_ready==1'b1) begin
                        state__tx <= WAIT_FIFO_TX;
                        tx_valid  <= 1'b0;
                    end
                end
                default: state__tx <= WAIT_FIFO_TX;
            endcase
        end
    end

endmodule