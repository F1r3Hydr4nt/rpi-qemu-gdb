#include <stdint.h>
#include <stddef.h>
#include "sha1.h"
#include "printf.h"
#include <string.h>
// #include "cast5.h"
#include "memory.h"
#include "loremIpsum.10k.h"
#include "libgcrypt.h"

// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t *)0x101f1000)

extern char __text_start[], __text_end[];
extern char __data_start[], __data_end[];
extern char __rodata_start[], __rodata_end[];
extern char __bss_start[], __bss_end[];

// Function prototypes
void uart_putc(char c);
void print(const char *str);
void print_hex(uint8_t byte);
uint8_t hex_to_nibble(char hex);
void hex_to_bytes(const char *hex, uint8_t *bytes, unsigned int len);
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key);

void putc_uart(void *p, char c)
{
    (void)p; // This parameter is not used in this implementation
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

void printData(const char *msg, const uint8_t *data, size_t length)
{
    printf("%s: ", msg);
    for (size_t i = 0; i < length; i++)
    {
        printf("%02X", data[i]);
    }
    printf("\n");
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

void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key) {
    printf("derive_key start - passphrase ptr: %p\n", (void*)password);

    // Add validation
    if (!password || !salt || !key) {
        printf("NULL pointer passed to derive_key\n");
        return;
    }
    
    SHA1_CTX ctx;
    SHA1Init(&ctx);
    unsigned int bytesProcessed = 0;
    unsigned int index = 0;

    // Debug prints
    printf("derive_key params:\n");
    printf("  salt addr: %p\n", (void*)salt);
    printf("  password addr: %p\n", (void*)password);
    printf("  key addr: %p\n", (void*)key);
    printf("  pass_len: %u\n", pass_len);
    printf("  iterations: %u\n", iterations);

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
    
    printf("derive_key end - passphrase ptr: %p\n", (void*)password);
}
// Add this function at the top of your file or in a separate header
int is_printable(char c)
{
    return (c >= 32 && c <= 126);
}

void convert_to_key(const uint8_t input_array[16], uint32_t key[KEY_LEN])
{
    for (int i = 0; i < KEY_LEN; i++)
    {
        key[i] = (((uint32_t)input_array[i * 4]) << 24) |
                 (((uint32_t)input_array[i * 4 + 1]) << 16) |
                 (((uint32_t)input_array[i * 4 + 2]) << 8) |
                 ((uint32_t)input_array[i * 4 + 3]);
    }
}

// Feistel Cast-128 (Cast-5) test vector test function
void testVector()
{
    int testPassing = 1;
    Key KEY = {0x01234567, 0x12345678, 0x23456789, 0x3456789A};
    struct Block msg = {
        .msb = 0x01234567,
        .lsb = 0x89ABCDEF};
    struct Block block = encrypt(KEY, msg);
    // printf("encrypted: %016lX\n", (long unsigned int)block);
    testPassing = block.msb == 0x238B4FE5 && block.lsb == 0x847E44B2;
    block = decrypt(KEY, block);
    // printf("decrypted: %016lX\n", (long unsigned int)block);
    testPassing = block.msb == 0x01234567 && block.lsb == 0x89ABCDEF;
    if (testPassing)
        printf("Test vectors passing\n");
    else
    {
        printf("Tests failing...\n");
    }
}

// Encrypted data as a byte array
static const uint8_t target_data[] = {
    0x8c, 0x0d, 0x04, 0x03, 0x03, 0x02, 0x0a, 0x0b,
    0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0xf8, 0xc9,
    0x1f, 0xa6, 0xca, 0x6c, 0x8a, 0xee, 0xf4, 0xae,
    0x83, 0x5e, 0xe0, 0xb8, 0xbe, 0x11, 0x22, 0xe0,
    0x36, 0x90, 0xcf, 0x3f, 0x28, 0xd6, 0x0d, 0x27,
    0xd6, 0x68, 0xd1, 0x17, 0xef, 0xfd, 0xba, 0x09};

static const uint8_t salt[] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11};
static const uint8_t random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};
static const uint8_t timestamp[] = {0x60, 0xD8, 0x30, 0x00};
static const char *fileData = "Hello World!";

void logBuffer(const unsigned char *buffer, size_t length)
{
    // log_printf("Buffer: ");
    for (size_t i = 0; i < length; i++)
    {
        printf("%02x ", buffer[i]);
    }
    printf("\n");
}

void bytesFromBlock(struct Block block, uint8_t *bytes)
{
    bytes[7] = (block.lsb & 0x000000FF) >> 0;
    bytes[6] = (block.lsb & 0x0000FF00) >> 8;
    bytes[5] = (block.lsb & 0x00FF0000) >> 16;
    bytes[4] = (block.lsb & 0xFF000000) >> 24;
    bytes[3] = (block.msb & 0x000000FF) >> 0;
    bytes[2] = (block.msb & 0x0000FF00) >> 8;
    bytes[1] = (block.msb & 0x00FF0000) >> 16;
    bytes[0] = (block.msb & 0xFF000000) >> 24;
}

void printUint32Hex(uint32_t data)
{
    printf("%08X\n", data);
}

void formatGPGOutput(const uint8_t* symKeyPacket, size_t symKeyPacketLen,
                    const uint8_t* encHeader, 
                    const uint8_t* randomEncrypted, size_t randomEncryptedLen,
                    const uint8_t* packetEncrypted,
                    const uint8_t* dataEncrypted, size_t dataEncryptedLen,
                    uint8_t* output, size_t* outputLen) {
    size_t offset = 0;
    
    // Copy symmetric key packet
    memcpy(output + offset, symKeyPacket, symKeyPacketLen);
    offset += symKeyPacketLen;
    
    // Add encrypted packet header (0xC9 0x1F)
    output[offset++] = 0xC9;
    output[offset++] = 0x1F;
    
    // Copy encrypted random data
    memcpy(output + offset, randomEncrypted, randomEncryptedLen);
    offset += randomEncryptedLen;
    
    // Copy encrypted packet byte 
    memcpy(output + offset, packetEncrypted, 1);
    offset += 1;
    
    // Copy encrypted data
    memcpy(output + offset, dataEncrypted, dataEncryptedLen);
    offset += dataEncryptedLen;

    // Add the final byte 0xB4
    output[offset++] = 0xB4;
    
    *outputLen = offset;
}

// Helper function to print the final output in hex format
void printFinalOutput(const uint8_t* data, size_t len) {
    for(size_t i = 0; i < len; i++) {
        printf("%02x", data[i]);
        if((i + 1) % 32 == 0) printf("\n");
    }
    printf("\n");
}

void printFinalOutput2(const uint8_t* data, size_t len) {
    for(size_t i = 0; i < len; i++) {
        printf("%c", data[i]);
        if((i + 1) % 32 == 0) printf("\n");
    }
    printf("\n");
}

// Maximum sizes for static buffers

#define MAX_FILENAME_LEN 64
#define MAX_DATA_LEN 256
#define MAX_PLAINTEXT_SIZE (1 + 1 + 1 + 4 + MAX_FILENAME_LEN + MAX_DATA_LEN)
// Global static buffers
static uint8_t g_finalOutput[512];
static uint8_t g_plaintextData[101000];
static uint8_t g_encryptedData[328];
static uint8_t g_symKeyPacket[15];
uint8_t hex_char_to_int(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return 0;
}

void hex_string_to_bytes(const char *hex, uint8_t *bytes, size_t len) {
    for (size_t i = 0; i < len; i++) {
        bytes[i] = (hex_char_to_int(hex[i*2]) << 4) | hex_char_to_int(hex[i*2 + 1]);
    }
}
#define MAX_BYTES 256

uint8_t* hex_string_to_bytes2(const char *hex, size_t len) {
    static uint8_t bytes[MAX_BYTES];
    if (len > MAX_BYTES) return NULL;
    
    for (size_t i = 0; i < len; i++) {
        bytes[i] = (hex_char_to_int(hex[i*2]) << 4) | hex_char_to_int(hex[i*2 + 1]);
    }
    return bytes;
}


char* my_strncpy(char* dest, const char* src, size_t n) {
    size_t i;
    for (i = 0; i < n && src[i] != '\0'; i++) {
        dest[i] = src[i];
    }
    for (; i < n; i++) {
        dest[i] = '\0';
    }
    return dest;
}

uint8_t *encryptToGPGFormat(const char *data, const char *filename, const char *passphrase, const char *derivedKey, size_t dataLength) {
    printf("Function start\n");
    printf("Start encrypt - passphrase ptr: %p\n", (void*)passphrase);
    
    // Copy passphrase to local buffer to protect original
    /*This is a common security practice - making a local copy of data you need to work with rather than operating directly on static data helps prevent memory corruption issues.*/
    char local_pass[64];
    my_strncpy(local_pass, passphrase, sizeof(local_pass)-1);
    local_pass[sizeof(local_pass)-1] = '\0';
    
    size_t outputLen = 0;
    const uint8_t salt[] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11};
    const uint8_t random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};
    
    // Initialize symmetric key packet
    memset(g_symKeyPacket, 0, sizeof(g_symKeyPacket));
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

    // Get key either from derived key string or generate it
    uint8_t key[16];
    if (derivedKey) {
        hex_string_to_bytes(derivedKey, key, 16);
    } else {
        uint8_t last_byte = g_symKeyPacket[14];
        uint32_t iterations = ((uint32_t)16 + (g_symKeyPacket[offset-1] & 15)) << ((g_symKeyPacket[offset-1] >> 4) + 6);
        printf("Last byte: %02X\n", last_byte);
        printf("Lower 4 bits: %d\n", last_byte & 15);
        printf("Upper 4 bits shifted: %d\n", last_byte >> 4);
        printf("Iterations: %u\n", iterations);
        printf("Password length: %d\n", my_strlen(local_pass));
        derive_key(salt, local_pass, my_strlen(local_pass), iterations, key);
    }
    
    printf("Derived Key: ");
    for (int i = 0; i < 16; i++) {
        printf("%02X", key[i]);
    }printf("\n");
    // printf("PASSPHRASE: %s\n",passphrase);
    // Prepare random data with quick check bytes
    uint8_t randomQuickCheck[10] = {0};
    memcpy(randomQuickCheck, random, 8);
    randomQuickCheck[8] = random[6];  // Duplicate last two bytes
    randomQuickCheck[9] = random[7];
    
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
    
    // Prepare and encrypt data packet
    size_t filenameLen = filename ? my_strlen(filename) : 0;
    size_t dataLen = my_strlen(data);
    printf("Filename length: %d\n", filenameLen);
    printf("dataLength: %d\n", dataLength);
    printf("Data length: %d\n", dataLen);
    // Verify sizes are within bounds
    if (filenameLen > MAX_FILENAME_LEN){//} || dataLen > MAX_DATA_LEN) {
        return NULL; // Error condition
    }
    
    // Calculate plaintext size
    size_t plaintextSize = 1 + 1 + 1 + 4 + filenameLen + dataLen; // length + mode + namelen + timestamp + filename + data
    printf("Plaintext size: %d\n", plaintextSize);
    offset = 0;
    g_plaintextData[offset++] = plaintextSize;// - 1;  // Length (excluding length byte itself)
    /* The data's formatting.  This is either 'b', 't', 'u', 'l' or '1'
     (however, the last two are deprecated).  */
    g_plaintextData[offset++] = 0x62;               // Mode byte 
    
    g_plaintextData[offset++] = filenameLen;        // Filename length
    // Add filename if present
    if (filename && filenameLen > 0) {

        memcpy(g_plaintextData + offset, filename, filenameLen);
        offset += filenameLen;
    }
    
    // Add timestamp
    const uint8_t timestamp[] = {0x60, 0xD8, 0x30, 0x00};
    memcpy(g_plaintextData + offset, timestamp, 4);
    offset += 4;
    
    // Add the actual data
    memcpy(g_plaintextData + offset, data, dataLen);
    
    // printf("PASSPHRASE: %s\n",passphrase);
    printData("Encrypting: ",g_plaintextData, plaintextSize);
    // Encrypt the data packet
    _gcry_cipher_cfb_encrypt(c, g_encryptedData, plaintextSize,
                            g_plaintextData, plaintextSize);
    // Format final output
    formatGPGOutput(
        g_symKeyPacket, sizeof(g_symKeyPacket),
        NULL,
        encryptedRandom, sizeof(encryptedRandom),
        encryptedPacket,
        g_encryptedData, plaintextSize,
        g_finalOutput, &outputLen
    );
    
    // printf("PASSPHRASE: %s\n",passphrase);
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

void print_memory_map() {
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
    testVector();
    // Test GPG encryption
    const char *data = "Hello World!";
    const char *filename = NULL;  // For initial test, matching original behavior
        
    // Place this in .data section
    static char passphrase_buffer[64] __attribute__((section(".data"), aligned(4))) = "password";
    static const char *passphrase = passphrase_buffer;
    static char derivedKeybuffer[64] __attribute__((section(".data"), aligned(4))) = "693B7847FA44CDC6E1C403F5E44E95C1";
    static const char* derivedKey = derivedKeybuffer;

    printf("\nEncrypting data: '%s'\n", data);
    printf("Passphrase ptr: %p\n", (void*)passphrase);

    printf("Passphrase: '%s'\n", passphrase);
    printf("Passphrase ptr: %p\n", (void*)passphrase);

    if (filename) {
        printf("Filename: '%s'\n", filename);
    } else {
        printf("No filename specified\n");
    }
    // Call the encryption function
  
    printf("Initial passphrase ptr: %p\n", (void*)passphrase);
    uint8_t *encrypted = encryptToGPGFormat(data, filename, passphrase, derivedKey, NULL);
    printf("After encrypt - passphrase ptr: %p\n", (void*)passphrase);
    
    // Calculate the output size 
    // 15 (symkey packet) + 2 (header) + 10 (random) + 1 (packet) + 20 (data packet)
    size_t outputSize = 15 + 2 + 10 + 1 + 20;  
    
    // Print the final output in hex format
    printf("\nFinal GPG Output:\n");
    printFinalOutput(encrypted, outputSize);

    // uint8_t decrypted[MAX_PLAINTEXT_SIZE];
    // size_t decryptedLen;

    // const char* encryptedHex = "8c0d040303020a0b0c0d0e0f1011ffc91fb2c61829aca2c86dc2ea88ef6899bee106f5fd7fa0bcb202ef09247d9820b4";
    // size_t bytesLen = my_strlen(encryptedHex) / 2;  // Each byte is 2 hex chars
    // //printf("Before decrypt - passphrase ptr: %p content: '%s'\n", 
    // //   (void*)passphrase, passphrase ? passphrase : "NULL");
    // decryptGPGData(encrypted, outputSize, passphrase, decrypted, &decryptedLen, derivedKey);
    // // printf("After decrypt - passphrase ptr: %p\n", (void*)passphrase);
  
    // printf("\nFinal GPG Output:\n");
    // printFinalOutput2(decrypted, decryptedLen);

    // // printf("Lorem Ipsum 10k %s",loremIpsum_10k_txt);
    //     uint8_t *encrypted2 = encryptToGPGFormat(loremIpsum_10k_txt, filename, passphrase, derivedKey, loremIpsum_10k_txt_len);

    // Halt execution
    while (1) {
        __asm__("wfi");  // Wait for interrupt - more power efficient than empty loop
    }
}