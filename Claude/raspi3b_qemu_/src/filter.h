/* simplified_filter.h - Filter definitions for bare metal encryption */
#ifndef SIMPLIFIED_FILTER_H
#define SIMPLIFIED_FILTER_H

#include <stdint.h>
#include <stddef.h>
#include "iobuf.h"
/* Basic type definitions */
typedef uint8_t byte;
typedef struct gcry_cipher_handle *gcry_cipher_hd_t;
typedef struct gcry_md_handle *gcry_md_hd_t;

/* DEK (Data Encryption Key) structure */
typedef struct {
    byte *key;
    size_t keylen;
    int algo;           /* cipher algorithm */
    int use_mdc;       /* flag for MDC */
    int use_aead;      /* flag for AEAD (not used in CFB) */
} DEK;

/* Cipher filter context */
typedef struct {
    /* Object with the key and algo */
    DEK *dek;

    /* Length of the data to encrypt */
    uint32_t datalen;

    /* The current cipher handle */
    gcry_cipher_hd_t cipher_hd;

    /* Processing flags */
    unsigned int wrote_header : 1;
    unsigned int short_blklen_warn : 1;
    unsigned long short_blklen_count;

    /* The hash context for MDC */
    gcry_md_hd_t mdc_hash;

    /* The start IV */
    byte startiv[16];

} cipher_filter_context_t;

/* Control values for filter operations */
#define IOBUFCTRL_UNDERFLOW  1
#define IOBUFCTRL_FLUSH      2
#define IOBUFCTRL_FREE       3
#define IOBUFCTRL_DESC       4

/* Function declarations */
int cipher_filter_cfb(void *opaque, int control, 
                     iobuf_t chain, byte *buf, size_t *ret_len);

/* Basic iobuf operations needed */
int iobuf_write(iobuf_t a, const void *buffer, size_t length);
int iobuf_read(iobuf_t a, void *buffer, size_t length);

#endif /* SIMPLIFIED_FILTER_H */