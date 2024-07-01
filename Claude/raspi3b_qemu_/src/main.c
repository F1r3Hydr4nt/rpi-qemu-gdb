#include <stdint.h>
#include <stddef.h>
#include "sha1.h"
#include "printf.h"
#include <string.h>
// #include "cast5.h"
#include "sboxes.h"
#include "memory.h"
// QEMU Versatile PB UART0 address
#define UART0_DR *((volatile uint32_t *)0x101f1000)

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

// Key derivation function using SHA1
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key)
{
    SHA1_CTX ctx;
    SHA1Init(&ctx);

    unsigned int saltPlusPasswordLen = 8 + pass_len; // 8 bytes of salt + password length
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
            byte = password[index - 8];
        }

        SHA1Update(&ctx, &byte, 1);
        bytesProcessed++;
        index++;

        // If we've reached the end of saltPlusPassword, wrap around
        if (index >= saltPlusPasswordLen)
        {
            index = 0;
        }
    }

    SHA1Final(key, &ctx);
}
// Add this function at the top of your file or in a separate header
int is_printable(char c)
{
    return (c >= 32 && c <= 126);
}

#define TRUE 1
#define FALSE 0

// static const size_t BYTE_SIZE = 8; // in bits

enum
{
    KEY_LEN = 128 / 32,
    MSG_LEN = 2
};

typedef uint32_t Key[KEY_LEN];

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
struct Block
{
    uint32_t msb;
    uint32_t lsb;
};

#define ROUND_COUNT 16

static const uint8_t K_MAP[sizeof(Key)] = {
    3, 2, 1, 0,
    7, 6, 5, 4,
    11, 10, 9, 8,
    15, 14, 13, 12};

static uint8_t g(const Key key, uint8_t i)
{
    return ((uint8_t *)key)[K_MAP[i]];
}

static void splitI(uint32_t I, uint8_t *Ia, uint8_t *Ib, uint8_t *Ic, uint8_t *Id)
{
    *Ia = (I >> 24) & 0xFF;
    *Ib = (I >> 16) & 0xFF;
    *Ic = (I >> 8) & 0xFF;
    *Id = (I) & 0xFF;
}

// Need to take this out
static const uint64_t MOD_2_32 = (uint64_t)2 << 31;
static const uint32_t MOD_2_32_MINUS_1 = 0xFFFFFFFF;

static void printBlock(struct Block block)
{
    printf("%08X%08X\n", block.msb, block.lsb);
}

static uint32_t sumMod2_32(uint32_t a, uint32_t b)
{
    // its just a remainder
    return ((a) + b) % MOD_2_32;
}

static uint32_t sumMod2_32b(uint32_t a, uint32_t b)
{

    return ((a) + b); // % MOD_2_32;
}

static uint32_t subtractMod2_32(uint32_t a, uint32_t b)
{
    // it's not just a remainder
    // you need to use 2 ^ 32 -1
    if (b <= a)
    {
        return a - b;
    }

    return (MOD_2_32 + a) - b;
}

static uint32_t subtractMod2_32b(uint32_t a, uint32_t b)
{
    if (b <= a)
    {
        return a - b;
    }

    return (MOD_2_32_MINUS_1 + a) - b + 1;
}

static uint32_t cyclicShift(uint32_t x, uint8_t shift)
{
    uint8_t s = shift % 32;
    return (x << s) | (x >> (32 - s));
}

static struct Block run(const Key key, struct Block data, int reverse)
{
    /*uint32_t MSB = data.msb;
    uint32_t LSB = data.lsb
    Message msg = {MSB, LSB};*/
    Key x = {0};
    memcpy(x, key, sizeof(Key));
    Key z = {0};

    uint32_t K[32] = {0};

    for (int i = 0; i < 2; ++i)
    {
        z[0] = x[0] ^ S5[g(x, 0xD)] ^ S6[g(x, 0xF)] ^ S7[g(x, 0xC)] ^ S8[g(x, 0xE)] ^ S7[g(x, 0x8)];
        z[1] = x[2] ^ S5[g(z, 0x0)] ^ S6[g(z, 0x2)] ^ S7[g(z, 0x1)] ^ S8[g(z, 0x3)] ^ S8[g(x, 0xA)];
        z[2] = x[3] ^ S5[g(z, 0x7)] ^ S6[g(z, 0x6)] ^ S7[g(z, 0x5)] ^ S8[g(z, 0x4)] ^ S5[g(x, 0x9)];
        z[3] = x[1] ^ S5[g(z, 0xA)] ^ S6[g(z, 0x9)] ^ S7[g(z, 0xB)] ^ S8[g(z, 0x8)] ^ S6[g(x, 0xB)];

        K[0 + i * 16] = S5[g(z, 0x8)] ^ S6[g(z, 0x9)] ^ S7[g(z, 0x7)] ^ S8[g(z, 0x6)] ^ S5[g(z, 0x2)];
        K[1 + i * 16] = S5[g(z, 0xA)] ^ S6[g(z, 0xB)] ^ S7[g(z, 0x5)] ^ S8[g(z, 0x4)] ^ S6[g(z, 0x6)];
        K[2 + i * 16] = S5[g(z, 0xC)] ^ S6[g(z, 0xD)] ^ S7[g(z, 0x3)] ^ S8[g(z, 0x2)] ^ S7[g(z, 0x9)];
        K[3 + i * 16] = S5[g(z, 0xE)] ^ S6[g(z, 0xF)] ^ S7[g(z, 0x1)] ^ S8[g(z, 0x0)] ^ S8[g(z, 0xC)];

        x[0] = z[2] ^ S5[g(z, 0x5)] ^ S6[g(z, 0x7)] ^ S7[g(z, 0x4)] ^ S8[g(z, 0x6)] ^ S7[g(z, 0x0)];
        x[1] = z[0] ^ S5[g(x, 0x0)] ^ S6[g(x, 0x2)] ^ S7[g(x, 0x1)] ^ S8[g(x, 0x3)] ^ S8[g(z, 0x2)];
        x[2] = z[1] ^ S5[g(x, 0x7)] ^ S6[g(x, 0x6)] ^ S7[g(x, 0x5)] ^ S8[g(x, 0x4)] ^ S5[g(z, 0x1)];
        x[3] = z[3] ^ S5[g(x, 0xA)] ^ S6[g(x, 0x9)] ^ S7[g(x, 0xB)] ^ S8[g(x, 0x8)] ^ S6[g(z, 0x3)];

        K[4 + i * 16] = S5[g(x, 0x3)] ^ S6[g(x, 0x2)] ^ S7[g(x, 0xC)] ^ S8[g(x, 0xD)] ^ S5[g(x, 0x8)];
        K[5 + i * 16] = S5[g(x, 0x1)] ^ S6[g(x, 0x0)] ^ S7[g(x, 0xE)] ^ S8[g(x, 0xF)] ^ S6[g(x, 0xD)];
        K[6 + i * 16] = S5[g(x, 0x7)] ^ S6[g(x, 0x6)] ^ S7[g(x, 0x8)] ^ S8[g(x, 0x9)] ^ S7[g(x, 0x3)];
        K[7 + i * 16] = S5[g(x, 0x5)] ^ S6[g(x, 0x4)] ^ S7[g(x, 0xA)] ^ S8[g(x, 0xB)] ^ S8[g(x, 0x7)];

        z[0] = x[0] ^ S5[g(x, 0xD)] ^ S6[g(x, 0xF)] ^ S7[g(x, 0xC)] ^ S8[g(x, 0xE)] ^ S7[g(x, 0x8)];
        z[1] = x[2] ^ S5[g(z, 0x0)] ^ S6[g(z, 0x2)] ^ S7[g(z, 0x1)] ^ S8[g(z, 0x3)] ^ S8[g(x, 0xA)];
        z[2] = x[3] ^ S5[g(z, 0x7)] ^ S6[g(z, 0x6)] ^ S7[g(z, 0x5)] ^ S8[g(z, 0x4)] ^ S5[g(x, 0x9)];
        z[3] = x[1] ^ S5[g(z, 0xA)] ^ S6[g(z, 0x9)] ^ S7[g(z, 0xB)] ^ S8[g(z, 0x8)] ^ S6[g(x, 0xB)];

        K[8 + i * 16] = S5[g(z, 0x3)] ^ S6[g(z, 0x2)] ^ S7[g(z, 0xC)] ^ S8[g(z, 0xD)] ^ S5[g(z, 0x9)];
        K[9 + i * 16] = S5[g(z, 0x1)] ^ S6[g(z, 0x0)] ^ S7[g(z, 0xE)] ^ S8[g(z, 0xF)] ^ S6[g(z, 0xC)];
        K[10 + i * 16] = S5[g(z, 0x7)] ^ S6[g(z, 0x6)] ^ S7[g(z, 0x8)] ^ S8[g(z, 0x9)] ^ S7[g(z, 0x2)];
        K[11 + i * 16] = S5[g(z, 0x5)] ^ S6[g(z, 0x4)] ^ S7[g(z, 0xA)] ^ S8[g(z, 0xB)] ^ S8[g(z, 0x6)];

        x[0] = z[2] ^ S5[g(z, 0x5)] ^ S6[g(z, 0x7)] ^ S7[g(z, 0x4)] ^ S8[g(z, 0x6)] ^ S7[g(z, 0x0)];
        x[1] = z[0] ^ S5[g(x, 0x0)] ^ S6[g(x, 0x2)] ^ S7[g(x, 0x1)] ^ S8[g(x, 0x3)] ^ S8[g(z, 0x2)];
        x[2] = z[1] ^ S5[g(x, 0x7)] ^ S6[g(x, 0x6)] ^ S7[g(x, 0x5)] ^ S8[g(x, 0x4)] ^ S5[g(z, 0x1)];
        x[3] = z[3] ^ S5[g(x, 0xA)] ^ S6[g(x, 0x9)] ^ S7[g(x, 0xB)] ^ S8[g(x, 0x8)] ^ S6[g(z, 0x3)];

        K[12 + i * 16] = S5[g(x, 0x8)] ^ S6[g(x, 0x9)] ^ S7[g(x, 0x7)] ^ S8[g(x, 0x6)] ^ S5[g(x, 0x3)];
        K[13 + i * 16] = S5[g(x, 0xA)] ^ S6[g(x, 0xB)] ^ S7[g(x, 0x5)] ^ S8[g(x, 0x4)] ^ S6[g(x, 0x7)];
        K[14 + i * 16] = S5[g(x, 0xC)] ^ S6[g(x, 0xD)] ^ S7[g(x, 0x3)] ^ S8[g(x, 0x2)] ^ S7[g(x, 0x8)];
        K[15 + i * 16] = S5[g(x, 0xE)] ^ S6[g(x, 0xF)] ^ S7[g(x, 0x1)] ^ S8[g(x, 0x0)] ^ S8[g(x, 0xD)];
    }

    uint32_t L[ROUND_COUNT + 1] = {0};
    L[0] = data.msb;

    uint32_t R[ROUND_COUNT + 1] = {0};
    R[0] = data.lsb;

    for (int i = 0; i < ROUND_COUNT; ++i)
    {
        int rIndex = reverse ? (ROUND_COUNT - 1 - i) : i;
        uint32_t Kmi = K[rIndex];
        uint8_t Kri = K[16 + rIndex] & 0x1F;

        uint32_t I = 0;
        uint32_t f = 0;

        uint8_t Ia, Ib, Ic, Id;

        switch (rIndex % 3)
        {
        case 0:
            I = cyclicShift(sumMod2_32(Kmi, R[i]), Kri);
            splitI(I, &Ia, &Ib, &Ic, &Id);
            f = sumMod2_32(subtractMod2_32(S1[Ia] ^ S2[Ib], S3[Ic]), S4[Id]);
            break;

        case 1:
            I = cyclicShift(Kmi ^ R[i], Kri);
            splitI(I, &Ia, &Ib, &Ic, &Id);
            f = sumMod2_32(subtractMod2_32(S1[Ia], S2[Ib]), S3[Ic]) ^ S4[Id];
            break;

        case 2:
            I = cyclicShift(subtractMod2_32(Kmi, R[i]), Kri);
            splitI(I, &Ia, &Ib, &Ic, &Id);
            f = subtractMod2_32(sumMod2_32(S1[Ia], S2[Ib]) ^ S3[Ic], S4[Id]);
            break;
        }

        L[i + 1] = R[i];
        R[i + 1] = L[i] ^ f;
        // printf(" L[i + 1]: %02X  R[i + 1]: %02X\n", L[i + 1], R[i + 1]);
    }

    data.msb = R[ROUND_COUNT];
    data.lsb = L[ROUND_COUNT];
    return data;
}

struct Block encrypt(const Key key, struct Block data)
{
    return run(key, data, FALSE);
}

struct Block decrypt(const Key key, struct Block data)
{
    return run(key, data, TRUE);
}

struct Block xorBlock(struct Block block, struct Block val)
{
    struct Block result = {
        .msb = block.msb ^ val.msb,
        .lsb = block.lsb ^ val.lsb};
    return result;
}

struct Block blockFromBytes(uint8_t *bytes)
{
    struct Block block = {
        .msb = 0,
        .lsb = 0};
    for (int i = 0; i < 8; i++)
    {
        if (i < 4)
            block.msb = (block.msb << 8) | bytes[i];
        else
            block.lsb = (block.lsb << 8) | bytes[i];
    }
    return block;
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

static const char password[] = "password";
static const uint8_t salt[] = {0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11};
static const uint8_t random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF};
static const uint8_t timestamp[] = {0x60, 0xD8, 0x30, 0x00};
static const char *fileData = "Hello World!";

void logBuffer(const unsigned char *buffer, size_t length) {
    // log_printf("Buffer: ");
    for (size_t i = 0; i < length; i++) {
        printf("%02x ", buffer[i]);
    }
    printf("\n");
}


void bytesFromBlock(struct Block block, uint8_t* bytes) {
    bytes[7] = (block.lsb & 0x000000FF) >> 0;
    bytes[6] = (block.lsb & 0x0000FF00) >> 8;
    bytes[5] = (block.lsb & 0x00FF0000) >> 16;
    bytes[4] = (block.lsb & 0xFF000000) >> 24;
    bytes[3] = (block.msb & 0x000000FF) >> 0;
    bytes[2] = (block.msb & 0x0000FF00) >> 8;
    bytes[1] = (block.msb & 0x00FF0000) >> 16;
    bytes[0] = (block.msb & 0xFF000000) >> 24;
}

// taken and modified from libgcrypt
void
do_cfb_encrypt(Key key, uint8_t *iv, uint8_t *lastiv, size_t blocksize, const uint8_t *inbuf, unsigned nbytes)
{
    uint8_t outbuf[nbytes];
    int encCount = 0;
    if (nbytes >= blocksize)
    {
        printData("inbuf", inbuf, nbytes);
        // printf("inbuf: ");
        // logBuffer(inbuf, nbytes);
        /* Save the current IV and then encrypt the IV. */
        printf("c->u_iv.iv: ");
        logBuffer(iv, blocksize);
        printData("iv", inbuf, blocksize);

        /* encrypt the IV (and save the current one) */
        memcpy(lastiv, iv, blocksize);
        struct Block ivEncrypted = encrypt(key, blockFromBytes(iv));
        printf("c->u_iv.iv encrypted: ");
        printBlock(ivEncrypted);
        struct Block xored = xorBlock(ivEncrypted, blockFromBytes(inbuf));
        printf("outbuf: ");
        printBlock(xored);
        uint8_t block[8];
        bytesFromBlock(xored,block);
        printData("BLock:",block,blocksize);
        for(int i = 0;i<blocksize; i++){
            outbuf[i] = block[i];
        }
        printData("Encrypted:",outbuf,blocksize);
        nbytes -= blocksize;
        encCount += blocksize;
        inbuf+=blocksize;
    }
    /* bla bla */
    if (nbytes)
    { /* process the remaining bytes */
               printData("if (nbytes) == inbuf", inbuf, nbytes);

        printf("c->u_iv.iv: ");
        logBuffer(iv, blocksize);
        printData("iv", inbuf, blocksize);
        /* encrypt the IV (and save the current one) */
        memcpy(lastiv, iv, blocksize);
        struct Block ivEncrypted = encrypt(key, blockFromBytes(iv));
        printf("c->u_iv.iv encrypted: ");
        printBlock(ivEncrypted);
        uint8_t final[8];
        for(int i = 0;i<8;i++){
            if(i<nbytes){
                final[i] = inbuf[i];
            }else{
                final[i] = 0x00;
            }
        }
        printData("final", final, blocksize);
        struct Block finalBlock = blockFromBytes(final);
        printBlock(finalBlock);
        struct Block xored = xorBlock(ivEncrypted, finalBlock);
        printf("outbuf: ");
        printBlock(xored);
        uint8_t* ivp;
         for (ivp = iv; nbytes; nbytes--)
            {
            uint8_t b = (*ivp++ ^= *inbuf++);
            printf("%02x ", b);
            }
    }
}

void printUint32Hex(uint32_t data)
{
    printf("%08X\n", data);
}

void main()
{
    init_printf(0, putc_uart);
    printf("Printf initialised!\n");
    testVector();
    uint8_t symKeyPacket[2 + 13] = {0}; // Header + length + packet bytes (5) + salt (8)
    const uint8_t symKeyPkt_ctb = 0x8C;
    const uint8_t symKeyPkt_length = 0x0d;
    const uint8_t symKeyPkt_version = 0x04;
    const uint8_t symKeyPkt_algo = 0x03;
    const uint8_t symKeyPkt_s2kMode = 0x03;
    const uint8_t symKeyPkt_s2kAlgo = 0x02;
    int offset = 0;
    symKeyPacket[offset++] = symKeyPkt_ctb;
    symKeyPacket[offset++] = symKeyPkt_length;
    symKeyPacket[offset++] = symKeyPkt_version;
    symKeyPacket[offset++] = symKeyPkt_algo;
    symKeyPacket[offset++] = symKeyPkt_s2kMode;
    symKeyPacket[offset++] = symKeyPkt_s2kAlgo;
    int saltIndex = 0;
    symKeyPacket[offset++] = salt[saltIndex++];
    symKeyPacket[offset++] = salt[saltIndex++];
    symKeyPacket[offset++] = salt[saltIndex++];
    symKeyPacket[offset++] = salt[saltIndex++];
    symKeyPacket[offset++] = salt[saltIndex++];
    symKeyPacket[offset++] = salt[saltIndex++];
    symKeyPacket[offset++] = salt[saltIndex++];
    symKeyPacket[offset++] = salt[saltIndex++];
    const uint8_t symKeyPkt_s2kCount = 0xFF;
    symKeyPacket[offset++] = symKeyPkt_s2kCount;
    uint32_t iterations = ((uint32_t)16 + (symKeyPkt_s2kCount & 15)) << ((symKeyPkt_s2kCount >> 4) + 6);
    printData("symKeyPacket", symKeyPacket, sizeof(symKeyPacket));

    uint8_t key[16];
    derive_key(salt, password, sizeof(password) - 1, iterations, key);
    printf("Derived Key: ");
    for (int i = 0; i < 16; i++)
    {
        printf("%02X", key[i]);
    }
    printf("\n");
    Key encKey = {0, 0, 0, 0};
    int j = 0;
    for (int i = 0; i < 4; i++)
    {
        encKey[i] = (key[j] << 24) + (key[j + 1] << 16) + (key[j + 2] << 8) + key[j + 3];
        // printUint32Hex(encKey[i]);
        j += 4;
    }
    // Now we take the random and duplicate the last two bytes
    uint8_t randomQuickCheck[10] = {0};
    for (int i = 0; i < 8; i++)
    {
        randomQuickCheck[i] = random[i];
    }
    randomQuickCheck[8] = random[6];
    randomQuickCheck[9] = random[7];
    uint8_t iv[8] = {0};
    uint8_t lastIv[8] = {0};
   
do_cfb_encrypt(encKey,iv,lastIv,8,randomQuickCheck,10);
   
    while (1)
    {
    } // Loop forever
}