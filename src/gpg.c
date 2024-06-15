#include "mem.h"
#include "gpg.h"
#include "common.h"
#include "sboxes.h"
#include <stdio.h>
#include "printf.h"
#define TRUE 1
#define FALSE 0

enum
{
  KEY_LEN = 128 / 32,
  MSG_LEN = 2
};

typedef uint32_t Key[KEY_LEN];

// Need to take this out if 64 bit
static const uint64_t MOD_2_32 = (uint64_t)2 << 31;
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

static uint32_t sumMod2_32(uint32_t a, uint32_t b)
{
  // its just a remainder
  return ((a) + b) % MOD_2_32;
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

static void printBlock2(const char* prefix, struct Block block){
  printf("%s%08X%08X\n", prefix, block.msb, block.lsb);
}

static struct Block run(const Key key, struct Block data, int reverse)
{
    printf("run\n");
    Key x = {0};
    memcpy(x, key, sizeof(Key));
    Key z = {0};

    uint32_t *K = (uint32_t *)malloc(32 * sizeof(uint32_t));
    if (K == NULL) {
        printf("Memory allocation failed\n");
        return data; // Return early if memory allocation fails
    }
    printf("Initializing K\n");

    for (int i = 0; i < 2; ++i)
    {
        printf("Round %d\n", i);
        z[0] = x[0] ^ S5[g(x, 0xD)] ^ S6[g(x, 0xF)] ^ S7[g(x, 0xC)] ^ S8[g(x, 0xE)] ^ S7[g(x, 0x8)];
        z[1] = x[2] ^ S5[g(z, 0x0)] ^ S6[g(z, 0x2)] ^ S7[g(z, 0x1)] ^ S8[g(z, 0x3)] ^ S8[g(x, 0xA)];
        z[2] = x[3] ^ S5[g(z, 0x7)] ^ S6[g(z, 0x6)] ^ S7[g(z, 0x5)] ^ S8[g(z, 0x4)] ^ S5[g(x, 0x9)];
        z[3] = x[1] ^ S5[g(z, 0xA)] ^ S6[g(z, 0x9)] ^ S7[g(z, 0xB)] ^ S8[g(z, 0x8)] ^ S6[g(x, 0xB)];

        printf("z[0]=%x, z[1]=%x, z[2]=%x, z[3]=%x\n", z[0], z[1], z[2], z[3]);

        K[0 + i * 16] = S5[g(z, 0x8)] ^ S6[g(z, 0x9)] ^ S7[g(z, 0x7)] ^ S8[g(z, 0x6)] ^ S5[g(z, 0x2)];
        K[1 + i * 16] = S5[g(z, 0xA)] ^ S6[g(z, 0xB)] ^ S7[g(z, 0x5)] ^ S8[g(z, 0x4)] ^ S6[g(z, 0x6)];
        K[2 + i * 16] = S5[g(z, 0xC)] ^ S6[g(z, 0xD)] ^ S7[g(z, 0x3)] ^ S8[g(z, 0x2)] ^ S7[g(z, 0x9)];
        K[3 + i * 16] = S5[g(z, 0xE)] ^ S6[g(z, 0xF)] ^ S7[g(z, 0x1)] ^ S8[g(z, 0x0)] ^ S8[g(z, 0xC)];

        printf("K[0]=%x, K[1]=%x, K[2]=%x, K[3]=%x\n", K[0 + i * 16], K[1 + i * 16], K[2 + i * 16], K[3 + i * 16]);

        x[0] = z[2] ^ S5[g(z, 0x5)] ^ S6[g(z, 0x7)] ^ S7[g(z, 0x4)] ^ S8[g(z, 0x6)] ^ S7[g(z, 0x0)];
        x[1] = z[0] ^ S5[g(x, 0x0)] ^ S6[g(x, 0x2)] ^ S7[g(x, 0x1)] ^ S8[g(x, 0x3)] ^ S8[g(z, 0x2)];
        x[2] = z[1] ^ S5[g(x, 0x7)] ^ S6[g(x, 0x6)] ^ S7[g(x, 0x5)] ^ S8[g(x, 0x4)] ^ S5[g(z, 0x1)];
        x[3] = z[3] ^ S5[g(x, 0xA)] ^ S6[g(x, 0x9)] ^ S7[g(x, 0xB)] ^ S8[g(x, 0x8)] ^ S6[g(z, 0x3)];

        K[4 + i * 16] = S5[g(x, 0x3)] ^ S6[g(x, 0x2)] ^ S7[g(x, 0xC)] ^ S8[g(x, 0xD)] ^ S5[g(x, 0x8)];
        K[5 + i * 16] = S5[g(x, 0x1)] ^ S6[g(x, 0x0)] ^ S7[g(x, 0xE)] ^ S8[g(x, 0xF)] ^ S6[g(x, 0xD)];
        K[6 + i * 16] = S5[g(x, 0x7)] ^ S6[g(x, 0x6)] ^ S7[g(x, 0x8)] ^ S8[g(x, 0x9)] ^ S7[g(x, 0x3)];
        K[7 + i * 16] = S5[g(x, 0x5)] ^ S6[g(x, 0x4)] ^ S7[g(x, 0xA)] ^ S8[g(x, 0xB)] ^ S8[g(x, 0x7)];

        printf("K[4]=%x, K[5]=%x, K[6]=%x, K[7]=%x\n", K[4 + i * 16], K[5 + i * 16], K[6 + i * 16], K[7 + i * 16]);

        z[0] = x[0] ^ S5[g(x, 0xD)] ^ S6[g(x, 0xF)] ^ S7[g(x, 0xC)] ^ S8[g(x, 0xE)] ^ S7[g(x, 0x8)];
        z[1] = x[2] ^ S5[g(z, 0x0)] ^ S6[g(z, 0x2)] ^ S7[g(z, 0x1)] ^ S8[g(z, 0x3)] ^ S8[g(x, 0xA)];
        z[2] = x[3] ^ S5[g(z, 0x7)] ^ S6[g(z, 0x6)] ^ S7[g(z, 0x5)] ^ S8[g(z, 0x4)] ^ S5[g(x, 0x9)];
        z[3] = x[1] ^ S5[g(z, 0xA)] ^ S6[g(z, 0x9)] ^ S7[g(z, 0xB)] ^ S8[g(z, 0x8)] ^ S6[g(x, 0xB)];

        K[8 + i * 16] = S5[g(z, 0x3)] ^ S6[g(z, 0x2)] ^ S7[g(z, 0xC)] ^ S8[g(z, 0xD)] ^ S5[g(z, 0x9)];
        K[9 + i * 16] = S5[g(z, 0x1)] ^ S6[g(z, 0x0)] ^ S7[g(z, 0xE)] ^ S8[g(z, 0xF)] ^ S6[g(z, 0xC)];
        K[10 + i * 16] = S5[g(z, 0x7)] ^ S6[g(z, 0x6)] ^ S7[g(z, 0x8)] ^ S8[g(z, 0x9)] ^ S7[g(z, 0x2)];
        K[11 + i * 16] = S5[g(z, 0x5)] ^ S6[g(z, 0x4)] ^ S7[g(z, 0xA)] ^ S8[g(z, 0xB)] ^ S8[g(z, 0x6)];

        printf("K[8]=%x, K[9]=%x, K[10]=%x, K[11]=%x\n", K[8 + i * 16], K[9 + i * 16], K[10 + i * 16], K[11 + i * 16]);

        x[0] = z[2] ^ S5[g(z, 0x5)] ^ S6[g(z, 0x7)] ^ S7[g(z, 0x4)] ^ S8[g(z, 0x6)] ^ S7[g(z, 0x0)];
        x[1] = z[0] ^ S5[g(x, 0x0)] ^ S6[g(x, 0x2)] ^ S7[g(x, 0x1)] ^ S8[g(x, 0x3)] ^ S8[g(z, 0x2)];
        x[2] = z[1] ^ S5[g(x, 0x7)] ^ S6[g(x, 0x6)] ^ S7[g(x, 0x5)] ^ S8[g(x, 0x4)] ^ S5[g(z, 0x1)];
        x[3] = z[3] ^ S5[g(x, 0xA)] ^ S6[g(x, 0x9)] ^ S7[g(x, 0xB)] ^ S8[g(x, 0x8)] ^ S6[g(z, 0x3)];

        K[12 + i * 16] = S5[g(x, 0x8)] ^ S6[g(x, 0x9)] ^ S7[g(x, 0x7)] ^ S8[g(x, 0x6)] ^ S5[g(x, 0x3)];
        K[13 + i * 16] = S5[g(x, 0xA)] ^ S6[g(x, 0xB)] ^ S7[g(x, 0x5)] ^ S8[g(x, 0x4)] ^ S6[g(x, 0x7)];
        K[14 + i * 16] = S5[g(x, 0xC)] ^ S6[g(x, 0xD)] ^ S7[g(x, 0x3)] ^ S8[g(x, 0x2)] ^ S7[g(x, 0x8)];
        K[15 + i * 16] = S5[g(x, 0xE)] ^ S6[g(x, 0xF)] ^ S7[g(x, 0x1)] ^ S8[g(x, 0x0)] ^ S8[g(x, 0xD)];

        printf("K[12]=%x, K[13]=%x, K[14]=%x, K[15]=%x\n", K[12 + i * 16], K[13 + i * 16], K[14 + i * 16], K[15 + i * 16]);
    }

    uint32_t *L = (uint32_t *)malloc((ROUND_COUNT + 1) * sizeof(uint32_t));
    if (L == NULL) {
        printf("Memory allocation failed\n");
        free(K);
        return data; // Return early if memory allocation fails
    }
    printf("Got here\n");

    L[0] = data.msb;
    printf("L[0] = %x\n", L[0]);

    uint32_t *R = (uint32_t *)malloc((ROUND_COUNT + 1) * sizeof(uint32_t));
    if (R == NULL) {
        printf("Memory allocation failed\n");
        free(K);
        free(L);
        return data; // Return early if memory allocation fails
    }
    
    memset(R, 0, (ROUND_COUNT + 1) * sizeof(uint32_t));
    printf("but not here\n");

    R[0] = data.lsb;
    printf("R[0] = %x\n", R[0]);

    for (int i = 0; i < ROUND_COUNT; ++i)
    {
        int rIndex = reverse ? (ROUND_COUNT - 1 - i) : i;
        uint32_t Kmi = K[rIndex];
        uint8_t Kri = K[16 + rIndex] & 0x1F;

        uint32_t I = 0;
        uint32_t f = 0;

        uint8_t Ia, Ib, Ic, Id;
        printf("switching\n");

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
    printf("ROUND_COUNT\n");

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
  printf("encrypt\n");
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
void doGPG() {
  testVector();
}