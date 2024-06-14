#include "mem.h"

#define HEAP_SIZE 1024 * 1024  // 1 MB heap size
#define PAGE_TABLE_SIZE 512
#define PAGE_SIZE 4096
#define STACK_SIZE 4096
#define GUARD_PAGE_SIZE 4096

static unsigned char heap[HEAP_SIZE] __attribute__((aligned(PAGE_SIZE)));
static size_t heap_index = 0;

unsigned long page_table_l1[PAGE_TABLE_SIZE] __attribute__((aligned(PAGE_SIZE)));
unsigned long page_table_l2[PAGE_TABLE_SIZE] __attribute__((aligned(PAGE_SIZE)));
unsigned char stack[STACK_SIZE + GUARD_PAGE_SIZE] __attribute__((aligned(GUARD_PAGE_SIZE)));

// Memory copy function
void *memcpy(void *dest, const void *src, size_t n) {
    char *d = dest;
    const char *s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

// Memory set function
void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

// Align size to multiple of alignment
static size_t align(size_t size, size_t alignment) {
    return (size + alignment - 1) & ~(alignment - 1);
}

// Memory allocation function
void *malloc(size_t size) {
    size = align(size, sizeof(void*)); // Align size to sizeof(void*)

    if (heap_index + size > HEAP_SIZE) {
        return NULL;  // Not enough memory
    }

    void *ptr = &heap[heap_index];
    heap_index += size;
    return ptr;
}

void free(void *ptr) {
    // No-op in this simple allocator
    (void)ptr; // Suppress unused parameter warning
}

// Initialize the page table
void init_page_table() {
    for (int i = 0; i < PAGE_TABLE_SIZE; i++) {
        page_table_l1[i] = ((unsigned long)page_table_l2 >> 12) | 0b11; // Set up level 1 to point to level 2
        page_table_l2[i] = (i << 21) | 0b10011; // 2MB pages
    }
}

// Enable the MMU
void enable_mmu() {
    unsigned long tcr = (1 << 0)  | // T0SZ, input address size
                        (0 << 6)  | // IRGN0, Inner WB RA WA Cacheable
                        (0 << 8)  | // ORGN0, Outer WB RA WA Cacheable
                        (0 << 10) | // SH0, Inner Shareable
                        (3 << 12) | // TG0, Granule size 4KB
                        (1 << 31);  // EPD0

    unsigned long sctlr;
    asm volatile (
        "msr ttbr0_el1, %0\n"
        "msr tcr_el1, %1\n"
        "dsb ish\n"          // Ensure changes are written
        "isb\n"              // Synchronize
        "mrs %2, sctlr_el1\n"
        "orr %2, %2, %3\n"   // Set M (bit 0) in SCTLR
        "msr sctlr_el1, %2\n"
        "isb\n"              // Synchronize
        : // no output
        : "r" ((unsigned long)page_table_l1), "r" (tcr), "r" (sctlr), "r" (1)
        : "memory"
    );
}

// Setup stack guard
void setup_stack_guard() {
    unsigned long guard_page_address = (unsigned long)stack + STACK_SIZE;

    // Configure the MMU to make the guard page inaccessible
    unsigned long *pte = &page_table_l2[guard_page_address >> 21];
    *pte = 0; // Set the entry to 0 to make it inaccessible
}