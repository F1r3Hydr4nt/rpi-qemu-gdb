#ifndef FILE_H
#define FILE_H

typedef void (*uart_puts_t)(const char *str);

void doGPG(uart_puts_t uart_puts);

#endif // FILE_H
