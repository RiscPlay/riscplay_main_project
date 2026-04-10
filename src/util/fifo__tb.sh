SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
old=$(pwd)
cd $SCRIPT_DIR
ls
iverilog -o fifo__tb.out fifo__tb.v fifo.v
vvp fifo__tb.out
cd $old