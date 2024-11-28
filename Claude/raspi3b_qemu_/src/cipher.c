
#include "memory.h"
#include "filter.h"
#include "libgcrypt.h"
int cipher_filter_cfb(void *opaque, int control,
                     iobuf_t a, byte *buf, size_t *ret_len)
{
    cipher_filter_context_t *cfx = opaque;
    size_t size = *ret_len;
    int rc = 0;

    if (control == IOBUFCTRL_UNDERFLOW) {
        return -1;  /* not used */
    }
    else if (control == IOBUFCTRL_FLUSH) {
        if (!cfx->wrote_header) {
            byte temp[18];
            unsigned int blocksize = 8;  // CAST5 block size
            unsigned int nprefix = blocksize;

            // Fixed IV for testing
            const byte fixed_iv[] = {
                0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF
            };
            memcpy(temp, fixed_iv, nprefix);
            
            // Add redundancy bytes
            temp[nprefix] = temp[nprefix-2];
            temp[nprefix+1] = temp[nprefix-1];

            // Setup cipher context if not done
            if (!cfx->cipher_hd) {
                struct gcry_cipher_handle hd;
                cfx->cipher_hd = &hd;
                memset(cfx->cipher_hd, 0, sizeof(struct gcry_cipher_handle));
                
                // Set up cipher key
                Key *ctx_key = (Key *)&((struct gcry_cipher_handle*)cfx->cipher_hd)->context.c;
                for (int i = 0, j = 0; i < 4; i++, j += 4) {
                    (*ctx_key)[i] = (cfx->dek->key[j] << 24) | 
                                   (cfx->dek->key[j + 1] << 16) |
                                   (cfx->dek->key[j + 2] << 8) | 
                                   cfx->dek->key[j + 3];
                }
                
                // Initialize IV
                ((struct gcry_cipher_handle*)cfx->cipher_hd)->unused = 0;
                memset(((struct gcry_cipher_handle*)cfx->cipher_hd)->u_iv.iv, 0, 
                       sizeof(((struct gcry_cipher_handle*)cfx->cipher_hd)->u_iv.iv));
            }

            // Encrypt the header
            _gcry_cipher_cfb_encrypt(cfx->cipher_hd, temp, nprefix+2,
                                   temp, nprefix+2);

            rc = iobuf_write(a, temp, nprefix+2);
            if (rc) return rc;

            cipher_sync(cfx->cipher_hd);
            cfx->wrote_header = 1;
        }

        // Process main data if we have any
        if (size > 0) {
            _gcry_cipher_cfb_encrypt(cfx->cipher_hd, buf, size, buf, size);
            rc = iobuf_write(a, buf, size);
        }
    }
    else if (control == IOBUFCTRL_FREE) {
        // Clear any remaining cipher state
        if (cfx->cipher_hd) {
            cipher_sync(cfx->cipher_hd);
            memset(cfx->cipher_hd, 0, sizeof(struct gcry_cipher_handle));
            cfx->cipher_hd = NULL;
        }
        
        // Clear the context
        cfx->wrote_header = 0;
    }
    else if (control == IOBUFCTRL_DESC) {
        memcpy(buf, "cipher_filter_cfb", *ret_len < 16 ? *ret_len : 16);
    }

    return rc;
}