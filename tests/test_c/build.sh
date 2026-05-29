export PATH=/opt/riscv/bin:$PATH
riscv32-unknown-elf-gcc \
-march=rv32i \
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

riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin