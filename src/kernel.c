#include "printf.h"
#include "gpg.h"
#include "mmu.h"
#include "uart.h"

void main() {
    // Initialize the page table
    init_page_table();

    // Setup stack guard
    setup_stack_guard();

    // Enable the MMU
    enable_mmu();

    // Initialize UART
    uart_init();
    init_printf(0, uart_putc);
    printf("Hello, World!\n");

    // Test memory functions
    char *message = (char *)malloc(20);
    if (message) {
        memcpy(message, "Memory allocated\n", 18);
        uart_puts(message);
        free(message); // Test free function
    }

    doGPG();
    while (1);
}
