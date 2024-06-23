#include <stdint.h>
#include <stddef.h>
#include "sboxes.h"
#include "sha1.h"
#include "printf.h"
// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t *)0x101f1000)

// Function prototypes
void uart_putc(char c);
void print(const char *str);
void print_hex(uint8_t byte);
uint8_t hex_to_nibble(char hex);
void hex_to_bytes(const char *hex, uint8_t *bytes, unsigned int len);
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key);
// void cast5_init(uint32_t *key_schedule, const uint8_t *key);
// void cast5_decrypt_block(uint32_t *key_schedule, uint8_t *block);
// void cfb_decrypt(uint8_t *data, unsigned int data_len, const uint8_t *iv, const uint8_t *key);


// Encrypted data as a byte array
static const uint8_t encrypted_data[] = {
    0x8c, 0x0d, 0x04, 0x03, 0x03, 0x02, 0xeb, 0x38, 0x1c, 0x55, 0xfe, 0xcc, 0x8f, 0x2f, 0xff, 0xd2,
    0x44, 0x01, 0x8c, 0x41, 0xf4, 0xe1, 0x69, 0x90, 0xd9, 0xc8, 0x46, 0xca, 0xfc, 0x6b, 0x04, 0xbc,
    0x37, 0xe0, 0x7a, 0x92, 0x48, 0x11, 0x0a, 0x6f, 0x11, 0x10, 0x4c, 0xfe, 0x74, 0x4d, 0x2b, 0x26,
    0x46, 0x22, 0x8c, 0x15, 0x52, 0x85, 0x25, 0x66, 0x8b, 0x97, 0xf3, 0x1b, 0xab, 0x07, 0xbf, 0xbc,
    0xed, 0xd0, 0x62, 0x84, 0x92, 0xee, 0x96, 0xbf, 0x11, 0xe8, 0xa4, 0xbe, 0x3a, 0xa6, 0xe9, 0x99,
    0x49, 0x01, 0xd9, 0x11, 0x95
};
static const char password[] = "password";

void putc_uart(void* p, char c) {
    (void)p;  // This parameter is not used in this implementation
    uart_putc(c);
}

void uart_putc(char c)
{
    UART0_DR = c;
}

void print(const char *str)
{
    while (*str)
    {
        uart_putc(*str++);
    }
}

void print_hex(uint8_t byte)
{
    const char hex_chars[] = "0123456789ABCDEF";
    uart_putc(hex_chars[byte >> 4]);
    uart_putc(hex_chars[byte & 0x0F]);
}

// Convert a hex character to its 4-bit value
uint8_t hex_to_nibble(char hex)
{
    if (hex >= '0' && hex <= '9')
        return hex - '0';
    if (hex >= 'A' && hex <= 'F')
        return hex - 'A' + 10;
    if (hex >= 'a' && hex <= 'f')
        return hex - 'a' + 10;
    return 0; // Invalid hex character
}

// Convert hex string to bytes
void hex_to_bytes(const char *hex, uint8_t *bytes, unsigned int len)
{
    for (unsigned int i = 0; i < len; i++)
    {
        bytes[i] = (hex_to_nibble(hex[i * 2]) << 4) | hex_to_nibble(hex[i * 2 + 1]);
    }
}

size_t my_strlen(const char *str)
{
    size_t len = 0;
    while (str[len] != '\0')
    {
        len++;
    }
    return len;
}

// Key derivation function using SHA1
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key)
{
    SHA1_CTX ctx;
    SHA1Init(&ctx);

    unsigned int saltPlusPasswordLen = 8 + pass_len;  // 8 bytes of salt + password length
    unsigned int bytesProcessed = 0;
    unsigned int index = 0;

    while (bytesProcessed < iterations) {
        uint8_t byte;
        if (index < 8) {
            byte = salt[index];
        } else {
            byte = password[index - 8];
        }

        SHA1Update(&ctx, &byte, 1);
        bytesProcessed++;
        index++;

        // If we've reached the end of saltPlusPassword, wrap around
        if (index >= saltPlusPasswordLen) {
            index = 0;
        }
    }

    SHA1Final(key, &ctx);
}

void main()
{
    init_printf(0, putc_uart);
    printf("Printf initialised!\n");
    
    printf("parseGPGFile\n");

    uint8_t packet_byte = encrypted_data[0];
    uint8_t length_byte = encrypted_data[1];
    uint8_t version_byte = encrypted_data[2];
    uint8_t algo_byte = encrypted_data[3];
    uint8_t s2k_byte = encrypted_data[4];
    uint8_t hashAlgo_byte = encrypted_data[5];

    if (algo_byte != 3 || s2k_byte != 3 || hashAlgo_byte != 2)
    {
        printf("This program only decrypts Cast-5 encrypted files, with a salted and iterated string-to-key, using SHA-1 as the hash algorithm.\n");
        return;
    }
    // Extract salt (8 bytes)
    const uint8_t *salt = &encrypted_data[6];
    printf("Salt: ");
    for (int i = 0; i < 8; i++) {
        printf("%02X", salt[i]);
    }
    printf("\n");
    // Parse s2kCount (1 byte)
    uint8_t s2kCount = encrypted_data[14];
    // Calculate the actual iteration count
    uint32_t iterations = 16 + (s2kCount & 15);
    iterations <<= ((s2kCount >> 4) + 6);
    printf("Iteration count: %u\n", iterations);

    printf("Starting key derivation...\r\n");
    uint8_t key[20];
    derive_key(salt, password, sizeof(password) - 1, iterations, key);
    printf("Key derived: ");
    for (unsigned int i = 0; i < sizeof(key); i++)
    {
        printf("%02X", key[i]);
    }
    printf("\n");

    while (1){} // Loop forever
}
