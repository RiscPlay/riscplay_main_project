SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
rm -rf obj_dir
cd $SCRIPT_DIR/../src

verilator --trace --cc --timing -f ../simulator/files_to_compile_v2.txt -D__RTL_SIMULATION__ --top-module top top 
#verilator --trace --cc --timing -f ../simulator/files_to_compile_v2.txt -D__RTL_SIMULATION__ --top-module top top 

mv obj_dir $SCRIPT_DIR/
cd $SCRIPT_DIR

g++ -std=c++17 \
    simulation.cpp \
    $(find obj_dir -maxdepth 1 -name '*.cpp' ! -name 'Vtop__main.cpp') \
    /usr/share/verilator/include/verilated.cpp \
    /usr/share/verilator/include/verilated_threads.cpp \
    /usr/share/verilator/include/verilated_vcd_c.cpp \
    -Iobj_dir \
    -I/usr/share/verilator/include \
    -I/usr/share/verilator/include/vltstd \
    -pthread \
    -O3 -o sim