#include <stdint.h>

// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t*)0x101f1000)

void uart_putc(char c) {
    UART0_DR = c;
}

void print(const char* str) {
    while(*str) {
        uart_putc(*str++);
    }
}

void main() {
    print("Hello from QEMU!\r\n");
}