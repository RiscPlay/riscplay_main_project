ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 8K
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
