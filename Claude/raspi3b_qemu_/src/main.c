#include <stdint.h>
#include <stddef.h>
#include "sha1.h"
#include "printf.h"
#include <string.h>
#include "memory.h"
#include "libgcrypt.h"

// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t *)0x101f1000)

extern char __text_start[], __text_end[];
extern char __data_start[], __data_end[];
extern char __rodata_start[], __rodata_end[];
extern char __bss_start[], __bss_end[];

// Constants
#define MAX_FILENAME_LEN 64
#define MAX_DATA_LEN 256
#define MAX_PLAINTEXT_SIZE (1 + 1 + 1 + 4 + MAX_FILENAME_LEN + MAX_DATA_LEN)

// Global buffers
static uint8_t g_finalOutput[512];
static uint8_t g_plaintextData[101000];
static uint8_t g_encryptedData[328];
static uint8_t g_symKeyPacket[15];

// Function prototypes
void uart_putc(char c);
void putc_uart(void *p, char c);
void printData(const char *msg, const uint8_t *data, size_t length);
size_t my_strlen(const char *str);
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key);
char *my_strncpy(char *dest, const char *src, size_t n);
void hex_string_to_bytes(const char *hex, uint8_t *bytes, size_t len);
void formatGPGOutput(const uint8_t *symKeyPacket, size_t symKeyPacketLen,
                     const uint8_t *encHeader,
                     const uint8_t *randomEncrypted, size_t randomEncryptedLen,
                     const uint8_t *packetEncrypted,
                     const uint8_t *dataEncrypted, size_t dataEncryptedLen,
                     uint8_t *output, size_t *outputLen);
void printFinalOutput(const uint8_t *data, size_t len);
void print_memory_map(void);

// UART functions
void putc_uart(void *p, char c)
{
    (void)p;
    uart_putc(c);
}

void uart_putc(char c)
{
    UART0_DR = c;
}

// Utility functions
void printData(const char *msg, const uint8_t *data, size_t length)
{
    printf("%s: ", msg);
    for (size_t i = 0; i < length; i++)
    {
        printf("%02X", data[i]);
    }
    printf("\n");
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

char *my_strncpy(char *dest, const char *src, size_t n)
{
    size_t i;
    for (i = 0; i < n && src[i] != '\0'; i++)
    {
        dest[i] = src[i];
    }
    for (; i < n; i++)
    {
        dest[i] = '\0';
    }
    return dest;
}

uint8_t hex_char_to_int(char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    return 0;
}

void hex_string_to_bytes(const char *hex, uint8_t *bytes, size_t len)
{
    for (size_t i = 0; i < len; i++)
    {
        bytes[i] = (hex_char_to_int(hex[i * 2]) << 4) | hex_char_to_int(hex[i * 2 + 1]);
    }
}

// Key derivation function
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key)
{
    if (!password || !salt || !key)
    {
        printf("NULL pointer passed to derive_key\n");
        return;
    }

    SHA1_CTX ctx;
    SHA1Init(&ctx);
    unsigned int bytesProcessed = 0;
    unsigned int index = 0;

    while (bytesProcessed < iterations)
    {
        uint8_t byte;
        if (index < 8)
        {
            byte = salt[index];
        }
        else
        {
            byte = password[(index - 8) % pass_len];
        }
        SHA1Update(&ctx, &byte, 1);
        bytesProcessed++;
        index++;

        if (index >= 8 + pass_len)
        {
            index = 0;
        }
    }

    SHA1Final(key, &ctx);
}

// GPG formatting function
void formatGPGOutput(const uint8_t *symKeyPacket, size_t symKeyPacketLen,
                     const uint8_t *encHeader,
                     const uint8_t *randomEncrypted, size_t randomEncryptedLen,
                     const uint8_t *packetEncrypted,
                     const uint8_t *dataEncrypted, size_t dataEncryptedLen,
                     uint8_t *output, size_t *outputLen)
{
    size_t offset = 0;

    memcpy(output + offset, symKeyPacket, symKeyPacketLen);
    offset += symKeyPacketLen;

    output[offset++] = 0xC9;
    output[offset++] = 0x1F;

    memcpy(output + offset, randomEncrypted, randomEncryptedLen);
    offset += randomEncryptedLen;

    memcpy(output + offset, packetEncrypted, 1);
    offset += 1;

    memcpy(output + offset, dataEncrypted, dataEncryptedLen);
    offset += dataEncryptedLen;

    output[offset++] = 0xB4;

    *outputLen = offset;
}

void printFinalOutput(const uint8_t *data, size_t len)
{
    for (size_t i = 0; i < len; i++)
    {
        printf("%02x", data[i]);
        if ((i + 1) % 32 == 0)
            printf("\n");
    }
    printf("\n");
}

// Main encryption function
uint8_t *encryptToGPGFormat(const char *data, const char *filename, const char *passphrase, const char *derivedKey, size_t dataLength)
{
    char local_pass[64];
    my_strncpy(local_pass, passphrase, sizeof(local_pass) - 1);
    local_pass[sizeof(local_pass) - 1] = '\0';

    size_t outputLen = 0;
    const uint8_t salt[] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11};
    const uint8_t random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};

    // Initialize symmetric key packet
    int offset = 0;
    g_symKeyPacket[offset++] = 0x8C;
    g_symKeyPacket[offset++] = 0x0d;
    g_symKeyPacket[offset++] = 0x04;
    g_symKeyPacket[offset++] = 0x03;
    g_symKeyPacket[offset++] = 0x03;
    g_symKeyPacket[offset++] = 0x02;
    memcpy(g_symKeyPacket + offset, salt, 8);
    offset += 8;
    g_symKeyPacket[offset++] = 0xFF;

    // Get key
    uint8_t key[16];
    if (derivedKey)
    {
        hex_string_to_bytes(derivedKey, key, 16);
    }
    else
    {
        uint8_t last_byte = g_symKeyPacket[14];
        uint32_t iterations = ((uint32_t)16 + (last_byte & 15)) << ((last_byte >> 4) + 6);
        derive_key(salt, local_pass, my_strlen(local_pass), iterations, key);
    }

    // Prepare random data
    uint8_t randomQuickCheck[10] = {0};
    memcpy(randomQuickCheck, random, 8);
    randomQuickCheck[8] = random[6];
    randomQuickCheck[9] = random[7];

    // Initialize cipher
    struct gcry_cipher_handle hd;
    gcry_cipher_hd_t c = &hd;
    memset(c, 0, sizeof(*c));

    // Set up key
    Key *ctx_key = (Key *)&c->context.c;
    for (int i = 0, j = 0; i < 4; i++, j += 4)
    {
        (*ctx_key)[i] = (key[j] << 24) | (key[j + 1] << 16) |
                        (key[j + 2] << 8) | key[j + 3];
    }

    memset(c->u_iv.iv, 0, sizeof(c->u_iv.iv));
    c->unused = 0;

    // Encrypt random data
    uint8_t encryptedRandom[10];
    _gcry_cipher_cfb_encrypt(c, encryptedRandom, sizeof(encryptedRandom),
                             randomQuickCheck, sizeof(randomQuickCheck));

    cipher_sync(c);

    // Encrypt packet byte
    uint8_t packetByte[1] = {0xcb};
    uint8_t encryptedPacket[1];
    _gcry_cipher_cfb_encrypt(c, encryptedPacket, sizeof(encryptedPacket),
                             packetByte, sizeof(packetByte));

    // Prepare data packet
    size_t filenameLen = filename ? my_strlen(filename) : 0;
    size_t dataLen = my_strlen(data);

    if (filenameLen > MAX_FILENAME_LEN)
    {
        return NULL;
    }

    size_t plaintextSize = 1 + 1 + 1 + 4 + filenameLen + dataLen;
    offset = 0;
    g_plaintextData[offset++] = plaintextSize;
    g_plaintextData[offset++] = 0x62;
    g_plaintextData[offset++] = filenameLen;

    if (filename && filenameLen > 0)
    {
        memcpy(g_plaintextData + offset, filename, filenameLen);
        offset += filenameLen;
    }

    const uint8_t timestamp[] = {0x60, 0xD8, 0x30, 0x00};
    memcpy(g_plaintextData + offset, timestamp, 4);
    offset += 4;

    memcpy(g_plaintextData + offset, data, dataLen);

    _gcry_cipher_cfb_encrypt(c, g_encryptedData, plaintextSize,
                             g_plaintextData, plaintextSize);

    formatGPGOutput(
        g_symKeyPacket, sizeof(g_symKeyPacket),
        NULL,
        encryptedRandom, sizeof(encryptedRandom),
        encryptedPacket,
        g_encryptedData, plaintextSize,
        g_finalOutput, &outputLen);

    return g_finalOutput;
}


void decryptGPGData(const uint8_t* encryptedData, size_t dataLen, const char* passphrase, uint8_t* output, size_t* outputLen, const char *derivedKey) {
     printf("Memory validation:\n");
    printf("  Valid data section: 0x%x - 0x%x\n", __data_start, __data_end);
    printf("  Passphrase ptr: %p\n", (void*)passphrase);
    
    // Validate pointer is in data section
    if ((uintptr_t)passphrase < (uintptr_t)__data_start || 
        (uintptr_t)passphrase >= (uintptr_t)__data_end) {
        printf("ERROR: Passphrase pointer not in data section\n");
        return;
    }
    
    printf("  Passphrase content: '%s'\n", passphrase);

    if(encryptedData[0] != 0x8C || dataLen < 15) {
        printf("Invalid GPG format\n");
        return;
    }
    
    const uint8_t* salt = encryptedData + 6;
    uint8_t key[16];
    
    if (derivedKey) {
        hex_string_to_bytes(derivedKey, key, 16);
        printf("Using provided key\n");
    } else {
        uint8_t last_byte = encryptedData[14];
        uint32_t iterations = ((uint32_t)16 + (last_byte & 15)) << ((last_byte >> 4) + 6);
        derive_key(salt, passphrase, my_strlen(passphrase), iterations, key);
    }
    printf("Derived Key: ");
    for (int i = 0; i < 16; i++) {
        printf("%02X", key[i]);
    }printf("\n");
    printData("Decrypting: ",encryptedData, dataLen);
    // Initialize cipher handle
    struct gcry_cipher_handle hd;
    gcry_cipher_hd_t c = &hd;
    memset(c, 0, sizeof(*c));

    // Set up key in context
    Key *ctx_key = (Key *)&c->context.c;
    for (int i = 0, j = 0; i < 4; i++, j += 4) {
        (*ctx_key)[i] = (key[j] << 24) | (key[j + 1] << 16) | 
                        (key[j + 2] << 8) | key[j + 3];
    }

    // Clear IV
    memset(c->u_iv.iv, 0, sizeof(c->u_iv.iv));
    c->unused = 0;

    // Skip symmetric key packet (15 bytes) and header (2 bytes)
    const uint8_t* encryptedContent = encryptedData + 17;
    size_t contentLen = dataLen - 18; // -18 for header and final byte

    // First decrypt the random data (10 bytes) to validate key
    uint8_t decryptedRandom[10];
    _gcry_cipher_cfb_decrypt(c, decryptedRandom, sizeof(decryptedRandom),
                             encryptedContent, sizeof(decryptedRandom));
    
    // Validate quick check bytes
    if (decryptedRandom[8] != decryptedRandom[6] || 
        decryptedRandom[9] != decryptedRandom[7]) {
        printf("Invalid passphrase (quick check failed)\n");
        return;
    }

    // Proceed with main data decryption
    encryptedContent += 10; // Skip random data
    contentLen -= 10;
    cipher_sync(c);    
    // // Decrypt packet type byte
    uint8_t packetType;
    _gcry_cipher_cfb_decrypt(c, &packetType, 1, encryptedContent, 1);
    if (packetType != 0xcb) {
        printf("Invalid packet type: %02x\n", packetType);
        return;
    }

    // Decrypt main data
    encryptedContent += 1;
    contentLen -= 1;
    
    _gcry_cipher_cfb_decrypt(c, output, contentLen, encryptedContent, contentLen);
    *outputLen = contentLen;

    // Parse decrypted data
    size_t offset = 0;
    uint8_t totalLen = output[offset++];
    uint8_t mode = output[offset++];
    uint8_t filenameLen = output[offset++];
    printf("Filename length: %d\n", filenameLen);
    if(filenameLen > 0) {
        printf("Filename: %.*s\n", filenameLen, output + offset);
        return -1;
    }
    // Skip filename if present
    offset += filenameLen;
    
    // Skip timestamp (4 bytes)
    offset += 4;

    // Move actual data to start of buffer
    size_t dataLen2 = totalLen - (offset - 1);
    memmove(output, output + offset, dataLen2);
    output[dataLen2] = '\0';
    *outputLen = dataLen2;
}

void print_memory_map()
{
    printf("Memory Map:\n");
    printf("  text:   %p - %p\n", __text_start, __text_end);
    printf("  rodata: %p - %p\n", __rodata_start, __rodata_end);
    printf("  data:   %p - %p\n", __data_start, __data_end);
    printf("  bss:    %p - %p\n", __bss_start, __bss_end);
}

void main()
{
    init_printf(0, putc_uart);
    printf("Printf initialised!\n");
    print_memory_map();

    // Test encryption
    const char *data = "Hello World!";
    const char *filename = NULL;

    static char passphrase_buffer[64] __attribute__((section(".data"), aligned(4))) = "password";
    static const char *passphrase = passphrase_buffer;
    static char derivedKeybuffer[64] __attribute__((section(".data"), aligned(4))) = "693B7847FA44CDC6E1C403F5E44E95C1";
    static const char *derivedKey = derivedKeybuffer;

    printf("\nEncrypting data: '%s'\n", data);
    printf("Passphrase: '%s'\n", passphrase);

    uint8_t *encrypted = encryptToGPGFormat(data, filename, passphrase, derivedKey, NULL);
    size_t outputSize = 15 + 2 + 10 + 1 + 20;

    printf("\nFinal GPG Output:\n");
    printFinalOutput(encrypted, outputSize);
    uint8_t decrypted[MAX_PLAINTEXT_SIZE];
    size_t decryptedLen;

    const char* encryptedHex = "8c0d040303020a0b0c0d0e0f1011ffc91fb2c61829aca2c86dc2ea88ef6899bee106f5fd7fa0bcb202ef09247d9820b4";
    size_t bytesLen = my_strlen(encryptedHex) / 2;  // Each byte is 2 hex chars
    //printf("Before decrypt - passphrase ptr: %p content: '%s'\n", 
    //   (void*)passphrase, passphrase ? passphrase : "NULL");
    decryptGPGData(encrypted, outputSize, passphrase, decrypted, &decryptedLen, NULL);//derivedKey);
    // printf("After decrypt - passphrase ptr: %p\n", (void*)passphrase);

    printf("\nFinal GPG Output:\n");
    printFinalOutput(decrypted, decryptedLen);
    while (1)
    {
        __asm__("wfi");
    }
}