
#include <stdint.h>
#include <stddef.h>
#include "printf.h"
#include <string.h>
// #include "7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c.gpg.h"// 
#include "passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword.gpg.h"
#include "encrypted.1k.h"
#include "file4.gpg.h"
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
// void print_memory_map(void)
// {
//     printf("Memory Map:\n");
//     printf(" text: %p - %p\n", __text_start, __text_end);
//     printf(" rodata: %p - %p\n", __rodata_start, __rodata_end);
//     printf(" data: %p - %p\n", __data_start, __data_end);
//     printf(" bss: %p - %p\n", __bss_start, __bss_end);
// }

void uart_putc(char c)
{
    UART0_DR = c;
}

void putc_uart(void *p, char c)
{
    (void)p;
    uart_putc(c);
}
void putc_uart2(void *p, char c)
{
    (void)p;
    uart_putc(c);
}

void main()
{
    init_printf(0, putc_uart);
    // print_memory_map();
    // Properly allocate control structure with debug output
    ctrl_t ctrl = malloc(sizeof(struct server_control_s));
    if (!ctrl) {
        printf("Failed to allocate control structure\n");
        goto cleanup;
    }
// 2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945
// passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword
//cat lorem.txt | ./g10/gpg --symmetric --cipher-algo CAST5 --passphrase "passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword" --s2k-digest-algo SHA1 --batch --rfc2440 --verbose > enc1k.gpg
    // Initialize with debug output
    memset(ctrl, 0, sizeof(struct server_control_s));

    // If we want to use the KDF leave this in
    // const char *test_passphrase = "passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword";// "2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945"; // Test 2. Good PW
    // // }
    // size_t pass_len = strlen(test_passphrase);
    // ctrl->passphrase = malloc(pass_len + 1);
    // if (!ctrl->passphrase) {
    //     printf("Failed to allocate passphrase\n");
    //     goto cleanup;
    // }
    // my_strcpy(ctrl->passphrase, test_passphrase);
    
    // Set up and verify session key
    // If we want to skip KDF comment out above block and leave this in
    // Define the key as a byte array (unsigned char)
    const unsigned char key_bytes[] = {
        0xaa, 0x26, 0x54, 0x2a, 0xfd, 0x6f, 0x97, 0x09,
        0x82, 0xee, 0xdb, 0x0c, 0xa8, 0x47, 0x7f, 0xd7
        // Second key commented out: 0x42, 0x7c, 0x02, 0x8e, 0x28, 0xee, 0xb1, 0x54, 0x64, 0xc3, 0x76, 0xd7, 0xdc, 0xca, 0x6c, 0xa2
    };
    size_t key_len = sizeof(key_bytes);

    // Allocate memory for the session key
    ctrl->session_key = malloc(key_len);
    if (!ctrl->session_key) {
        printf("Failed to allocate session_key\n");
        goto cleanup;
    }

    // Copy the key bytes to the session key
    memcpy(ctrl->session_key, key_bytes, key_len);
    // ctrl->session_key = NULL; // Force KDF

    // Add some guard values
    uint32_t guard1 = 0xDEADBEEF;
    uint32_t guard2 = 0xBABECAFE;
    printf("Guard values before decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    
    // Decrypt the data
    int rc = decrypt_memory(ctrl, __passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword_gpg, __passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword_gpg_len);
    if (rc) {
        printf("Decryption failed with code: %d\n", rc);
    }
    // Check guard values
    printf("Guard values after decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    printf("CTRL-A + X\n");
cleanup:
    while (1) {
        __asm__("wfi");
    }
}
