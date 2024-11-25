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
void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key) {
    SHA1_CTX ctx;
    SHA1Init(&ctx);
//-   unsigned int saltPlusPasswordLen = 8 + pass_len;
    unsigned int bytesProcessed = 0;
    unsigned int index = 0;

    while (bytesProcessed < iterations) {
        uint8_t byte;
        if (index < 8) {
            byte = salt[index];
        } else {
// -           byte = password[index - 8];
           byte = password[(index - 8) % pass_len];
        }
        SHA1Update(&ctx, &byte, 1);
        bytesProcessed++;
        index++;
        
// -       if (index >= saltPlusPasswordLen) {
       if (index >= 8 + pass_len) {
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

/* The data object used to hold a handle to an encryption object.  */
struct gcry_cipher_handle;
typedef struct gcry_cipher_handle *gcry_cipher_hd_t;

   typedef unsigned long u64;
      typedef unsigned int  u32;

   typedef unsigned char byte;
typedef union
{
  int a;
  short b;
  char c[1];
  long d;
  u64 e;
  float f;
  double g;
} PROPERLY_ALIGNED_TYPE;
typedef union
{
  PROPERLY_ALIGNED_TYPE foo;
#ifdef NEED_16BYTE_ALIGNED_CONTEXT
  char bar[16] __attribute__ ((aligned (16)));
#endif
  char c[1];
} cipher_context_alignment_t;


/* The maximum supported size of a block in bytes.  */
#define MAX_BLOCKSIZE 16
/* The handle structure.  */
struct gcry_cipher_handle
{
  /* The initialization vector.  For best performance we make sure
     that it is properly aligned.  In particular some implementations
     of bulk operations expect an 16 byte aligned IV.  IV is also used
     to store CBC-MAC in CCM mode; counter IV is stored in U_CTR.  For
     OCB mode it is used for the offset value.  */
  union {
    cipher_context_alignment_t iv_align;
    unsigned char iv[MAX_BLOCKSIZE];
  } u_iv;

  /* Space to save an IV or CTR for chaining operations.  */
  unsigned char lastiv[MAX_BLOCKSIZE];
  int unused;  /* Number of unused bytes in LASTIV. */


  /* What follows are two contexts of the cipher in use.  The first
     one needs to be aligned well enough for the cipher operation
     whereas the second one is a copy created by cipher_setkey and
     used by cipher_reset.  That second copy has no need for proper
     aligment because it is only accessed by memcpy.  */
  cipher_context_alignment_t context;
};



static inline u32 buf_get_le32(const void *_buf)
{
  const byte *in = _buf;
  return ((u32)in[3] << 24) | ((u32)in[2] << 16) | \
         ((u32)in[1] << 8) | (u32)in[0];
}
static inline void buf_put_le32(void *_buf, u32 val)
{
  byte *out = _buf;
  out[3] = val >> 24;
  out[2] = val >> 16;
  out[1] = val >> 8;
  out[0] = val;
}


static inline u64 buf_get_le64(const void *_buf)
{
  const byte *in = _buf;
  return ((u64)in[7] << 56) | ((u64)in[6] << 48) | \
         ((u64)in[5] << 40) | ((u64)in[4] << 32) | \
         ((u64)in[3] << 24) | ((u64)in[2] << 16) | \
         ((u64)in[1] << 8) | (u64)in[0];
}
static inline void buf_put_le64(void *_buf, u64 val)
{
  byte *out = _buf;
  out[7] = val >> 56;
  out[6] = val >> 48;
  out[5] = val >> 40;
  out[4] = val >> 32;
  out[3] = val >> 24;
  out[2] = val >> 16;
  out[1] = val >> 8;
  out[0] = val;
}


# define buf_get_he32 buf_get_le32
# define buf_put_he32 buf_put_le32
# define buf_get_he64 buf_get_le64
# define buf_put_he64 buf_put_le64
/* Optimized function for cipher block xoring with two destination cipher
   blocks.  Used mainly by CFB mode encryption.  */

static inline void
cipher_block_xor_2dst(void *_dst1, void *_dst2, const void *_src, size_t blocksize)
{
    byte *dst1 = _dst1;
    byte *dst2 = _dst2;
    const byte *src = _src;

    // Process complete blocks
    if (blocksize == 8)
    {
        // For 64-bit blocks
        for (size_t i = 0; i < 8; i++)
        {
            byte temp = dst2[i] ^ src[i];
            dst2[i] = temp;
            dst1[i] = temp;
        }
    }
    else /* blocksize == 16 */
    {
        // For 128-bit blocks
        for (size_t i = 0; i < 16; i++)
        {
            byte temp = dst2[i] ^ src[i];
            dst2[i] = temp;
            dst1[i] = temp;
        }
    }
}

// Helper function to XOR buffers of any length
static inline void
buf_xor_2dst_v2(void *_dst1, void *_dst2, const void *_src, size_t len)
{
    byte *dst1 = _dst1;
    byte *dst2 = _dst2;
    const byte *src = _src;

    // Process all bytes
    for (size_t i = 0; i < len; i++)
    {
        byte temp = dst2[i] ^ src[i];
        dst2[i] = temp;
        dst1[i] = temp;
    }
}
/* Optimized function for buffer xoring with two destination buffers.  Used
   mainly by CFB mode encryption.  */
static inline void
buf_xor_2dst(void *_dst1, void *_dst2, const void *_src, size_t len)
{
  byte *dst1 = _dst1;
  byte *dst2 = _dst2;
  const byte *src = _src;

  while (len >= sizeof(u64))
    {
      u64 temp = buf_get_he64(dst2) ^ buf_get_he64(src);
      buf_put_he64(dst2, temp);
      buf_put_he64(dst1, temp);
      dst2 += sizeof(u64);
      dst1 += sizeof(u64);
      src += sizeof(u64);
      len -= sizeof(u64);
    }

  if (len >= sizeof(u32))
    {
      u32 temp = buf_get_he32(dst2) ^ buf_get_he32(src);
      buf_put_he32(dst2, temp);
      buf_put_he32(dst1, temp);
      dst2 += sizeof(u32);
      dst1 += sizeof(u32);
      src += sizeof(u32);
      len -= sizeof(u32);
    }

  /* Handle tail.  */
  for (; len; len--)
    *dst1++ = (*dst2++ ^= *src++);
}

/* Optimized function for cipher block copying */
static inline void
cipher_block_cpy(void *_dst, const void *_src, size_t blocksize)
{
  byte *dst = _dst;
  const byte *src = _src;
  u64 s[2];

  if (blocksize == 8)
    {
      buf_put_he64(dst + 0, buf_get_he64(src + 0));
    }
  else /* blocksize == 16 */
    {
      s[0] = buf_get_he64(src + 0);
      s[1] = buf_get_he64(src + 8);
      buf_put_he64(dst + 0, s[0]);
      buf_put_he64(dst + 8, s[1]);
    }
}


/* Optimized function for combined cipher block xoring and copying.
   Used by mainly CBC mode decryption.  */
static inline void
cipher_block_xor_n_copy_2(void *_dst_xor, const void *_src_xor,
                          void *_srcdst_cpy, const void *_src_cpy,
                          size_t blocksize)
{
  byte *dst_xor = _dst_xor;
  byte *srcdst_cpy = _srcdst_cpy;
  const byte *src_xor = _src_xor;
  const byte *src_cpy = _src_cpy;
  u64 sc[2];
  u64 sx[2];
  u64 sdc[2];

  if (blocksize == 8)
    {
      sc[0] = buf_get_he64(src_cpy + 0);
      buf_put_he64(dst_xor + 0,
                   buf_get_he64(srcdst_cpy + 0) ^ buf_get_he64(src_xor + 0));
      buf_put_he64(srcdst_cpy + 0, sc[0]);
    }
  else /* blocksize == 16 */
    {
      sc[0] = buf_get_he64(src_cpy + 0);
      sc[1] = buf_get_he64(src_cpy + 8);
      sx[0] = buf_get_he64(src_xor + 0);
      sx[1] = buf_get_he64(src_xor + 8);
      sdc[0] = buf_get_he64(srcdst_cpy + 0);
      sdc[1] = buf_get_he64(srcdst_cpy + 8);
      sx[0] ^= sdc[0];
      sx[1] ^= sdc[1];
      buf_put_he64(dst_xor + 0, sx[0]);
      buf_put_he64(dst_xor + 8, sx[1]);
      buf_put_he64(srcdst_cpy + 0, sc[0]);
      buf_put_he64(srcdst_cpy + 8, sc[1]);
    }
}

/* Optimized function for combined buffer xoring and copying.  Used by mainly
   CBC mode decryption.  */
static inline void
buf_xor_n_copy_2(void *_dst_xor, const void *_src_xor, void *_srcdst_cpy,
		 const void *_src_cpy, size_t len)
{
  byte *dst_xor = _dst_xor;
  byte *srcdst_cpy = _srcdst_cpy;
  const byte *src_xor = _src_xor;
  const byte *src_cpy = _src_cpy;

  while (len >= sizeof(u64))
    {
      u64 temp = buf_get_he64(src_cpy);
      buf_put_he64(dst_xor, buf_get_he64(srcdst_cpy) ^ buf_get_he64(src_xor));
      buf_put_he64(srcdst_cpy, temp);
      dst_xor += sizeof(u64);
      srcdst_cpy += sizeof(u64);
      src_xor += sizeof(u64);
      src_cpy += sizeof(u64);
      len -= sizeof(u64);
    }

  if (len >= sizeof(u32))
    {
      u32 temp = buf_get_he32(src_cpy);
      buf_put_he32(dst_xor, buf_get_he32(srcdst_cpy) ^ buf_get_he32(src_xor));
      buf_put_he32(srcdst_cpy, temp);
      dst_xor += sizeof(u32);
      srcdst_cpy += sizeof(u32);
      src_xor += sizeof(u32);
      src_cpy += sizeof(u32);
      len -= sizeof(u32);
    }

  /* Handle tail.  */
  for (; len; len--)
    {
      byte temp = *src_cpy++;
      *dst_xor++ = *srcdst_cpy ^ *src_xor++;
      *srcdst_cpy++ = temp;
    }
}


/* Optimized function for combined buffer xoring and copying.  Used by mainly
   CFB mode decryption.  */
static inline void
buf_xor_n_copy(void *_dst_xor, void *_srcdst_cpy, const void *_src, size_t len)
{
  buf_xor_n_copy_2(_dst_xor, _src, _srcdst_cpy, _src, len);
}

/* Optimized function for combined cipher block xoring and copying.
   Used by mainly CFB mode decryption.  */
static inline void
cipher_block_xor_n_copy(void *_dst_xor, void *_srcdst_cpy, const void *_src,
                        size_t blocksize)
{
  cipher_block_xor_n_copy_2(_dst_xor, _src, _srcdst_cpy, _src, blocksize);
}


// gcry_err_code_t
int _gcry_cipher_cfb_encrypt (gcry_cipher_hd_t c,
                          unsigned char *outbuf, size_t outbuflen,
                          const unsigned char *inbuf, size_t inbuflen)
{  
  unsigned char *ivp;
  size_t blocksize = 8; //1 << blocksize_shift;
  size_t blocksize_x_2 = blocksize + blocksize;
  unsigned int burn, nburn;
  int shouldShift = inbuflen > blocksize;
  if (outbuflen < inbuflen)
    return -1; //GPG_ERR_BUFFER_TOO_SHORT;

  if ( inbuflen <= c->unused )
    {
        printf("cfb_encrypt 1 %d %d %d\n",inbuflen,outbuflen,c->unused);
      /* Short enough to be encoded by the remaining XOR mask. */
      /* XOR the input with the IV and store input into IV. */
      ivp = c->u_iv.iv + blocksize - c->unused;
      buf_xor_2dst_v2(outbuf, ivp, inbuf, inbuflen);
      c->unused -= inbuflen;
      return 0;
    }

  burn = 0;

  if ( c->unused )
    {
      printf("cfb_encrypt 2 %d %d %d\n",inbuflen,outbuflen,c->unused);
      /* XOR the input with the IV and store input into IV */
      inbuflen -= c->unused;
      ivp = c->u_iv.iv + blocksize - c->unused;
      buf_xor_2dst_v2(outbuf, ivp, inbuf, c->unused);
      outbuf += c->unused;
      inbuf += c->unused;
      c->unused = 0;
      // log_printhex("IV", c->u_iv.iv, blocksize);
    }

  /* Now we can process complete blocks.  We use a loop as long as we
     have at least 2 blocks and use conditions for the rest.  This
     also allows to use a bulk encryption function if available.  */
if (inbuflen >= blocksize_x_2 && 0){} //c->bulk.cfb_enc)
  else
    {
    printf("cfb_encrypt 4 %d %d %d\n",inbuflen,outbuflen,c->unused);

      while ( inbuflen >= blocksize_x_2 )
        {
          /* Encrypt the IV. */
        //   nburn = enc_fn ( &c->context.c, c->u_iv.iv, c->u_iv.iv );
        //   burn = nburn > burn ? nburn : burn;
        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
        printBlock(ivBlock);

        // Encrypt the IV using our encrypt function
        ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
        printBlock(ivBlock);
        // Convert encrypted block back to IV
        bytesFromBlock(ivBlock, c->u_iv.iv);
          /* XOR the input with the IV and store input into IV.  */
          cipher_block_xor_2dst(outbuf, c->u_iv.iv, inbuf, blocksize);
        printBlock(blockFromBytes(c->u_iv.iv));

          outbuf += blocksize;
          inbuf += blocksize;
          inbuflen -= blocksize;
          // log_printhex("IV", c->u_iv.iv, blocksize);
        }
        // log_printhex("IV", c->u_iv.iv, blocksize);
    }

  if ( inbuflen >= blocksize )
    {
    printf("cfb_encrypt 5 %d %d %d\n",inbuflen,outbuflen,c->unused);
      /* Save the current IV and then encrypt the IV. */
      cipher_block_cpy( c->lastiv, c->u_iv.iv, blocksize );
      // nburn = enc_fn ( &c->context.c, c->u_iv.iv, c->u_iv.iv );
      // burn = nburn > burn ? nburn : burn;

      // Convert IV to block structure and encrypt
      struct Block ivBlock = blockFromBytes(c->u_iv.iv);
                    printBlock(ivBlock);

      ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
      bytesFromBlock(ivBlock, c->u_iv.iv);
        printBlock(ivBlock);

      /* XOR the input with the IV and store input into IV */
      cipher_block_xor_2dst(outbuf, c->u_iv.iv, inbuf, blocksize);
                              printBlock(blockFromBytes(c->u_iv.iv));

      outbuf += blocksize;
      inbuf += blocksize;
      inbuflen -= blocksize;
      // log_printhex("IV", c->u_iv.iv, blocksize);
    }
   if (inbuflen)
    {
        printf("cfb_encrypt 6 %d %d %d\n", inbuflen, outbuflen, c->unused);

        /* Save the current IV before encryption */
        unsigned char saved_iv[blocksize];
        memcpy(saved_iv, c->u_iv.iv, blocksize);
        
        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
        printBlock(ivBlock);

        ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
        bytesFromBlock(ivBlock, c->u_iv.iv);
        printBlock(ivBlock);

        /* XOR with input to get output */
        buf_xor_2dst_v2(outbuf, c->u_iv.iv, inbuf, inbuflen);
        if(shouldShift){
            /* Copy entire shifted value: 1829ACA2C86DC2EA */
            memcpy(c->u_iv.iv, saved_iv + inbuflen, blocksize - inbuflen);  // Copy 1829ACA2C86D
            memcpy(c->u_iv.iv + blocksize - inbuflen, outbuf, inbuflen);         // Copy C2EA
        }else{
            // replace first byte of ivBlock with first byte of outbuf
            memcpy(c->u_iv.iv, outbuf, inbuflen);  // Copy 1829ACA2C86D
            c->unused = blocksize - inbuflen;
        }

        outbuf += inbuflen;
        inbuf += inbuflen;
        inbuflen = 0;
    }

  if (burn > 0){
    printf("SHOULD BE BURNING?");//// _gcry_burn_stack (burn + 4 * sizeof(void *));
  }

  return 0;
}

size_t
_gcry_cipher_cfb_decrypt (gcry_cipher_hd_t c,
                          unsigned char *outbuf, size_t outbuflen,
                          const unsigned char *inbuf, size_t inbuflen)
{
  printf("gcry_cipher_cfb_decrypt inbuflen %d outbuflen %d\n",inbuflen,outbuflen);
  unsigned char *ivp;
  // gcry_cipher_encrypt_t enc_fn = c->spec->encrypt;
  size_t blocksize_shift = 8; //gcry_blocksize_shift(c);
  size_t blocksize = 1 << blocksize_shift;
  size_t blocksize_x_2 = blocksize + blocksize;
  unsigned int burn, nburn;
  int shouldShift = inbuflen > blocksize;

  if (outbuflen < inbuflen)
    return -1; // GPG_ERR_BUFFER_TOO_SHORT;

  if (inbuflen <= c->unused)
    {
      /* Short enough to be encoded by the remaining XOR mask. */
      /* XOR the input with the IV and store input into IV. */
      ivp = c->u_iv.iv + blocksize - c->unused;
      buf_xor_n_copy(outbuf, ivp, inbuf, inbuflen);
      c->unused -= inbuflen;
      return 0;
    }

  burn = 0;

  if (c->unused)
    {
      /* XOR the input with the IV and store input into IV. */
      inbuflen -= c->unused;
      ivp = c->u_iv.iv + blocksize - c->unused;
      buf_xor_n_copy(outbuf, ivp, inbuf, c->unused);
      outbuf += c->unused;
      inbuf += c->unused;
      c->unused = 0;
    }

  /* Now we can process complete blocks.  We use a loop as long as we
     have at least 2 blocks and use conditions for the rest.  This
     also allows to use a bulk encryption function if available.  */
  if (inbuflen >= blocksize_x_2 && 0)//c->bulk.cfb_dec)
    {
    
    }
  else
    {
      while (inbuflen >= blocksize_x_2 )
        {
          /* Encrypt the IV. */
         struct Block ivBlock = blockFromBytes(c->u_iv.iv);
          printBlock(ivBlock);

          ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
          printBlock(ivBlock);
          /* XOR the input with the IV and store input into IV. */
          bytesFromBlock(ivBlock, c->u_iv.iv);
          cipher_block_xor_n_copy(outbuf, c->u_iv.iv, inbuf, blocksize);
          printBlock(blockFromBytes(c->u_iv.iv));          outbuf += blocksize;
          inbuf += blocksize;
          inbuflen -= blocksize;
        }
    }

  if (inbuflen >= blocksize )
    {
      /* Save the current IV and then encrypt the IV. */
      cipher_block_cpy ( c->lastiv, c->u_iv.iv, blocksize);
 struct Block ivBlock = blockFromBytes(c->u_iv.iv);
      printBlock(ivBlock);
      ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
      bytesFromBlock(ivBlock, c->u_iv.iv);
      printBlock(ivBlock);
      /* XOR the input with the IV and store input into IV */
      cipher_block_xor_n_copy(outbuf, c->u_iv.iv, inbuf, blocksize);
      printBlock(blockFromBytes(c->u_iv.iv));
      outbuf += blocksize;
      inbuf += blocksize;
      inbuflen -= blocksize;
    }

  if (inbuflen)
    {
      /* Save the current IV and then encrypt the IV. */
      cipher_block_cpy ( c->lastiv, c->u_iv.iv, blocksize );
   struct Block ivBlock = blockFromBytes(c->u_iv.iv);
      printBlock(ivBlock);

      ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
      bytesFromBlock(ivBlock, c->u_iv.iv);
      printBlock(ivBlock);
      c->unused = blocksize;
      /* Apply the XOR. */
      c->unused -= inbuflen;
      /*   if(shouldShift) {
        unsigned char saved_iv[blocksize];
        memcpy(saved_iv, c->u_iv.iv, blocksize);
        buf_xor_n_copy(outbuf, c->u_iv.iv, inbuf, inbuflen);
        memcpy(c->u_iv.iv, saved_iv + inbuflen, blocksize - inbuflen);
        memcpy(c->u_iv.iv + blocksize - inbuflen, outbuf, inbuflen);
      } else {
        buf_xor_n_copy(outbuf, c->u_iv.iv, inbuf, inbuflen);
        memcpy(c->u_iv.iv, outbuf, inbuflen);
      }*/
      buf_xor_n_copy(outbuf, c->u_iv.iv, inbuf, inbuflen);
      outbuf += inbuflen;
      inbuf += inbuflen;
      inbuflen = 0;
    }

  if (burn > 0)
    printf("SHOULD BE BURNING?");//// _gcry_burn_stack (burn + 4 * sizeof(void *));

  return 0;
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

// Maximum sizes for static buffers

#define MAX_FILENAME_LEN 64
#define MAX_DATA_LEN 256
#define MAX_PLAINTEXT_SIZE (1 + 1 + 1 + 4 + MAX_FILENAME_LEN + MAX_DATA_LEN)
// Global static buffers
static uint8_t g_finalOutput[512];
static uint8_t g_plaintextData[328];
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

uint8_t *encryptToGPGFormat(const char *data, const char *filename, const char *passphrase, const char *derivedKey) {
    printf("Function start\n");
    
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
        printf("Password length: %d\n", my_strlen(passphrase));
        derive_key(salt, passphrase, my_strlen(passphrase), iterations, key);
    }
    printf("Derived Key: ");
    for (int i = 0; i < 16; i++) {
        printf("%02X", key[i]);
    }printf("\n");
    printf("PASSPHRASE: %s\n",passphrase);
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
    
    // Encrypt packet byte
    uint8_t packetByte[1] = {0xcb};
    uint8_t encryptedPacket[1];
    _gcry_cipher_cfb_encrypt(c, encryptedPacket, sizeof(encryptedPacket),
                            packetByte, sizeof(packetByte));
    
    // Prepare and encrypt data packet
    size_t filenameLen = filename ? my_strlen(filename) : 0;
    size_t dataLen = my_strlen(data);
    
    // Verify sizes are within bounds
    if (filenameLen > MAX_FILENAME_LEN || dataLen > MAX_DATA_LEN) {
        return NULL; // Error condition
    }
    
    // Calculate plaintext size
    size_t plaintextSize = 1 + 1 + 1 + 4 + filenameLen + dataLen; // length + mode + namelen + timestamp + filename + data
    
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
    
    printf("PASSPHRASE: %s\n",passphrase);
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
    
    printf("PASSPHRASE: %s\n",passphrase);
    return g_finalOutput;
}

void decryptGPGData(const uint8_t* encryptedData, size_t dataLen, const char* passphrase, uint8_t* output, size_t* outputLen, const char *derivedKey) {
    printf("Passphrase pointer: %p\n", passphrase);
    printf("Passphrase: '%s'\n", passphrase);
    if (!passphrase) {
        printf("Invalid passphrase\n");
        return;
    }

    printf("Password string: '%s'\n", passphrase);
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

void main()
{
    init_printf(0, putc_uart);
    printf("Printf initialised!\n");
    testVector();
    // Test GPG encryption
    const char *data = "Hello World!";
    const char *filename = NULL;  // For initial test, matching original behavior
    static const char *passphrase = "password";
    
    printf("\nEncrypting data: '%s'\n", data);
    printf("Passphrase: '%s'\n", passphrase);
    if (filename) {
        printf("Filename: '%s'\n", filename);
    } else {
        printf("No filename specified\n");
    }
    const char* derivedKey = "693B7847FA44CDC6E1C403F5E44E95C1";
    char passCopy[64];
    my_strncpy(passCopy, passphrase, sizeof(passCopy)-1);
    passCopy[sizeof(passCopy)-1] = '\0';
    
    printf("Passphrase pointer: %p\n", passCopy);
    printf("Passphrase: '%s'\n", passCopy);
    // Call the encryption function
    uint8_t *encrypted = encryptToGPGFormat(data, filename, passphrase, derivedKey);
    
    // Calculate the output size 
    // 15 (symkey packet) + 2 (header) + 10 (random) + 1 (packet) + 20 (data packet)
    size_t outputSize = 15 + 2 + 10 + 1 + 20;  
    
  
    // Print the final output in hex format
    printf("\nFinal GPG Output:\n");
    printFinalOutput(encrypted, outputSize);
    // In main():
    uint8_t decrypted[MAX_PLAINTEXT_SIZE];
    size_t decryptedLen;

    printf("PASSPHRASE: %s\n",passphrase);
    printf("PASSPHRASE: %s\n",passCopy);
    decryptGPGData(encrypted, outputSize, passphrase==""?passCopy:passphrase, decrypted, &decryptedLen, NULL);
    printf("Decrypted text: %s\n", decrypted);

    
    decryptGPGData(encrypted, outputSize, passCopy, decrypted, &decryptedLen, derivedKey);
    printf("Decrypted text: %s\n", decrypted);
    
    // Halt execution
    while (1) {
        __asm__("wfi");  // Wait for interrupt - more power efficient than empty loop
    }
}