/* simplified_filter.h - Filter definitions for bare metal encryption */
#ifndef FILTER_H
#define FILTER_H

#include <stdint.h>
#include <stddef.h>
#include "common/iobuf.h"
#include "dek.h"
/* Basic type definitions */
typedef struct gcry_cipher_handle *gcry_cipher_hd_t;
typedef struct gcry_md_handle *gcry_md_hd_t;

// /* DEK (Data Encryption Key) structure */
// typedef struct {
//     byte *key;
//     size_t keylen;
//     int algo;           /* cipher algorithm */
//     int use_mdc;       /* flag for MDC */
//     int use_aead;      /* flag for AEAD (not used in CFB) */
// } DEK;

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

typedef struct {
    byte *buffer;	    /* malloced buffer */
    unsigned buffer_size;   /* and size of this buffer */
    unsigned buffer_len;    /* used length of the buffer */
    unsigned buffer_pos;    /* read position */
    int truncated;	    /* number of truncated lines */
    int not_dash_escaped;
    int escape_from;
    // gcry_md_hd_t md;
    int pending_lf;
    int pending_esc;
} text_filter_context_t;


/* Function declarations */
int cipher_filter_cfb(void *opaque, int control, 
                     iobuf_t chain, byte *buf, size_t *len);

/*-- textfilter.c --*/
int text_filter( void *opaque, int control,
		 iobuf_t chain, byte *buf, size_t *ret_len);
/* Basic iobuf operations needed */
int iobuf_write(iobuf_t a, const void *buffer, size_t length);
int iobuf_read(iobuf_t a, void *buffer, size_t length);

#endif /* FILTER_H */