
#include "memory.h"
#include "filter.h"
#include "libgcrypt.h"
#include "packet.h"
#include "printf.h"


static void
write_cfb_header (cipher_filter_context_t *cfx, iobuf_t a)
{
  printf ("write_cfb_header\n");
  int err;
  PACKET pkt;
  PKT_encrypted ed;
  byte temp[18];
  unsigned int blocksize;
  unsigned int nprefix;

  blocksize = 8;// CAST5
  //openpgp_cipher_get_algo_blklen (cfx->dek->algo);
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
      printf (_("WARNING: "
                  "encrypting without integrity protection is dangerous\n"));
      printf (_("Hint: Do not use option %s\n"), "--rfc2440");
    }*/

  // write_status_printf (STATUS_BEGIN_ENCRYPTION, "%d %d",
  //                      ed.mdc_method, cfx->dek->algo);

  init_packet (&pkt);
  printf("use_mdc %d\n", cfx->dek->use_mdc);
  pkt.pkttype = //cfx->dek->use_mdc? PKT_ENCRYPTED_MDC :
   PKT_ENCRYPTED;
  pkt.pkt.encrypted = &ed;
  if (build_packet( a, &pkt))
    printf ("build_packet(ENCR_DATA) failed\n");
  nprefix = blocksize;
  // gcry_randomize (temp, nprefix, GCRY_STRONG_RANDOM );
  printf("Fixing random %d bytes\n", nprefix);
  const unsigned char fixed_random[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF}; // Example fixed bytes
memcpy(temp, fixed_random, nprefix);
  temp[nprefix] = temp[nprefix-2];
  temp[nprefix+1] = temp[nprefix-1];
  // log_printhex (temp, nprefix+2, "RANDOM:");
  // print_cipher_algo_note (cfx->dek->algo);
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
    //log_printhex (cfx->dek->key, cfx->dek->keylen, "KEY:");
  _gcry_cipher_setkey (cfx->cipher_hd, cfx->dek->key, cfx->dek->keylen);
  log_hexdump(&cfx->cipher_hd->key, 16);

  _gcry_cipher_setiv (cfx->cipher_hd, NULL, 8);

  log_hexdump(&cfx->cipher_hd->u_iv, 8);
  // if (cfx->mdc_hash) /* Hash the "IV". */{
  //   printf("Hashing IV\n");
  //   gcry_md_write (cfx->mdc_hash, temp, nprefix+2 );
  // }

      printf("Encrypting: %d bytes\n", nprefix+2);
    // log_printhex (temp, nprefix+2, "TO ENCRYPT:");
  _gcry_cipher_encrypt (cfx->cipher_hd, temp, nprefix+2, NULL, 0);
  // printf("TEMP:");
   // log_printhex (temp, nprefix+2, "ENCRYPTED:");

  // printf("gcry_cipher_sync:");
  cipher_sync (cfx->cipher_hd);
  iobuf_write (a, temp, nprefix+2);
  // log_hexdump (a->d.buf,nprefix+2);


  cfx->short_blklen_warn = (blocksize < 16);
  // printf("short_blklen_warn: %d\n", cfx->short_blklen_warn);
  cfx->short_blklen_count = nprefix+2;
  // printf("short_blklen_count: %d\n", cfx->short_blklen_count);

  cfx->wrote_header = 1;
}

int
_gcry_cipher_encrypt (gcry_cipher_hd_t h, void *out, size_t outsize,
                      const void *in, size_t inlen)
{
  printf("_gcry_cipher_encrypt inlen: %d, outSize: %d, unused: %d\n", inlen, outsize, h->unused);
  int rc;

  if (!in)  /* Caller requested in-place encryption.  */
    {
      // printf("Caller requested in-place encryption.");
      in = out;
      inlen = outsize;
      
    }
  // log_hexdump(in, inlen);

  // if (h->mode != GCRY_CIPHER_MODE_NONE && !h->marks.key)
  //   {
  //     log_error ("cipher_encrypt: key not set\n");
  //     return GPG_ERR_MISSING_KEY;
  //   }

  rc = _gcry_cipher_cfb_encrypt (h, out, outsize, in, inlen);

  /* Failsafe: Make sure that the plaintext will never make it into
     OUT if the encryption returned an error.  */
  if (rc && out)
    memset (out, 0x42, outsize);

  return rc;
}

int
cipher_filter_cfb (void *opaque, int control,
                   iobuf_t chain, byte *buf, size_t *len)
{
  printf("cipher_filter_cfb\n");
  cipher_filter_context_t *cfx = opaque;

  size_t size = *len;
  int rc = 0;
  printf("cipher_filter_cfb %d %d\n",control, cfx->wrote_header);
  // log_hexdump(buf, size);
  if (control == IOBUFCTRL_UNDERFLOW) /* decrypt */
    {
      // printf("IOBUFCTRL_UNDERFLOW\n");
      rc = -1; /* not used */
    }
  else if (control == IOBUFCTRL_FLUSH) /* encrypt */
    {
      printf("IOBUFCTRL_FLUSH\n");
      // log_assert (a);
      if (!cfx->wrote_header){
        //printf("write_cfb_header\n");
write_cfb_header (cfx, chain);

      }
        
      // if (cfx->mdc_hash){
      //   printf("Hashing mdc_hash\n");
      //   gcry_md_write (cfx->mdc_hash, buf, size);
      // }
      printf("Encrypting2: %d bytes\n", size);
          // log_printf("size: %d\n", size);
       //    log_printhex (buf, size, "TO ENCRYPT 2:");
          

      _gcry_cipher_encrypt (cfx->cipher_hd, buf, size, NULL, 0);
      if (cfx->short_blklen_warn)
        {
          cfx->short_blklen_count += size;
          // if (cfx->short_blklen_count > (150 * 1024 * 1024))
          //   {
          //     printf ("WARNING: encrypting more than %d MiB with algorithm "
          //               "%s should be avoided\n", 150,
          //               openpgp_cipher_algo_name (cfx->dek->algo));
          //     cfx->short_blklen_warn = 0; /* Don't show again.  */
          //   }
          // else {
          //  // printf("short_blklen_count: %d\n", cfx->short_blklen_count);
          // }
        }
      printf("short_blklen_count: %d\n", cfx->short_blklen_count);

      rc = iobuf_write (chain, buf, size);
    }
  else if (control == IOBUFCTRL_FREE)
    {
      printf("IOBUFCTRL_FREE\n");
  //     if (cfx->mdc_hash)
  //       {
  //         byte *hash;
  //         int hashlen = gcry_md_get_algo_dlen (gcry_md_get_algo(cfx->mdc_hash));
  //         byte temp[22];

  //         // log_assert (hashlen == 20);
  //         /* We must hash the prefix of the MDC packet here. */
  //         temp[0] = 0xd3;
  //         temp[1] = 0x14;
  //         gcry_md_putc (cfx->mdc_hash, temp[0]);
  //         gcry_md_putc (cfx->mdc_hash, temp[1]);

  //         gcry_md_final (cfx->mdc_hash);
  //         hash = gcry_md_read (cfx->mdc_hash, 0);
  //         memcpy(temp+2, hash, 20);
  //         printf("Encrypting3: %d bytes\n", 22);
  //         log_printhex (temp, 22, "TO ENCRYPT 3:");

  //         gcry_cipher_encrypt (cfx->cipher_hd, temp, 22, NULL, 0);
  //         gcry_md_close (cfx->mdc_hash); cfx->mdc_hash = NULL;
  //         if (iobuf_write( a, temp, 22))
  //           log_error ("writing MDC packet failed\n");
  //           else            printf ("writing MDC packet\n");

	// }

      _gcry_cipher_close (cfx->cipher_hd);
    }
  else if (control == IOBUFCTRL_DESC)
    {
      // printf("IOBUFCTRL_DESC\n");
     // mem2str (buf, "cipher_filter_cfb", *ret_len);
    }
    printf("cipher_filter_cfb RETURNING %d\n",rc);

  return rc;
}

