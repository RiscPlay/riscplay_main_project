# Files need to compile beyond  main.c:
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

# To install C compiler:
```bash
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
cd riscv-gnu-toolchain
git checkout 2026.05.06
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
sudo make newlib -j$(nproc)
```

# To compile:
```bash
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
```

### Transform elf in bin 

```bash
export PATH=/opt/riscv/bin:$PATH
riscv32-unknown-elf-objcopy -O binary firmware.elf firmware.bin
```


