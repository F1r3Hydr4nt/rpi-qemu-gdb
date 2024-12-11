#include <stdint.h>
#include <stddef.h>
#include "printf.h"
#include <string.h>
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
void print_memory_map(void);

size_t strlen(const char *str)
{
    const char *s;
    for (s = str; *s; ++s);
    return (s - str);
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
    const char *key = "693B7847FA44CDC6E1C403F5E44E95C1";
    size_t key_len = strlen(key);
    printf("Setting up session key at address: %p\n", (void*)&ctrl->session_key);
    ctrl->session_key = malloc(key_len + 1);
    my_strcpy(ctrl->session_key, key);
    printf("Copied session key: %s\n", ctrl->session_key);
    // ctrl->session_key = NULL; // 
    // Add some guard values
    uint32_t guard1 = 0xDEADBEEF;
    uint32_t guard2 = 0xBABECAFE;
    printf("Guard values before decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    
    // Decrypt the data
    int rc = decrypt_memory(ctrl, encrypted_1k_gpg, encrypted_1k_gpg_len);
    if (rc) {
        printf("Decryption failed with code: %d\n", rc);
    }
    
    // Check guard values
    printf("Guard values after decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    
cleanup:
    while (1) {
        __asm__("wfi");
    }
}