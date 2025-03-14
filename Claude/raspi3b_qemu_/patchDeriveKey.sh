#!/bin/bash

# Check that kernel2.img exists
if [ ! -f "results/kernel2.img" ]; then
    echo "Error: results/kernel2.img not found."
    exit 1
fi

# Create timestamp for backup
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="results/kernel2.img.bak.${TIMESTAMP}"

# Make backup
echo "Creating backup of kernel2.img to ${BACKUP_FILE}..."
cp results/kernel2.img "${BACKUP_FILE}"

# Create a patched copy
cp results/kernel2.img results/kernel2.img.patched

echo "Patching kernel2.img based on execution logs..."

# # Patch #1: Fix the main function branch (around address 0x13780)
# echo "Patching main function branch points..."
# # Convert 0x00013780: e59f4110 to 0x00013844: e59f4064 (ldr r4, [pc, #100])
# printf '\x64\x40\x9f\xe5' | dd of=results/kernel2.img.patched bs=1 seek=$((0x13780)) conv=notrunc status=none
# # Add the branch instruction at 0x13784 (eaffffcd b 0x13788)
# printf '\xcd\xff\xff\xea' | dd of=results/kernel2.img.patched bs=1 seek=$((0x13784)) conv=notrunc status=none

# # Patch #2: Fix the second branch point in main (around address 0x137ec)
# # Convert 0x000137ec: e59f20ac to 0x00013860: e59f2050 (ldr r2, [pc, #80])
# printf '\x50\x20\x9f\xe5' | dd of=results/kernel2.img.patched bs=1 seek=$((0x137ec)) conv=notrunc status=none
# # Convert 0x000137f0: e59f30ac to 0x00013864: e59f3050 (ldr r3, [pc, #80])
# printf '\x50\x30\x9f\xe5' | dd of=results/kernel2.img.patched bs=1 seek=$((0x137f0)) conv=notrunc status=none
# # Add the branch instruction at 0x137f4 (eaffffe1 b 0x137f4)
# printf '\xe1\xff\xff\xea' | dd of=results/kernel2.img.patched bs=1 seek=$((0x137f4)) conv=notrunc status=none

# # Patch #3: Fix the tfp_format function (around address 0x11f6c)
# echo "Patching tfp_format function..."
# # Replace the complex math sequence with the simpler version:
# # 0x000120f8: e1a0200e (mov r2, lr)
# # 0x000120fc: eaffffa1 (b 0x11f88)
# printf '\x0e\x20\xa0\xe1\xa1\xff\xff\xea' | dd of=results/kernel2.img.patched bs=1 seek=$((0x11f6c)) conv=notrunc status=none

# # Patch #4: Remove the additional tfp_format instructions (around address 0x11fac)
# echo "Patching additional tfp_format instructions..."
# # Fill with NOPs (e1a00000 = mov r0, r0) to effectively remove these instructions
# for i in {0..6}; do
#     printf '\x00\x00\xa0\xe1' | dd of=results/kernel2.img.patched bs=1 seek=$((0x11fac + i*4)) conv=notrunc status=none
# done

# Patch #5: Fix the derive_key ordering (around address 0xf0a0)
echo "Patching derive_key function ordering..."
# This is more complex - we'd need to modify the control flow
# For now, we'll just replace the instructions with NOPs at the problematic
# addresses and hope it forces the right flow
for i in {0..3}; do
    printf '\x00\x00\xa0\xe1' | dd of=results/kernel2.img.patched bs=1 seek=$((0xf0a0 + i*4)) conv=notrunc status=none
done

echo "Patching complete!"
echo "Patched kernel is at results/kernel2.img.patched"
# echo ""
# echo "To test the patched kernel, you can add these targets to your Makefile:"
# echo ""
# echo "runpatch:"
# echo "	\$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -nographic -serial mon:stdio"
# echo ""
# echo "logpatch:"
# echo "	@mkdir -p results"
# echo "	\$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -d int,guest_errors,mmu,in_asm -D results/kernel2.patched.in_asm.log -nographic -serial mon:stdio"
# echo ""
echo "Run: make runpatch"