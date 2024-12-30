#ifndef LIBGCRYPT_H
#define LIBGCRYPT_H

#include <stdint.h>
#include <stddef.h>

/* The maximum supported size of a block in bytes */
#define MAX_BLOCKSIZE 16

/* Types */
typedef unsigned short int u16;
typedef unsigned int u32;
typedef unsigned char byte;

/* Basic types needed for CAST5 */
typedef uint32_t Key[4];

struct Block {
    uint32_t msb;
    uint32_t lsb;
};

/* Alignment types */
typedef union {
    int a;
    short b;
    char c[1];
    long d;
    float f;
    double g;
} PROPERLY_ALIGNED_TYPE;

typedef union {
    PROPERLY_ALIGNED_TYPE foo;
    #ifdef NEED_16BYTE_ALIGNED_CONTEXT
    char bar[16] __attribute__ ((aligned (16)));
    #endif
    char c[1];
} cipher_context_alignment_t;

/* The handle structure */
struct gcry_cipher_handle {
    /* The initialization vector. */
    union {
        cipher_context_alignment_t iv_align;
        unsigned char iv[MAX_BLOCKSIZE];
    } u_iv;

    /* Space to save an IV or CTR for chaining operations */
    unsigned char lastiv[MAX_BLOCKSIZE];
    int unused;  /* Number of unused bytes in LASTIV */

    /* Cipher context */
    cipher_context_alignment_t context;
    Key key;
};

typedef struct gcry_cipher_handle *gcry_cipher_hd_t;

/* CAST5 function prototypes */
void bytesFromBlock(struct Block block, uint8_t *bytes);
struct Block blockFromBytes(uint8_t *bytes);
int
_gcry_cipher_setiv (gcry_cipher_hd_t c, const void *iv, size_t ivlen);
int
_gcry_cipher_setkey (gcry_cipher_hd_t hd, const byte *key, size_t keylen);
/* Function prototypes */
int _gcry_cipher_cfb_encrypt(gcry_cipher_hd_t c,
                            unsigned char *outbuf, size_t outbuflen,
                            const unsigned char *inbuf, size_t inbuflen);

size_t _gcry_cipher_cfb_decrypt(gcry_cipher_hd_t c,
                               unsigned char *outbuf, size_t outbuflen,
                               const unsigned char *inbuf, size_t inbuflen);

void cipher_sync(gcry_cipher_hd_t c);
void
_gcry_cipher_close (gcry_cipher_hd_t h);
/* Buffer handling functions */
u32 buf_get_le32(const void *_buf);
void buf_put_le32(void *_buf, u32 val);
void buf_xor(void *_dst, const void *_src1, const void *_src2, size_t len, int debug);
void buf_xor_2dst(void *_dst1, void *_dst2, const void *_src, size_t len);
void buf_xor_n_copy(void *_dst_xor, void *_srcdst_cpy, const void *_src, size_t len);
void buf_xor_n_copy_2(void *_dst_xor, const void *_src_xor, void *_srcdst_cpy, const void *_src_cpy, size_t len);

/* Cipher block operations */
void cipher_block_cpy(void *_dst, const void *_src, size_t blocksize);
void cipher_block_xor_2dst(void *_dst1, void *_dst2, const void *_src, size_t blocksize);
void cipher_block_xor_n_copy(void *_dst_xor, void *_srcdst_cpy, const void *_src, size_t blocksize);
void cipher_block_xor_n_copy_2(void *dst_xor, const void *src_xor, void *srcdst_cpy, const void *src_cpy, size_t blocksize);

enum
{
    KEY_LEN = 128 / 32,
    MSG_LEN = 2
};
typedef uint32_t Key[KEY_LEN];
struct Block blockFromBytes(uint8_t *bytes);
struct Block encrypt(const Key key, struct Block data, int debug);
struct Block decrypt(const Key key, struct Block data);
static void printBlock(struct Block block);


#define TRUE 1
#define FALSE 0

#endif /* LIBGCRYPT_H */