#include <stdint.h>
#include <stddef.h>
#include "sha1.h"
#include "printf.h"
#include <string.h>
#include "encrypt.h"
#include "encrypted.1k.h"
#include "fwddecl.h"
#include "gpg.h"
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

// Convert single hex character to integer value
static uint8_t hex_to_int(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return 0;  // Invalid hex charactergfd
}

void hex_string_to_key(const char *hex_string, Key *key) {
    printf("Key array address: %p\n", (void*)key);
    
    for (int i = 0; i < 4; i++) {
        uint32_t value = 0;
        for (int j = 0; j < 8; j++) {
            char c = hex_string[i * 8 + j];
            value = (value << 4) | hex_to_int(c);
        }
        printf("Storing 0x%08x at index %d (address: %p)\n", 
               value, i, (void*)&((*key)[i]));
        (*key)[i] = value;
    }
}

void main()
{
    init_printf(0, putc_uart);
    printf("Printf initialised!\n");
    print_memory_map();
    // const uint8_t salt[] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11};
    // const uint8_t random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};
    // const char *data = "Hello World!";
    // const char *passphrase = "password";
    // const char *derivedKey = "693B7847FA44CDC6E1C403F5E44E95C1";
    // printf("\nEncrypting data: '%s'\n", data);
    // printf("Passphrase: '%s'\n", passphrase);
    // uint8_t key[16];
    // uint32_t iterations = ((uint32_t)16 + (0xFF & 15)) << ((0xFF >> 4) + 6);
    // //         derive_key(salt, passphrase, strlen(passphrase), iterations, key);
    // // printf("Key: ");
    // // for (int i = 0; i < 16; i++) {
    // //    printf("%02x", key[i]);
    // // }
    // // printf("\n");
    // size_t test_data_len = strlen(data);
    // uint8_t output[1024];
    // size_t output_len = sizeof(output);
    // hex_string_to_bytes(derivedKey, key, 16);

    // int rc = encrypt_simple((uint8_t *)data, test_data_len,
    //                         passphrase,
    //                         output, &output_len, derivedKey);
    // decrypt_message(NULL, "message.txt");

     // ctrl_t ctrl; /* Your GPG control context */
     ctrl_t ctrl = malloc(sizeof(struct server_control_s));
    if (!ctrl) return NULL;
    const char *test_passphrase = "password";
    ctrl->passphrase = malloc(strlen(test_passphrase) + 1);
    my_strcpy(ctrl->passphrase, test_passphrase);
    hex_string_to_key("693B7847FA44CDC6E1C403F5E44E95C1", &ctrl->session_key);

    // Then access it directly
    printf("Session Key values:\n");
    for (int i = 0; i < 4; i++) {
        printf("key[%d] = 0x%08x\n", i, ctrl->session_key[i]);
    }

    ctrl->session_key = NULL;
    int rc = decrypt_memory(ctrl, encrypted_1k_gpg, encrypted_1k_gpg_len);
    if (rc) {
        printf("Decryption failed: %s\n");//, gpg_strerror(rc));
    }
    // return rc;
    while (1)
    {
        __asm__("wfi");
    }
}