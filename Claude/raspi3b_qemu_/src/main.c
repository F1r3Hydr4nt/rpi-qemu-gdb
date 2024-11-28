#include <stdint.h>
#include <stddef.h>
#include "sha1.h"
#include "printf.h"
#include <string.h>
#include "encrypt.h"

// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t *)0x101f1000)

extern char __text_start[], __text_end[];
extern char __data_start[], __data_end[];
extern char __rodata_start[], __rodata_end[];
extern char __bss_start[], __bss_end[];

// Function prototypes
void uart_putc(char c);
void putc_uart(void *p, char c);
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key);
void hex_string_to_bytes(const char *hex, uint8_t *bytes, size_t len);
void print_memory_map(void);

size_t strlen(const char *str)
{
    const char *s;
    for (s = str; *s; ++s)
        ;
    return (s - str);
}

void hex_string_to_bytes(const char *hex, uint8_t *bytes, size_t len)
{
    for (size_t i = 0; i < len; i++)
    {
        uint8_t high = hex[i * 2];
        uint8_t low = hex[i * 2 + 1];
        high = (high >= 'a') ? (high - 'a' + 10) : (high >= 'A') ? (high - 'A' + 10)
                                                                 : (high - '0');
        low = (low >= 'a') ? (low - 'a' + 10) : (low >= 'A') ? (low - 'A' + 10)
                                                             : (low - '0');
        bytes[i] = (high << 4) | low;
    }
}

void print_memory_map(void)
{
    printf("Memory Map:\n");
    printf(" text: %p - %p\n", __text_start, __text_end);
    printf(" rodata: %p - %p\n", __rodata_start, __rodata_end);
    printf(" data: %p - %p\n", __data_start, __data_end);
    printf(" bss: %p - %p\n", __bss_start, __bss_end);
}

void uart_putc(char c)
{
    UART0_DR = c;
}

void putc_uart(void *p, char c)
{
    (void)p;
    uart_putc(c);
}

void main()
{
    init_printf(0, putc_uart);
    printf("Printf initialised!\n");
    print_memory_map();
    const uint8_t salt[] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11};
    const uint8_t random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};
    const char *data = "Hello World!";
    const char *passphrase = "password";
    const char *derivedKey = "693B7847FA44CDC6E1C403F5E44E95C1";
    printf("\nEncrypting data: '%s'\n", data);
    printf("Passphrase: '%s'\n", passphrase);
    uint8_t key[16];
    uint32_t iterations = ((uint32_t)16 + (0xFF & 15)) << ((0xFF >> 4) + 6);
    //         derive_key(salt, passphrase, strlen(passphrase), iterations, key);
    // printf("Key: ");
    // for (int i = 0; i < 16; i++) {
    //    printf("%02x", key[i]);
    // }
    // printf("\n");
    size_t test_data_len = strlen(data);
    uint8_t output[1024];
    size_t output_len = sizeof(output);
    hex_string_to_bytes(derivedKey, key, 16);

    int rc = encrypt_simple((uint8_t *)data, test_data_len,
                            passphrase,
                            output, &output_len, derivedKey);
    // if (rc == 0)
    // {
    //     printf("Encrypted with encrypt_simple (%zu bytes):", output_len);
    //     for (size_t i = 0; i < output_len; i++)
    //     {
    //         printf("%02x", output[i]);
    //     }
    //     printf("\n");
    // }

    while (1)
    {
        __asm__("wfi");
    }
}