#ifndef UART_H
#define UART_H

void uart_init();
void uart_putc(void* p, char c);
void uart_puts(const char *str);

#endif // UART_H
