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

    /* Define the stack space */
    .stack (NOLOAD) : {
        _stack_bottom = .;
        . = . + 0x4000; /* Allocate 16KB for stack */
        _stack_top = .;
    }

    /* End of the image */
    _end = .;
}