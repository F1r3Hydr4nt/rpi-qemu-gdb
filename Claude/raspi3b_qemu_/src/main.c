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

    // Properly allocate control structure with debug output
    ctrl_t ctrl = malloc(sizeof(struct server_control_s));
    printf("Allocated ctrl at address: %p\n", (void*)ctrl);
    if (!ctrl) {
        printf("Failed to allocate control structure\n");
        goto cleanup;
    }
    
    // Initialize with debug output
    memset(ctrl, 0, sizeof(struct server_control_s));
    printf("Zeroed ctrl structure of size: %d bytes\n", sizeof(struct server_control_s));
    
    // Set up passphrase with length verification
    const char *test_passphrase = "password";
    size_t pass_len = strlen(test_passphrase);
    printf("Passphrase length before malloc: %d\n", pass_len);
    
    ctrl->passphrase = malloc(pass_len + 1);
    printf("Allocated passphrase at address: %p\n", (void*)ctrl->passphrase);
    if (!ctrl->passphrase) {
        printf("Failed to allocate passphrase\n");
        goto cleanup;
    }
    
    my_strcpy(ctrl->passphrase, test_passphrase);
    printf("Copied passphrase. Length after copy: %d\n", strlen(ctrl->passphrase));
    
    // Debug print the passphrase bytes
    printf("Passphrase bytes: ");
    for(size_t i = 0; i <= pass_len; i++) {
        printf("%02x ", (unsigned char)ctrl->passphrase[i]);
    }
    printf("\n");
    
    // Set up and verify session key
    printf("Setting up session key at address: %p\n", (void*)&ctrl->session_key);
    // hex_string_to_key("693B7847FA44CDC6E1C403F5E44E95C1", &ctrl->session_key);
    
    // Print session key for verification
    printf("Initial Session Key values:\n");
    for (int i = 0; i < 4; i++) {
        printf("key[%d] = 0x%08x at address %p\n", 
               i, ctrl->session_key[i], (void*)&ctrl->session_key[i]);
    }
    
    // Add some guard values
    uint32_t guard1 = 0xDEADBEEF;
    uint32_t guard2 = 0xBEEFDEAD;
    printf("Guard values before decrypt: 0x%08x 0x%08x\n", guard1, guard2);
    
    // Decrypt the data
    int rc = decrypt_memory(ctrl, encrypted_1k_gpg, encrypted_1k_gpg_len);
    if (rc) {
        printf("Decryption failed with code: %d\n", rc);
    }
    
    // Check guard values
    printf("Guard values after decrypt: 0x%08x 0x%08x\n", guard1, guard2);
    
    // Print session key again to see if it changed
    printf("Final Session Key values:\n");
    for (int i = 0; i < 4; i++) {
        printf("key[%d] = 0x%08x at address %p\n", 
               i, ctrl->session_key[i], (void*)&ctrl->session_key[i]);
    }

cleanup:
    if (ctrl) {
        if (ctrl->passphrase) {
            printf("Cleaning up passphrase at %p\n", (void*)ctrl->passphrase);
            memset(ctrl->passphrase, 0, strlen(ctrl->passphrase));
            free(ctrl->passphrase);
        }
        printf("Cleaning up ctrl at %p\n", (void*)ctrl);
        free(ctrl);
    }

    while (1) {
        __asm__("wfi");
    }
}