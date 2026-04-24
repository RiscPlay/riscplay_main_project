Files need to compile beyond  main.c:
### linker.ld
```ld

ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 16K
}

SECTIONS
{
  /* Código */
  .text : {
    *(.init)
    *(.text*)
  } > RAM

  /* Constantes */
  .rodata : {
    *(.rodata*)
  } > RAM

  /* Dados já inicializados (já estarão na RAM) */
  .data : {
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } > RAM

  /* Dados não inicializados */
  .bss : {
    . = ALIGN(4);
    _sbss = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > RAM

  /* Topo da stack */
  _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
```

### startup.S
```bash
.section .init
.global _start

_start:

    /* inicializa stack */
    la sp, _stack_top

    /* opcional: zerar alguns registradores (debug mais previsível) */
    li t0, 0
    li t1, 0
    li t2, 0

    /* limpar .bss */
    la a0, _sbss
    la a1, _ebss

clear_bss_loop:
    bge a0, a1, call_main
    sw zero, 0(a0)
    addi a0, a0, 4
    j clear_bss_loop

call_main:

    /* chama main */
    call main

/* se main retornar, trava */
hang:
    j hang
```

### To compile:
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
riscv64-unknown-elf-gcc \
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

### Transform elf in bin 

```bash
riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin
```


