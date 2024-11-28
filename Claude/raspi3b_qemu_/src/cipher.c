
#include "memory.h"
#include "filter.h"
#include "libgcrypt.h"
#include "packet.h"
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


static void
write_cfb_header (cipher_filter_context_t *cfx, iobuf_t a)
{
  log_info ("write_cfb_header\n");
  int err;
  PACKET pkt;
  PKT_encrypted ed;
  byte temp[18];
  unsigned int blocksize;
  unsigned int nprefix;

  blocksize = openpgp_cipher_get_algo_blklen (cfx->dek->algo);
  if ( blocksize < 8 || blocksize > 16 )
    log_fatal ("unsupported blocksize %u\n", blocksize);

  memset (&ed, 0, sizeof ed);
  ed.len = cfx->datalen;
  ed.extralen = blocksize + 2;
  ed.new_ctb = !ed.len;
  // if (cfx->dek->use_mdc)
  //   {
  //     ed.mdc_method = DIGEST_ALGO_SHA1;
  //     gcry_md_open (&cfx->mdc_hash, DIGEST_ALGO_SHA1, 0);
  //     if (DBG_HASHING)
  //       gcry_md_debug (cfx->mdc_hash, "creatmdc");
  //   }
  // else{}
    /*
      log_info (_("WARNING: "
                  "encrypting without integrity protection is dangerous\n"));
      log_info (_("Hint: Do not use option %s\n"), "--rfc2440");
    }*/

  // write_status_printf (STATUS_BEGIN_ENCRYPTION, "%d %d",
  //                      ed.mdc_method, cfx->dek->algo);

  init_packet (&pkt);
  log_info("use_mdc %d", cfx->dek->use_mdc);
  pkt.pkttype = //cfx->dek->use_mdc? PKT_ENCRYPTED_MDC :
   PKT_ENCRYPTED;
  pkt.pkt.encrypted = &ed;
  if (build_packet( a, &pkt))
    log_bug ("build_packet(ENCR_DATA) failed\n");
  nprefix = blocksize;
  // gcry_randomize (temp, nprefix, GCRY_STRONG_RANDOM );
  log_info("Fixing random %d bytes\n", nprefix);
  const unsigned char fixed_random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}; // Example fixed bytes
memcpy(temp, fixed_random, nprefix);
  temp[nprefix] = temp[nprefix-2];
  temp[nprefix+1] = temp[nprefix-1];
    log_printhex (temp, nprefix+2, "RANDOM:");
  print_cipher_algo_note (cfx->dek->algo);
  // err = openpgp_cipher_open (&cfx->cipher_hd,
  //                            cfx->dek->algo,
  //                            GCRY_CIPHER_MODE_CFB,
  //                            (GCRY_CIPHER_SECURE
  //                             | ((cfx->dek->use_mdc || cfx->dek->algo >= 100)?
  //                                0 : GCRY_CIPHER_ENABLE_SYNC)));
  // if (err)
  //   {
  //     /* We should never get an error here cause we already checked,
  //      * that the algorithm is available.  */
  //     BUG();
  //   }
    log_printhex (cfx->dek->key, cfx->dek->keylen, "KEY:");
  gcry_cipher_setkey (cfx->cipher_hd, cfx->dek->key, cfx->dek->keylen);
  gcry_cipher_setiv (cfx->cipher_hd, NULL, 0);

    log_printhex (cfx->startiv, nprefix+2, "IV:");
  if (cfx->mdc_hash) /* Hash the "IV". */{
    log_info("Hashing IV\n");
    gcry_md_write (cfx->mdc_hash, temp, nprefix+2 );
  }

      log_info("Encrypting: %d bytes\n", nprefix+2);
    log_printhex (temp, nprefix+2, "TO ENCRYPT:");
  gcry_cipher_encrypt (cfx->cipher_hd, temp, nprefix+2, NULL, 0);
  // log_info("TEMP:");
    log_printhex (temp, nprefix+2, "ENCRYPTED:");

  // log_info("gcry_cipher_sync:");
  gcry_cipher_sync (cfx->cipher_hd);
  iobuf_write (a, temp, nprefix+2);
  // log_hexdump (a->d.buf,nprefix+2);


  cfx->short_blklen_warn = (blocksize < 16);
  // log_info("short_blklen_warn: %d\n", cfx->short_blklen_warn);
  cfx->short_blklen_count = nprefix+2;
  // log_info("short_blklen_count: %d\n", cfx->short_blklen_count);

  cfx->wrote_header = 1;
}
