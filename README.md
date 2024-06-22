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
echo "A small amount of text" | gpg --symmetric --cipher-algo CAST5 --passphrase "password" --batch > encrypted.gpg

# And decrypt...
gpg --decrypt --passphrase "password" --batch encrypted.gpg

# Taking the encrypted file hex
xxd -p -c 100000 encrypted.gpg 
8c0d0403030289a71db66a8c902effd244019109abb415910e93142e3aa4482ce3106c4ada74bc22e1a6ae31b9090e10dea2ecb81bf60cebb3017e98c22d9c6bd4ef58060d99f1158465ec680071ac746c1bf909bf

# Now we can use it in the program
```