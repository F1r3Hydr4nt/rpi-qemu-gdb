ENTRY(_start)

SECTIONS
{
    . = 0x80000; /* Start address */

    .text : {
        _start = .;  /* Entry point */
        *(.text*)
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

    .bss : {
        _bss_start = .;
        *(.bss*)
        _bss_end = .;
    }

    . = ALIGN(8);
    _stack_top = . + 0x10000; /* Allocate 64KB for stack */
}