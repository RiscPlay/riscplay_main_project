Files need to compile beyond  main.c:
* linker.ld
```ld

ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 64K
}

SECTIONS
{
  .text : {
    *(.init)
    *(.text*)
  } > RAM

  .rodata : {
    *(.rodata*)
  } > RAM

  .data : {
    *(.data*)
  } > RAM

  .bss : {
    *(.bss*)
  } > RAM
}
```

* startup.S
```bash
.section .init
.global _start

_start:

    # inicializa stack
    la sp, _stack_top

    # copiar .data da ROM para RAM
    la a0, _sidata
    la a1, _sdata
    la a2, _edata

copy_data:
    bge a1, a2, clear_bss
    lw t0, 0(a0)
    sw t0, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    j copy_data

clear_bss:

    # limpar .bss
    la a0, _sbss
    la a1, _ebss

clear_bss_loop:
    bge a0, a1, call_main
    sw zero, 0(a0)
    addi a0, a0, 4
    j clear_bss_loop

call_main:

    # chamar main
    call main

hang:
    j hang
```

To compile:
```bash
riscv32-unknown-elf-gcc \
-march=rv32im \
-mabi=ilp32 \
-O2 \
-nostdlib \
-T linker.ld \
startup.S main.c \
-o firmware.elf
```
or

```bash
riscv32-unknown-elf-gcc \
-march=rv32im \
-mabi=ilp32 \
-ffreestanding \
-nostdlib \
-O2 \
startup.S main.c \
-T linker.ld \
-o firmware.elf
```
or
```bash
riscv32-unknown-elf-gcc \
-march=rv32im \
-mabi=ilp32 \
-ffreestanding \
-fno-builtin \
-nostdlib \
startup.S main.c \
-T linker.ld \
-o firmware.elf
```

or 
```bash
riscv32-unknown-elf-gcc \
-march=rv32im \
-mabi=ilp32 \
-O2 \
-ffreestanding \
-fno-builtin \
-fdata-sections \
-ffunction-sections \
-nostdlib \
-Wl,--gc-sections \
-T linker.ld \
startup.S main.c \
-o firmware.elf
```
or

```bash
riscv32-unknown-elf-gcc \
-march=rv32i \
-mabi=ilp32 \
-O2 \
-mno-mul -mno-div \
-ffreestanding \
-fno-builtin \
-fno-tree-vectorize \
-fdata-sections \
-ffunction-sections \
-fno-asynchronous-unwind-tables \
-fno-unwind-tables \
-fno-exceptions \
-nostdlib \
-Wl,--gc-sections \
-T linker.ld \
startup.S main.c \
-o firmware.elf
```

Transform elf in bin 

```bash
riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin
```


