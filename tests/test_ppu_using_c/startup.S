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
