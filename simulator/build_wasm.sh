#!/bin/bash

set -e

IMAGEM_NOME="my-emscripten"
OUTPUT_NOME="riscplay_system.js"

echo "======= 1. Verificando/Construindo Imagem Docker ======="
if [[ "$(docker images -q $IMAGEM_NOME:latest 2> /dev/null)" == "" ]]; then
    echo "Image not found. Building '$IMAGEM_NOME'..."
    docker build -t $IMAGEM_NOME .
else
    echo "Image '$IMAGEM_NOME' found. Skipping build."
fi


echo -e "\n======= 3. Compiling C++ to WebAssembly======="


sudo docker run --rm -v "$(pwd)":/src $IMAGEM_NOME  bash -c "cd /src ; verilator --cc counter.v -exe tb.cpp  --top-module counter"
sudo cp tb.cpp obj_dir
echo "------"

ARQUIVOS_CPP=$(ls obj_dir/*.cpp)
docker run --rm -v "$(pwd)":/src $IMAGEM_NOME em++ \
    -O3 \
    -DVM_SIMULATION=1 \
    -DVERILATOR=1 \
    -DVL_IGNORE_UNKNOWN_ARCH=1 \
    -I/usr/local/share/verilator/include \
    -I/usr/share/verilator/include \
    -I/src/obj_dir \
     /usr/share/verilator/include/verilated.cpp \
     /usr/share/verilator/include/verilated_threads.cpp \
     $ARQUIVOS_CPP\
    -o /src/$OUTPUT_NOME \
    -lembind \
    -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] \
    -s WASM=1 \
    -s EXIT_RUNTIME=1

echo -e "\n======= Compilation completed successfully ======="
ls -la | grep $OUTPUT_NOME || true
ls -la | grep "${OUTPUT_NOME%.*}.wasm" || true
