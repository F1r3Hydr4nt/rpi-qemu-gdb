#include "mmu.h"

// Define the page table
unsigned long page_table[4096] __attribute__((aligned(16384))); // 16KB aligned

void init_page_table() {
    // Clear page table
    for (int i = 0; i < 4096; i++) {
        page_table[i] = 0;
    }

    // Example: Identity mapping first 1 MB
    for (int i = 0; i < 256; i++) {
        page_table[i] = (i << 20) | 0x3;  // Section entry: AP=01 (kernel RW, user NO), domain 0
    }
}

void setup_stack_guard() {
    // Assuming the stack is at a specific address range
    // Place guard page before and after the stack
    unsigned long stack_start = (unsigned long)&_stack_bottom;
    unsigned long guard_page_entry = 0x0; // Non-accessible entry

    // Configure guard pages in page table
    page_table[(stack_start - PAGE_SIZE) >> 20] = guard_page_entry;
    page_table[(stack_start + STACK_SIZE) >> 20] = guard_page_entry;
}

void enable_mmu() {
    unsigned long ttb = (unsigned long)page_table;
    asm volatile(
        "msr ttbr0_el1, %0\n"   // Set TTBR0
        "msr ttbr1_el1, %0\n"   // Set TTBR1
        "dsb ish\n"
        "isb\n"
        : : "r" (ttb)
    );

    unsigned long sctlr;
    asm volatile(
        "mrs %0, sctlr_el1\n"   // Read SCTLR
        "orr %0, %0, #(1 << 0)\n" // Set M bit to enable MMU
        "msr sctlr_el1, %0\n"   // Write SCTLR
        "dsb ish\n"
        "isb\n"
        : "=r" (sctlr)
    );
}
