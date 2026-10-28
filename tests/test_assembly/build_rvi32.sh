#!/bin/bash

riscv64-unknown-elf-gcc \
-march=rv32i \
-mabi=ilp32 \
-ffreestanding \
-nostdlib \
-static \
-Wl,-Ttext=0x80000000 \
-Wl,-e,_start \
-Wl,--no-relax \
-Wl,--build-id=none \
-Wl,-Bstatic \
-Wl,--no-gc-sections \
$1.S -o $1.elf

riscv64-unknown-elf-objcopy -O binary $1.elf $1.bin

