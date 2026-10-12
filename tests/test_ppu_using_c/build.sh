#!/bin/bash
chmod +x riscv32_unknown_elf_objcopy.AppImage
chmod +x riscv32_unknown_elf_gcc.AppImage

./riscv32_unknown_elf_gcc.AppImage \
-march=rv32im \
-mabi=ilp32 \
-O0 \
-ffreestanding \
-fno-builtin \
-fno-tree-vectorize \
-fdata-sections \
-ffunction-sections \
-fno-asynchronous-unwind-tables \
-fno-tree-loop-distribute-patterns \
-fno-unwind-tables \
-fno-exceptions \
-nostartfiles \
-Wl,--gc-sections \
-T linker.ld \
startup.S $1 \
-lgcc \
-lc \
-lnosys \
-o firmware.elf 

./riscv32_unknown_elf_objcopy.AppImage  -O binary firmware.elf firmware.bin
