#include "mem.h"
#include "gpg.h"
#include "common.h"
#include "sboxes.h"
#include "printf.h"
#include "zlib.h"
#include <ctype.h>
#include <assert.h>
#include <string.h>
#include "sha1.h"

#define TRUE 1
#define FALSE 0

// Function prototypes for hex digit checks
int my_isdigit(char c);
int my_isxdigit(char c);
char my_tolower(char c);
int xtoi_2(const char *hex);
void *xtrymalloc(size_t size);
const char *hex2str(const char *hexstring, char *buffer, size_t bufsize, size_t *buflen);
char *hex2str_alloc(const char *hexstring, size_t *r_count);

enum
{
  KEY_LEN = 128 / 32,
  MSG_LEN = 2
};

typedef uint32_t Key[KEY_LEN];

// Need to take this out if 64 bit
// static const uint64_t MOD_2_32 = (uint64_t)2 << 31;
#define MOD_2_32 ((uint32_t)1 << 31) * 2
// static const uint32_t MOD_2_32_MINUS_1 = 0xFFFFFFFF;

struct Block{
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
  *Id = (I)&0xFF;
}

// static uint32_t sumMod2_32(uint32_t a, uint32_t b)
// {
//   // its just a remainder
//   return ((a) + b) % MOD_2_32;
// }

// Function to add two 32-bit unsigned integers with wrap-around at 2^32
static uint32_t sumMod2_32(uint32_t a, uint32_t b)
{
    // In 32-bit unsigned arithmetic, adding two uint32_t values
    // automatically wraps around on overflow, effectively performing
    // the operation modulo 2^32. Therefore, no explicit modulus operation is needed.
    return a + b;
}

// static uint32_t sumMod2_32b(uint32_t a, uint32_t b)
// {

//   return ((a) + b);// % MOD_2_32;

// }

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

// static uint32_t subtractMod2_32b(uint32_t a, uint32_t b)
// {
//   if (b <= a)
//   {
//     return a - b;
//   }

//   return (MOD_2_32_MINUS_1 + a) - b + 1;
// }

static uint32_t cyclicShift(uint32_t x, uint8_t shift)
{
  uint8_t s = shift % 32;
  return (x << s) | (x >> (32 - s));
}

unsigned char *uint32ToChar(uint32_t val)
{
  int shiftBy = 32;
  unsigned char *res = malloc(4);
  for (int i = 0; i < 4; i++)
  {
    res[i] = (val >> (shiftBy -= 8)) & 0xf;
  }
  return res;
}

static void printBlock(struct Block block){
  printf("%08X%08X\n", block.msb, block.lsb);
}

static struct Block run(const Key key, struct Block data, int reverse)
{
    Key x = {0};
    memcpy(x, key, sizeof(Key));
    Key z = {0};

    uint32_t *K = (uint32_t *)malloc(32 * sizeof(uint32_t));
    if (K == NULL) {
        printf("Memory allocation failed\n");
        return data; // Return early if memory allocation fails
    }

    for (int i = 0; i < 2; ++i)
    {
        z[0] = x[0] ^ S5[g(x, 0xD)] ^ S6[g(x, 0xF)] ^ S7[g(x, 0xC)] ^ S8[g(x, 0xE)] ^ S7[g(x, 0x8)];
        z[1] = x[2] ^ S5[g(z, 0x0)] ^ S6[g(z, 0x2)] ^ S7[g(z, 0x1)] ^ S8[g(z, 0x3)] ^ S8[g(x, 0xA)];
        z[2] = x[3] ^ S5[g(z, 0x7)] ^ S6[g(z, 0x6)] ^ S7[g(z, 0x5)] ^ S8[g(z, 0x4)] ^ S5[g(x, 0x9)];
        z[3] = x[1] ^ S5[g(z, 0xA)] ^ S6[g(z, 0x9)] ^ S7[g(z, 0xB)] ^ S8[g(z, 0x8)] ^ S6[g(x, 0xB)];

        // printf("z[0]=%x, z[1]=%x, z[2]=%x, z[3]=%x\n", z[0], z[1], z[2], z[3]);

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

    uint32_t *L = (uint32_t *)malloc((ROUND_COUNT + 1) * sizeof(uint32_t));
    if (L == NULL) {
        printf("Memory allocation failed\n");
        free(K);
        return data; // Return early if memory allocation fails
    }

    L[0] = data.msb;

    uint32_t *R = (uint32_t *)malloc((ROUND_COUNT + 1) * sizeof(uint32_t));
    if (R == NULL) {
        printf("Memory allocation failed\n");
        free(K);
        free(L);
        return data; // Return early if memory allocation fails
    }
    
    memset(R, 0, (ROUND_COUNT + 1) * sizeof(uint32_t));

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
    }

    data.msb = R[ROUND_COUNT];
    data.lsb = L[ROUND_COUNT];

    // Free allocated memory
    free(K);
    free(L);
    free(R);

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

// Feistel Cast-128 (Cast-5) test vector test function
void testVector()
{
  printf("testVector\n");
  int testPassing = 1;
  Key KEY = {0x01234567, 0x12345678, 0x23456789, 0x3456789A};
  struct Block msg = {
    .msb = 0x01234567,
    .lsb = 0x89ABCDEF
  };
  
  struct Block block = encrypt(KEY, msg);  

  testPassing = block.msb == 0x238B4FE5 && block.lsb == 0x847E44B2;
  block = decrypt(KEY, block);
  testPassing = block.msb == 0x01234567 && block.lsb == 0x89ABCDEF;
  if (testPassing)
    printf("Test vectors passing\n");
  else
  {
    printf("Tests failing...\n");
    // exit(-1);
  }
}
char *testAAAHex = "41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410a";
char *textAAAFilename = "testAAA.txt";
const char *testPassphrase = "password";

// static void
// print_hex(const char *text, const void *buf, size_t n)
// {
//   const unsigned char *p = buf;

//   // fputs(text, stdout);
//   for (; n; n--, p++)
//     printf("%02X", *p);
//   // putchar('\n');
// }

// Check if a character is a valid ASCII character
int my_isascii(char c) {
    return (unsigned char)c <= 0x7F;
}

// Check if a character is a whitespace character
int my_isspace(char c) {
    return c == ' ' || c == '\t' || c == '\n' || c == '\v' || c == '\f' || c == '\r';
}

// Check if a character is a decimal digit
int my_isdigit(char c) {
    return c >= '0' && c <= '9';
}

// Check if a character is a hexadecimal digit
int my_isxdigit(char c) {
    return (c >= '0' && c <= '9') ||
           (c >= 'A' && c <= 'F') ||
           (c >= 'a' && c <= 'f');
}

// Convert a character to lowercase if it's an uppercase letter
char my_tolower(char c) {
    if (c >= 'A' && c <= 'Z') {
        return c + ('a' - 'A');
    }
    return c;
}

// Convert a two-character hex string to an integer
int xtoi_2(const char *hex) {
    int result = 0;
    for (int i = 0; i < 2; i++) {
        char c = hex[i];
        if (my_isdigit(c)) {
            result = result * 16 + (c - '0');
        } else if (my_isxdigit(c)) {
            result = result * 16 + (my_tolower(c) - 'a' + 10);
        } else {
            return -1; // Error: not a hex digit
        }
    }
    return result;
}

// Try to allocate memory, handle error if allocation fails
void *xtrymalloc(size_t size) {
    void *ptr = malloc(size);
    if (!ptr) {
        printf("Memory allocation failed\n");
        // exit(EXIT_FAILURE); // Or handle the error as appropriate for your project
    }
    return ptr;
}

// Check if a character is a hexadecimal digit
int hexdigitp(char c) {
    return my_isxdigit(c);
}

// Convert a hexadecimal string to a byte string
const char *hex2str(const char *hexstring, char *buffer, size_t bufsize, size_t *buflen) {
    const char *s = hexstring;
    int idx, count;
    int need_nul = 0;

    if (buflen)
        *buflen = 0;

    for (s = hexstring, count = 0; hexdigitp(*s) && hexdigitp(*(s + 1)); s += 2, count++)
        ;

    if (*s && (!my_isascii(*s) || !my_isspace(*s)))
        return NULL; /* Not followed by Nul or white space.  */
    
    /* We need to append a nul character.  However we don't want that if
       the hexstring already ends with "00".  */
    need_nul = ((s == hexstring) || !(s[-2] == '0' && s[-1] == '0'));
    if (need_nul)
        count++;

    if (buffer) {
        if (count > bufsize)
            return NULL; /* Too long.  */

        for (s = hexstring, idx = 0; hexdigitp(*s) && hexdigitp(*(s + 1)); s += 2)
            ((unsigned char *)buffer)[idx++] = xtoi_2(s);
        
        if (need_nul)
            buffer[idx] = 0;
    }

    if (buflen)
        *buflen = count - 1;
    
    return s;
}

// Allocate and convert a hexadecimal string to a byte string
char *hex2str_alloc(const char *hexstring, size_t *r_count) {
    const char *tail;
    size_t nbytes;
    char *result;

    tail = hex2str(hexstring, NULL, 0, &nbytes);
    if (!tail) {
        if (r_count)
            *r_count = 0;
        // errno = EINVAL;
        return NULL;
    }
    if (r_count)
        *r_count = tail - hexstring;
    result = xtrymalloc(nbytes + 1);
    if (!result)
        return NULL;
    if (!hex2str(hexstring, result, nbytes + 1, NULL))
        printf("BUG ();\n");
    return result;
}


/* The first partial length header block must be of size 512
 * to make it easier (and efficienter) we use a min. block size of 512
 * for all chunks (but the last one) */
#define OP_MIN_PARTIAL_CHUNK	  512
#define OP_MIN_PARTIAL_CHUNK_2POW 9

struct Block blockFromBytes(uint8_t *bytes)
{
  struct Block block = {
    .msb = 0,
    .lsb = 0
  };
  for (int i = 0; i < 8; i++)
  {
    if(i<4)
      block.msb = (block.msb << 8) | bytes[i];
    else
      block.lsb = (block.lsb << 8) | bytes[i];
  }
  return block;
}

struct Block xorBlock2(struct Block block, struct Block val)
{
  struct Block result = {
    .msb = block.msb ^ val.msb,
    .lsb = block.lsb ^ val.lsb
  };
  return result;
}

struct IVsPlusData{
  uint8_t* iv;
  uint8_t* data;
};

uint8_t *bytesFromBlock(struct Block block)
{
  uint8_t *bytes = malloc((sizeof(uint8_t)) * 8);
  bytes[7] = (block.lsb & 0x000000FF) >> 0;
  bytes[6] = (block.lsb & 0x0000FF00) >> 8;
  bytes[5] = (block.lsb & 0x00FF0000) >> 16;
  bytes[4] = (block.lsb & 0xFF000000) >> 24;
  bytes[3] = (block.msb & 0x000000FF) >> 0;
  bytes[2] = (block.msb & 0x0000FF00) >> 8;
  bytes[1] = (block.msb & 0x00FF0000) >> 16;
  bytes[0] = (block.msb & 0xFF000000) >> 24;
  return bytes;
}
// taken and modified from libgcrypt
struct IVsPlusData
do_cfb_encrypt(Key key, uint8_t *iv, uint8_t *lastiv, size_t blocksize, uint8_t *outbuf, const uint8_t *inbuf, unsigned nbytes)
{
  printf("do_cfb_encrypt\n");
  int totalIn = nbytes;
  //uint8_t *encrypted = malloc(sizeof(uint8_t) * nbytes);

  struct IVsPlusData returnData = {
    .iv =  malloc(sizeof(uint8_t) * 8),
    .data = malloc(sizeof(uint8_t) * nbytes)
  };
  int encCount = 0;
  // print_hex("iv: ", iv, 8);
  // print_hex("lastiv: ", lastiv, 8);
  //printf("nbytes: %i\n",nbytes);
  uint8_t *ivp;

  uint8_t *blockPtr;
  blockPtr = outbuf;
  // WE KNOW THE FILES ARE NOT TINY
  //   if( nbytes <= c->unused ) {
  //     printf("!!!!!! nbytes <= c->unused\n");
  //   print_hex("in: \n",inbuf,blocksize);
  // /* Short enough to be encoded by the remaining XOR mask. */
  // /* XOR the input with the IV and store input into IV. */
  // for (ivp=c->iv+c->cipher->blocksize - c->unused;
  //            nbytes;
  //            nbytes--, c->unused-- )
  //         *outbuf++ = (*ivp++ ^= *inbuf++);

  //   print_hex("out: \n",blockPtr,blocksize);
  // return;
  //   }

  //   if( c->unused ) {
  //     printf("!!!!! c->unused\n");
  // /* XOR the input with the IV and store input into IV */
  // nbytes -= c->unused;
  // for(ivp=c->iv+blocksize - c->unused; c->unused; c->unused-- )
  //     *outbuf++ = (*ivp++ ^= *inbuf++);
  //   }
  size_t byteCount = 0;
    // print_hex("in 0: ", inbuf, blocksize);
  /* Now we can process complete blocks. */
  while (nbytes >= blocksize)
  {
    byteCount+=blocksize;
    // printf("while\n");
    blockPtr = outbuf;
    int i;
    /* Encrypt the IV (and save the current one). */
    memcpy(lastiv, iv, blocksize);
    struct Block ivEncrypted = encrypt(key, blockFromBytes(iv));
    iv = bytesFromBlock(ivEncrypted);
    returnData.iv = iv;
    // c->cipher->encrypt ( &c->context.c, c->iv, c->iv );
    // print_hex("encrypted iv: \n", &ivEncrypted, blocksize);

    /* XOR the input with the IV and store input into IV */
    for (ivp = iv, i = 0; i < blocksize; i++)
    {
      uint8_t b = (*ivp++ ^= *inbuf++);
      *outbuf++ = b;
      returnData.data[encCount++] = b;
    }
    nbytes -= blocksize;
    if(nbytes < blocksize){
      //  print_hex("LAST block: ", blockPtr, blocksize);
    }
    
  }
  if (nbytes)
  { /* process the remaining bytes */
   // printf("nbytes %d\n",nbytes);
    //print_hex("in end: \n", inbuf, blocksize);
    byteCount+=nbytes;

    blockPtr = outbuf;
    /* encrypt the IV (and save the current one) */
    memcpy(lastiv, iv, blocksize);
    struct Block ivEncrypted = encrypt(key, blockFromBytes(iv));
    iv = bytesFromBlock(ivEncrypted);
        returnData.iv = iv;

    /* and apply the xor */
    // c->unused -= nbytes;
    for (ivp = iv; nbytes; nbytes--)
    {
      uint8_t b = (*ivp++ ^= *inbuf++);
      *outbuf++ = b;
      returnData.data[encCount++] = b;
      returnData.iv = &b;
    }

   //print_hex("block: ", blockPtr, blocksize);
  }
 // printf("totalIn %d\n",totalIn);
  //printf("byteCount %ld\n",byteCount);

  // print_hex("iv: ", iv, 8);
  // print_hex("lastiv: ", lastiv, 8);
  // print_hex("total encrypted: \n", encrypted, totalIn);
  //printf("END ENCRYPT\n");
  return returnData;
}

// Generate Key
int keySize = 16;
int blocksize = 8;

/* The first partial length header block must be of size 512
 * to make it easier (and efficienter) we use a min. block size of 512
 * for all chunks (but the last one) */
#define OP_MIN_PARTIAL_CHUNK	  512
#define OP_MIN_PARTIAL_CHUNK_2POW 9

size_t my_strlen(const char *str) {
    size_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}


// 3.7.1.3.  Iterated and Salted S2K

//    This includes both a salt and an octet count.  The salt is combined
//    with the passphrase and the resulting value is hashed repeatedly.
//    This further increases the amount of work an attacker must do to try
//    dictionary attacks.

//        Octet  0:        0x03
//        Octet  1:        hash algorithm
//        Octets 2-9:      8-octet salt value
//        Octet  10:       count, a one-octet, coded value

//    The count is coded into a one-octet number using the following
//    formula:

//        #define EXPBIAS 6
//            count = ((Int32)16 + (c & 15)) << ((c >> 4) + EXPBIAS);

//    The above formula is in C, where "Int32" is a type for a 32-bit
//    integer, and the variable "c" is the coded count, Octet 10.

//    Iterated-Salted S2K hashes the passphrase and salt data multiple
//    times.  The total number of octets to be hashed is specified in the
//    encoded count in the S2K specifier.
//    ********************************************************************
//    Note that the resulting count
//    value is an octet count of how many octets will be hashed, not an
//    iteration count.
//    **********************************************************************
//    Initially, one or more hash contexts are set up as with the other S2K
//    algorithms, depending on how many octets of key data are needed.
//    Then the salt, followed by the passphrase data, is repeatedly hashed
//    until the number of octets specified by the octet count has been
//    hashed.  The one exception is that if the octet count is less than
//    the size of the salt plus passphrase, the full salt plus passphrase
//    will be hashed even though that is greater than the octet count.
//    After the hashing is done, the data is unloaded from the hash
//    context(s) as with the other S2K algorithms.*/

// // https://raysnotebook.info/computing/crypto-gnupg-s2k.html
// // The passphrase is "abc", and the count is 1,408. Thus the salted passphrase appears 128 times: (8+3)×128 = 1,408.

#define EXPBIAS 6

unsigned char *passphraseStringToKey(const char *passphrase, char *salt, int count)
{
  printf("passphraseStringToKey: %s,\nsalt: %s,\ncount: %d\n", passphrase, salt, count);
  unsigned char *key = malloc(16);
  unsigned char saltPlusPassphrase[8 + my_strlen(passphrase)];
  memcpy(saltPlusPassphrase, salt, my_strlen((const char *)(salt)));
  memcpy(saltPlusPassphrase + 8, passphrase, my_strlen((const char *)passphrase));
  int octetExpansionCount = ((int32_t)16 + (count & 15)) << ((count >> 4) + EXPBIAS);
  int totalLen = 8 + my_strlen(passphrase);
  printf("octetExpansionCount: %d\ntotalLen: %d\n",octetExpansionCount,totalLen);
  // Now we multiply the total length by the repeat count
  // And loop copying a single byte at a time, wrapping around the end to the start
  int byteIndex = 0;
  // unsigned char saltPlusPassphraseExpanded[octetExpansionCount];
  unsigned char *saltPlusPassphraseExpanded = (unsigned char *)malloc(octetExpansionCount);
  for (int i = 0; i < octetExpansionCount; i++)
  {
    memcpy(saltPlusPassphraseExpanded + (i * sizeof(unsigned char)), &saltPlusPassphrase[byteIndex], sizeof(unsigned char));
    byteIndex++;
    if (byteIndex == totalLen) // Wrap around end
      byteIndex = 0;
  }
  char result[21];
  printf("strlen((char *)saltPlusPassphraseExpanded: %ld\n",my_strlen((char *)saltPlusPassphraseExpanded));
  // calculate hash
  SHA1(result, (char *)saltPlusPassphraseExpanded, my_strlen((char *)saltPlusPassphraseExpanded));
  // sha256SumData(saltPlusPassphraseExpanded, my_strlen((char *)saltPlusPassphraseExpanded), "saltPlusPassphraseExpanded");

  printf("result: ",result,20);
  char hexresult[41];
  size_t offset;
  // format the hash for comparison
  for (offset = 0; offset < 20; offset++)
  {
    sprintf((hexresult + (2 * offset)), "%02x", result[offset] & 0xff);
    if (offset < 16) // We only need the first 16 bytes
      key[offset] = result[offset];
  }

  return key;
}

uint8_t *encryptToGPGFormat(char *data, const char *filename, const char *passphrase,  size_t *totalFileSize)
{
  printf("encryptToGPGFormat\n");
  int totalDataLen = my_strlen(data); // Will compress to be smaller
  uint8_t *encryptedGpgFile = malloc(totalDataLen);
  uint8_t *encryptedData = malloc(totalDataLen);
  int offset = 0;
  // write the file header
  encryptedGpgFile[offset++] = 0x8c; // gpgPacket
  encryptedGpgFile[offset++] = 0x0d; // packetLen
  encryptedGpgFile[offset++] = 0x04; // version
  encryptedGpgFile[offset++] = 0x03; // cipher algo cast5 (cast128)
  encryptedGpgFile[offset++] = 0x03; // s2k salted and iterated hash
  encryptedGpgFile[offset++] = 0x02; // hashAlgo sha1 only
  // Generate a random salt


  size_t *count = 0;
  char *salt = hex2str_alloc("c99a13a5944b4f4a", count); // genRandomBytes(8);
 // print_hex("Salt: ", salt, 8);
  for (int i = 0; i < 8; i++)
  {
    encryptedGpgFile[offset++] = salt[i];
  }
  int s2kCount = 255;
  encryptedGpgFile[offset++] = s2kCount; // s2key count
  // print_hex("Header: ", encryptedGpgFile, offset);

  const unsigned char *decryptionKey = passphraseStringToKey(passphrase, salt, s2kCount);
  /*Key key = {0, 0, 0, 0};
  int j = 0;
  for (int i = 0; i < 4; i++)
  {
    key[i] = (decryptionKey[j] << 24) + (decryptionKey[j + 1] << 16) + (decryptionKey[j + 2] << 8) + decryptionKey[j + 3];
    // printUint32Hex(key[i]);
    j += 4;
  }
  // print_hex("Key: ", decryptionKey, keySize);

  // Initialise cipher
  // Step by step, here is the procedure:

  //    1.  The feedback register (FR) is set to the IV, which is all zeros.
  // unsigned char* iv = malloc(blocksize);
  struct Block iv = {.msb=0x00000000,.lsb=0x00000000};
  printBlock(iv);
  // uLong feedbackRegister = iv;
  // block = decrypt(KEY, block);
  struct Block fr = iv;
  printBlock(fr);

  //    2.  FR is encrypted to produce FRE (FR Encrypted).  This is the
  //        encryption of an all-zero value.
  // print_hex("encrypted: ",&encrypted, blocksize);

  struct Block encrypted = encrypt(key, fr);
  // print_hex("encrypted: ", msgP, 8);
  printBlock(encrypted);
  //    3.  FRE is xored with the first 8 octets of random data prefixed to
  //        the plaintext to produce C1-C8, the first 8 octets of ciphertext.

  unsigned char *randomHex = (unsigned char *)hex2str_alloc("1772898647157B467B46", count); // genRandomBytes(10); THEN DUPLICATE [6]=>[8] & [7]=>[9]
  // print_hex("randomHex: ", randomHex, blocksize + 2);
  struct Block freXored = xorBlock2(encrypted, blockFromBytes((uint8_t *)randomHex));
  printBlock(freXored);

  int encOffset = 0;
  appendBytes(encryptedData, encOffset, bytesFromBlock(freXored), 8);
  encOffset += 8;
  //    4.  FR is loaded with C1-C8.
  fr = freXored;
  printBlock(fr);

  //    5.  FR is encrypted to produce FRE, the encryption of the first 8
  //        octets of ciphertext.
  encrypted = encrypt(key, fr);
  printBlock(encrypted);

  //    6.  The left two octets of FRE get xored with the next two octets of
  //        data that were prefixed to the plaintext.  This produces C9-C10,
  //        the next two octets of ciphertext.
  uint8_t *encryptedBlock1 = bytesFromBlock(encrypted);
  uint8_t *c9c10 = malloc(sizeof(uint8_t) * 2);
  c9c10[0] = encryptedBlock1[0] ^ randomHex[8];
  c9c10[1] = encryptedBlock1[1] ^ randomHex[9];
  // printf("c9: %02x\n", c9c10[0]);
  // printf("c10: %02x\n", c9c10[1]);
  appendBytes(encryptedData, encOffset, c9c10, 2);
  encOffset += 2;
 // print_hex("ENCRYPTED DATA: ", encryptedData, encOffset);

  //    7.  (The resync step) FR is loaded with C3-C10.
  fr = blockFromBytes((uint8_t *)encryptedData + 2);
  printBlock(fr);
  

  int compOffset = 0;
 // printf("totalDataLen %d\n", totalDataLen);
  uint8_t namelen = my_strlen(filename);
  // printf("namelen %d\n", namelen);

  int totalPacketLength = totalDataLen? (1 + 1 + namelen + 4 + totalDataLen) : 0;
  // printf("totalPacketLength: %d\n",totalPacketLength);

  uint8_t *dataToCompress = malloc(totalPacketLength);
  // print_hex("dataToCompress",dataToCompress,totalDataLen);
   // printf("CTB: %d\n",0xAC);

  compOffset = write_header2(dataToCompress, 0xAC, totalPacketLength, 0, compOffset);
  // printf("compOffset: %d\n",compOffset);
  int totalCompCount = compOffset + totalPacketLength;
  uint8_t mode = 0x62;
  uint8_t *concatModeNameLen = malloc(sizeof(uint8_t) * 2);
  concatModeNameLen[0] = mode;
  concatModeNameLen[1] = namelen;
  appendBytes(dataToCompress, compOffset, concatModeNameLen, 2); // pt->mode
  compOffset += 2;

  appendBytes(dataToCompress, compOffset, (uint8_t *)filename, namelen); // filename
  compOffset += namelen;
  // Add timestamp
  // time_t current = time (NULL);
  // uint32_t curTime8Bytes = (uint32_t)current;
  // uint8_t* t = (uint8_t *)0x62F4805F;
  // -> timestamp
  char *t = hex2str_alloc("63323268", count); // genRandomBytes(8); // Clamped timestamp in gnupg also (sync)
  // A3015B332989BB24B5B8C4D1D151AFA4A224E96FAA80E300032E060000
  appendBytes(dataToCompress, compOffset, (uint8_t *)t, 4); // timestamp
  compOffset += 4;
  // print_hex("plaintextHeader:",dataToCompress,compOffset);
  // totalDataLen + 
  appendBytes2(dataToCompress, compOffset, data, totalDataLen); // 
  compOffset += totalDataLen;
  // dataToCompress[compOffset - 1] = 0x0A; // for some reason need to swap null byte out for 0A (perhaps only for small file? No xxd provides it)
  // print_hex("dataToCompress:",dataToCompress,compOffset);

  Byte *compr, *uncompr;
  uLong comprLen = 1000000 * sizeof(int); // don't overflow on MSDOS
  uLong uncomprLen = comprLen;
  static const char *myVersion = ZLIB_VERSION;

  if (zlibVersion()[0] != myVersion[0])
  {
    fprintf("incompatible zlib version\n");
    exit(1);
  }
  else if (strcmp(zlibVersion(), ZLIB_VERSION) != 0)
  {
    fprintf( "warning: different zlib version\n");
  }

  printf("zlib version %s = 0x%04x, compile flags = 0x%lx\n",
         ZLIB_VERSION, ZLIB_VERNUM, zlibCompileFlags());

  compr = (Byte *)calloc((uInt)comprLen, 1);
  uncompr = (Byte *)calloc((uInt)uncomprLen, 1);
  // printf("comprLen: %ld\n",comprLen);
  // printf("uncomprLen: %ld\n",uncomprLen);
  // compr and uncompr are cleared to avoid reading uninitialized
  // data and to ensure that uncompr compresses well.
   
  if (compr == Z_NULL || uncompr == Z_NULL)
  {
    printf("out of memory\n");
    exit(1);
  }

  uint8_t *compressed = malloc(sizeof(uint8_t) * totalDataLen); // compresses below totalDataLen
  printf("compOffset: %d\n",compOffset);

  // sha256SumData(dataToCompress, totalCompCount, "decompressed");

  size_t compressedLength = test_deflate(compr, comprLen, dataToCompress, compressed, totalCompCount);
  // size_t compressedLength = test_deflate(compr, comprLen, dataToCompress, compressed, totalCompCount);
  // printf("compressedLength: %ld\n",compressedLength);
  // sha256SumData(compr, compressedLength, "compressed");
    // test_inflate(compr, compressedLength, uncompr, uncomprLen, dataToCompress);

  // While:
  //    8.  FR is encrypted to produce FRE.

  //    9.  FRE is xored with the first 8 octets of the given plaintext, now
  //        that we have finished encrypting the 10 octets of prefixed data.
  //        This produces C11-C18, the next 8 octets of ciphertext.

  //    10.  FR is loaded with C11-C18

  //    11.  FR is encrypted to produce FRE.

  //    12.  FRE is xored with the next 8 octets of plaintext, to produce the
  //        next 8 octets of ciphertext.  These are loaded into FR and the
  //        process is repeated until the plaintext is used up.

  int plusHeaderCount = compressedLength+2;
  // printf("plusHeaderCount: %d\n", plusHeaderCount);
  uint8_t *compressedPacket = malloc((sizeof(uint8_t) * plusHeaderCount)); // packet + mode bytes + extra byte

  // We need to prepend the packet tag (A301)
  write_header2(compressedPacket, 0xA0, 0, 0, 0);
  compressedPacket[1] = 0x01; // compression mode ???
  // Now set all the rest of the compressed packet bytes
  for(int i = 0;i<compressedLength;i++)
    compressedPacket[i+2] = compressed[i];
  
  // print_hex("COMPRESSED: ", compressedPacket, plusHeaderCount);
  
  char *encryptedPacketTag = hex2str_alloc("c9", count);
  appendBytes(encryptedGpgFile, offset++, (unsigned char *)encryptedPacketTag, 1);

  

// Taken from gnupg/common/iobuf.c -> block_filter(...)


  char* pLen = malloc(10);
  int pByteCount = 0;

  // printf("block_filter\n");
  int c; // needed
  char *p;
	  //     u32 len;
    uint32_t len;
    len = encOffset + plusHeaderCount;
    //the complicated openpgp scheme 
	  size_t blen, n, nbytes = len;

  size_t inOffset = 0;
// If the file is very small it's just "WRITE THE END MARKERS" buf len + encrypted data e.g. nbytes < OP_MIN_PARTIAL_CHUNK

  size_t currentCompressedPktOffset = 0;

  struct Block currentIV = fr;
  uint8_t *lastIV = encryptedBlock1;
  uint8_t* remainingBytes = encryptedData;
if(len < OP_MIN_PARTIAL_CHUNK){
    printf("len < OP_MIN_PARTIAL_CHUNK: %d\n",len);
	  //     //  write out the remaining bytes without a partial header
	  //     //  * the length of this header may be 0 - but if it is
	  //     //  * the first block we are not allowed to use a partial header
	  //     //  * and frankly we can't do so, because this length must be
	  //     //  * a power of 2. This is _really_ complicated because we
	  //     //  * have to check the possible length of a packet prior
	  //     //  * to it's creation: a chain of filters becomes complicated
	  //     //  * and we need a lot of code to handle compressed packets etc.
	  //     //  *   :-(((((((
	  //     //  
	  //     //  construct header 
	  //     len = a->buflen;
	  //     // log_debug("partial: remaining length=%u\n", len ); 

	  //     if (len < 192)
		//         rc = iobuf_put (chain, len);
    if(len<192){


        printf("Writing SINGLE byte header\n");
  sprintf(pLen, "%02x", len);
      printf("pLen + : %s\n",pLen);
  pByteCount=1;
    }
	  //     else if (len < 8384)
	      else if (len < 8384)
		// {
		//   if (!(rc = iobuf_put (chain, ((len - 192) / 256) + 192)))
		//     rc = iobuf_put (chain, ((len - 192) % 256));
		// }
    {
        printf("Writing DOUBLE byte header\n");
      sprintf(pLen, "%02x%02x", ((len - 192) / 256) + 192, ((len - 192) % 256));
      printf("pLen + : %s\n",pLen);
      pByteCount=2;
    }
	  //     else
		// {		
    //   //  use a 4 byte header 
		//   if (!(rc = iobuf_put (chain, 0xff)))
		//     if (!(rc = iobuf_put (chain, (len >> 24) & 0xff)))
		//       if (!(rc = iobuf_put (chain, (len >> 16) & 0xff)))
		// 	if (!(rc = iobuf_put (chain, (len >> 8) & 0xff)))
		// 	  rc = iobuf_put (chain, len & 0xff);
    else{      
      
        printf("Writing QUAD byte header\n");
        sprintf(pLen, "%02x%02x%02x%02x%02x", 0xff, (len >> 24) & 0xff, (len >> 16) & 0xff, (len >> 8) & 0xff, len & 0xff);
  pByteCount=5;
      printf("pLen + : %s\n",pLen);
      pByteCount=5;
    }

		// }
	  //     if (!rc && len)
		// rc = iobuf_write (chain, a->buffer, len);
	  //     if (rc)
		// {
		//   log_error ("block_filter: write error: %s\n",
		// 	     strerror (errno));
		//   rc = gpg_error_from_syserror ();
		// }
  char *packetLen = hex2str_alloc(pLen, count);
  
  // char *packetLen = hex2str_alloc(pLen, count);
  // printf("count: %ld\n", *count);
  print_hex("packetLen: ", packetLen, pByteCount);


  // Now we append all of this to the file header

  appendBytes(encryptedGpgFile, offset, (uint8_t *)packetLen, pByteCount);
  offset+=pByteCount;

  // 7a8d6533bcc7b9d408225d788e2faf027d5baa674bc97bd29c8c42b4a6a571189514fe361e
  uint8_t *encryptedCompressed = malloc((sizeof(uint8_t) * plusHeaderCount)); // packet + mode bytes + extra byte
  struct IVsPlusData encryptedIvData = do_cfb_encrypt(key, bytesFromBlock(fr), encryptedBlock1, 8, encryptedCompressed, compressedPacket, plusHeaderCount);
  // printf("encOffset: %d\n", encOffset);

  appendBytes(encryptedData, encOffset, encryptedIvData.data, plusHeaderCount);
  // encOffset += plusHeaderCount;
  print_hex("ENCRYPTED DATA START: ", encryptedData, 10);
  print_hex_skip_bytes("ENCRYPTED DATA END: ", encryptedData, 10, encOffset + plusHeaderCount-10);

  // printf("encOffset: %d, plusHeaderCount: %d\n",encOffset, plusHeaderCount);

  *totalFileSize = offset + encOffset + plusHeaderCount;
  appendBytes(encryptedGpgFile, offset, encryptedData,*totalFileSize);
  // set len to zero to skip end partial packet block
  len = 0;
}
else{ // We need multiple marked packets

  struct IVsPlusData encryptedIvData = {
    .iv =  malloc(sizeof(uint8_t) * 8),
    .data = malloc(sizeof(uint8_t) * nbytes)
  };
  // *totalFileSize = offset + encOffset + plusHeaderCount;
  // len
  // Now we need to encrypt into 8192 byte packets
  if(nbytes>8192){
      // printf("nbytes: %ld\n",nbytes);

    // We need to write out the already encrypted header
    // So what we do is encrypt 8192 bytes
    // loop 
    //   write out 8192 bytes
    //   encrypt the rest
    uint8_t *encryptedPacket = malloc((sizeof(uint8_t) * 8192)); // packet + mode bytes + extra byte
    // uint8_t *encryptedPartialPacket = malloc((sizeof(uint8_t) * 8192 - encOffset)); // packet + mode bytes + extra byte
    encryptedIvData = do_cfb_encrypt(key, bytesFromBlock(currentIV), lastIV, 8, encryptedPacket, compressedPacket, 8192);//

  // print_hex("ENCRYPTED DATA: ", encryptedData, encOffset);
  print_hex("ENCRYPTED DATA START: ", encryptedData, 10);
  print_hex_skip_bytes("ENCRYPTED DATA END: ", encryptedIvData.data, 10, 8192 - encOffset - 10);
  // print_hex("iv: ", encryptedIvData.iv, 8);
  // print_hex("lastIV: ", lastIV, 8);

  char* cHex = malloc(1);
  sprintf(cHex,"%02x",0xed);
    char *pktCLen = hex2str_alloc(cHex, count);
		  // iobuf_put (chain, c);
      // Write next packet Tag directly to gpgFile buffer
        appendBytes(encryptedGpgFile, offset++, (uint8_t *)pktCLen, 1);
              printf("encPacketLen: %02X\n",0xed);

  currentCompressedPktOffset+=8192;
    while(nbytes>8192){
        appendBytes(encryptedGpgFile,offset,remainingBytes, encOffset);
              // print_hex("wrote: ", encryptedGpgFile+offset, encOffset);
        offset += encOffset;
      nbytes -= encOffset;

          // print_hex("remainingBytes: ", remainingBytes, encOffset);

        appendBytes(encryptedGpgFile,offset,encryptedIvData.data, 8192 - encOffset); // So we need to keep those end encOffset bytes and write them to the next packet

      // Copy end of enc block
        for(int i = 0;i<encOffset;i++){
          remainingBytes[i] = encryptedIvData.data[8192 - encOffset + i];
        }
        offset += (8192 - encOffset);
        nbytes -= (8192 - encOffset);
            // printf("nbytes: %ld\n",nbytes);

          size_t n = nbytes <= 8192 ? nbytes : 8192;
          encryptedIvData = do_cfb_encrypt(key, encryptedIvData.iv, lastIV, 8, encryptedPacket, compressedPacket + currentCompressedPktOffset, n);//

        print_hex("ENCRYPTED DATA START: ", remainingBytes, 10);
        print_hex_skip_bytes("ENCRYPTED DATA END: ", encryptedIvData.data, 10, n - 20);

        currentCompressedPktOffset+=n;
        if(nbytes>8192){ // add the length tag
              appendBytes(encryptedGpgFile, offset++, (uint8_t *)pktCLen, 1);
                            printf("encPacketLen: %02X\n",0xed);
        }
  // encOffset += plusHeaderCount;
    }
  }else{ // We only need 1 8192 encrypted packet split into sub packets
    // printf("NBYTES: %ld, plusHeaderCount: %d\n", nbytes, plusHeaderCount);
    uint8_t *encryptedCompressed = malloc((sizeof(uint8_t) * plusHeaderCount)); // packet + mode bytes + extra byte
    encryptedIvData = do_cfb_encrypt(key, bytesFromBlock(currentIV), lastIV, 8, encryptedCompressed, compressedPacket + currentCompressedPktOffset, plusHeaderCount);//
          appendBytes(encryptedData, encOffset, encryptedIvData.data, plusHeaderCount);


  // encOffset += plusHeaderCount;
  // print_hex("ENCRYPTED DATA START: ", encryptedData, 10);
  // print_hex_skip_bytes("ENCRYPTED DATA END: ", encryptedData, 10, encOffset + plusHeaderCount-10);

  }
  int loopCount = 0;
  do
		{
      // printf("nbytes: %ld\nBest matching block length:\n",nbytes);
		  // find the best matching block length - this is limited
		   // by the size of the internal buffering
		  for (blen = OP_MIN_PARTIAL_CHUNK * 2,
		       c = OP_MIN_PARTIAL_CHUNK_2POW + 1; blen <= nbytes;
		       blen *= 2, c++)
		    ;
		  blen /= 2;
		  c--;
		  // write the partial length header
		  assert (c <= 0x1f);	//;-) 
		  c |= 0xe0;

  char* cHex = malloc(1);
  
  sprintf(cHex,"%02x",c);
    char *pktCLen = hex2str_alloc(cHex, count);

		  // iobuf_put (chain, c);
        appendBytes(encryptedGpgFile, offset++, (uint8_t *)pktCLen, 1);
      printf("encPacketLen: %02X\n",c);

      if(loopCount==0){ // pure hack

        appendBytes(encryptedGpgFile,offset,encryptedData, encOffset);
        // print_hex("wrote: ", encryptedGpgFile+offset, encOffset);

        offset+=encOffset;
     }
      // printf("(n = a->buflen): %d\n",(n = a->buflen));
      
		  // if ((n = a->buflen))
		  //   {		 write stuff from the buffer 
      //   printf("// write stuff from the buffer \n");
		  //     // assert (n == OP_MIN_PARTIAL_CHUNK);
		  //     if (iobuf_write (chain, a->buffer, n))
			// rc = gpg_error_from_syserror ();encryptedData
		  //     a->buflen = 0;
		  //     nbytes -= n;
		  //   }
      
		  if ((n = nbytes) > blen){
        // printf("(n = nbytes) > blen %d\n",((n = nbytes) > blen));
		    n = blen;
      }
      if(n){
		  // if (n && iobuf_write (chain, p, n))
          int byteAppendCount = loopCount == 0 ? n - encOffset : n;

          appendBytesInOffset(encryptedGpgFile, offset, encryptedIvData.data, byteAppendCount, inOffset);
          
        print_hex_skip_bytes("ENCRYPTED DATA START: ", encryptedGpgFile, 10, offset);
        print_hex_skip_bytes("ENCRYPTED DATA END: ", encryptedGpgFile, 10, offset+byteAppendCount -10);

      // printf("byteAppendCount: %d\n", byteAppendCount);
      // print_hex("wrote: ", encryptedGpgFile+offset, byteAppendCount);
          offset+=byteAppendCount;

          
          inOffset+=byteAppendCount;
   // printf("inOffset:  %lu\n",inOffset);


  for(int i = 0;i<encOffset;i++){
    remainingBytes[i] = encryptedIvData.data[inOffset - encOffset + i];
  }

      }
      else{
        nbytes+=encOffset;
      }
		  p += n;
		  nbytes -= n;
      loopCount++;
		}
    while (nbytes >= OP_MIN_PARTIAL_CHUNK);



  // printf("// store the rest in the buffer %ld\n",nbytes);

    // save remaining bytes
    len = nbytes;
    // Now copy remaining into "encryptedData"
 // print_hex_skip_bytes("encryptedIvData.data: ", (encryptedIvData.data), len, inOffset);
 // printf("len: %d\n",len);
  // Overwrite the end of the <8192 encryptedData with the remaining encrypted packet data for the end write
  for(int i = 0;i<len;i++){
      encryptedData[i+inOffset+encOffset] = encryptedIvData.data[i+inOffset];
  }  
    inOffset += encOffset;
}

if(len){ // If remaining bytes to write

    // printf("LAST WRITE LEN:  %u\n",len);

	  //     if (len < 192)
		//         rc = iobuf_put (chain, len);
    if(len<192){


        printf("Writing SINGLE byte header\n");
  sprintf(pLen, "%02x", len);
      printf("pLen + : %s\n",pLen);
  pByteCount=1;
    }
	  //     else if (len < 8384)
	      else if (len < 8384)
		// {
		//   if (!(rc = iobuf_put (chain, ((len - 192) / 256) + 192)))
		//     rc = iobuf_put (chain, ((len - 192) % 256));
		// }
    {
        printf("Writing DOUBLE byte header\n");
      sprintf(pLen, "%02x%02x", ((len - 192) / 256) + 192, ((len - 192) % 256));
      printf("pLen + : %s\n",pLen);
      pByteCount=2;
    }
	  //     else
		// {		
    //   //  use a 4 byte header 
		//   if (!(rc = iobuf_put (chain, 0xff)))
		//     if (!(rc = iobuf_put (chain, (len >> 24) & 0xff)))
		//       if (!(rc = iobuf_put (chain, (len >> 16) & 0xff)))
		// 	if (!(rc = iobuf_put (chain, (len >> 8) & 0xff)))
		// 	  rc = iobuf_put (chain, len & 0xff);
    else{      
      
        printf("Writing QUAD byte header\n");
        sprintf(pLen, "%02x%02x%02x%02x%02x", 0xff, (len >> 24) & 0xff, (len >> 16) & 0xff, (len >> 8) & 0xff, len & 0xff);
  pByteCount=5;
      printf("pLen + : %s\n",pLen);
      pByteCount=5;
    }

		// }
	  //     if (!rc && len)
		// rc = iobuf_write (chain, a->buffer, len);
	  //     if (rc)
		// {
		//   log_error ("block_filter: write error: %s\n",
		// 	     strerror (errno));
		//   rc = gpg_error_from_syserror ();
		// }
  char *packetLen = hex2str_alloc(pLen, count);
  
  // char *packetLen = hex2str_alloc(pLen, count);
  // printf("count: %ld\n", *count);
//   print_hex("packetLen: ", packetLen, pByteCount);


  // Now we append all of this to the file header

  appendBytes(encryptedGpgFile, offset, (uint8_t *)packetLen, pByteCount);
  offset+=pByteCount;

      // printf("len: %d\n",len);
      // print_hex("SHOULD WRITE: ", encryptedData+inOffset, len);
      // printf("inOffset: %ld\n",inOffset);


  appendBytesInOffset(encryptedGpgFile, offset, encryptedData, len, inOffset);
   //print_hex("wrote: ", encryptedGpgFile+offset, len);

  // printf("inOffset: %ld\n", inOffset);
  
  *totalFileSize = offset + len;
}
  // print_hex("encryptedGpgFile: ", encryptedGpgFile, *totalFileSize);

  // printf("totalFileSize: %ld\n",*totalFileSize);
  // print_hex("encryptedGpgFile: ", encryptedGpgFile, totalFileSize);
*/  
  return encryptedGpgFile;
}

void doGPG() {
  testVector();
  size_t totalFileSize = 0;
  size_t countData = 0;
  char *dataTest = hex2str_alloc(testAAAHex, &countData);
  // Ensure dataTest is not NULL before proceeding
  if (dataTest) {
    printf("Decoded data:\n");
    for (size_t i = 0; i < countData; i++) {
      printf("%c", dataTest[i]);
    }
    printf("\n");

    // Print the countData value
    printf("CountData: %zu\n", countData);

    // Free the allocated memory
    free(dataTest);
  } else {
    printf("Failed to decode hex string.\n");
  }
  // uint8_t* gpgFile = encryptToGPGFormat(dataTest, textAAAFilename, testPassphrase, &totalFileSize);

}