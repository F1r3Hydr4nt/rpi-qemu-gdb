.global _start

.section .text
_start:
    ldr x0, =_stack_top
    mov sp, x0

    ldr x0, =_bss_start
    ldr x1, =_bss_end
    mov x2, #0

zero_bss:
    cmp x0, x1
    b.ge done_zero_bss
    str x2, [x0], #8
    b zero_bss

done_zero_bss:
    bl main

1:  wfi
    b 1b

.section .bss
.balign 16
_stack_top: