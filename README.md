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
