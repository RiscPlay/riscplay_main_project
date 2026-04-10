SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
old=$(pwd)
cd $SCRIPT_DIR
ls
rm tb.out
rm tb.vcd
rm waveforms/tb.vcd
iverilog  -g2005-sv -o tb.out ../util/fifo.v ../util/fifo_debug.v  ../util/crc32_fsm.v consumer_spi.v ../math_modules/fibonacci/fibonacci.v ../recvdata/recvdata.v fifo_spi.v spi_slave.v    tb_test___recvdata.v
vvp tb.out
rm tb.out
mv tb.vcd waveforms/tb.vcd
cd $old