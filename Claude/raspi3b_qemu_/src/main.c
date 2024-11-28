#include <stdint.h>
#include <stddef.h>
#include "sha1.h"
#include "printf.h"
#include <string.h>
#include "memory.h"
#include "libgcrypt.h"
#include "iobuf.h"
#include "encrypt.h" 

// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t *)0x101f1000)

extern char __text_start[], __text_end[];
extern char __data_start[], __data_end[];
extern char __rodata_start[], __rodata_end[];
extern char __bss_start[], __bss_end[];

// Constants
#define MAX_FILENAME_LEN 64
#define MAX_DATA_LEN 256

// Function prototypes
void uart_putc(char c);
void putc_uart(void *p, char c);
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key);
void hex_string_to_bytes(const char *hex, uint8_t *bytes, size_t len);
void print_memory_map(void);
// Add strlen implementation
size_t strlen(const char *str) {
    const char *s;
    for (s = str; *s; ++s);
    return (s - str);
}

// Add hex_string_to_bytes implementation
void hex_string_to_bytes(const char *hex, uint8_t *bytes, size_t len) {
    for (size_t i = 0; i < len; i++) {
        uint8_t high = hex[i * 2];
        uint8_t low = hex[i * 2 + 1];
        
        // Convert high nibble
        high = (high >= 'a') ? (high - 'a' + 10) :
               (high >= 'A') ? (high - 'A' + 10) :
               (high - '0');
               
        // Convert low nibble
        low = (low >= 'a') ? (low - 'a' + 10) :
              (low >= 'A') ? (low - 'A' + 10) :
              (low - '0');
              
        bytes[i] = (high << 4) | low;
    }
}

// Add derive_key implementation

void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key) {
    SHA1_CTX ctx;
    SHA1Init(&ctx);
    unsigned int bytesProcessed = 0;
    unsigned int index = 0;

    while (bytesProcessed < iterations) {
        uint8_t byte;
        if (index < 8) {
            byte = salt[index];
        } else {
            byte = password[(index - 8) % pass_len];
        }
        SHA1Update(&ctx, &byte, 1);
        bytesProcessed++;
        index++;
        
        if (index >= 8 + pass_len) {
            index = 0;
        }
    }
    SHA1Final(key, &ctx);
}

// Add print_memory_map implementation
void print_memory_map(void) {
    extern char __text_start[], __text_end[];
    extern char __rodata_start[], __rodata_end[];
    extern char __data_start[], __data_end[];
    extern char __bss_start[], __bss_end[];

    printf("Memory Map:\n");
    printf("  text:   %p - %p\n", __text_start, __text_end);
    printf("  rodata: %p - %p\n", __rodata_start, __rodata_end);
    printf("  data:   %p - %p\n", __data_start, __data_end);
    printf("  bss:    %p - %p\n", __bss_start, __bss_end);
}

// Basic functions remain the same
void uart_putc(char c) {
    UART0_DR = c;
}

void putc_uart(void *p, char c) {
    (void)p;
    uart_putc(c);
}

// Modified encryption function to use IOBUFs
iobuf_t encryptToGPGFormat(const char *data, const char *filename, const char *passphrase, const char *derivedKey) {
    const uint8_t salt[] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11};
    const uint8_t random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};

    // Create output IOBUF
    iobuf_t out = iobuf_temp();
    if (!out) return NULL;
    
    // Write symmetric key packet
    iobuf_writebyte(out, 0x8C);
    iobuf_writebyte(out, 0x0d);
    iobuf_writebyte(out, 0x04);
    iobuf_writebyte(out, 0x03);
    iobuf_writebyte(out, 0x03);
    iobuf_writebyte(out, 0x02);
    iobuf_write(out, salt, 8);
    iobuf_writebyte(out, 0xFF);

    // Get key
    uint8_t key[16];
    if (derivedKey) {
        hex_string_to_bytes(derivedKey, key, 16);
    } else {
        uint32_t iterations = ((uint32_t)16 + (0xFF & 15)) << ((0xFF >> 4) + 6);
        derive_key(salt, passphrase, strlen(passphrase), iterations, key);
    }

    // Initialize cipher
    struct gcry_cipher_handle hd;
    gcry_cipher_hd_t c = &hd;
    memset(c, 0, sizeof(*c));

    // Set up key
    Key *ctx_key = (Key *)&c->context.c;
    for (int i = 0, j = 0; i < 4; i++, j += 4) {
        (*ctx_key)[i] = (key[j] << 24) | (key[j + 1] << 16) |
                        (key[j + 2] << 8) | key[j + 3];
    }

    memset(c->u_iv.iv, 0, sizeof(c->u_iv.iv));
    c->unused = 0;

    // Write packet header
    iobuf_writebyte(out, 0xC9);
    iobuf_writebyte(out, 0x1F);

    // Encrypt and write random data
    uint8_t randomQuickCheck[10] = {0};
    memcpy(randomQuickCheck, random, 8);
    randomQuickCheck[8] = random[6];
    randomQuickCheck[9] = random[7];

    uint8_t encryptedRandom[10];
    _gcry_cipher_cfb_encrypt(c, encryptedRandom, sizeof(encryptedRandom),
                            randomQuickCheck, sizeof(randomQuickCheck));
    iobuf_write(out, encryptedRandom, sizeof(encryptedRandom));

    cipher_sync(c);

    // Encrypt and write packet type
    uint8_t packetByte[1] = {0xcb};
    uint8_t encryptedPacket[1];
    _gcry_cipher_cfb_encrypt(c, encryptedPacket, sizeof(encryptedPacket),
                            packetByte, sizeof(packetByte));
    iobuf_write(out, encryptedPacket, 1);

    // Create data packet in temporary IOBUF
    iobuf_t plaintext = iobuf_temp();
    if (!plaintext) {
        iobuf_close(out);
        return NULL;
    }

    size_t filenameLen = filename ? strlen(filename) : 0;
    size_t dataLen = strlen(data);
    size_t plaintextSize = 1 + 1 + 1 + 4 + filenameLen + dataLen;

    iobuf_writebyte(plaintext, plaintextSize);
    iobuf_writebyte(plaintext, 0x62);
    iobuf_writebyte(plaintext, filenameLen);

    if (filename && filenameLen > 0) {
        iobuf_write(plaintext, (const uint8_t*)filename, filenameLen);
    }

    const uint8_t timestamp[] = {0x60, 0xD8, 0x30, 0x00};
    iobuf_write(plaintext, timestamp, 4);
    iobuf_write(plaintext, (const uint8_t*)data, dataLen);

    // Get plaintext data
    uint8_t *plaintextData = malloc(plaintextSize);
    size_t actualSize = iobuf_temp_to_buffer(plaintext, plaintextData, plaintextSize);
    iobuf_close(plaintext);

    // Encrypt and write data
    uint8_t *encryptedData = malloc(actualSize);
    _gcry_cipher_cfb_encrypt(c, encryptedData, actualSize,
                            plaintextData, actualSize);
    iobuf_write(out, encryptedData, actualSize);

    free(plaintextData);
    free(encryptedData);

    // Write final marker
    iobuf_writebyte(out, 0xB4);

    return out;
}
int decryptGPGData(iobuf_t encrypted, const char *passphrase, iobuf_t output, const char *derivedKey) {
    uint8_t header[15];
    size_t headerLen = iobuf_read(encrypted, header, sizeof(header));
    
    if (headerLen != 15 || header[0] != 0x8C) {
        printf("Invalid GPG format\n");
        return -1;
    }

    const uint8_t *salt = header + 6;

    uint8_t key[16];
    if (derivedKey) {
        hex_string_to_bytes(derivedKey, key, 16);
    } else {
        uint8_t last_byte = header[14];
        uint32_t iterations = ((uint32_t)16 + (last_byte & 15)) << ((last_byte >> 4) + 6);
        derive_key(salt, passphrase, strlen(passphrase), iterations, key);
    }

    printf("Final key: ");
    for(int i = 0; i < 16; i++) {
        printf("%02X", key[i]);
    }
    printf("\n");

    // Initialize cipher
    struct gcry_cipher_handle hd;
    gcry_cipher_hd_t c = &hd;
    memset(c, 0, sizeof(*c));

    // Set up key
    Key *ctx_key = (Key *)&c->context.c;
    for (int i = 0, j = 0; i < 4; i++, j += 4) {
        (*ctx_key)[i] = (key[j] << 24) | (key[j + 1] << 16) |
                        (key[j + 2] << 8) | key[j + 3];
    }
    memset(c->u_iv.iv, 0, sizeof(c->u_iv.iv));
    c->unused = 0;

    // Skip packet header
    uint8_t packetHeader[2];
    iobuf_read(encrypted, packetHeader, 2);

    // Decrypt random data
    uint8_t encryptedRandom[10], decryptedRandom[10];
    iobuf_read(encrypted, encryptedRandom, sizeof(encryptedRandom));

    _gcry_cipher_cfb_decrypt(c, decryptedRandom, sizeof(decryptedRandom),
                            encryptedRandom, sizeof(encryptedRandom));

    if (decryptedRandom[8] != decryptedRandom[6] ||
        decryptedRandom[9] != decryptedRandom[7]) {
        printf("Invalid passphrase (quick check failed)\n");
        return -1;
    }

    cipher_sync(c);

    // Decrypt packet type
    uint8_t encryptedPacket, packetType;
    iobuf_read(encrypted, &encryptedPacket, 1);
    _gcry_cipher_cfb_decrypt(c, &packetType, 1, &encryptedPacket, 1);

    if (packetType != 0xcb) {
        printf("Invalid packet type\n");
        return -1;
    }

    // Create temporary buffer for encrypted content
    iobuf_t temp = iobuf_temp();
    if (!temp) return -1;

    // Copy remaining data to temp buffer
    iobuf_copy(temp, encrypted);

    // Get encrypted data
    uint8_t *encryptedData = malloc(temp->d.len);
    size_t encryptedLen = iobuf_temp_to_buffer(temp, encryptedData, temp->d.len);
    iobuf_close(temp);

    // Decrypt data
    uint8_t *decryptedData = malloc(encryptedLen);
    _gcry_cipher_cfb_decrypt(c, decryptedData, encryptedLen,
                            encryptedData, encryptedLen);

    // Parse decrypted data
    size_t offset = 3;  // Skip total length and mode bytes
    uint8_t filenameLen = decryptedData[2];
    offset += filenameLen + 4;  // Skip filename and timestamp

    // Write decrypted content to output
    iobuf_write(output, decryptedData + offset, encryptedLen - offset);

    free(encryptedData);
    free(decryptedData);

    return 0;
}

void main() {
    init_printf(0, putc_uart);
    printf("Printf initialised!\n");
    print_memory_map();

    // Test encryption
    const char *data = "Hello World!";
    const char *filename = NULL;
    const char *passphrase = "password";
    const char *derivedKey = "693B7847FA44CDC6E1C403F5E44E95C1";

    printf("\nEncrypting data: '%s'\n", data);
    printf("Passphrase: '%s'\n", passphrase);

    // // Encrypt using IOBUFs
    // iobuf_t encrypted = encryptToGPGFormat(data, filename, passphrase, derivedKey);
    // if (!encrypted) {
    //     printf("Encryption failed!\n");
    //     return;
    // }

    // // Create a new IOBUF with the encrypted content
    // uint8_t *encbuf = malloc(encrypted->d.len);
    // size_t enclen = iobuf_temp_to_buffer(encrypted, encbuf, encrypted->d.len);
    // iobuf_close(encrypted);

    // // Print encrypted hex bytes
    // printf("\nEncrypted data (hex):\n");
    // for (size_t i = 0; i < enclen; i++) {
    //     printf("%02x", encbuf[i]);
    //     if ((i + 1) % 16 == 0) {
    //         printf("\n");
    //     } else {
    //         // printf(" ");
    //     }
    // }
    // printf("\nTotal encrypted length: %d bytes\n\n", enclen);

    // // Create new input IOBUF with the encrypted data
    // iobuf_t enc_input = iobuf_temp_with_content((char*)encbuf, enclen);
    // free(encbuf);

    // if (!enc_input) {
    //     printf("Failed to create input buffer!\n");
    //     return;
    // }

    // // Create temporary IOBUF for decrypted output
    // iobuf_t decrypted = iobuf_temp();
    // if (!decrypted) {
    //     iobuf_close(enc_input);
    //     printf("Failed to create output buffer!\n");
    //     return;
    // }

    // // Decrypt using IOBUFs
    // if (decryptGPGData(enc_input, passphrase, decrypted, NULL) != 0) {
    //     printf("Decryption failed!\n");
    //     iobuf_close(enc_input);
    //     iobuf_close(decrypted);
    //     return;
    // }

    // // Get decrypted content
    // uint8_t outbuf[256];
    // size_t outlen = iobuf_temp_to_buffer(decrypted, outbuf, sizeof(outbuf));
    // outbuf[outlen] = '\0';

    // printf("\nDecrypted data (ASCII): %s\n", outbuf);
    // printf("Decrypted length: %d bytes\n", outlen);

    // // Also show decrypted bytes
    // printf("\nDecrypted data (hex):\n");
    // for (size_t i = 0; i < outlen; i++) {
    //     printf("%02x", outbuf[i]);
    //     if ((i + 1) % 16 == 0) {
    //         printf("\n");
    //     } else {
    //         // printf(" ");
    //     }
    // }
    // printf("\n");

    // // Cleanup
    // iobuf_close(enc_input);
    // iobuf_close(decrypted);
 // Test encrypt_simple
    const char *test_data = "Hello World!";
    size_t test_data_len = strlen(test_data);
    uint8_t output[1024];
    size_t output_len = sizeof(output);
    
    // Use the same key as in your example
    uint8_t key[16];
    hex_string_to_bytes("693B7847FA44CDC6E1C403F5E44E95C1", key, 16);
    
    int rc = encrypt_simple((uint8_t*)test_data, test_data_len,
                          key, sizeof(key),
                          output, &output_len);
                          
    if (rc == 0) {
printf("Encrypted with encrypt_simple (%zu bytes):", output_len);
        for (size_t i = 0; i < output_len; i++) {
            printf("%02x", output[i]);
        }
        printf("\n");
    }
    while (1) {
        __asm__("wfi");
    }
}