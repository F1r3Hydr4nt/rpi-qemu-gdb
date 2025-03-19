A QEMU compatible Bare-Metal 64-bit kernel for Raspberry Pi 3b(+)
Build & run (debug):
```
make clean && make
qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -serial mon:stdio -nographic -s -S -d in_asm,cpu_reset
```

To quit:

`CTRL-A, x`

Run GDB, in a separate terminal:

`gdb-multiarch build/kernel8.elf -ex "target remote localhost:1234" -ex "break *_start" -ex "continue"~ `

AI queries used to get up and running:
https://chatgpt.com/share/547bc108-f1e5-4b09-a92e-cae47f55bd10

See the pdf, and blockchain-stuff folder README.md

EXPERIMENT:
Encrypt a small amount of text with GPG Cast128 and try decrypt...
```
gpg --version
gpg (GnuPG) 2.2.27
libgcrypt 1.9.4
Copyright (C) 2021 Free Software Foundation, Inc.
License GNU GPL-3.0-or-later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Home: /home/freddie/.gnupg
Supported algorithms:
Pubkey: RSA, ELG, DSA, ECDH, ECDSA, EDDSA
Cipher: IDEA, 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH,
        CAMELLIA128, CAMELLIA192, CAMELLIA256
Hash: SHA1, RIPEMD160, SHA256, SHA384, SHA512, SHA224
Compression: Uncompressed, ZIP, ZLIB, BZIP2

# Encrypt...
echo "A small amount of text" | gpg --symmetric --cipher-algo CAST5 --passphrase "password" --s2k-digest-algo SHA1 --batch > encrypted.gpg

# And decrypt...
gpg --decrypt --passphrase "password" --batch encrypted.gpg

# Taking the encrypted file hex
xxd -p -c 100000 encrypted.gpg 
8c0d04030302eb381c55fecc8f2fffd244018c41f4e16990d9c846cafc6b04bc37e07a9248110a6f11104cfe744d2b2646228c15528525668b97f31bab07bfbcedd0628492ee96bf11e8a4be3aa6e9994901d91195

# Now we can use it in the program
# But we are getting a bad key lets check gpg1 instead ...

Key is good:
gpg --show-session-key  --decrypt --passphrase "password" --b
atch encrypted.gpg 
gpg: CAST5.CFB encrypted data
gpg: encrypted with 1 passphrase
gpg: session key: '3:896E9344A9E485B8934BBBDA07A59868'
A small amount of text
```

echo "Hello World!" | ./g10/gpg --symmetric --cipher-algo CAST5 --passphrase "password" --s2k-digest-algo SHA1 --compress-algo none --batch --rfc2440 --verbose > encrypted.gpg && xxd encrypted.gpg

00000000: 8c0d 0403 0302 7600 e37f 7d84 7c00 e6c9  ......v...}.|...
00000010: 1f3c 9911 a8bd 78c7 f823 d800 5596 dfff  .<....x..#..U...
00000020: 075f 07ba 605a 615e 8cf8 aa74 7fee bc04  ._..`Za^...t....

00000000: 8c0d 0403 0302 7600 e37f 7d84 7c00 e6c9
        -- Symmetric-key encrypted data
        -- Packet type: Symmetric-key encrypted data packet (9)
        -- Packet length: 13 bytes
        -- Cipher algorithm: CAST5 (3)
        -- S2K (string-to-key) usage: Iterated and salted (3)
        -- S2K hash algorithm: SHA1 (2)
        -- Initialization Vector (IV)

00000010: 1f3c 9911 a8bd 78c7 f823 d800 5596 dfff
        -- Ciphertext

00000020: 075f 07ba 605a 615e 8cf8 aa74 7fee bc04
        -- Ciphertext


Need more verbosity within _gcry_cast5_cfb_dec
static int
do_plaintext( IOBUF out, int ctb, PKT_plaintext *pt )
{
  log_info("do_plaintext pt->buf: %d\n", pt->buf);
    int rc = 0;
    size_t nbytes;

    log_assert (ctb_pkttype (ctb) == PKT_PLAINTEXT);

    log_info("Checking packet type\n");
    log_assert(ctb_pkttype(ctb) == PKT_PLAINTEXT);

    log_info("Writing header\n");
    

    write_header(out, ctb, calc_plaintext( pt ) );
    log_info("CTB: %d\n", ctb);
    log_info("Checking mode validity: mode = %c\n", pt->mode);
    log_assert(pt->mode == 'b' || pt->mode == 't' || pt->mode == 'u'
                || pt->mode == 'm' || pt->mode == 'l' || pt->mode == '1');

    log_info("Writing mode: %c\n", pt->mode);
    iobuf_put(out, pt->mode);

    log_info("Writing namelen: %zu\n", pt->namelen);
    iobuf_put(out, pt->namelen);

    log_info("Writing name: %.*s\n", (int)pt->namelen, pt->name);
    iobuf_write(out, pt->name, pt->namelen);
    pt->timestamp = 1624780800; // 60d83000
    log_info("Writing timestamp: %u\n", pt->timestamp);
    rc = write_32(out, pt->timestamp);
    log_info("rc: %d\n", rc);
    log_info("pt->buf: %d\n", pt->buf);
    print_iobuf_info2(pt->buf);
    if (rc)
      return rc;

    if (pt->buf)
      {
        nbytes = iobuf_copy (out, pt->buf);
        log_info("!!!!! Wrote buf %d bytes", nbytes);
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
          log_info("Turned off partial body length mode\n");
        }
        if (pt->len && nbytes != pt->len)
          {
            log_error ("do_plaintext(): wrote %lu bytes"
                       " but expected %lu bytes\n",
                       (ulong)nbytes, (ulong)pt->len );
            if (!rc) /* Just in case no error was set  */
              rc = gpg_error (GPG_ERR_EIO);
          }
      }
    log_info("do_plaintext done %d\n", rc);
    return rc;
}

echo 4c6f72656d20697
073756d20646f | xxd -p -r
Lorem ipsum dofreddie@fre


https://claude.site/artifacts/d7dd8907-3399-4a2b-9816-7f1ec51fb08c

https://claude.site/artifacts/caed6f03-3caa-4090-8412-5c64261a5537

https://claude.site/artifacts/d653b23c-7ccd-4d48-9ba2-04f957a76285

make clean && make run

Good decrypt DEK to finish:
DO DEK HERE password
DEK Information:
Algorithm: 3
Key Length: 16 bytes
Iterations: 65011712 bytes
Key: 693b7847fa44cdc6e1c403f5e44e95c1
SALT: 0a0b0c0d0e0f1011
dbg_parse_packet
parse
Starting packet parse at position: 16
Read CTB: 0xc9 (new_format=1)
iobuf_set_partial_body_length_mode 234
pushing partial block filter 1
iobuf_push_filter 1
block_filter IOBUFCTRL_INIT
Parsing new format packet length
First length byte: 0xea
One byte length: 0
Two byte length: 0
Four byte length: 0
Partial length encoding: mode=0xea
Parsing old format length (lenbytes=0)
Old format packet length: 0
Begin processing packet (type=9, len=0, partial=1)
Skipping packet type 9
Packet processing complete (rc=2)
Processing packet type: ENCRYPTED (9)
parse_encrypted
Packet length: 0
=== parse_encrypted start ===
Input buffer: 0x3D294
Packet type: 9 (MDC: 0)
Partial: 1
Buffer use: 0
Encrypted data length: 0
Allocated encrypted packet at: 0x41A44
Setting buf to input stream: 0x3D294
=== parse_encrypted end (rc=0) ===
Packet header (2 bytes):
2 bytes:
8d   c9ea                                      ..
processing encrypted packet
encrypted with 1 passphrase
pkt->pkt.encrypted: 0x41A44
decrypt_data
decrypt_data 1044
_gcry_cipher_setkey
key[0] = 0x693b7847
key[1] = 0xfa44cdc6
key[2] = 0xe1c403f5
key[3] = 0xe44e95c1
_gcry_cipher_setiv 8
block_filter IOBUFCTRL_UNDERFLOW
IOBUFCTRL_UNDERFLOW 8192
These OpenPGP introduced huffman like encoded length bytes are really a mess :-(
iobuf_read 1024 a->nlimit 0
These OpenPGP introduced huffman like encoded length bytes are really a mess :-(
iobuf_read 2 a->nlimit 0
Caller params - in: 0x0, inlen: 0
_gcry_cipher_decrypt inlen: 0, outSize: 10, unused: 0
Caller requested in-place encryption.
_gcry_cipher_cfb_decrypt inbuflen 10 outbuflen 10 cfb_bulk 1
Initial iv contents: 0000000000000000
cfb_decrypt 4 10 10 0
cfb_decrypt 5 10 10 0
0000000000000000
B3E55D4E25090582
cfb_decrypt 6 2 10 0
B2C61829ACA2C86D
0F056AEEF440FCE6
C2EA6AEEF440FCE6
cipher_sync 6


GOOD KEY!

iobuf_push_filter 0
decode_filter control 1, ret_len=0 len=1044
proc_packets
do_proc_packets 1044
dbg_parse_packet
parse
decode_filter control 3, ret_len=8192 len=1044
control == IOBUFCTRL_UNDERFLOW
fill_buffer
dfx->partial nread=0 nbytes=1044
iobuf_read 1044 a->nlimit 0
cipher_hd is allocated
Caller params - in: 0x0, inlen: 1044
_gcry_cipher_decrypt inlen: 1044, outSize: 1044, unused: 0
Caller requested in-place encryption.
_gcry_cipher_cfb_decrypt inbuflen 1044 outbuflen 1044 cfb_bulk 1
Initial iv contents: 1829ACA2C86DC2EA
cfb_decrypt 3 1044 1044 0
_gcry_cast5_cfb_dec
nblocks: 130
IV: 1829ACA2C86DC2EA
��b`�0

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque elementum, felis nec ultricies placerat, ante sapien aliquam massa, sit amet sagittis tortor magna tincidunt diam. Cras in tempus ex. Sed vel eros at erat consectetur consequat non nec dolor. Maecenas nunc nibh, accumsan aliquet commodo sit amet, dignissim sit amet felis. Quisque porttitor, dolor pharetra aliquam semper, orci nunc tristique tellus, eu mollis ipsum ligula ac mi. Fusce mollis malesuada mi non feugiat. Nulla tellus n�4ulla, convallis non orci sit amet, sollicitudin fringilla tellus. Donec vitae elit a dolor ultrices condimentum eget sed urna. Quisque aliquet urna elementum mi mattis, sed rhoncus nisi consequat. Fusce varius tempus justo quis congue.

Maecenas eget felis eu eros pulvinar fermentum. Aliquam id faucibus eros. Phasellus nec rutrum massa. Vivamus sit amet ligula id magna placerat pharetra. Sed elementum orci et feugiat laoreet. Donec lacinia euismod leo, ac rhoncus ante posuere a. Sed porttitor. 
ր��e��]N%       ���]N%  �

_gcry_cast5_cfb_dec END
cfb_decrypt 6 4 1044 0
0000000000000000
B3E55D4E25090582
0000000025090582
Starting packet parse at position: 28
Read CTB: 0xcb (new_format=1)
iobuf_set_partial_body_length_mode 233
pushing partial block filter 0
iobuf_push_filter 0
block_filter IOBUFCTRL_INIT
Parsing new format packet length
First length byte: 0xe9
One byte length: 0
Two byte length: 0
Four byte length: 0
Partial length encoding: mode=0xe9
Parsing old format length (lenbytes=0)
Old format packet length: 0
Begin processing packet (type=11, len=0, partial=1)
Skipping packet type 11
Packet processing complete (rc=2)
Processing packet type: PLAINTEXT (11)
block_filter IOBUFCTRL_UNDERFLOW
IOBUFCTRL_UNDERFLOW 8192
These OpenPGP introduced huffman like encoded length bytes are really a mess :-(
iobuf_read 512 a->nlimit 0
These OpenPGP introduced huffman like encoded length bytes are really a mess :-(
iobuf_read 500 a->nlimit 0
Packet header (2 bytes):
2 bytes:
8d   cbe9                                      ..
dbg_parse_packet
parse
Starting packet parse at position: 36
Read CTB: 0x0a (new_format=0)
[don't know]: invalid packet (ctb=0a)
free_packet() type=11
free_packet() type=11
decrypt_data result: 0
�decryption okay
WARNING: message was not integrity protected
free_packet() type=9
 dbg_parse_packet
parse
Starting packet parse at position: 37
Read CTB: 0x0a (new_format=0)
[don't know]: invalid packet (ctb=0a)
free_packet() type=9
free_packet() type=9
Decryption failed with code: 14
Printf initialised!
Guard values after decrypt: 0xDEADBEEF 0xBABECAFE
QEMU: Terminated
rm src/start.s




head -c 87222 lorem.txt | ./g10/gpg --symmetric --compress-algo none --cipher-algo CAST5 --passphrase "passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword" --s2k-digest-algo SHA1 --batch --rfc2440 --verbose > passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword.gpg && ls -la passwordpasswordpasswordpasswordpasswordpasswordpasswordpassword.gpg #TARGET=87282

