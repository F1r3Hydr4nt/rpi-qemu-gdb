#include "uart.h"

#define UART0_BASE 0x3F201000
#define GPFSEL1    0x3F200004
#define GPSET0     0x3F20001C
#define GPCLR0     0x3F200028
#define GPPUD      0x3F200094
#define GPPUDCLK0  0x3F200098

volatile unsigned int * const UART0_DR    = (unsigned int *) (UART0_BASE + 0x00);
volatile unsigned int * const UART0_FR    = (unsigned int *) (UART0_BASE + 0x18);
volatile unsigned int * const GPFSEL1_REG = (unsigned int *) GPFSEL1;
volatile unsigned int * const GPSET0_REG  = (unsigned int *) GPSET0;
volatile unsigned int * const GPCLR0_REG  = (unsigned int *) GPCLR0;
volatile unsigned int * const GPPUD_REG   = (unsigned int *) GPPUD;
volatile unsigned int * const GPPUDCLK0_REG = (unsigned int *) GPPUDCLK0;

void uart_init() {
    // Disable UART
    *GPPUD_REG = 0;
    for (volatile int i = 0; i < 150; i++);
    *GPPUDCLK0_REG = (1 << 14) | (1 << 15);
    for (volatile int i = 0; i < 150; i++);
    *GPPUDCLK0_REG = 0;

    // Configure UART pins
    unsigned int r = *GPFSEL1_REG;
    r &= ~(7 << 12); // Clear GPIO14
    r |= 4 << 12;    // Set ALT0 for GPIO14 (TX)
    r &= ~(7 << 15); // Clear GPIO15
    r |= 4 << 15;    // Set ALT0 for GPIO15 (RX)
    *GPFSEL1_REG = r;

    // Initialize UART
    *UART0_DR = 0;
}

void uart_putc(void* p, char c) {
    (void)p; // suppress unused parameter warning
    while (*UART0_FR & (1 << 5));
    *UART0_DR = c;
}

void uart_puts(const char *str) {
    while (*str) {
        uart_putc(0, *str++);
    }
}
