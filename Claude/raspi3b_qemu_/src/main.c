#include <stdint.h>
#include <stddef.h>
#include "printf.h"
#include <string.h>
#include "7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c.gpg.h"
#include "encrypted.1k.h"
#include "file4.gpg.h"
#include "fwddecl.h"
#include "gpg.h"
#include "testNumber.h"

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
void putc_uart2(void *p, char c)
{
    (void)p;
    uart_putc(c);
}

/*{
  txid: 'ee7881862ceb30d9f957bc6edcae96e27099b126e275ff040672a76c8a6ee1b9'
}
PW: 2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945 // 427c028e28eeb15464c376d7dcca6ca2
{
  txid: 'ce81de6360502c6bc603fb77806b07eb52b796914a805196fe83f15cf7b8ff06'
}
PW: 8120ac3368532126d4a86b17eb094569f4ef11703e5147d234af78d72503d960
{
  txid: 'aa353913b68ed3448cbd83ec942067eb4862b34bf88a1cc5d4ccbb10354f94a4'
}
PW: 60ddbd0df3246dd5542a1076b2b9ed7db35e388e7e8bf6bd83250a2117dd6c75
{
  txid: '57065d22d9d6b26fe05d58d627fb1472baf6d2e3b494f13e7e781252a3c94e8d'
}
PW: df1aea260a0f85d24b5ee0cd0e09af73321401731dfa78865a7929bc61d2e539*/
/* file -b gpgFiles/7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c.gpg 
GPG symmetrically encrypted data (CAST5 cipher)
freddie@freddie-Precision-7510:~/rpiPT/blockchain-stuff$ pgpdump gpgFiles/
7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c.gpg 
Old: Symmetric-Key Encrypted Session Key Packet(tag 3)(13 bytes)
        New version(4)
        Sym alg - CAST5(sym 3)
        Iterated and salted string-to-key(s2k 3):
                Hash alg - SHA1(hash 2)
                Salt - 43 b7 a2 56 d8 47 6b 18 
                Count - 65536(coded count 96)
New: Symmetrically Encrypted Data Packet(tag 9)(8192 bytes) partial start
        Encrypted data [sym alg is specified in sym-key encrypted session key]*/

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
    
    // Initialize with debug output
    memset(ctrl, 0, sizeof(struct server_control_s));

    // If we want to use the KDF leave this in
    // const char *test_passphrase;
    // if(testNumber==1){
    //     test_passphrase = "password"; // Test 1. Good PW
    // }else{
    //     test_passphrase = "2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945"; // Test 2. Good PW
    // }
    // size_t pass_len = strlen(test_passphrase);
    // ctrl->passphrase = malloc(pass_len + 1);
    // if (!ctrl->passphrase) {
    //     printf("Failed to allocate passphrase\n");
    //     goto cleanup;
    // }
    // my_strcpy(ctrl->passphrase, test_passphrase);
    
    // Set up and verify session key
    // If we want to skip KDF comment out above block and leave this in
    const char *key;
    if(testNumber==1) key = "693B7847FA44CDC6E1C403F5E44E95C1"; // Test 1. Good Derived Key
    else key = "427c028e28eeb15464c376d7dcca6ca2"; // Test 2. Good/Bad Derived Key???
    size_t key_len = strlen(key);
    ctrl->session_key = malloc(key_len + 1);
    if (!ctrl->session_key) {
        printf("Failed to allocate session_key\n");
        goto cleanup;
    }
    my_strcpy(ctrl->session_key, key);
    // ctrl->session_key = NULL; // Force KDF

    // Add some guard values
    uint32_t guard1 = 0xDEADBEEF;
    uint32_t guard2 = 0xBABECAFE;
    printf("Guard values before decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    
    // Decrypt the data
    int rc = -1;
    if(testNumber==1) rc = decrypt_memory(ctrl, encrypted_1k_gpg, encrypted_1k_gpg_len); // Test 1. Good Decrypt
    else rc = decrypt_memory(ctrl, __7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c_gpg, __7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c_gpg_len); // Test 2. BAD DECRYPT !!!!
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