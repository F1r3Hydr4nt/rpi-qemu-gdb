.global _start
.global _stack_bottom
.global _stack_top
.global _bss_start
.global _bss_end

.section .text
_start:
    ldr x0, =_stack_top
    mov sp, x0

    // Zero out the BSS section
    ldr x0, =_bss_start
    ldr x1, =_bss_end
    mov x2, #0

zero_bss:
    cmp x0, x1
    b.ge done_zero_bss
    str x2, [x0], #8
    b zero_bss

done_zero_bss:
    // Setup page tables
    ldr x0, =page_table
    msr ttbr0_el1, x0      // Set Translation Table Base Register 0
    msr ttbr1_el1, x0      // Set Translation Table Base Register 1
    mov x0, #1
    msr sctlr_el1, x0      // Enable the MMU by setting the M bit in SCTLR_EL1

    // Jump to main
    bl main

1:  wfi
    b 1b

.section .bss
.balign 16
_stack_bottom:
    .space 0x4000  // 16KB stack space
_stack_top:

.section .data
.align 14
page_table:
    .space 0x4000  // 16KB space for page table