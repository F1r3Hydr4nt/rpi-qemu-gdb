/* build-packet.c - assemble packets and write them
 * Copyright (C) 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
 *               2006, 2010, 2011  Free Software Foundation, Inc.
 *
 * This file is part of GnuPG.
 *
 * GnuPG is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * GnuPG is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
// #include "gpg.h"
#include "printf.h"
#include "packet.h"
#include "common/iobuf.h"

static int do_symkey_enc( IOBUF out, int ctb, PKT_symkey_enc *enc );
static u32 calc_plaintext( PKT_plaintext *pt );
static int do_plaintext( IOBUF out, int ctb, PKT_plaintext *pt );
static int do_encrypted( IOBUF out, int ctb, PKT_encrypted *ed );
static int calc_header_length( u32 len, int new_ctb );
static int write_16(IOBUF inp, u16 a);
static int write_32(IOBUF inp, u32 a);
static int write_header( IOBUF out, int ctb, u32 len );
static int write_header2( IOBUF out, int ctb, u32 len, int hdrlen );
static int write_new_header( IOBUF out, int ctb, u32 len, int hdrlen );

/* Returns 1 if CTB is a new format ctb and 0 if CTB is an old format
   ctb.  */
static int
ctb_new_format_p (int ctb)
{
  /* Bit 7 must always be set.  */
  // log_assert ((ctb & (1 << 7)));
  /* Bit 6 indicates whether the packet is a new format packet.  */
  int res = (ctb & (1 << 6));
  printf("ctb new format: %d\n", res);
  return res;
}

/* Extract the packet type from a CTB.  */
static int
ctb_pkttype (int ctb)
{
  if (ctb_new_format_p (ctb))
    /* Bits 0 through 5 are the packet type.  */
    return (ctb & ((1 << 6) - 1));
  else
    /* Bits 2 through 5 are the packet type.  */
    return (ctb & ((1 << 6) - 1)) >> 2;
}

const char* get_pkttype_name(pkttype_t pkttype) {
    switch (pkttype) {
        // case PKT_NONE: return "PKT_NONE";
        // case PKT_PUBKEY_ENC: return "PKT_PUBKEY_ENC";
        // case PKT_SIGNATURE: return "PKT_SIGNATURE";
        case PKT_SYMKEY_ENC: return "PKT_SYMKEY_ENC";
        // case PKT_ONEPASS_SIG: return "PKT_ONEPASS_SIG";
        // case PKT_SECRET_KEY: return "PKT_SECRET_KEY";
        // case PKT_PUBLIC_KEY: return "PKT_PUBLIC_KEY";
        // case PKT_SECRET_SUBKEY: return "PKT_SECRET_SUBKEY";
        // case PKT_COMPRESSED: return "PKT_COMPRESSED";
        case PKT_ENCRYPTED: return "PKT_ENCRYPTED";
        // case PKT_MARKER: return "PKT_MARKER";
        case PKT_PLAINTEXT: return "PKT_PLAINTEXT";
        // case PKT_RING_TRUST: return "PKT_RING_TRUST";
        // case PKT_USER_ID: return "PKT_USER_ID";
        // case PKT_PUBLIC_SUBKEY: return "PKT_PUBLIC_SUBKEY";
        // case PKT_OLD_COMMENT: return "PKT_OLD_COMMENT";
        // case PKT_ATTRIBUTE: return "PKT_ATTRIBUTE";
        // case PKT_ENCRYPTED_MDC: return "PKT_ENCRYPTED_MDC";
        // case PKT_MDC: return "PKT_MDC";
        // case PKT_ENCRYPTED_AEAD: return "PKT_ENCRYPTED_AEAD";
        // case PKT_COMMENT: return "PKT_COMMENT";
        // case PKT_GPG_CONTROL: return "PKT_GPG_CONTROL";
        default: return "UNKNOWN";
    }
}

/* Build a packet and write it to the stream OUT.
 * Returns: 0 on success or on an error code.  */
int
build_packet (IOBUF out, PACKET *pkt)
{
    printf("        BUILD PACKET: %s out->use %d\n",get_pkttype_name(pkt->pkttype), out->use);

  int rc = 0;
  int new_ctb = 0;
  int ctb, pkttype;

  // if (DBG_PACKET)
  //   log_debug ("build_packet() type=%d\n", pkt->pkttype);
  // // log_assert (pkt->pkt.generic);

  switch ((pkttype = pkt->pkttype))
    {
    // case PKT_PUBLIC_KEY:
    //   if (pkt->pkt.public_key->seckey_info)
    //     pkttype = PKT_SECRET_KEY;
    //   break;
    // case PKT_PUBLIC_SUBKEY:
    //   if (pkt->pkt.public_key->seckey_info)
    //     pkttype = PKT_SECRET_SUBKEY;
    //   break;
    case PKT_PLAINTEXT:
      new_ctb = pkt->pkt.plaintext->new_ctb;
      break;
    case PKT_ENCRYPTED:
    // case PKT_ENCRYPTED_MDC:
    // case PKT_ENCRYPTED_AEAD:
      new_ctb = pkt->pkt.encrypted->new_ctb;
      break;
    // case PKT_COMPRESSED:
    //   new_ctb = pkt->pkt.compressed->new_ctb;
    //   break;
    // case PKT_USER_ID:
    //   if (pkt->pkt.user_id->attrib_data)
    //     pkttype = PKT_ATTRIBUTE;
    //   break;
    default:
      break;
    }

  if (new_ctb || pkttype > 15) /* new format */
    ctb = (0xc0 | (pkttype & 0x3f));
  else
    ctb = (0x80 | ((pkttype & 15)<<2));
  printf("CTB: pkttype %02x %d\n", ctb, pkttype);
  switch (pkttype)
    {
    // case PKT_ATTRIBUTE:
    // case PKT_USER_ID:
    //   rc = do_user_id (out, ctb, pkt->pkt.user_id);
    //   break;
    // case PKT_OLD_COMMENT:
    // case PKT_COMMENT:
    //   /* Ignore these.  Theoretically, this will never be called as we
    //    * have no way to output comment packets any longer, but just in
    //    * case there is some code path that would end up outputting a
    //    * comment that was written before comments were dropped (in the
    //    * public key?) this is a no-op. 	*/
    //   break;
    // case PKT_PUBLIC_SUBKEY:
    // case PKT_PUBLIC_KEY:
    // case PKT_SECRET_SUBKEY:
    // case PKT_SECRET_KEY:
    //   rc = do_key (out, ctb, pkt->pkt.public_key);
    //   break;
    case PKT_SYMKEY_ENC:
      rc = do_symkey_enc (out, ctb, pkt->pkt.symkey_enc);
      break;
    // case PKT_PUBKEY_ENC:
    //   rc = do_pubkey_enc (out, ctb, pkt->pkt.pubkey_enc);
    //   break;
    case PKT_PLAINTEXT:
      rc = do_plaintext (out, ctb, pkt->pkt.plaintext);
      break;
    case PKT_ENCRYPTED:
      rc = do_encrypted (out, ctb, pkt->pkt.encrypted);
      break;
    // case PKT_ENCRYPTED_MDC:
    //   rc = do_encrypted_mdc (out, ctb, pkt->pkt.encrypted);
    //   break;
    // case PKT_ENCRYPTED_AEAD:
    //   rc = do_encrypted_aead (out, ctb, pkt->pkt.encrypted);
    //   break;
    // case PKT_COMPRESSED:
    //   rc = do_compressed (out, ctb, pkt->pkt.compressed);
    //   break;
    // case PKT_SIGNATURE:
    //   rc = do_signature (out, ctb, pkt->pkt.signature);
    //   break;
    // case PKT_ONEPASS_SIG:
    //   rc = do_onepass_sig (out, ctb, pkt->pkt.onepass_sig);
    //   break;
    // case PKT_RING_TRUST:
    //   /* Ignore it (only written by build_packet_and_meta)  */
    //   break;
    // case PKT_MDC:
    //   /* We write it directly, so we should never see it here. */
    default:
      printf ("invalid packet type in build_packet()\n");
      break;
    }

  return rc;
}



/* Calculate the length of a packet described by PKT.  */
u32
calc_packet_length( PACKET *pkt )
{
  u32 n = 0;
  int new_ctb = 0;

  // log_assert (pkt->pkt.generic);
  switch (pkt->pkttype)
    {
    case PKT_PLAINTEXT:
      n = calc_plaintext (pkt->pkt.plaintext);
      new_ctb = pkt->pkt.plaintext->new_ctb;
      break;
    // case PKT_ATTRIBUTE:
    // case PKT_USER_ID:
    // case PKT_COMMENT:
    // case PKT_PUBLIC_KEY:
    // case PKT_SECRET_KEY:
    case PKT_SYMKEY_ENC:
    // case PKT_PUBKEY_ENC:
    case PKT_ENCRYPTED:
    // case PKT_SIGNATURE:
    // case PKT_ONEPASS_SIG:
    // case PKT_RING_TRUST:
    // case PKT_COMPRESSED:
    default:
      printf ("invalid packet type in calc_packet_length()");
      break;
    }

  n += calc_header_length (n, new_ctb);
  return n;
}

#define HEX_DUMP_BUFFER_SIZE 256
void log_hexdump(const uint8_t *buffer, int length) {
    char text[17];
    int written = 0;
    
    printf("%d bytes:\n", length);
    while (length > 0) {
        int have = (length > 16) ? 16 : length;
        
        printf("%-8d ", written);
        
        for (int i = 0; i < 16; i++) {
            if (i % 2 == 0) printf(" ");
            if (i % 8 == 0) printf(" ");
            
            if (i < have) {
                printf("%02x", buffer[i]);
            } else {
                printf("  ");
            }
        }
        
        printf("  ");
        for (int i = 0; i < have; i++) {
            text[i] = (buffer[i] >= 32 && buffer[i] <= 126) ? buffer[i] : '.';
        }
        text[have] = '\0';
        printf("%s\n", text);
        
        buffer += have;
        length -= have;
        written += have;
    }
}

void print_iobuf_info2(const struct iobuf_struct *iobuf) {
    printf("print_iobuf_info2\n");
    if (!iobuf) {
        printf("iobuf is NULL\n");
        return;
    }
;
    printf("  Use: %d\n", iobuf->use);
    printf("  nlimit: %ld\n", (long)iobuf->nlimit);
    printf("  nbytes: %ld\n", (long)iobuf->nbytes);
    printf("  ntotal: %ld\n", (long)iobuf->ntotal);
    printf("  nofast: %d\n", iobuf->nofast);
    printf("  Buffer size: %zu\n", iobuf->d.size);
    printf("  Buffer start: %zu\n", iobuf->d.start);
    printf("  Buffer length: %zu\n", iobuf->d.len);
    printf("  Filter EOF: %d\n", iobuf->filter_eof);
    printf("  Error: %d\n", iobuf->error);
    printf("  Filter owner: %d\n", iobuf->filter_ov_owner);
    // if (iobuf->real_fname) {
    //     printf("  Real filename: %s\n", iobuf->real_fname);
    // } else {
    //     printf("  Real filename: (null)\n");
    // }
    printf("  Filter number: %d\n", iobuf->no);
    printf("  Sub filters count: %d\n", iobuf->subno);

    // Assuming the chain is a pointer to another iobuf_struct, you can recursively print info about the chain if needed
    if (iobuf->chain) {
        printf("  Chain:\n");
        print_iobuf_info2(iobuf->chain);
    }
}


/* Serialize the symmetric-key encrypted session key packet (RFC 4880,
 * 5.3) described by ENC and write it to OUT.
 *
 * CTB is the serialization's CTB.  It specifies the header format and
 * the packet's type.  The header length must not be set.  */
static int
do_symkey_enc( IOBUF out, int ctb, PKT_symkey_enc *enc )
{
 printf("do_symkey_enc out->use %d\n", out->use);
   printf("PKT_symkey_enc:\n");
    printf("  version: %u\n", enc->version);
    printf("  cipher_algo: %u\n", enc->cipher_algo);
    printf("  aead_algo: %u\n", enc->aead_algo);
     printf("  s2k:\n");
    printf("    mode: %d\n", enc->s2k.mode);
    printf("    hash_algo: %u\n", enc->s2k.hash_algo);
    printf("    salt: ");
    log_hexdump(enc->s2k.salt, 8);
    printf("    count: %08x\n", enc->s2k.count);
    printf("  seskeylen: %u\n", enc->seskeylen);
    // printf("  seskey: ");
    // for (int i = 0; i < pkt.seskeylen; i++) {
    //     printf("0x%02x ", pkt.seskey[i]);
    // }
    // printf("\n");

  int rc = 0;
  IOBUF a = iobuf_temp();

  // log_assert (ctb_pkttype (ctb) == PKT_SYMKEY_ENC);
  // log_assert (enc->version == 4 || enc->version == 5);

  /* RFC 4880, Section 3.7.  */
  switch (enc->s2k.mode)
    {
    case 0: /* Simple S2K.  */
    case 1: /* Salted S2K.  */
    case 3: /* Iterated and salted S2K.  */
      break; /* Reasonable values.  */

    default:
      printf ("do_symkey_enc: s2k=%d\n", enc->s2k.mode);
    }
    iobuf_put( a, enc->version );
    iobuf_put( a, enc->cipher_algo );
    if (enc->version == 5)
      iobuf_put (a, enc->aead_algo);
    iobuf_put( a, enc->s2k.mode );
    iobuf_put( a, enc->s2k.hash_algo );
    if( enc->s2k.mode == 1 || enc->s2k.mode == 3 ) {
       // Overwrite the salt with new values
	iobuf_write(a, enc->s2k.salt, 8 );
	if( enc->s2k.mode == 3 )
  // printf("Writing s2k.count");
	    iobuf_put(a, enc->s2k.count);
    }
    // printf("enc->seskeylen = %d", enc->seskeylen);
    if( enc->seskeylen )
	iobuf_write(a, enc->seskey, enc->seskeylen );

    write_header(out, ctb, iobuf_get_temp_length(a) );
    rc = iobuf_write_temp( out, a );
    iobuf_close(a);
    return rc;
}


/* Calculate the length of the serialized plaintext packet PT (RFC
   4480, Section 5.9).  */
static u32
calc_plaintext( PKT_plaintext *pt )
{
  /* Truncate namelen to the maximum 255 characters.  Note this means
     that a function that calls build_packet with an illegal literal
     packet will get it back legalized. */

  if(pt->namelen>255)
    pt->namelen=255;
  u32 res = pt->len? (1 + 1 + pt->namelen + 4 + pt->len) : 0;
  printf("calc_plaintext write_32 %08x",res);
  return res;
}

/* Serialize the plaintext packet (RFC 4880, 5.9) described by PT and
   write it to OUT.

   The body of the message is stored in PT->BUF.  The amount of data
   to write is PT->LEN.  (PT->BUF should be configured to return EOF
   after this much data has been read.)  If PT->LEN is 0 and CTB
   indicates that this is a new format packet, then partial block mode
   is assumed to have been enabled on OUT.  On success, partial block
   mode is disabled.

   If PT->BUF is NULL, the caller must write out the data.  In
   this case, if PT->LEN was 0, then partial body length mode was
   enabled and the caller must disable it by calling
   iobuf_set_partial_body_length_mode (out, 0).  */
static int
do_plaintext( IOBUF out, int ctb, PKT_plaintext *pt )
{
  printf("do_plaintext pt->buf: %d\n", pt->buf);
    int rc = 0;
    size_t nbytes;

    // log_assert (ctb_pkttype (ctb) == PKT_PLAINTEXT);

printf("Checking packet type\n");
    // log_assert(ctb_pkttype(ctb) == PKT_PLAINTEXT);

    printf("Writing header\n");
    

    write_header(out, ctb, calc_plaintext( pt ) );
    printf("CTB: %d\n", ctb);
    printf("Checking mode validity: mode = %c\n", pt->mode);
    // log_assert(pt->mode == 'b' || pt->mode == 't' || pt->mode == 'u'
                // || pt->mode == 'm' || pt->mode == 'l' || pt->mode == '1');

    printf("Writing mode: %c\n", pt->mode);
    iobuf_put(out, pt->mode);

    printf("Writing namelen: %zu\n", pt->namelen);
    iobuf_put(out, pt->namelen);

    printf("Writing name: %.*s\n", (int)pt->namelen, pt->name);
    iobuf_write(out, pt->name, pt->namelen);
    pt->timestamp = 1624780800;
    printf("Writing timestamp: %u\n", pt->timestamp);
    rc = write_32(out, pt->timestamp);
    printf("rc: %d\n", rc);
    printf("pt->buf: %d\n", pt->buf->nbytes);

    if (rc)
      return rc;

    if (pt->buf)
      {
        nbytes = iobuf_copy (out, pt->buf);
        printf("!!!!! Wrote buf %d bytes", nbytes);
        // log_printhex("Writing buf", pt->buf, pt->len);
        
        if (nbytes == (size_t)(-1)
            && (iobuf_error (out) || iobuf_error (pt->buf)))
            return iobuf_error (out)? iobuf_error (out):iobuf_error (pt->buf);
        /* Always get the error to catch write errors because
         * iobuf_copy does not reliable return (-1) in that case.  */
        rc = iobuf_error (out);
        if(ctb_new_format_p (ctb) && !pt->len){
          /* Turn off partial body length mode.  */
          iobuf_set_partial_body_length_mode (out, 0);
          printf("Turned off partial body length mode\n");
        }
        if (pt->len && nbytes != pt->len)
          {
            // printf ("do_plaintext(): wrote %lu bytes"
            //            " but expected %lu bytes\n",
            //            (ulong)nbytes, (ulong)pt->len );
            if (!rc) /* Just in case no error was set  */
              rc = -1;//gpg_error (GPG_ERR_EIO);
          }
      }
    printf("do_plaintext done %d\n", rc);
    return rc;
}



/* Serialize the symmetrically encrypted data packet (RFC 4880,
   Section 5.7) described by ED and write it to OUT.

   Note: this only writes the packets header!  The call must then
   follow up and write the initial random data and the body to OUT.
   (If you use the encryption iobuf filter (cipher_filter), then this
   is done automatically.)  */
static int
do_encrypted( IOBUF out, int ctb, PKT_encrypted *ed )
{
    int rc = 0;
    u32 n;

    // log_assert (! ed->mdc_method);
    // log_assert (ctb_pkttype (ctb) == PKT_ENCRYPTED);

    n = ed->len ? (ed->len + ed->extralen) : 0;
    write_header(out, ctb, n );

    /* This is all. The caller has to write the real data */

    return rc;
}

/* Write a 16-bit quantity to OUT in big endian order.  */
static int
write_16(IOBUF out, u16 a)
{
    iobuf_put(out, a>>8);
    if( iobuf_put(out,a) )
	return -1;
    return 0;
}

/* Write a 32-bit quantity to OUT in big endian order.  */
static int
write_32(IOBUF out, u32 a)
{

  printf("write_32 %08x\n",a);
    iobuf_put(out, a>> 24);
    iobuf_put(out, a>> 16);
    iobuf_put(out, a>> 8);
    return iobuf_put(out, a);
}


/****************
 * calculate the length of a header.
 *
 * LEN is the length of the packet's body.  NEW_CTB is whether we are
 * using a new or old format packet.
 *
 * This function does not handle indeterminate lengths or partial body
 * lengths.  (If you pass LEN as 0, then this function assumes you
 * really mean an empty body.)
 */
static int
calc_header_length( u32 len, int new_ctb )
{
    if( new_ctb ) {
	if( len < 192 )
	    return 2;
	if( len < 8384 )
	    return 3;
	else
	    return 6;
    }
    if( len < 256 )
	return 2;
    if( len < 65536 )
	return 3;

    return 5;
}

/****************
 * Write the CTB and the packet length
 */
static int
write_header( IOBUF out, int ctb, u32 len )
{
    return write_header2( out, ctb, len, 0 );
}

static int
write_header2( IOBUF out, int ctb, u32 len, int hdrlen )
{

  printf("write_header2  %08X %d %02X %d",len,hdrlen,ctb, out->use);
  if (ctb_new_format_p (ctb)){
    printf("writing_new_header\n");
    return write_new_header( out, ctb, len, hdrlen );
  }

  /* An old format packet.  Refer to RFC 4880, Section 4.2.1 to
     understand how lengths are encoded in this case.  */

  /* The length encoding is stored in the two least significant bits.
     Make sure they are cleared.  */
  // log_assert ((ctb & 3) == 0);

  // log_assert (hdrlen == 0 || hdrlen == 2 || hdrlen == 3 || hdrlen == 5);

  if (hdrlen)
    /* Header length is given.  */
    {  

      if( hdrlen == 2 && len < 256 )
        /* 00 => 1 byte length.  */
	;
      else if( hdrlen == 3 && len < 65536 )
        /* 01 => 2 byte length.  If len < 256, this is not the most
           compact encoding, but it is a correct encoding.  */
	ctb |= 1;
      else if (hdrlen == 5)
        /* 10 => 4 byte length.  If len < 65536, this is not the most
           compact encoding, but it is a correct encoding.  */
	ctb |= 2;
      else
        printf ("Can't encode length=%d in a %d byte header!\n",
                 len, hdrlen);
    }
  else
    {
      printf("len=%d\n",len);
      if( !len )
        /* 11 => Indeterminate length.  */
	ctb |= 3;
      else if( len < 256 )
        /* 00 => 1 byte length.  */
	;
      else if( len < 65536 )
        /* 01 => 2 byte length.  */
	ctb |= 1;
      else
        /* 10 => 4 byte length.  */
	ctb |= 2;
    }

  if( iobuf_put(out, ctb ) ){
    printf("Failing here\n");
    return -1;
  }

  if( len || hdrlen )
    {
      if( ctb & 2 )
	{
	  if(iobuf_put(out, len >> 24 ))
	    return -1;
	  if(iobuf_put(out, len >> 16 ))
	    return -1;
	}

      if( ctb & 3 ){

	if(iobuf_put(out, len >> 8 ))
	  return -1;

      }
      if( iobuf_put(out, len ) )
	return -1;
    }
    printf("WRITE HEADER:     ctb=%02x, len=%d\n", ctb, len);
    log_hexdump(out->d.buf, out->d.len);
  return 0;
}


/* Write a new format header to OUT.

   CTB is the ctb.

   LEN is the length of the packet's body.  If LEN is 0, then enables
   partial body length mode (i.e., the body is of an indeterminant
   length) on OUT.  Note: this function cannot be used to generate a
   header for a zero length packet.

   HDRLEN is the length of the packet's header.  If HDRLEN is 0, the
   shortest encoding is chosen based on the length of the packet's
   body.  Currently, values other than 0 are not supported.

   Returns 0 on success.  */
static int
write_new_header( IOBUF out, int ctb, u32 len, int hdrlen )
{
  printf("write_new_header %02X %08X %d\n",ctb,len,hdrlen);
    if( hdrlen )
	printf("can't cope with hdrlen yet\n");

    if( iobuf_put(out, ctb ) )
	return -1;
    if( !len ) {
  printf("enable partial body length mode\n");
	iobuf_set_partial_body_length_mode(out, 512 );
    }
    else {
      printf("len=%d\n",len);
	if( len < 192 ) {
	    if( iobuf_put(out, len ) )
		return -1;
	}
	else if( len < 8384 ) {
	    len -= 192;
	    if( iobuf_put( out, (len / 256) + 192) )
		return -1;
	    if( iobuf_put( out, (len % 256) )  )
		return -1;
	}
	else {
	    if( iobuf_put( out, 0xff ) )
		return -1;
	    if( iobuf_put( out, (len >> 24)&0xff ) )
		return -1;
	    if( iobuf_put( out, (len >> 16)&0xff ) )
		return -1;
	    if( iobuf_put( out, (len >> 8)&0xff )  )
		return -1;
	    if( iobuf_put( out, len & 0xff ) )
		return -1;
	}
    }
    return 0;
}
