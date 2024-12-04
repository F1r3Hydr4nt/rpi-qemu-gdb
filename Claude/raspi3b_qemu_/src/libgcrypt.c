#include "libgcrypt.h"
#include "memory.h"
#include "printf.h"
#include "sboxes.h"

u32 buf_get_le32(const void *_buf) {
    if (!_buf) {
        return 0; // Handle NULL pointer case
    }
    
    const byte *in = _buf;
    // Force memory read using volatile to prevent optimization
    volatile const byte *vin = in;
    
    u32 b0 = (u32)vin[0];
    u32 b1 = (u32)vin[1]; 
    u32 b2 = (u32)vin[2];
    u32 b3 = (u32)vin[3];
    
    return (b3 << 24) | (b2 << 16) | (b1 << 8) | b0;
}

void buf_put_le32(void *_buf, u32 val) {
    byte *out = _buf;
    out[3] = val >> 24;
    out[2] = val >> 16;
    out[1] = val >> 8;
    out[0] = val;
}

#define buf_get_he32 buf_get_le32
#define buf_put_he32 buf_put_le32

void cipher_block_xor_2dst(void *_dst1, void *_dst2, const void *_src, size_t blocksize) {
    byte *dst1 = _dst1;
    byte *dst2 = _dst2;
    const byte *src = _src;

    if (blocksize == 8) {
        for (size_t i = 0; i < 8; i++) {
            byte temp = dst2[i] ^ src[i];
            dst2[i] = temp;
            dst1[i] = temp;
        }
    }
    else /* blocksize == 16 */ {
        for (size_t i = 0; i < 16; i++) {
            byte temp = dst2[i] ^ src[i];
            dst2[i] = temp;
            dst1[i] = temp;
        }
    }
}

static void buf_xor_2dst_v2(void *_dst1, void *_dst2, const void *_src, size_t len) {
    byte *dst1 = _dst1;
    byte *dst2 = _dst2;
    const byte *src = _src;

    for (size_t i = 0; i < len; i++) {
        byte temp = dst2[i] ^ src[i];
        dst2[i] = temp;
        dst1[i] = temp;
    }
}

void buf_xor_2dst(void *_dst1, void *_dst2, const void *_src, size_t len) {
    byte *dst1 = _dst1;
    byte *dst2 = _dst2;
    const byte *src = _src;

    while (len >= 2 * sizeof(u32)) {
        u32 temp_high = buf_get_he32(dst2) ^ buf_get_he32(src);
        u32 temp_low = buf_get_he32(dst2 + 4) ^ buf_get_he32(src + 4);
        buf_put_he32(dst2, temp_high);
        buf_put_he32(dst2 + 4, temp_low);
        buf_put_he32(dst1, temp_high);
        buf_put_he32(dst1 + 4, temp_low);
        dst2 += 2 * sizeof(u32);
        dst1 += 2 * sizeof(u32);
        src += 2 * sizeof(u32);
        len -= 2 * sizeof(u32);
    }

    if (len >= sizeof(u32)) {
        u32 temp = buf_get_he32(dst2) ^ buf_get_he32(src);
        buf_put_he32(dst2, temp);
        buf_put_he32(dst1, temp);
        dst2 += sizeof(u32);
        dst1 += sizeof(u32);
        src += sizeof(u32);
        len -= sizeof(u32);
    }

    for (; len; len--)
        *dst1++ = (*dst2++ ^= *src++);
}

void cipher_block_cpy(void *_dst, const void *_src, size_t blocksize) {
    byte *dst = _dst;
    const byte *src = _src;
    u32 s[4];

    if (blocksize == 8) {
        s[0] = buf_get_he32(src);
        s[1] = buf_get_he32(src + 4);
        buf_put_he32(dst, s[0]);
        buf_put_he32(dst + 4, s[1]);
    }
    else /* blocksize == 16 */ {
        s[0] = buf_get_he32(src);
        s[1] = buf_get_he32(src + 4);
        s[2] = buf_get_he32(src + 8);
        s[3] = buf_get_he32(src + 12);
        buf_put_he32(dst, s[0]);
        buf_put_he32(dst + 4, s[1]);
        buf_put_he32(dst + 8, s[2]);
        buf_put_he32(dst + 12, s[3]);
    }
}

void cipher_block_xor_n_copy_2(void *dst_xor, const void *src_xor,
                              void *srcdst_cpy, const void *src_cpy,
                              size_t blocksize) {
    printf("cipher_block_xor_n_copy_2\n");
    byte *dst_xor_p = dst_xor;
    byte *srcdst_cpy_p = srcdst_cpy;
    const byte *src_xor_p = src_xor;
    const byte *src_cpy_p = src_cpy;
    u32 sc[4], sx[4], sdc[4];

    if (blocksize == 8) {
        sc[0] = buf_get_he32(src_cpy_p + 0);
        sc[1] = buf_get_he32(src_cpy_p + 4);
        sdc[0] = buf_get_he32(srcdst_cpy_p);
        sdc[1] = buf_get_he32(srcdst_cpy_p + 4);
        sx[0] = buf_get_he32(src_xor_p) ^ sdc[0];
        sx[1] = buf_get_he32(src_xor_p + 4) ^ sdc[1];
        
        buf_put_he32(dst_xor_p, sx[0]);
        buf_put_he32(dst_xor_p + 4, sx[1]);
        buf_put_he32(srcdst_cpy_p, sc[0]);
        buf_put_he32(srcdst_cpy_p + 4, sc[1]);
    }
    else /* blocksize == 16 */ {
        for(int i = 0; i < 4; i++) {
            sc[i] = buf_get_he32(src_cpy_p + i*4);
            sdc[i] = buf_get_he32(srcdst_cpy_p + i*4);
            sx[i] = buf_get_he32(src_xor_p + i*4) ^ sdc[i];
            
            buf_put_he32(dst_xor_p + i*4, sx[i]);
            buf_put_he32(srcdst_cpy_p + i*4, sc[i]);
        }
    }
}

void buf_xor_n_copy_2(void *_dst_xor, const void *_src_xor,
                      void *_srcdst_cpy, const void *_src_cpy, size_t len) {
    // printf("buf_xor_n_copy_2\n");
    byte *dst_xor = _dst_xor;
    byte *srcdst_cpy = _srcdst_cpy;
    const byte *src_xor = _src_xor;
    const byte *src_cpy = _src_cpy;

    while (len >= sizeof(u32)) {
        // printf("len >= sizeof(u32)\n");
        u32 temp = buf_get_he32(src_cpy);
        buf_put_he32(dst_xor, buf_get_he32(srcdst_cpy) ^ buf_get_he32(src_xor));
        buf_put_he32(srcdst_cpy, temp);
        dst_xor += sizeof(u32);
        srcdst_cpy += sizeof(u32);
        src_xor += sizeof(u32);
        src_cpy += sizeof(u32);
        len -= sizeof(u32);
    }

    for (; len; len--) {
        //printf("len < sizeof(u32)\n");
        byte temp = *src_cpy++;
        *dst_xor++ = *srcdst_cpy ^ *src_xor++;
        *srcdst_cpy++ = temp;
    }
    //printf("buf_xor_n_copy_2 end\n");
}

void buf_xor_n_copy(void *_dst_xor, void *_srcdst_cpy,
                    const void *_src, size_t len) {
    buf_xor_n_copy_2(_dst_xor, _src, _srcdst_cpy, _src, len);
}

void cipher_block_xor_n_copy(void *_dst_xor, void *_srcdst_cpy,
                            const void *_src, size_t blocksize) {
    cipher_block_xor_n_copy_2(_dst_xor, _src, _srcdst_cpy, _src, blocksize);
}

void buf_xor(void *_dst, const void *_src1, const void *_src2, size_t len) {
    unsigned char *dst = (unsigned char *)_dst;
    const unsigned char *src1 = (const unsigned char *)_src1;
    const unsigned char *src2 = (const unsigned char *)_src2;

    while (len >= sizeof(uint32_t)) {
        buf_put_he32(dst, buf_get_he32(src1) ^ buf_get_he32(src2));
        dst += sizeof(uint32_t);
        src1 += sizeof(uint32_t);
        src2 += sizeof(uint32_t);
        len -= sizeof(uint32_t);
    }

    for (; len; len--)
        *dst++ = *src1++ ^ *src2++;
}

void printUint32Hex(uint32_t data)
{
  printf("%08X\n", data);
}

int _gcry_cipher_setkey(gcry_cipher_hd_t hd, const byte *key, size_t keylen)
{
    uint32_t *keywords;
    int i;
        
    Key key2 = {0, 0, 0, 0};
    int j = 0;
    for (int i = 0; i < 4; i++)
    {
        hd->key[i] = (key[j] << 24) + (key[j + 1] << 16) + (key[j + 2] << 8) + key[j + 3];
        printf("key[%d] = 0x%08x\n", i, hd->key[i]);
        j += 4;
    }
    
    return 0;//GPG_ERR_NO_ERROR;
}

void
_gcry_cipher_close (gcry_cipher_hd_t h)
{
  size_t off;

  if (!h)
    return;

//   if ((h->magic != CTX_MAGIC_SECURE)
//       && (h->magic != CTX_MAGIC_NORMAL))
//     _gcry_fatal_error(GPG_ERR_INTERNAL,
// 		      "gcry_cipher_close: already closed/invalid handle");
//   else
//     h->magic = 0;

  /* We always want to wipe out the memory even when the context has
     been allocated in secure memory.  The user might have disabled
     secure memory or is using his own implementation which does not
     do the wiping.  To accomplish this we need to keep track of the
     actual size of this structure because we have no way to known
     how large the allocated area was when using a standard malloc. */
//   off = h->handle_offset;
//   wipememory (h, h->actual_handle_size);

  xfree ((char*)h - off);
}

int
_gcry_cipher_setiv (gcry_cipher_hd_t c, const void *iv, size_t ivlen)
{
    printf("_gcry_cipher_setiv %d\n", ivlen);

    c->unused = 0;
    // memcpy (c->u_iv.iv, iv, ivlen);

  memset (c->u_iv.iv, 0, ivlen);
  return 0;// c->mode_ops.setiv (c, iv, ivlen);
}

void cipher_sync(gcry_cipher_hd_t c) {
    printf("cipher_sync %d\n", c->unused);
    if (c->unused) {
        memmove(c->u_iv.iv + c->unused,
                c->u_iv.iv,
                8 - c->unused);
        memcpy(c->u_iv.iv,
               c->lastiv + 8 - c->unused,
               c->unused);
        c->unused = 0;
    }
}

int _gcry_cipher_cfb_encrypt(gcry_cipher_hd_t c,
                          unsigned char *outbuf, size_t outbuflen,
                          const unsigned char *inbuf, size_t inbuflen) {
    printf("_gcry_cipher_cfb_encrypt inbuflen %d outbuflen %d\n", inbuflen, outbuflen);
    printf("inbuf: ");
    for (size_t i = 0; i < inbuflen; i++) {
        printf("%02x", inbuf[i]);
        if ((i + 1) % 16 == 0) printf("\n");
        else if ((i + 1) % 4 == 0) printf(" ");
    }
    printf("\n");
    unsigned char *ivp;
    size_t blocksize = 8;
    size_t blocksize_x_2 = blocksize + blocksize;
    unsigned int burn = 0;
    (void)burn; // Suppress unused variable warning
            struct Block ivBlock1 = blockFromBytes(c->u_iv.iv);

        printBlock(ivBlock1);

    if (outbuflen < inbuflen)
        return -1; /* Buffer too short */

    if (inbuflen <= c->unused) {
        printf("cfb_encrypt 1 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* Short enough to be encoded by the remaining XOR mask. */
        ivp = c->u_iv.iv + blocksize - c->unused;
        buf_xor_2dst_v2(outbuf, ivp, inbuf, inbuflen);
        c->unused -= inbuflen;
        return 0;
    }

    burn = 0;

    if (c->unused) {
        printf("cfb_encrypt 2 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* XOR the input with the IV and store input into IV */
        inbuflen -= c->unused;
        ivp = c->u_iv.iv + blocksize - c->unused;
        buf_xor_2dst_v2(outbuf, ivp, inbuf, c->unused);
        outbuf += c->unused;
        inbuf += c->unused;
        c->unused = 0;
    }

    /* Now we can process complete blocks. */
    printf("cfb_encrypt 4 %d %d %d\n", inbuflen, outbuflen, c->unused);
    while (inbuflen >= blocksize_x_2) {
        /* Encrypt the IV. */
        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
        ivBlock = encrypt(c->key, ivBlock);
        bytesFromBlock(ivBlock, c->u_iv.iv);
        printBlock(ivBlock);
        /* XOR the input with the IV and store input into IV. */
        cipher_block_xor_2dst(outbuf, c->u_iv.iv, inbuf, blocksize);

        outbuf += blocksize;
        inbuf += blocksize;
        inbuflen -= blocksize;
    }

    if (inbuflen >= blocksize) {
        printf("cfb_encrypt 5 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* Save the current IV and then encrypt the IV. */
        cipher_block_cpy(c->lastiv, c->u_iv.iv, blocksize);

        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
                printBlock(ivBlock);

        ivBlock = encrypt(c->key, ivBlock);
        bytesFromBlock(ivBlock, c->u_iv.iv);
        printBlock(ivBlock);

        /* XOR the input with the IV and store input into IV */
        cipher_block_xor_2dst(outbuf, c->u_iv.iv, inbuf, blocksize);

        outbuf += blocksize;
        inbuf += blocksize;
        inbuflen -= blocksize;
    }

    if (inbuflen) {
        printf("cfb_encrypt 6 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* Save the current IV and then encrypt the IV. */
        cipher_block_cpy(c->lastiv, c->u_iv.iv, blocksize);

        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
                printBlock(ivBlock);

        ivBlock = encrypt(c->key, ivBlock);
        bytesFromBlock(ivBlock, c->u_iv.iv);
        printBlock(ivBlock);

        c->unused = blocksize;
        /* Apply the XOR. */
        c->unused -= inbuflen;
        buf_xor_2dst_v2(outbuf, c->u_iv.iv, inbuf, inbuflen);
    }

    return 0;
}

size_t _gcry_cipher_cfb_decrypt(gcry_cipher_hd_t c,
                               unsigned char *outbuf, size_t outbuflen,
                               const unsigned char *inbuf, size_t inbuflen) {
    printf("gcry_cipher_cfb_decrypt inbuflen %d outbuflen %d\n", inbuflen, outbuflen);
    unsigned char *ivp;
    size_t blocksize = 8;
    size_t blocksize_x_2 = blocksize + blocksize;
    unsigned int burn = 0;
    (void)burn; // Suppress unused variable warning
    int shouldShift = inbuflen > blocksize;
    (void)shouldShift; // Suppress unused variable warning

    if (outbuflen < inbuflen)
        return -1; // GPG_ERR_BUFFER_TOO_SHORT

    if (inbuflen <= c->unused) {
        printf("cfb_decrypt 1 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* Short enough to be encoded by the remaining XOR mask. */
        ivp = c->u_iv.iv + blocksize - c->unused;
        buf_xor_n_copy(outbuf, ivp, inbuf, inbuflen);
        c->unused -= inbuflen;
        return 0;
    }

    if (c->unused) {
        printf("cfb_decrypt 2 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* XOR the input with the IV and store input into IV. */
        inbuflen -= c->unused;
        ivp = c->u_iv.iv + blocksize - c->unused;
        buf_xor_n_copy(outbuf, ivp, inbuf, c->unused);
        outbuf += c->unused;
        inbuf += c->unused;
        c->unused = 0;
    }

    /* Process complete blocks */
    printf("cfb_decrypt 4 %d %d %d\n", inbuflen, outbuflen, c->unused);
    while (inbuflen >= blocksize_x_2) {
        /* Encrypt the IV. */
        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
        ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
        bytesFromBlock(ivBlock, c->u_iv.iv);
        
        /* XOR the input with the IV and store input into IV. */
        cipher_block_xor_n_copy(outbuf, c->u_iv.iv, inbuf, blocksize);
        
        outbuf += blocksize;
        inbuf += blocksize;
        inbuflen -= blocksize;
    }

    if (inbuflen >= blocksize) {
        printf("cfb_decrypt 5 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* Save the current IV and then encrypt the IV. */
        cipher_block_cpy(c->lastiv, c->u_iv.iv, blocksize);
        
        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
        ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
        bytesFromBlock(ivBlock, c->u_iv.iv);
        
        /* XOR the input with the IV and store input into IV */
        cipher_block_xor_n_copy(outbuf, c->u_iv.iv, inbuf, blocksize);
        
        outbuf += blocksize;
        inbuf += blocksize;
        inbuflen -= blocksize;
    }

    if (inbuflen) {
        printf("cfb_decrypt 6 %d %d %d\n", inbuflen, outbuflen, c->unused);
        /* Save the current IV and then encrypt the IV. */
        cipher_block_cpy(c->lastiv, c->u_iv.iv, blocksize);
        
        struct Block ivBlock = blockFromBytes(c->u_iv.iv);
        ivBlock = encrypt(*(Key*)&c->context.c, ivBlock);
        bytesFromBlock(ivBlock, c->u_iv.iv);
        
        c->unused = blocksize;
        /* Apply the XOR. */
        c->unused -= inbuflen;
        buf_xor_n_copy(outbuf, c->u_iv.iv, inbuf, inbuflen);
    }

    return 0;
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
// static const uint64_t MOD_2_32 = (uint64_t)2 << 31;
static const uint32_t MOD_2_32_MINUS_1 = 0xFFFFFFFF;

static void printBlock(struct Block block)
{
    printf("%08X%08X\n", block.msb, block.lsb);
}

static uint32_t sumMod2_32b(uint32_t a, uint32_t b)
{

    return ((a) + b); // % MOD_2_32;
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
            I = cyclicShift(sumMod2_32b(Kmi, R[i]), Kri);
            splitI(I, &Ia, &Ib, &Ic, &Id);
            f = sumMod2_32b(subtractMod2_32b(S1[Ia] ^ S2[Ib], S3[Ic]), S4[Id]);
            break;

        case 1:
            I = cyclicShift(Kmi ^ R[i], Kri);
            splitI(I, &Ia, &Ib, &Ic, &Id);
            f = sumMod2_32b(subtractMod2_32b(S1[Ia], S2[Ib]), S3[Ic]) ^ S4[Id];
            break;

        case 2:
            I = cyclicShift(subtractMod2_32b(Kmi, R[i]), Kri);
            splitI(I, &Ia, &Ib, &Ic, &Id);
            f = subtractMod2_32b(sumMod2_32b(S1[Ia], S2[Ib]) ^ S3[Ic], S4[Id]);
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