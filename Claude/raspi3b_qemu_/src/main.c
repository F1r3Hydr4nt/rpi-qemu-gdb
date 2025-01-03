#include <stdint.h>
#include <stddef.h>
#include "printf.h"
#include <string.h>
#include "7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c.gpg.h"
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
    // (void)p;
    // uart_putc(c);
}
void putc_uart2(void *p, char c)
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
    /*Transaction file .hex not found.
{
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
    // Set up passphrase with length verification
    const char *test_passphrase = "password";//2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945";//"60ddbd0df3246dd5542a1076b2b9ed7db35e388e7e8bf6bd83250a2117dd6c75"; //"2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945";
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
    const char *key = "693B7847FA44CDC6E1C403F5E44E95C1"; // 
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
    // int rc = decrypt_memory(ctrl, __7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c_gpg, __7379ab5047b143c0b6cfe5d8d79ad240b4b4f8cced55aa26f86d1d3d370c0d4c_gpg_len);
    if (rc) {
        printf("Decryption failed with code: %d\n", rc);
    }
    init_printf(0, putc_uart2);

    printf("Printf initialised!\n");
    // Check guard values
    printf("Guard values after decrypt: 0x%08X 0x%08X\n", guard1, guard2);
    
cleanup:
    while (1) {
        __asm__("wfi");
    }
}

/*_gcry_cipher_decrypt inlen: 0, outSize: 8192, unused: 0
Caller requested in-place encryption.
_gcry_cipher_cfb_decrypt inbuflen 64 outbuflen 8192 cfb_bulk 1
Initial iv contents: c4db7d3e310fc874
C4DB7D3E310FC874
cfb_decrypt 3 64 8192 0
_gcry_cast5_cfb_dec
nblocks: 8
IV: c4db7d3e310fc874

IN : 474f1b917a8f2cdb535b684f1408190b2c87fa1080cb12fc

OUT: baa18fdda5c86e786165e1f02c39bc562b5792d926ec97e0
���ݥ�nxae��,9�V+W��&��
IN : 43c485be32888688f3dcf382bdf68c80d9e6db490fc8e500

OUT: 33b5c49c3d49a6ced7bb68f43cb18f68fbf640875ed3e622
3�Ĝ=I��׻h�<��h��@�^��"Starting packet parse at position: 28
Read CTB: 0xba (new_format=0)
Parsing new format packet length
First length byte: 0xa5
Partial length encoding: mode=0xa5
Begin processing packet (type=14, len=2710560165, partial=0)
Skipping packet type 14
Packet processing complete (rc=2)
Processing packet type: PUBLIC_SUBKEY (14)
dbg_parse_packet
parse
Starting packet parse at position: 33
Read CTB: 0xc8 (new_format=1)
Parsing new format packet length
First length byte: 0x6e
Partial length encoding: mode=0x6e
Begin processing packet (type=8, len=110, partial=0)*/