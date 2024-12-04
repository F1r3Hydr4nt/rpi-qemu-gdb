// /* encrypt.c */
// #include "filter.h"
// #include "iobuf.h"
// #include "packet.h"
// #include "printf.h"
// #include "memory.h"
// #include "sha1.h"
// static uint8_t hex_digit(char h) {
//     if (h >= '0' && h <= '9') return h - '0';
//     if (h >= 'A' && h <= 'F') return h - 'A' + 10;
//     if (h >= 'a' && h <= 'f') return h - 'a' + 10;
//     return 0;
// }

// void hex_to_bytes(const char *hex, uint8_t *bytes, size_t length) {
//     for (size_t i = 0; i < length; i++) {
//         bytes[i] = (hex_digit(hex[i*2]) << 4) | hex_digit(hex[i*2 + 1]);
//     }
// }
// void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key);

// void derive_key(const uint8_t *salt, const char *password, unsigned int pass_len, uint32_t iterations, uint8_t *key)
// {
//     SHA1_CTX ctx;
//     SHA1Init(&ctx);
//     unsigned int bytesProcessed = 0;
//     unsigned int index = 0;
//     while (bytesProcessed < iterations)
//     {
//         uint8_t byte;
//         if (index < 8)
//         {
//             byte = salt[index];
//         }
//         else
//         {
//             byte = password[(index - 8) % pass_len];
//         }
//         SHA1Update(&ctx, &byte, 1);
//         bytesProcessed++;
//         index++;
//         if (index >= 8 + pass_len)
//         {
//             index = 0;
//         }
//     }
//     SHA1Final(key, &ctx);
// }

// DEK *
// passphrase_to_dek (int cipher_algo, STRING2KEY *s2k,
//                    int create, int nocache,
//                    const char *tryagain_text, unsigned int flags,
//                    int *canceled, const char *passphrase, const char* derivedKey)
// {
//   char *pw = NULL;
//   DEK *dek;
//   STRING2KEY help_s2k;
//   int dummy_canceled;
//   char s2k_cacheidbuf[1+16+1];
//   char *s2k_cacheid = NULL;

//   if (!canceled)
//     canceled = &dummy_canceled;
//   *canceled = 0;

//   // if (opt.no_symkey_cache)
//   //   nocache = 1;  /* Force no symmetric key caching.  */

//   // if ( !s2k )
//   //   {
//   //     log_assert (create && !nocache);
//   //     /* This is used for the old rfc1991 mode
//   //      * Note: This must match the code in encode.c with opt.rfc1991 set */
//   //     memset (&help_s2k, 0, sizeof (help_s2k));
//   //     s2k = &help_s2k;
//   //     s2k->hash_algo = S2K_DIGEST_ALGO;
//   //   }

//   /* Create a new salt or what else to be filled into the s2k for a
//      new key.  */
//   if (create && (s2k->mode == 1 || s2k->mode == 3))
//     {
//       // gcry_randomize (s2k->salt, 8, GCRY_STRONG_RANDOM);

//        printf("FIXING SALT VALUE\n");
//     s2k->salt[0] = 0x0a;
//     s2k->salt[1] = 0x0b;
//     s2k->salt[2] = 0x0c;
//     s2k->salt[3] = 0x0d;
//     s2k->salt[4] = 0x0e;
//     s2k->salt[5] = 0x0f;
//     s2k->salt[6] = 0x10;
//     s2k->salt[7] = 0x11;
//       if ( s2k->mode == 3 )
//         {
//           /* We delay the encoding until it is really needed.  This is
//              if we are going to dynamically calibrate it, we need to
//              call out to gpg-agent and that should not be done during
//              option processing in main().  */
//           // if (!opt.s2k_count)
//           //   opt.s2k_count = encode_s2k_iterations (0);
//           s2k->count = 0xFF;//opt.s2k_count;
//         }
//     }

//   // /* If we do not have a passphrase available in NEXT_PW and status
//   //    information are request, we print them now. */
//   // if ( !next_pw && is_status_enabled() )
//   //   {
//   //     char buf[50];

//   //     snprintf (buf, sizeof buf, "%d %d %d",
//   //               cipher_algo, s2k->mode, s2k->hash_algo );
//   //     write_status_text ( STATUS_NEED_PASSPHRASE_SYM, buf );
//   //   }

//   // if ( next_pw )
//   //   {
//   //     /* Simply return the passphrase we already have in NEXT_PW. */
//   //     pw = next_pw;
//   //     next_pw = NULL;
//   //   }
//   // else if ( have_static_passphrase () )
//   //   {
//   //     /* Return the passphrase we have stored in FD_PASSWD. */
//   //     pw = xmalloc_secure ( strlen(fd_passwd)+1 );
//   //     strcpy ( pw, fd_passwd );
//   //   }
//   // else
//   //   {
//   //     if (!nocache && (s2k->mode == 1 || s2k->mode == 3))
// 	// {
// 	//   memset (s2k_cacheidbuf, 0, sizeof s2k_cacheidbuf);
// 	//   *s2k_cacheidbuf = 'S';
// 	//   bin2hex (s2k->salt, 8, s2k_cacheidbuf + 1);
// 	//   s2k_cacheid = s2k_cacheidbuf;
// 	// }

//   //     if (opt.pinentry_mode == PINENTRY_MODE_LOOPBACK)
//   //       {
//   //         char buf[32];

//   //         snprintf (buf, sizeof (buf), "%u", 100);
//   //         write_status_text (STATUS_INQUIRE_MAXLEN, buf);
//   //       }

//   //     /* Divert to the gpg-agent. */
//   //     pw = passphrase_get (create, create && nocache, s2k_cacheid,
//   //                          create? opt.passphrase_repeat : 0,
//   //                          tryagain_text, flags, canceled);
//   //     if (*canceled)
//   //       {
//   //         xfree (pw);
// 	//   write_status( STATUS_CANCELED_BY_USER );
//   //         return NULL;
//   //       }
//   //   }

//   // if ( !pw || !*pw )
//   //   write_status( STATUS_MISSING_PASSPHRASE );

//   /* Hash the passphrase and store it in a newly allocated DEK object.
//      Keep a copy of the passphrase in LAST_PW for use by
//      get_last_passphrase(). */
//   dek = xmalloc_clear ( sizeof *dek );
//   dek->algo = cipher_algo;
//   // if ( (!pw || !*pw) && create)
//   //   dek->keylen = 0;
//   // else
//   //   {
//   //     int err;

//       dek->keylen = 16;// openpgp_cipher_get_algo_keylen (dek->algo);
//       // if (!(dek->keylen > 0 && dek->keylen <= DIM(dek->key)))
//       //   BUG ();
//   //     err = gcry_kdf_derive (pw, strlen (pw),
//   //                            s2k->mode == 3? GCRY_KDF_ITERSALTED_S2K :
//   //                            s2k->mode == 1? GCRY_KDF_SALTED_S2K :
//   //                            /* */           GCRY_KDF_SIMPLE_S2K,
//   //                            s2k->hash_algo, s2k->salt, 8,
//   //                            S2K_DECODE_COUNT(s2k->count),
//   //                            dek->keylen, dek->key);
//   //     if (err)
//   //       {
//   //         log_error ("gcry_kdf_derive failed: %s", gpg_strerror (err));
//   //         xfree (pw);
//   //         xfree (dek);
// 	//   write_status( STATUS_MISSING_PASSPHRASE );
//   //         return NULL;
//   //       }
//   // }
//   // if (s2k_cacheid)
//   //   memcpy (dek->s2k_cacheid, s2k_cacheid, sizeof dek->s2k_cacheid);
//   // xfree(last_pw);
//   // last_pw = pw;
//       uint32_t iterations = ((uint32_t)16 + (0xFF & 15)) << ((0xFF >> 4) + 6);
//   if(derivedKey){
//     printf("DERIVED: %s\n", derivedKey);
//     // Usage example:
// uint8_t key[dek->keylen];  // For SHA1 output
// hex_to_bytes(derivedKey, key, dek->keylen);
// memcpy(dek->key, key, dek->keylen);

//   }
//   else derive_key(s2k->salt, passphrase, strlen(passphrase), iterations, dek->key);
//     printf("DEK Information:\n");
//     printf("Algorithm: %d\n", dek->algo);
//     printf("Key Length: %d bytes\n", dek->keylen);
//     // printf("Algorithm Info Printed: %s\n", dek->algo_info_printed ? "Yes" : "No");
//     // printf("Use AEAD: %d\n", dek->use_aead);
//     // printf("Use MDC: %s\n", dek->use_mdc ? "Yes" : "No");
//     // printf("Symmetric: %s\n", dek->symmetric ? "Yes" : "No");
//     // log_hexdump( dek->key, dek->keylen);
//     printf("Key: ");
//     for (int i = 0; i < dek->keylen; i++) {
//        printf("%02x", dek->key[i]);
//     }
//     printf("\n");
//     // printf("S2K Cache ID: %s\n", dek->s2k_cacheid);
//   return dek;
// }

// PKT_plaintext *
// setup_plaintext_name (const char *filename, IOBUF iobuf)
// {
//   PKT_plaintext *pt;

//   // if ((filename && !iobuf_is_pipe_filename (filename))
//   //      || (opt.set_filename && !iobuf_is_pipe_filename (opt.set_filename)))
//   //   {
//   //     char *s;

//   //     if (opt.set_filename)
// 	// s = make_basename (opt.set_filename, iobuf_get_real_fname (iobuf));
//   //     else if (filename && !opt.flags.utf8_filename)
// 	// {
// 	//   char *tmp = native_to_utf8 (filename);
// 	//   s = make_basename (tmp, iobuf_get_real_fname (iobuf));
// 	//   xfree (tmp);
// 	// }
//   //     else
// 	// s = make_basename (filename, iobuf_get_real_fname (iobuf));

//   //     pt = xmalloc (sizeof *pt + strlen (s) - 1);
//   //     pt->namelen = strlen (s);
//   //     memcpy (pt->name, s, pt->namelen);
//   //     xfree (s);
//   //   }
//   // else
//   //   {
//       /* no filename */
//       pt = xmalloc (sizeof *pt - 1);
//       pt->namelen = 0;
//     // }

//   return pt;
// }


// int 
// setup_symkey (STRING2KEY **symkey_s2k, DEK **symkey_dek, const char *passphrase, const char *derivedKey)
// {
//   printf("setup_symkey\n");
//   int canceled;
//   int defcipher;
//   int s2kdigest;

//   defcipher = 0x03;//default_cipher_algo ();
//   /*  encryptedGpgFile[offset++] = 0x8c; // gpgPacket
//   encryptedGpgFile[offset++] = 0x0d; // packetLen
//   encryptedGpgFile[offset++] = 0x04; // version
//   encryptedGpgFile[offset++] = 0x03; // cipher algo cast5 (cast128)
//   encryptedGpgFile[offset++] = 0x03; // s2k salted and iterated hash
//   encryptedGpgFile[offset++] = 0x02; // hashAlgo sha1 only
//   // Generate a random salt*/

//   s2kdigest = 0x02; // SHA1 // S2K_DIGEST_ALGO;

//   *symkey_s2k = xmalloc_clear (sizeof **symkey_s2k);
//   (*symkey_s2k)->mode = 0x03;// opt.s2k_mode;
//   (*symkey_s2k)->hash_algo = s2kdigest;

//   *symkey_dek = passphrase_to_dek (defcipher,
//                                    *symkey_s2k, 1, 0, NULL, 0, &canceled, passphrase, derivedKey);
                                   
//   // if (!*symkey_dek || !(*symkey_dek)->keylen)
//   //   {
//   //     xfree(*symkey_dek);
//   //     xfree(*symkey_s2k);
//   //     return gpg_error (canceled?GPG_ERR_CANCELED:GPG_ERR_INV_PASSPHRASE);
//   //   }

//   return 0;
// }

// int open_outfile(int inp_fd, const char *iname, int mode, int restrictedperm, iobuf_t *a) {
//     int rc = 0;
//     *a = NULL;
    
//     printf("Opening outfile with: fd=%d, iname=%s, mode=%d\n", inp_fd, iname ? iname : "NULL", mode);

//     if (0){//inp_fd != -1) {
//         // printf("Path 1: Using file descriptor");
//         // char xname[64];
//         // *a = iobuf_fdopen_nc(inp_fd, "wb");
//         // if (!*a) {
//         //     rc = gpg_error_from_syserror();
//         //     snprintf(xname, sizeof xname, "[fd %d]", inp_fd);
//         //     log_error("Path 1 error: can't open '%s': %s\n", xname, gpg_strerror(rc));
//         // }
//     }
//     else if (1){//iobuf_is_pipe_filename(iname) && !opt.outfile) {
//         printf("Path 2: Using pipe/stdout\n");
//         *a = iobuf_create(NULL, 0);
//         // if (!*a) {
//         //     rc = gpg_error_from_syserror();
//         //     log_error("Path 2 error: can't open stdout: %s\n", strerror(errno));
//         // }
//     }
//     // else {
//     //     printf("Path 3: Using regular file");
//     //     char *buf = NULL;
//     //     const char *name;
        
//     //     if (opt.dry_run) {
//     //         printf("Path 3a: Dry run - using null device");
//     //         name = NAME_OF_DEV_NULL;
//     //     }
//     //     else if (opt.outfile) {
//     //         printf("Path 3b: Using specified outfile: %s", opt.outfile);
//     //         name = opt.outfile;
//     //     }
//     //     else {
//     //         printf("Path 3c: Constructing filename from iname: %s", iname);
//     //         // Rest of filename construction logic...
//     //     }

//     //     while (!overwrite_filep(name)) {
//     //         printf("Path 3 loop: Asking for new filename");
//     //         // ... rest of loop
//     //     }
        
//     //     if (!rc) {
//     //         if (is_secured_filename(name)) {
//     //             log_error("Path 3 error: Secured filename not allowed: %s", name);
//     //             *a = NULL;
//     //             gpg_err_set_errno(EPERM);
//     //         }
//     //         else {
//     //             *a = iobuf_create(name, restrictedperm);
//     //             if (!*a) {
//     //                 rc = gpg_error_from_syserror();
//     //                 log_error("Path 3 error: Creation failed for '%s': %s\n", 
//     //                          name, strerror(errno));
//     //             }
//     //         }
//     //     }
//     // }

//     if (*a) {
//         printf("Setting NO_CACHE on output buffer\n");
//         // iobuf_ioctl(*a, IOBUF_IOCTL_NO_CACHE, 1, NULL);
        
//     }

//     return rc;
// }


// int encrypt_simple(const uint8_t *data, size_t data_len,const char* passphrase,
//                    uint8_t *output, size_t *output_len, const char *derivedKey)
// {
//   printf("encrypt_simple\n");
//   int mode = 1;
//   int use_seskey = 0;
//   iobuf_t inp, out;
//   PACKET pkt;
//   PKT_plaintext *pt = NULL;
//   STRING2KEY *s2k = 0x03;//s2k salted and iterated hash
//   void *enckey = NULL;
//   size_t enckeylen = 0;
//   int rc = 0;
//   u32 filesize;
//   cipher_filter_context_t cfx;
//   memset(&cfx, 0, sizeof cfx);
//   cfx.cipher_hd = malloc(sizeof(struct gcry_cipher_handle));
//   if (!cfx.cipher_hd) {
//       return -1; // Handle allocation failure
//   }
//   memset(cfx.cipher_hd, 0, sizeof(struct gcry_cipher_handle));
//   init_packet(&pkt);
//   char peekbuf[32];
//   int  peekbuflen;
//    //pfx = new_progress_context ();
//   // memset( &cfx, 0, sizeof cfx);
//   // memset( &zfx, 0, sizeof zfx);
//   // memset( &tfx, 0, sizeof tfx);
//   // init_packet(&pkt);

//   /* Prepare iobufs. */
//   inp = do_open (NULL, 1, IOBUF_INPUT, "rb", 0);//iobuf_open(NULL);
//     printf("encrypt_simple inp: %d\n", inp);

//   if (inp)
//    iobuf_ioctl (inp, IOBUF_IOCTL_NO_CACHE, 1, NULL);
//   // if (inp && is_secured_file (iobuf_get_fd (inp)))
//   //   {
//   //     iobuf_close (inp);
//   //     inp = NULL;
//   //     gpg_err_set_errno (EPERM);
//   //   }
//   // if (!inp)
//   //   {
//   //     rc = gpg_error_from_syserror ();
//   //     log_error(_("can't open '%s': %s\n"), filename? filename: "[stdin]",
//   //               strerror(errno) );
//   //     release_progress_context (pfx);
//   //     return rc;
//   //   }

//   peekbuflen = iobuf_ioctl (inp, IOBUF_IOCTL_PEEK, sizeof peekbuf, peekbuf);

// printf("peekbuflen %d\n",peekbuflen);
//   if (peekbuflen < 0)
//     {
//       peekbuflen = 0;
//      //  if (DBG_FILTER)
//         printf ("peeking at input failed\n");
//     }

//   cfx.dek = NULL;
//  if ( mode )
//     {
//       printf("mode");
//       // aead_algo_t aead_algo;

//       rc = setup_symkey (&s2k, &cfx.dek, passphrase, derivedKey);
//       if (rc)
//         {
//           // iobuf_close (inp);
//           // if (gpg_err_code (rc) == GPG_ERR_CIPHER_ALGO
//           //     || gpg_err_code (rc) == GPG_ERR_DIGEST_ALGO)
//           //   ; /* Error has already been printed.  */
//           // else
//           //   log_error (_("error creating passphrase: %s\n"), gpg_strerror (rc));
//           // release_progress_context (pfx);
//           // return rc;
//         }
//       // if (use_seskey && s2k->mode != 1 && s2k->mode != 3)
//       //   {
//       //     use_seskey = 0;
//       //     printf (_("can't use a SKESK packet due to the S2K mode\n"));
//       //   }

//     //   /* See whether we want to use OCB.  */
//     //   aead_algo = use_aead (NULL, cfx.dek->algo);

//     //   if ( use_seskey )
//     //     {
//     //       DEK *dek = NULL;

//     // printf("use_seskey");
//     //       rc = encrypt_seskey (cfx.dek, aead_algo, &dek, &enckey, &enckeylen);
//     //       if (rc)
//     //         {
//     //           xfree (cfx.dek);
//     //           xfree (s2k);
//     //           iobuf_close (inp);
//     //           release_progress_context (pfx);
//     //           return rc;
//     //         }
//     //       /* Replace key in DEK.  */
//     //       xfree (cfx.dek);
//     //       cfx.dek = dek;
//     //     }

//     //   if (aead_algo)
//     //     cfx.dek->use_aead = aead_algo;
//     //   else
//         cfx.dek->use_mdc = 0;//!!use_mdc (NULL, cfx.dek->algo);

//       // if (opt.verbose)
//       //   printf(_("using cipher %s.%s\n"),
//       //            openpgp_cipher_algo_name (cfx.dek->algo),
//       //            cfx.dek->use_aead? openpgp_aead_algo_name (cfx.dek->use_aead)
//       //            /**/             : "CFB");
//     }
//      // printf("armor2 %d",rc);
//   if ( rc || (rc = open_outfile (-1, NULL, 0, 0, &out )))
//     {
//       // iobuf_cancel (inp);
//       // xfree (cfx.dek);
//       // xfree (s2k);
//       // release_progress_context (pfx);
//       // return rc;
//     }

// if ( s2k )
//     {
//       printf("s2k");
//       PKT_symkey_enc *enc = xmalloc_clear (sizeof *enc + enckeylen);
//       enc->version = cfx.dek->use_aead ? 5 : 4;
//       enc->cipher_algo = cfx.dek->algo;
//       enc->aead_algo = cfx.dek->use_aead;
//       enc->s2k = *s2k;
//       if (enckeylen)
//         {
//           printf("Enc key len %d\n",enckeylen);
//           enc->seskeylen = enckeylen;
//           memcpy (enc->seskey, enckey, enckeylen);
//         }
//       pkt.pkttype = PKT_SYMKEY_ENC;
//       pkt.pkt.symkey_enc = enc;
//       if ((rc = build_packet( out, &pkt )))
//         printf("build symkey packet failed: \n");//, gpg_strerror (rc) );

//       xfree (enc);
//       xfree (enckey);
//       enckey = NULL;
//     }

//   if (1){//!opt.no_literal)
//     pt = setup_plaintext_name(NULL, inp);
//   }
//   // if (!iobuf_is_pipe_filename(filename) && *filename && !opt.textmode)
//   // {
//   //   printf("iobuf_is_pipe_filename");
//   //   uint64_t tmpsize;

//   //   tmpsize = iobuf_get_filelength(inp);
//   //   // printf("tmpsize %d",tmpsize);
//   //   if (!tmpsize && opt.verbose)
//   //     printf(_("WARNING: '%s' is an empty file\n"), filename);

//   //   /* We can't encode the length of very large files because
//   //      OpenPGP uses only 32 bit for file sizes.  So if the
//   //      size of a file is larger than 2^32 minus some bytes for
//   //      packet headers, we switch to partial length encoding. */
//   //   if (tmpsize < (IOBUF_FILELENGTH_LIMIT - 65536))
//   //     filesize = tmpsize;
//   //   else
//   //     filesize = 0;
//   // }
//   // else
//   //   filesize = opt.set_filesize ? opt.set_filesize : 0; /* stdin */

//   // printf("filesize %d", filesize);
//   if (1)//!opt.no_literal)
//   {
//     printf("no_literal\n");
//     /* Note that PT has been initialized above in !no_literal mode.  */
//     // pt->timestamp = 
//     pt->timestamp = 1624780800;// make_timestamp();
//     pt->mode = //opt.mimemode ? 'm' : opt.textmode ? 't'
// // : 
// 'b';
//     pt->len = filesize;
//     pt->new_ctb = !pt->len;
//     pt->buf = inp;
//     pkt.pkttype = PKT_PLAINTEXT;
//     pkt.pkt.plaintext = pt;
//     cfx.datalen = filesize && !FALSE ? calc_packet_length(&pkt) : 0;
//     printf("cfx.datalen %d\n", cfx.datalen);
//   }
//   // else
//   // {
//   //   printf("opt.no_literal");
//   //   cfx.datalen = filesize && !FALSE ? filesize : 0;
//   //   pkt.pkttype = 0;
//   //   pkt.pkt.generic = NULL;
//   // }

//   //     // printf("cfx.datalen %d",cfx.datalen);
//   //   /* Register the cipher filter. */
//     if (mode){
//       printf("mode %d, cfx.dek->use_aead %d\n",mode,cfx.dek->use_aead);
//       iobuf_push_filter (out,
//                          //cfx.dek->use_aead? cipher_filter_ocb
//                          ///**/             : 
//                          cipher_filter_cfb,
//                          &cfx );
//     }

//   //   /* Do the work. */
//     if (1)//!opt.no_literal)
//       {
//   printf("opt.no_literal");
//         if ( (rc = build_packet( out, &pkt )) )
//           printf("build_packet failed: %s\n");//, gpg_strerror (rc) );

// //          print_iobuf_info(out);

//       }

//       printf("DONE\n");
//   //   else
//   //     {
//   //       printf("no_literal copying plain data");
//   //       /* User requested not to create a literal packet, so we copy the
//   //          plain data.  */
//   //       byte copy_buffer[4096];
//   //       int  bytes_copied;
//   //       while ((bytes_copied = iobuf_read(inp, copy_buffer, 4096)) != -1)
//   //         if ( (rc=iobuf_write(out, copy_buffer, bytes_copied)) ) {
//   //           log_error ("copying input to output failed: %s\n",
//   //                      gpg_strerror (rc) );
//   //           break;
//   //         }else printf("copied %d bytes",bytes_copied);
//   //       wipememory (copy_buffer, 4096); /* burn buffer */
//   //     }
//     printf("rc %d\n",rc);
//     /* Finish the stuff.  */
//     iobuf_close (inp);
//     if (rc){
//       printf("rc %d",rc);
//       // iobuf_cancel(out);
//       return rc;
//     }
//     else
//       {
//         rc = iobuf_close (out); /* fixme: check returncode */
//         printf("rc %d\n",rc);

//         // if (mode)
//         //   write_status ( STATUS_END_ENCRYPTION );
//       }
//     if (pt)
//       pt->buf = NULL;
//     free_packet (&pkt, NULL);
//     printf("FINISHED ENCRYPTING\n");
//     xfree (enckey);
//     xfree (cfx.dek);
//     xfree (s2k);
//   //   release_armor_context (afx);
//   //   release_progress_context (pfx);
//   return rc;
// }
