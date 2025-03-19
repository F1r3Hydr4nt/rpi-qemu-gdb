.section ".text.boot"
.global _start

_start:
    // Set up stack
    mov sp, #0x8000000

    // Jump to main
    bl main

    // Loop forever if main returns
    b .
    