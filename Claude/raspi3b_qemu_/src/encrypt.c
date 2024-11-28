/* encrypt.c */
#include "filter.h"
#include "iobuf.h"
#include "packet.h"
#include "memory.h"

int
encrypt_simple(const uint8_t *data, size_t data_len,
               const uint8_t *key, size_t key_len,
               uint8_t *output, size_t *output_len)
{
    iobuf_t inp, out;
    PACKET pkt;
    PKT_plaintext *pt = NULL;
    cipher_filter_context_t cfx;
    int rc = 0;

    // Initialize
    memset(&cfx, 0, sizeof(cfx));
    init_packet(&pkt);

    // Create input/output buffers
    inp = iobuf_temp_with_content((char *)data, data_len);
    if (!inp) return -1;

    out = iobuf_temp();
    if (!out) {
        iobuf_close(inp);
        return -1;
    }

    // Write symmetric key packet
    PKT_symkey_enc *enc = malloc(sizeof(*enc));
    enc->version = 4;
    enc->cipher_algo = 3;  // CAST5
    enc->aead_algo = 0;
    enc->s2k.mode = 3;
    enc->s2k.hash_algo = 2;  // SHA1
    memcpy(enc->s2k.salt, (uint8_t[]){0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x11}, 8);
    enc->s2k.count = 0xFF;
    enc->seskeylen = 0;

    pkt.pkttype = PKT_SYMKEY_ENC;
    pkt.pkt.symkey_enc = enc;
    rc = build_packet(out, &pkt);
    free(enc);
    if (rc) goto cleanup;

    // Setup DEK
    cfx.dek = malloc(sizeof(DEK));
    if (!cfx.dek) {
        rc = -1;
        goto cleanup;
    }
    memset(cfx.dek, 0, sizeof(DEK));
    cfx.dek->algo = 3;  // CAST5
    cfx.dek->keylen = key_len;
    cfx.dek->key = (uint8_t *)key;
    cfx.datalen = 0;  // Set for no_literal mode

    // Write encrypted data packet header
    iobuf_writebyte(out, 0xC9);

    // Set partial length mode
    iobuf_set_partial_body_length_mode(out, 512);

    // Push block filter for partial lengths
    iobuf_push_filter(out, block_filter, NULL);

    // Push cipher filter
    iobuf_push_filter(out, cipher_filter_cfb, &cfx);

    // Always build plaintext packet 
    pt = malloc(sizeof(*pt));
    if (!pt) {
        rc = -1;
        goto cleanup;
    }
    pt->mode = 'b';
    pt->timestamp = 0x60D83000;
    pt->len = data_len;
    pt->buf = inp;
    
    pkt.pkttype = PKT_PLAINTEXT;
    pkt.pkt.plaintext = pt;
        
    // Build packet through filters
    rc = build_packet(out, &pkt);

cleanup:
    if (rc == 0) {
        *output_len = out->d.len;
        memcpy(output, out->d.buf, *output_len);
    }

    if (pt) {
        pt->buf = NULL;  // Don't free inp twice
        free(pt);
    }
    free(cfx.dek);
    iobuf_close(inp);
    iobuf_close(out);

    return rc;
}