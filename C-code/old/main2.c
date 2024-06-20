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

static void
print_hex(const char *text, const void *buf, size_t n)
{
  const unsigned char *p = buf;

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

struct Block {
  uint32_t msb, lsb
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
  *Id = (I)&0xFF;
}

// Need to swap this out for 32bits
static const uint64_t MOD_2_32 = (uint64_t)2 << 31;

static uint32_t sumMod2_32(uint32_t a, uint32_t b)
{
  return (((uint64_t)a) + (uint64_t)b) % MOD_2_32;
}

static uint32_t subtractMod2_32(uint32_t a, uint32_t b)
{
  if (b <= a)
  {
    return a - b;
  }

  return (MOD_2_32 + a) - b;
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

static Block run(const Key key, Block msg, int reverse)
{
  // uint32_t MSB = data >> 32;
  // uint32_t LSB = data;
  /// Message msg = {MSB, LSB};
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
  L[0] = msg[0];

  uint32_t R[ROUND_COUNT + 1] = {0};
  // memset( R, 0, (ROUND_COUNT + 1)*(ROUND_COUNT + 1)*sizeof(uint32_t) );
  R[0] = msg[1];

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

  msg[0] = R[ROUND_COUNT];
  msg[1] = L[ROUND_COUNT];
  // printf("b: %08x%08x\n",msg[0],msg[1]);
  // uint64_t encrypted = (uint64_t)msg[0] << 32 | msg[1];

  // return msg;
}

void encrypt(const Key key, Block data)
{
  // printf("encrypting: %016lX\n", (long unsigned int)data);
  // return 
  run(key, data, FALSE);
}

uint64_t decrypt(const Key key, Block data)
{
  // printf("decrypting: %016lX\n", (long unsigned int)data);
  // return
  run(key, data, TRUE);
}


// Feistel Cast-128 (Cast-5) test vector test function
void testVector()
{
  int testPassing = 1;
  Key KEY = {0x01234567, 0x12345678, 0x23456789, 0x3456789A};
  Block msg = { msb.0x01234567, 0x89ABCDEF };
  encrypt(KEY, msg);
  // printf("encrypted: %016lX\n", (long unsigned int)block);
  testPassing = msg[0] == 0x238B4FE5 && msg[1] == 0x847E44B2;
  decrypt(KEY, msg);
  // printf("decrypted: %016lX\n", (long unsigned int)block);
  testPassing =  msg[0] == 0x01234567 && msg[1] == 0x89ABCDEF;
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

int parseGPGFile(u_int8_t *data, uint8_t *salt, int *offset)
{
  // int offset = 0;
  int dataLength = strlen((const char *)data);
  printf("parseGPGFile len: %i\n", dataLength);
  // print("GpgData: ", data);
  u_int8_t gpgPacket = data[(*offset)++];
  u_int8_t packetLen = data[(*offset)++];
  u_int8_t version = data[(*offset)++];
  u_int8_t algo = data[(*offset)++];
  u_int8_t s2k = data[(*offset)++];
  u_int8_t hashAlgo = data[(*offset)++];
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
char *testAAA = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
const char *testPassphrase = "password";
/* ===========================================================================
 * Test deflate() with small buffers
 */
size_t test_deflate(compr, comprLen, dataFromHex, compressed)
Byte *compr;
uLong comprLen;
uint8_t *dataFromHex;
uint8_t *compressed;
{
  z_stream c_stream; /* compression stream */
  int err;
  // AC92620B746573744141412E74787462FD651041414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410A
  // AC92620B746573744141412E74787462FD651041414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410A
  uLong len = (uLong)strlen((const char *)dataFromHex);

  c_stream.zalloc = zalloc;
  c_stream.zfree = zfree;
  c_stream.opaque = (voidpf)0;

  err = // deflateInit(&c_stream, Z_DEFAULT_COMPRESSION);
      deflateInit2(&c_stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED,
                   -13, 8, Z_DEFAULT_STRATEGY);
  CHECK_ERR(err, "deflateInit");

  c_stream.next_in = (z_const unsigned char *)dataFromHex;
  c_stream.next_out = compr;
  
  while (c_stream.total_in != len && c_stream.total_out < comprLen)
  {
    c_stream.avail_in = c_stream.avail_out = 1; /* force small buffers */
    err = deflate(&c_stream, Z_NO_FLUSH);
    CHECK_ERR(err, "deflate");
  }
  /* Finish the stream, still forcing small buffers: */
  for (;;)
  {
    c_stream.avail_out = 1;
    err = deflate(&c_stream, Z_FINISH);
    if (err == Z_STREAM_END)
      break;
    CHECK_ERR(err, "deflate");
  }

  err = deflateEnd(&c_stream);
  for (int i = 0; i < c_stream.total_out; i++)
  {
    compressed[i] = (uint8_t)compr[i];
  }
  CHECK_ERR(err, "deflateEnd");

  size_t count = c_stream.total_out;
  return count;
}
/* ===========================================================================
 * Test inflate() with small buffers
 */
void test_inflate(compr, comprLen, uncompr, uncomprLen, uncompressed)
    Byte *compr,
    *uncompr;
uLong comprLen, uncomprLen;
uint8_t *uncompressed;
{
  print_hex("test_inflate: ",compr,comprLen);
  printf("comprLen: %ld, uncomprLen: %ld\n",comprLen,uncomprLen);
  int err;
  z_stream d_stream; /* decompression stream */

  strcpy((char *)uncompr, "garbage");

  d_stream.zalloc = zalloc;
  d_stream.zfree = zfree;
  d_stream.opaque = (voidpf)0;

  d_stream.next_in = compr;
  d_stream.avail_in = 0;
  d_stream.next_out = uncompr;

  err =                       // inflateInit(&d_stream);
      inflateInit2(&d_stream, // Z_DEFAULT_COMPRESSION, Z_DEFLATED,
                   -13);      //, 8, Z_DEFAULT_STRATEGY);
  CHECK_ERR(err, "inflateInit");

  while (d_stream.total_out < uncomprLen && d_stream.total_in < comprLen)
  {
    d_stream.avail_in = d_stream.avail_out = 1; /* force small buffers */
    err = inflate(&d_stream, Z_NO_FLUSH);
    if (err == Z_STREAM_END)
      break;
    CHECK_ERR(err, "inflate");
  }

  err = inflateEnd(&d_stream);
  CHECK_ERR(err, "inflateEnd");

  // if (strcmp((char *)uncompr, (const char *)uncompressed))
  // {
  //   fprintf(stderr, "bad inflate\n");
  //   exit(1);
  // }
  // else
  {
    printf("inflate(): %s\n", (char *)uncompr);
  }
}

char *genRandomBytes(int count)
{
  char *stream = malloc(count);
  for (int i = 0; i < count; i++)
    stream[i] = rand();
  return stream;
}

uint8_t *bytesFrom64(uint64_t block)
{
  uint8_t *bytes = malloc((sizeof(uint8_t)) * 8);
  bytes[7] = (block & 0x00000000000000FFull) >> 0;
  bytes[6] = (block & 0x000000000000FF00ull) >> 8;
  bytes[5] = (block & 0x0000000000FF0000ull) >> 16;
  bytes[4] = (block & 0x00000000FF000000ull) >> 24;
  bytes[3] = (block & 0x000000FF00000000ull) >> 32;
  bytes[2] = (block & 0x0000FF0000000000ull) >> 40;
  bytes[1] = (block & 0x00FF000000000000ull) >> 48;
  bytes[0] = (block & 0xFF00000000000000ull) >> 56;
  return bytes;
}

Message messageFromBytes(uint8_t *bytes)
{
  Message block;
  for (int i = 0; i < 8; i++)
    block Message[i<4?0:1][i<4?i:i-4] = (block << 8) | bytes[i];
  return block;
}

uint64_t xorBlock(uint64_t block, uint64_t val)
{
  return (block ^ val);
}

void appendBytes(uint8_t *outbuf, int offset, uint8_t *bytes, int len)
{
  for (int i = 0; i < len; i++)
  {
    outbuf[i + offset] = bytes[i];
  }
}

void appendBytes2(uint8_t *outbuf, int offset, char *bytes, int len)
{
  for (int i = 0; i < len; i++)
  {
    outbuf[i + offset] = bytes[i];
  }
}

typedef enum
{
  PKT_SYMKEY_ENC = 3, /* Session key packet. */
  PKT_ENCRYPTED = 9,  /* Conventional encrypted data. */
  PKT_PLAINTEXT = 11, /* Literal data packet. */
  PKT_COMPRESSED = 8, /* Compressed data packet. */
} pkttype_t;

// taken and modified from gpg/g10/build-packet.c
int write_header2(uint8_t *out, int ctb, uint32_t len, int hdrlen, int offset)
{
  printf("write_header2 ctb %02x len %d hdrlen %d\n", ctb, len, hdrlen);
  /*if( ctb & 0x40 )
    return write_new_header( out, ctb, len, hdrlen );*/

  /*if( hdrlen )
    {
      if( hdrlen == 2 && len < 256 )
  ;
      else if( hdrlen == 3 && len < 65536 )
  ctb |= 1;
      else
  ctb |= 2;
    }
  else
    {*/
  if (!len)
    ctb |= 3;
  else if (len < 256)
    ;
  else if (len < 65536)
    ctb |= 1;
  else
    ctb |= 2;
  //}

  printf("dataLen CTB: %02X\n", ctb);
  /*if( iobuf_put(out, ctb ) )
    return -1;*/
  out[offset++] = ctb;

  if (len || hdrlen)
  {
    if (ctb & 2)
    {
      // if(iobuf_put(out, len >> 24 ))
      //   return -1;
      out[offset++] = len >> 24;

      // if(iobuf_put(out, len >> 16 ))
      //   return -1;
      out[offset++] = len >> 16;
    }

    if (ctb & 3)
      // if(iobuf_put(out, len >> 8 ))
      //   return -1;

      out[offset++] = len >> 8;
    //     if( iobuf_put(out, len ) )
    // return -1;
    out[offset++] = len;
  }
  print_hex("out: ",out,offset);
  return offset;
}
// taken and modified from libgcrypt
static uint8_t *
do_cfb_encrypt(Key key, uint8_t *iv, uint8_t *lastiv, size_t blocksize, uint8_t *outbuf, const uint8_t *inbuf, unsigned nbytes)
{
  int totalIn = nbytes;
  uint8_t *encrypted = malloc(sizeof(uint8_t) * nbytes);
  int encCount = 0;
  /*print_hex("iv: ", iv, 8);
  print_hex("lastiv: ", lastiv, 8);
  print_hex("inbuf: ", inbuf, nbytes);*/
  printf("do_cfb_encrypt\n");
  uint8_t *ivp;

  uint8_t *blockPtr;
  blockPtr = outbuf;
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

  /* Now we can process complete blocks. */
  while (nbytes >= blocksize)
  {
    printf("while\n");
    print_hex("in: \n", inbuf, blocksize);
    blockPtr = outbuf;
    int i;
    /* Encrypt the IV (and save the current one). */
    memcpy(lastiv, iv, blocksize);
    uint64_t ivEncrypted = encrypt(key, messageFromBytes(iv));
    iv = bytesFrom64(ivEncrypted);
    // c->cipher->encrypt ( &c->context.c, c->iv, c->iv );
    print_hex("encrypted iv: \n", &ivEncrypted, blocksize);

    /* XOR the input with the IV and store input into IV */
    for (ivp = iv, i = 0; i < blocksize; i++)
    {
      uint8_t b = (*ivp++ ^= *inbuf++);
      *outbuf++ = b;
      encrypted[encCount++] = b;
    }
    nbytes -= blocksize;
    print_hex("block: \n", blockPtr, blocksize);
  }
  if (nbytes)
  { /* process the remaining bytes */
    printf("nbytes\n");
    print_hex("in: \n", inbuf, blocksize);

    blockPtr = outbuf;
    /* encrypt the IV (and save the current one) */
    memcpy(lastiv, iv, blocksize);
    uint64_t ivEncrypted = encrypt(key, (uint64_t *)messageFromBytes(iv));
    iv = bytesFrom64(ivEncrypted);
    // c->unused = blocksize;
    /* and apply the xor */
    // c->unused -= nbytes;
    for (ivp = iv; nbytes; nbytes--)
    {
      uint8_t b = (*ivp++ ^= *inbuf++);
      *outbuf++ = b;
      encrypted[encCount++] = b;
    }

    print_hex("block: \n", blockPtr, blocksize);
  }
  print_hex("total encrypted: \n", encrypted, totalIn);
  return encrypted;
}

// Generate Key
int keySize = 16;
int blocksize = 8;

uint8_t *encryptToGPGFormat(const char *data, const char *filename, const char *passphrase)
{
  int totalDataLen = strlen(data) + 1; // Will compress to be smaller
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
  print_hex("Salt: ", salt, 8);
  for (int i = 0; i < 8; i++)
  {
    encryptedGpgFile[offset++] = salt[i];
  }
  int s2kCount = 255;
  encryptedGpgFile[offset++] = s2kCount; // s2key count
  print_hex("Header: ", encryptedGpgFile, offset);

  const unsigned char *decryptionKey = passphraseStringToKey(passphrase, salt, s2kCount);
  Key key = {0, 0, 0, 0};
  int j = 0;
  for (int i = 0; i < 4; i++)
  {
    key[i] = (decryptionKey[j] << 24) + (decryptionKey[j + 1] << 16) + (decryptionKey[j + 2] << 8) + decryptionKey[j + 3];
    // printUint32Hex(key[i]);
    j += 4;
  }
  print_hex("Key: ", decryptionKey, keySize);

  // Initialise cipher
  // Step by step, here is the procedure:

  //    1.  The feedback register (FR) is set to the IV, which is all zeros.
  // unsigned char* iv = malloc(blocksize);
  uint64_t iv = 0x0000000000000000;
  printf("iv: %016lX\n", (uint64_t)iv);
  // uLong feedbackRegister = iv;
  // block = decrypt(KEY, block);
  uint64_t fr = iv;
  printf("fr: %016lX\n", (uint64_t)fr);

  //    2.  FR is encrypted to produce FRE (FR Encrypted).  This is the
  //        encryption of an all-zero value.
  // print_hex("encrypted: ",&encrypted, blocksize);

  uint64_t encrypted = encrypt(key, (uint64_t *)fr);
  // print_hex("encrypted: ", msgP, 8);
  printf("fre: %16lX\n", (uint64_t)encrypted);
  //    3.  FRE is xored with the first 8 octets of random data prefixed to
  //        the plaintext to produce C1-C8, the first 8 octets of ciphertext.

  unsigned char *randomHex = (unsigned char *)hex2str_alloc("9A28BF8A0047F43CF43C", count); // genRandomBytes(10); THEN DUPLICATE [6]=>[8] & [7]=>[9]
  print_hex("randomHex: ", randomHex, blocksize + 2);
  uint64_t freXored = xorBlock(encrypted, messageFromBytes((uint8_t *)randomHex));
  printf("freXored: %16lX\n", (uint64_t)freXored);

  int encOffset = 0;
  appendBytes(encryptedData, encOffset, bytesFrom64(freXored), 8);
  encOffset += 8;
  //    4.  FR is loaded with C1-C8.
  fr = freXored;
  printf("fr: %16lX\n", (uint64_t)fr);

  //    5.  FR is encrypted to produce FRE, the encryption of the first 8
  //        octets of ciphertext.
  encrypted = encrypt(key, (uint64_t *)fr);
  printf("encrypted: %16lX\n", (uint64_t)encrypted);

  //    6.  The left two octets of FRE get xored with the next two octets of
  //        data that were prefixed to the plaintext.  This produces C9-C10,
  //        the next two octets of ciphertext.
  uint8_t *encryptedBytes = bytesFrom64(encrypted);
  uint8_t *c9c10 = malloc(sizeof(uint8_t) * 2);
  c9c10[0] = encryptedBytes[0] ^ randomHex[8];
  c9c10[1] = encryptedBytes[1] ^ randomHex[9];
  printf("c9: %02x\n", c9c10[0]);
  printf("c10: %02x\n", c9c10[1]);
  appendBytes(encryptedData, encOffset, c9c10, 2);
  encOffset += 2;
  print_hex("ENCRYPTED DATA: ", encryptedData, encOffset);
  //    7.  (The resync step) FR is loaded with C3-C10.
  fr = messageFromBytes((uint8_t *)encryptedData + 2);
  printf("fr: %16lX\n", (uint64_t)fr);

  /*  if( new_ctb || pkttype > 15 ) // new format
  ctb = 0xc0 | (pkttype & 0x3f);
    else
  ctb = 0x80 | ((pkttype & 15)<<2);
  */

  // Now we compress the data
  // First we write PKT_PLAINTEXT
  /*
  CTB: AC
  pt->namelen: 11
  calc_plaintext: 92 // how to deal with greater ??? write_header2
  pt->mode 62,
  pt->namelen 0b

  filename (truncated to < 255)

  rc = write_32(out, pt->timestamp );
  62F435E5*/
  int compOffset = 0;
  uint8_t *dataToCompress = malloc(totalDataLen);
  print_hex("dataToCompress",dataToCompress,totalDataLen);
  compOffset = write_header2(dataToCompress, 0xAC, 146, 0, compOffset);
  uint8_t mode = 0x62;
  uint8_t namelen = strlen(filename);
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
  char *t = hex2str_alloc("62FD6510", count); // genRandomBytes(8);
// A3015B332989BB24B5B8C4D1D151AFA4A224E96FAA80E300032E060000
  appendBytes(dataToCompress, compOffset, (uint8_t *)t, 4); // filename
  compOffset += 4;

  appendBytes2(dataToCompress, compOffset, testAAA, totalDataLen);
  compOffset += totalDataLen;
  dataToCompress[compOffset - 1] = 0x0A; // for some reason need to swap null byte out for 0A
  print_hex("dataToCompress: ", dataToCompress, compOffset);

  Byte *compr, *uncompr;
  uLong comprLen = 10000 * sizeof(int); /* don't overflow on MSDOS */
  uLong uncomprLen = comprLen;
  static const char *myVersion = ZLIB_VERSION;

  if (zlibVersion()[0] != myVersion[0])
  {
    fprintf(stderr, "incompatible zlib version\n");
    exit(1);
  }
  else if (strcmp(zlibVersion(), ZLIB_VERSION) != 0)
  {
    fprintf(stderr, "warning: different zlib version\n");
  }

  printf("zlib version %s = 0x%04x, compile flags = 0x%lx\n",
         ZLIB_VERSION, ZLIB_VERNUM, zlibCompileFlags());

  compr = (Byte *)calloc((uInt)comprLen, 1);
  uncompr = (Byte *)calloc((uInt)uncomprLen, 1);
  /* compr and uncompr are cleared to avoid reading uninitialized
   * data and to ensure that uncompr compresses well.
   */
  if (compr == Z_NULL || uncompr == Z_NULL)
  {
    printf("out of memory\n");
    exit(1);
  }

  uint8_t *compressed = malloc(sizeof(uint8_t) * totalDataLen);

  size_t compressedLength = test_deflate(compr, comprLen, dataToCompress, compressed);
  printf("compressedLength: %ld\n",compressedLength);
  print_hex("compressed: ", compressed, compressedLength);
// A3015B332989BB24B5B8C4D1D151AFA4A224E96FAA80E30003
// A3015B332989BB24B5B8C4D1D151AFA4A224E96FAA80E300032E060000

// AC92620B746573744141412E74787462FD651041414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141410A
  test_inflate(compr, compressedLength, uncompr, uncomprLen, dataToCompress);

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
    uint8_t *headerCompressed = malloc((sizeof(uint8_t) * plusHeaderCount)); // packet + mode bytes + extra byte

  // We need to prepend the packet tag (A301)
  write_header2(headerCompressed, 0xA0, 0, 0, 0);
  headerCompressed[1] = 0x01; // compression mode ???
  for(int i = 0;i<compressedLength;i++)
    headerCompressed[i+2] = compressed[i];
  
  print_hex("headerCompressed: ", headerCompressed, plusHeaderCount);
  // 7a8d6533bcc7b9d408225d788e2faf027d5baa674bc97bd29c8c42b4a6a571189514fe361e
  uint8_t *encryptedCompressed = malloc((sizeof(uint8_t) * plusHeaderCount)); // packet + mode bytes + extra byte
  encryptedCompressed = do_cfb_encrypt(key, bytesFrom64(fr), encryptedBytes, 8, encryptedCompressed, headerCompressed, plusHeaderCount);

  
  // Now we append all of this to the file header
  appendBytes(encryptedData, encOffset, encryptedCompressed, plusHeaderCount);
  encOffset += compressedLength;
  print_hex("ENCRYPTED DATA: ", encryptedData, strlen((const char *)encryptedData));

  printf("compressedLength: %ld\n", compressedLength);
  printf("offset: %d\n", offset);
  char *encryptedPacketTag = hex2str_alloc("c9", count);
  char pLen[10];

  sprintf(pLen, "%ld", compressedLength);
  char *packetLen = hex2str_alloc(pLen, count);
  appendBytes(encryptedGpgFile, offset++, (unsigned char *)encryptedPacketTag, 1);
  appendBytes(encryptedGpgFile, offset++, (uint8_t *)packetLen, 1);
  print_hex("encryptedGpgFile: ", encryptedGpgFile, encOffset + compressedLength);
  appendBytes(encryptedGpgFile, offset, encryptedData, strlen((const char *)encryptedData));

  print_hex("encryptedGpgFile: ", encryptedGpgFile, strlen((const char *)encryptedGpgFile));
  /*+  PKT_ENCRYPTED
    new_ctb 1
                CTB: C9
    write_header2 ctb c9 len 0 hdrlen 0
  */
  return encryptedGpgFile;
}

// // taken and modified from libgcrypt
static uint8_t *
do_cfb_decrypt(Key key, uint8_t *iv, uint8_t *lastiv, size_t blocksize, uint8_t *outbuf, const uint8_t *inbuf, unsigned nbytes, int unused){
// static void do_cfb_decrypt(gcry_cipher_hd_t c, byte *outbuf, const byte *inbuf, unsigned int nbytes)
  
  printf("do_cfb_decrypt\n");
  uint8_t *ivp;
  uint64_t temp;
    print_hex("BUF:",inbuf,nbytes);
  printf("blocksize:  %li\n",blocksize);
  printf("nbytes:  %i\n",nbytes);
  printf("unused:  %i\n",unused);

  int totalIn = nbytes;
  uint8_t *decrypted = malloc(sizeof(uint8_t) * nbytes);
  int decCount = 0; // change to dec count
  temp = messageFromBytes(outbuf);
  // taken directly frmo gcrypt skippiing unnecessary small input crap
  
  /* now we can process complete blocks */
  while (nbytes >= blocksize)
  {
  print_hex("LAST:\n",lastiv,blocksize);
  print_hex("IV:\n",iv,blocksize);
    int i;
    /* encrypt the IV (and save the current one) */
    memcpy(lastiv, iv, blocksize);
    uint64_t ivEncrypted = encrypt(key, (uint64_t *)messageFromBytes(iv));
    iv = bytesFrom64(ivEncrypted);

    /* XOR the input with the IV and store input into IV */
    for (ivp = iv, i = 0; i < blocksize; i++)
    {
      temp = *inbuf++;
      //*outbuf++ = *ivp ^ temp;
      uint8_t b = (*ivp ^ temp);
      *outbuf++ = b;
      decrypted[decCount++] = b;
      *ivp++ = temp;

    }
    nbytes -= blocksize;
  }
  if (nbytes)
  { /* process the remaining bytes */
    /* encrypt the IV (and save the current one) */
  print_hex("LAST:\n",lastiv,blocksize);
  print_hex("IV:\n",iv,blocksize);
    memcpy(lastiv, iv, blocksize);
    uint64_t ivEncrypted = encrypt(key, (uint64_t *)messageFromBytes(iv));
    iv = bytesFrom64(ivEncrypted);
    // encrypt(&c->context.c, c->iv, c->iv);
    // c->unused = blocksize;
    /* and apply the xor */
    // c->unused -= nbytes;
    for (ivp = iv; nbytes; nbytes--)
    {
      temp = *inbuf++;
      //*outbuf++ = *ivp ^ temp;
      uint8_t b = (*ivp ^ temp);
      *outbuf++ = b;
      decrypted[decCount++] = b;
      *ivp++ = temp;
    }
  } 
  print_hex("total decrypted: ", decrypted, totalIn);
  return decrypted;
}

uint8_t *decryptGPGFile(u_int8_t *fileData, const char *passphrase)
{

  int dataLen = strlen((const char *)fileData);
  printf("dataLen: %i\n", dataLen);
  uint8_t *salt = malloc(8);
  int o = 0;
  int *offset = &o;

  int s2kCount = parseGPGFile(fileData, salt, offset);
  print_hex("SALT: ", (const char *)salt, strlen((const char *)salt));

  printf("s2kCount: %i\n", s2kCount);

  uint8_t *decryptionKey = passphraseStringToKey(passphrase, (char *)salt, s2kCount);
  print_hex("decryptionKey: ", (const char *)decryptionKey, strlen((const char *)decryptionKey));

  printf("offset: %d\n", *offset);
  uint8_t encPacketTag = fileData[(*offset)++];
  printf("encPacketTag: %02X\n", encPacketTag);
  int encPacketLen = fileData[(*offset)++];
  printf("encPacketLen: %d\n", encPacketLen);

  Key key = {0, 0, 0, 0};
  int j = 0;
  for (int i = 0; i < 4; i++)
  {
    key[i] = (decryptionKey[j] << 24) + (decryptionKey[j + 1] << 16) + (decryptionKey[j + 2] << 8) + decryptionKey[j + 3];
    // printUint32Hex(key[i]);
    j += 4;
  }
  print_hex("Key: ", decryptionKey, keySize);

  int encryptedLen = dataLen - *offset;
  uint8_t *encryptedBytes = malloc((sizeof(uint8_t) * encryptedLen)); // packet + mode bytes + extra byte
  encryptedBytes = fileData+(*offset);
  print_hex("encryptedBytes: ", encryptedBytes, encryptedLen);

  uint8_t* prefixedData = malloc(sizeof(uint8_t) * 10);
  for(int i = 0;i<10;i++)
    prefixedData[i] = encryptedBytes[i];
  print_hex("prefixedData: ", prefixedData, 10);

  // uint64_t decrypted = decrypt(key, (uint64_t*)messageFromBytes(prefixedData));
  // printf("decrypted: %16lX\n", (uint64_t)decrypted);
  


  // Now we encrypt a zero value IV (as it is what we are expecting as the decryption of the first block)
  uint64_t iv = 0x0000000000000000;
  printf("iv: %016lX\n", (uint64_t)iv);
  uint64_t fr = iv;
  printf("fr: %016lX\n", (uint64_t)fr);
  uint64_t fre = encrypt(key, (uint64_t *)fr);
  printf("fre: %16lX\n", (uint64_t)fre);

  uint8_t *decryptedPrefix10Bytes = malloc((sizeof(uint8_t) * 10)); // packet + mode bytes + extra byte
  decryptedPrefix10Bytes = do_cfb_decrypt(key, bytesFrom64(iv), bytesFrom64(fr), blocksize, decryptedPrefix10Bytes, prefixedData, 10, 0);

  print_hex("decryptedPrefix10Bytes: ", decryptedPrefix10Bytes, 10);
  if(decryptedPrefix10Bytes[6]!=decryptedPrefix10Bytes[8] && 
    decryptedPrefix10Bytes[7]!=decryptedPrefix10Bytes[9])
    {
      printf("BAD KEY");
      exit(-1);
    }
  
  printf("CIPHER SYNC\n");
  // get first block
  // encrypt then overwrite the last two bytes

/*
  encrypting: 0000000000000000
  fre: EB7BA8BA520AD308
  randomHex: 9A28BF8A0047F43CF43C
  freXored: 71531730524D2734
  fr: 71531730524D2734
  encrypting: 71531730524D2734
  encrypted: 68A039AAEE6F7E3F
  c9: 9c
  c10: 9c
  ENCRYPTED DATA: 71531730524D27349C9C
  fr: 1730524D27349C9C
*/

  fr = messageFromBytes(encryptedBytes);
  //    5.  FR is encrypted to produce FRE, the encryption of the first 8
  //        octets of ciphertext.
  fre = encrypt(key, (uint64_t *)fr);
  printf("fre: %16lX\n", (uint64_t)fre);

  //    6.  The left two octets of FRE get xored with the next two octets of
  //        data that were prefixed to the plaintext.  This produces C9-C10,
  //        the next two octets of ciphertext.
  
  uint8_t *tmp = bytesFrom64(fre);
  tmp[0] = tmp[0] ^ decryptedPrefix10Bytes[8];
  tmp[1] = tmp[1] ^ decryptedPrefix10Bytes[9];
  printf("c9: %02x\n", tmp[0]);
  printf("c10: %02x\n", tmp[1]);
  print_hex("tmp: ", tmp, 8);

  //    7.  (The resync step) FR is loaded with C3-C10.
  // fr = messageFromBytes((uint8_t *)encryptedData + 2);

  uint64_t lastiv = fr;
  printf("lastiv: %16lX\n", (uint64_t)lastiv);
  
  uint8_t *newIv = malloc(8);
  for(int i=0;i<6;i++){
    newIv[i] = bytesFrom64(fr)[i+2];//:[]
  }
  newIv[6]=tmp[0];
  newIv[7]=tmp[1]; 
   printf("newIv: %16lX\n", messageFromBytes(newIv));

   // SYNC complete, decrypt the rest
   int remainingByteCount = encryptedLen-10;
  print_hex("encryptedBytes: ", encryptedBytes+10, remainingByteCount);

  uint8_t *decryptedCompressed = malloc((sizeof(uint8_t) *remainingByteCount )); // packet + mode bytes + extra byte
  decryptedCompressed = do_cfb_decrypt(key, newIv, bytesFrom64(lastiv), blocksize, decryptedCompressed, encryptedBytes+10, remainingByteCount, 0);

  print_hex("decryptedCompressed: ", decryptedCompressed, remainingByteCount);

  // READ HEADER HERE AND ADJUST FOR LENGTH
  // expecting compressed packet (zlib)
  // uint8_t *compressed = malloc((sizeof(uint8_t) *(remainingByteCount-2) ));


  Byte *compr, *uncompr;
  uLong comprLen = 10000 * sizeof(int); /* don't overflow on MSDOS */
  uLong uncomprLen = comprLen;
  static const char *myVersion = ZLIB_VERSION;

  if (zlibVersion()[0] != myVersion[0])
  {
    fprintf(stderr, "incompatible zlib version\n");
    exit(1);
  }
  else if (strcmp(zlibVersion(), ZLIB_VERSION) != 0)
  {
    fprintf(stderr, "warning: different zlib version\n");
  }

  printf("zlib version %s = 0x%04x, compile flags = 0x%lx\n",
         ZLIB_VERSION, ZLIB_VERNUM, zlibCompileFlags());

  compr = (Byte *)calloc((uInt)comprLen, 1);
  uncompr = (Byte *)calloc((uInt)uncomprLen, 1);
  /* compr and uncompr are cleared to avoid reading uninitialized
   * data and to ensure that uncompr compresses well.
   */
  if (compr == Z_NULL || uncompr == Z_NULL)
  {
    printf("out of memory\n");
    exit(1);
  }

  // uint8_t *decompressed = malloc(sizeof(uint8_t) * uncomprLen);
  /*
    size_t compressedLength = test_inflate(compr, comprLen, decryptedCompressed+2, compressed);
    printf("compressedLength: %ld\n",compressedLength);
    print_hex("compressed: ", compressed, compressedLength);
  */

  test_inflate(decryptedCompressed+2, remainingByteCount-2, uncompr, uncomprLen);
    printf("inflate2(): %s\n", (char *)uncompr);

  return prefixedData;
}

int main(int argc, char *argv[])
{
  testVector();
  // uint8_t *gpgFile = encryptToGPGFormat(testAAA, textAAAFilename, testPassphrase);
  // decryptGPGFile(gpgFile, testPassphrase);
  
  return 0;
}
