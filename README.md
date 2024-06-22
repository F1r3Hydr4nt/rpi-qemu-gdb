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
```