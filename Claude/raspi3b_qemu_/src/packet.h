#ifndef SIMPLIFIED_PACKET_H
#define SIMPLIFIED_PACKET_H

#include <stdint.h>
#include <stddef.h>
#include "libgcrypt.h"
#include "iobuf.h"

/* Basic types */
typedef uint8_t byte;

/* Packet types */
typedef enum {
    PKT_SYMKEY_ENC = 3,
    PKT_PLAINTEXT = 11,
    PKT_ENCRYPTED = 9
} pkttype_t;

/* S2K (String-to-Key) specification */
typedef struct {
    int mode;
    byte hash_algo;
    byte salt[8];
    uint32_t count;
} STRING2KEY;

/* Plaintext packet */
typedef struct {
    uint32_t len;
    iobuf_t buf;
    byte new_ctb;
    byte is_partial;
    int mode;
    uint32_t timestamp;
    int namelen;
    char name[1];
} PKT_plaintext;

/* Base packet structure */
typedef struct packet_struct PACKET;

/* A symmetric-key encrypted session key packet as defined in RFC
   4880, Section 5.3.  All fields are serialized.  */
typedef struct {
  /* RFC 4880: this must be 4.  */
  byte version;
  /* The cipher algorithm used to encrypt the session key.  (This may
     be different from the algorithm that is used to encrypt the SED
     packet.)  */
  byte cipher_algo;
  /* The AEAD algorithm or 0 for CFB encryption.  */
  byte aead_algo;
  /* The string-to-key specifier.  */
  STRING2KEY s2k;
  /* The length of SESKEY in bytes or 0 if this packet does not
     encrypt a session key.  (In the latter case, the results of the
     S2K function on the password is the session key. See RFC 4880,
     Section 5.3.)  */
  byte seskeylen;
  /* The session key as encrypted by the S2K specifier.  For AEAD this
   * includes the nonce and the authentication tag.  */
  byte seskey[1];
} PKT_symkey_enc;


/* A symmetrically encrypted data packet (RFC 4880, Section 5.7) or a
   symmetrically encrypted integrity protected data packet (Section
   5.13) */
typedef struct {
  /* Remaining length of encrypted data. */
  u32  len;
  /* When encrypting in CFB mode, the first block size bytes of data
   * are random data and the following 2 bytes are copies of the last
   * two bytes of the random data (RFC 4880, Section 5.7).  This
   * provides a simple check that the key is correct.  EXTRALEN is the
   * size of this extra data or, in AEAD mode, the length of the
   * headers and the tags.  This is used by build_packet when writing
   * out the packet's header. */
  int  extralen;
  /* Whether the serialized version of the packet used / should use
     the new format.  */
  byte new_ctb;
  /* Whether the packet has an indeterminate length (old format) or
     was encoded using partial body length headers (new format).
     Note: this is ignored when encrypting.  */
  byte is_partial;
  /* If 0, MDC is disabled.  Otherwise, the MDC method that was used
     (currently, only DIGEST_ALGO_SHA1 is supported).  */
  byte mdc_method;
  /* If 0, AEAD is not used.  Otherwise, the used AEAD algorithm.
   * MDC_METHOD (above) shall be zero if AEAD is used.  */
  byte aead_algo;
  /* The cipher algo for/from the AEAD packet.  0 for other encryption
   * packets. */
  byte cipher_algo;
  /* The chunk byte from the AEAD packet.  */
  byte chunkbyte;

  /* An iobuf holding the data to be decrypted.  (This is not used for
     encryption!)  */
  iobuf_t buf;
} PKT_encrypted;

/* combine all packets into a union */
struct packet_struct {
    pkttype_t pkttype;
    union {
	void *generic;
	PKT_symkey_enc	*symkey_enc;	/* PKT_SYMKEY_ENC */
	// PKT_pubkey_enc	*pubkey_enc;	/* PKT_PUBKEY_ENC */
	// PKT_onepass_sig *onepass_sig;	/* PKT_ONEPASS_SIG */
	// PKT_signature	*signature;	/* PKT_SIGNATURE */
	// PKT_public_key	*public_key;	/* PKT_PUBLIC_[SUB]KEY */
	// PKT_public_key	*secret_key;	/* PKT_SECRET_[SUB]KEY */
	// PKT_comment	*comment;	/* PKT_COMMENT */
	// PKT_user_id	*user_id;	/* PKT_USER_ID */
	// PKT_compressed	*compressed;	/* PKT_COMPRESSED */
	// PKT_encrypted	*encrypted;	/* PKT_ENCRYPTED[_MDC] */
	// PKT_mdc 	*mdc;		/* PKT_MDC */
	PKT_plaintext	*plaintext;	/* PKT_PLAINTEXT */
    PKT_encrypted *encrypted;
        // PKT_gpg_control *gpg_control;   /* PKT_GPG_CONTROL */
    } pkt;
};

/* Function prototypes */
void init_packet(PACKET *pkt);
int build_packet(iobuf_t out, PACKET *pkt);
void free_packet(PACKET *pkt, void *ctx);

#define init_packet(a) do { (a)->pkttype = 0;		\
			    (a)->pkt.generic = NULL;	\
		       } while(0)
#endif /* SIMPLIFIED_PACKET_H */
