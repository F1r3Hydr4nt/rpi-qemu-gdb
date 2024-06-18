#include "mem.h"
#include "gpg.h"
#include "common.h"
#include "sboxes.h"
#include "printf.h"
#include "sha1.h"
// #include <stdio.h>
#include <ctype.h>

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

static void
print_hex(const char *text, const void *buf, size_t n)
{
  const unsigned char *p = buf;

  printf(text);
  for (; n; n--, p++)
    printf("%02X", *p);
  printf('\n');
}

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

size_t my_strlen(const char *str) {
    size_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}
// /*

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
    if (key == NULL) {
        printf("Memory allocation failed for key\n");
        return NULL;
    }

    size_t passphraseLen = my_strlen(passphrase);
    size_t saltLen = my_strlen((const char *)salt);

    // Ensure the salt length is at least 8
    if (saltLen < 8) {
        printf("Salt length is too short\n");
        free(key);
        return NULL;
    }

    unsigned char *saltPlusPassphrase = malloc(8 + passphraseLen);
    if (saltPlusPassphrase == NULL) {
        printf("Memory allocation failed for saltPlusPassphrase\n");
        free(key);
        return NULL;
    }

    memcpy(saltPlusPassphrase, salt, 8);
    memcpy(saltPlusPassphrase + 8, passphrase, passphraseLen);

    int octetExpansionCount = ((int32_t)16 + (count & 15)) << ((count >> 4) + EXPBIAS);
    int totalLen = 8 + passphraseLen;

    printf("octetExpansionCount: %d\ntotalLen: %d\n", octetExpansionCount, totalLen);

    // Use a smaller buffer for the expanded data
    unsigned char *expandedBuffer = malloc(totalLen);
    if (expandedBuffer == NULL) {
        printf("Memory allocation failed for expandedBuffer\n");
        free(key);
        free(saltPlusPassphrase);
        return NULL;
    }
    char result[20] = {0}; // Placeholder, implement actual hashing here

    // Expand the salt plus passphrase into the smaller buffer repeatedly
    int expandedBufferIndex = 0;
    for (int i = 0; i < octetExpansionCount; i++) {
        expandedBuffer[expandedBufferIndex] = saltPlusPassphrase[i % totalLen];
        expandedBufferIndex++;
        if (expandedBufferIndex == totalLen) {
            expandedBufferIndex = 0;
            // Example hash calculation per segment (implement actual hashing here)
            SHA1(result, (char *)expandedBuffer, totalLen);
        }
    }

    printf("Final buffer length: %d\n", octetExpansionCount);

    // Example final hash calculation (replace with actual hash function)
    // SHA1(result, (char *)expandedBuffer, totalLen);

    // Just a placeholder for actual hash, replace with real hash calculation

    for (size_t offset = 0; offset < 16; offset++) {
        key[offset] = result[offset];
    }

    // Free allocated memory
    free(saltPlusPassphrase);
    free(expandedBuffer);

    return key;
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
    
    // Free the allocated memory
    free(dataTest);
  } else {
    printf("Failed to decode hex string.\n");
  }

  size_t *count = 0;
  char *salt = hex2str_alloc("c99a13a5944b4f4a", count); // genRandomBytes(8);
 
  int s2kCount = 255;
  const unsigned char *decryptionKey = passphraseStringToKey(testPassphrase, salt, s2kCount);

}