`ifndef MODULES____DEFINES_TO_A_MODULE_CONNECT_TO__CONSUMER_SPI_0__OF_TOP_LEVEL____DEFINE_MUX___V
`define MODULES____DEFINES_TO_A_MODULE_CONNECT_TO__CONSUMER_SPI_0__OF_TOP_LEVEL____DEFINE_MUX___V

`include "define_ids.vh"
//`include "modules/defines_to_a_module_connect_to__consumer_spi_0__of_top_level/define_ids.vh"
`define MUX_COMB__FOR_MODULES(input_signal,mux_array)\
assign mux_array[ID_MODULE____SPI___CONSUMER_SPI] = \
     (module_id_sel == ID_MODULE____SPI___CONSUMER_SPI) ? input_signal : '0;\
assign mux_array[ID_MODULE____MATH_MODULES____FIBONACCI] =\
     (module_id_sel == ID_MODULE____MATH_MODULES____FIBONACCI) ? input_signal : '0;\
assign mux_array[ID_MODULE____RECV_DATA] =\
     (module_id_sel == ID_MODULE____RECV_DATA) ? input_signal : '0; \
assign mux_array[ID_MODULE____SEND_DATA] =\
     (module_id_sel == ID_MODULE____SEND_DATA) ? input_signal : '0;



`define DMUX_COMB__FOR_MODULES(output_signal, mux_array) \
assign output_signal = \
    (module_id_sel == ID_MODULE____SPI___CONSUMER_SPI) ? mux_array[ID_MODULE____SPI___CONSUMER_SPI]: \
    (module_id_sel == ID_MODULE____MATH_MODULES____FIBONACCI) ? mux_array[ID_MODULE____MATH_MODULES____FIBONACCI]:\
    (module_id_sel == ID_MODULE____RECV_DATA) ? mux_array[ID_MODULE____RECV_DATA]: \
    (module_id_sel == ID_MODULE____SEND_DATA) ? mux_array[ID_MODULE____SEND_DATA]: \
    '0;
    
    
wire [N_BITS_TO_ADDRESS_MODULES-1:0] module_id_sel;
wire [N_MODULES-1:0] awake_module;
wire  module_stopped [N_MODULES] ;


wire [7:0] mux__din__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(din__consumer_spi,mux__din__consumer_spi)


wire mux__rd_req__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`DMUX_COMB__FOR_MODULES(rd_req__consumer_spi,mux__rd_req__consumer_spi)

wire mux__rd_ready__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(rd_ready__consumer_spi,mux__rd_ready__consumer_spi)

wire mux__empty__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(empty__consumer_spi,mux__empty__consumer_spi)

wire [7:0] mux__dout__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`DMUX_COMB__FOR_MODULES(dout__consumer_spi,mux__dout__consumer_spi)


wire mux__wr_req__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`DMUX_COMB__FOR_MODULES(wr_req__consumer_spi,mux__wr_req__consumer_spi)


wire mux__wr_ready__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(wr_ready__consumer_spi,mux__wr_ready__consumer_spi)

wire mux__full__consumer_spi [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(full__consumer_spi,mux__full__consumer_spi)

wire mux__busy___fifo_spi_slave_read__and__fifo_spi_consumer_write [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(busy___fifo_spi_slave_read__and__fifo_spi_consumer_write,mux__busy___fifo_spi_slave_read__and__fifo_spi_consumer_write)

wire mux__busy___fifo_spi_slave_write__and__fifo_spi_consumer_read [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(busy___fifo_spi_slave_write__and__fifo_spi_consumer_read,mux__busy___fifo_spi_slave_write__and__fifo_spi_consumer_read)


wire mux__start_crc32____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`DMUX_COMB__FOR_MODULES(start_crc32____for_consumer_spi_mods,mux__start_crc32____for_consumer_spi_mods)

wire [7:0] mux__data_in_crc32____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`DMUX_COMB__FOR_MODULES(data_in_crc32____for_consumer_spi_mods,mux__data_in_crc32____for_consumer_spi_mods)

wire mux__finish_calc_crc____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`DMUX_COMB__FOR_MODULES(finish_calc_crc____for_consumer_spi_mods,mux__finish_calc_crc____for_consumer_spi_mods)

wire [31:0] mux__crc_out____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(crc_out____for_consumer_spi_mods,mux__crc_out____for_consumer_spi_mods)

wire mux__crc_done____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(crc_done____for_consumer_spi_mods,mux__crc_done____for_consumer_spi_mods)

wire mux__process_new_data_in_crc32_module____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`DMUX_COMB__FOR_MODULES(process_new_data_in_crc32_module____for_consumer_spi_mods,mux__process_new_data_in_crc32_module____for_consumer_spi_mods)

wire [31:0] mux__crc_bytes_processed____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(crc_bytes_processed____for_consumer_spi_mods,mux__crc_bytes_processed____for_consumer_spi_mods)

wire mux__crc32_module_is_ready_for_recv_data____for_consumer_spi_mods [N_MODULES__THAT_USE_SPI_TO_COMM];
`MUX_COMB__FOR_MODULES(crc32_module_is_ready_for_recv_data____for_consumer_spi_mods,mux__crc32_module_is_ready_for_recv_data____for_consumer_spi_mods)

`endif
