ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 32K
}

PHDRS
{
  text PT_LOAD FLAGS(5); /* R + X */
  data PT_LOAD FLAGS(6); /* R + W */
}

SECTIONS
{
  /* Código */
  .text : {
    *(.init)
    *(.text*)
  } > RAM :text

  /* Constantes */
  .rodata : {
    *(.rodata*)
  } > RAM :text

  /* Dados inicializados */
  .data : {
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } > RAM :data

  /* Dados não inicializados */
  .bss (NOLOAD) : {
    . = ALIGN(4);
    _sbss = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > RAM :data

  /* Topo da stack */
  _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}