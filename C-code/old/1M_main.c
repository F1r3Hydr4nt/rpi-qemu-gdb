#include "stdio.h"
#include "sboxes.h"
#include "stdlib.h"
#include "string.h" // memcpy
#include "sha1.h"
#include <string.h>
#include <assert.h>
#include "zlib.h"
#include "ctype.h"
#include "time.h"
#include "sha256.h"

static void
print_hex(const char *text, const void *buf, size_t n)
{
  const unsigned char *p = buf;

  fputs(text, stdout);
  for (; n; n--, p++)
    printf("%02X", *p);
  putchar('\n');
}

static void
print_hex_startOffset(const char *text, const void *buf, size_t n, size_t offset)
{
  // printf("offset: %ld\n",offset);
  const unsigned char *p = buf;
  p+=offset;

  fputs(text, stdout);
  for (; n; n--, p++)
    printf("%02X", *p);
  putchar('\n');
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
// typedef uint32_t Message[MSG_LEN];

// I can't be arsed compiling to 64 bit 32 will do
// can be run on 32 & 64 bit ARM (rpi 1-> 4 ++) or compiled to any 32/64 bit cpu/fpga
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

// Need to take this out
static const uint64_t MOD_2_32 = (uint64_t)2 << 31;
static const uint32_t MOD_2_32_MINUS_1 = 0xFFFFFFFF;

static void printBlock(struct Block block){
  printf("%08X%08X\n", block.msb, block.lsb);
}

static void printBlock2(const char* prefix, struct Block block){
  printf("%s%08X%08X\n", prefix, block.msb, block.lsb);
}

static uint32_t sumMod2_32(uint32_t a, uint32_t b)
{
  // its just a remainder
  return ((a) + b) % MOD_2_32;
}

static uint32_t sumMod2_32b(uint32_t a, uint32_t b)
{

  return ((a) + b);// % MOD_2_32;

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

unsigned char *blockToChar(uint32_t val, uint32_t val2)
{
  unsigned char *res = malloc(8);
  unsigned char *v1 = uint32ToChar(val);
  unsigned char *v2 = uint32ToChar(val2);
  for (int i = 0; i < 8; i++)
    res[i] = i < 4 ? v1[i] : v2[i];
  return res;
}

void sha256SumData(uint8_t *input, uint32_t length){
  sha256_context ctx = {
    .total = {0},
    .state = {0},
    .buffer = {0}
  };
  sha256_starts(&ctx);
  sha256_update(&ctx,input,length);
  uint8_t digest [32] = {0x00};
  sha256_finish(&ctx,digest);
  printf("SHA256SUM:\n");
  for(int i = 0;i<32;i++){
    printf("%02X",digest[i]);
  }
  printf("\n");
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


// Feistel Cast-128 (Cast-5) test vector test function
void testVector()
{
  int testPassing = 1;
  Key KEY = {0x01234567, 0x12345678, 0x23456789, 0x3456789A};
  struct Block msg = {
    .msb = 0x01234567,
    .lsb = 0x89ABCDEF
  };
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
    exit(-1);
  }
}

void printUint32Hex(uint32_t data)
{
  printf("%08X\n", data);
}

// /*
// Byte 1: gpg packet tag
// Byte 2: packet length
// Byte 3: version tag
// Byte 4: algo
// Byte 5: s2k
// Byte 6: hash algo
// Byte 7 - 15: 8 byte salt
// Byte 16: count (hash algo iterations)
// Byte 17: gpg packet tag
// Byte 18: packet length
// */

int parseGPGFile(uint8_t *data, uint8_t *salt, int *offset)
{
  // int offset = 0;
  int dataLength = strlen((const char *)data);
  printf("parseGPGFile len: %i\n", dataLength);
  // print("GpgData: ", data);
  uint8_t gpgPacket = data[(*offset)++];
  uint8_t packetLen = data[(*offset)++];
  uint8_t version = data[(*offset)++];
  uint8_t algo = data[(*offset)++];
  uint8_t s2k = data[(*offset)++];
  uint8_t hashAlgo = data[(*offset)++];
  printf("gpg byte: %x\npacketLen: %i\nversion: %i\nalgo: %i\ns2k: %i\nhashAlgo: %i, (*offset) %i\n", gpgPacket, packetLen, version, algo, s2k, hashAlgo, (*offset));
  if (algo != 3 || s2k != 3 || hashAlgo != 2)
  {
    printf("This program only decrypts Cast-5 encrypted files\n");
    printf("with a salted and iterated string-to-key\n");
    printf("using SHA-1 as the hash algorithm.\n");
    exit(-1);
  }
  // Now parse the salt
  for (int i = 0; i < 8; i++)
  {
    salt[i] = data[(*offset)];
    (*offset)++;
  }
  int s2kCount = data[(*offset)];
  (*offset)++;
  data += (*offset);
  return s2kCount;
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
  unsigned char *key = malloc(16);
  unsigned char saltPlusPassphrase[sizeof(salt) + strlen(passphrase)];
  memcpy(saltPlusPassphrase, salt, strlen((const char *)(salt)));
  memcpy(saltPlusPassphrase + sizeof(salt), passphrase, strlen((const char *)passphrase));
  int octetExpansionCount = ((int32_t)16 + (count & 15)) << ((count >> 4) + EXPBIAS);
  int totalLen = sizeof(saltPlusPassphrase);
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
  // calculate hash
  SHA1(result, (char *)saltPlusPassphraseExpanded, strlen((char *)saltPlusPassphraseExpanded));

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
/*Appendix B. Test Vectors

   This appendix provides test vectors for the CAST-128 cipher described
   this document.

B.1. Single Plaintext-Key-Ciphertext Sets

   In order to ensure that the algorithm is implemented correctly, the
   following test vectors can be used for verification (values given in
   hexadecimal notation).

   128-bit key         = 01 23 45 67 12 34 56 78 23 45 67 89 34 56 78 9A
           plaintext   = 01 23 45 67 89 AB CD EF
           ciphertext  = 23 8B 4F E5 84 7E 44 B2

   80-bit  key         = 01 23 45 67 12 34 56 78 23 45
                       = 01 23 45 67 12 34 56 78 23 45 00 00 00 00 00 00
           plaintext   = 01 23 45 67 89 AB CD EF
           ciphertext  = EB 6A 71 1A 2C 02 27 1B

   40-bit  key         = 01 23 45 67 12
                       = 01 23 45 67 12 00 00 00 00 00 00 00 00 00 00 00
           plaintext   = 01 23 45 67 89 AB CD EF
           ciphertext  = 7A C8 16 D1 6E 9B 30 2E*/

#define CHECK_ERR(err, msg)                        \
  {                                                \
    if (err != Z_OK)                               \
    {                                              \
      fprintf(stderr, "%s error: %d\n", msg, err); \
      exit(1);                                     \
    }                                              \
  }
static alloc_func zalloc = (alloc_func)0;
static free_func zfree = (free_func)0;

// static z_const char hello[] = "hello, hello!";

#define digitp(p) (*(p) >= '0' && *(p) <= '9')

#define hexdigitp(a) (digitp(a) || (*(a) >= 'A' && *(a) <= 'F') || (*(a) >= 'a' && *(a) <= 'f'))

/* The atoi macros assume that the buffer has only valid digits. */
#define xtoi_1(p) (*(p) <= '9' ? (*(p) - '0') : *(p) <= 'F' ? (*(p) - 'A' + 10) \
                                                            : (*(p) - 'a' + 10))
#define xtoi_2(p) ((xtoi_1(p) * 16) + xtoi_1((p) + 1))

/* Convert HEXSTRING consisting of hex characters into string and
   store that at BUFFER.  HEXSTRING is either delimited by end of
   string or a white space character.  The function makes sure that
   the resulting string in BUFFER is terminated by a Nul character.
   BUFSIZE is the availabe length of BUFFER; if the converted result
   plus a possible required Nul character does not fit into this
   buffer, the function returns NULL and won't change the existing
   conent of buffer.  In-place conversion is possible as long as
   BUFFER points to HEXSTRING.

   If BUFFER is NULL and bufsize is 0 the function scans HEXSTRING but
   does not store anything.  This may be used to find the end of
   hexstring.

   On sucess the function returns a pointer to the next character
   after HEXSTRING (which is either end-of-string or a the next white
   space).  If BUFLEN is not NULL the strlen of buffer is stored
   there; this will even be done if BUFFER has been passed as NULL. */
const char *
hex2str(const char *hexstring, char *buffer, size_t bufsize, size_t *buflen)
{
  const char *s = hexstring;
  int idx, count;
  int need_nul = 0;

  if (buflen)
    *buflen = 0;

  for (s = hexstring, count = 0; hexdigitp(s) && hexdigitp(s + 1); s += 2, count++)
    ;
  if (*s && (!isascii(*s) || !isspace(*s)))
    return NULL; /* Not followed by Nul or white space.  */
  /* We need to append a nul character.  However we don't want that if
     the hexstring already ends with "00".  */
  need_nul = ((s == hexstring) || !(s[-2] == '0' && s[-1] == '0'));
  if (need_nul)
    count++;

  if (buffer)
  {
    if (count > bufsize)
      return NULL; /* Too long.  */

    for (s = hexstring, idx = 0; hexdigitp(s) && hexdigitp(s + 1); s += 2)
      ((unsigned char *)buffer)[idx++] = xtoi_2(s);
    if (need_nul)
      buffer[idx] = 0;
  }

  if (buflen)
    *buflen = count - 1;
  return s;
}

void *
gcry_malloc(size_t n)
{
  return malloc(n);
}
#define xtrymalloc(a) gcry_malloc((a))

/* Same as hex2str but this function allocated a new string.  Returns
   NULL on error.  If R_COUNT is not NULL, the number of scanned bytes
   will be stored there.  ERRNO is set on error. */
char *
hex2str_alloc(const char *hexstring, size_t *r_count)
{
  const char *tail;
  size_t nbytes;
  char *result;

  tail = hex2str(hexstring, NULL, 0, &nbytes);
  if (!tail)
  {
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

uint32_t stringTo32(unsigned char *bytes)
{
  return (bytes[0] << 24) + (bytes[1] << 16) + (bytes[2] << 8) + bytes[3];
}
char *textAAAFilename = "testAAA.txt";
// char *testAAA = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
char *testAAAHex = "41414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410a";
char *test1MFilename = "asdasd";