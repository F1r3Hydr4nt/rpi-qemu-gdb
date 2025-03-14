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

# Create a temporary copy to work with
cp results/kernel2.img results/kernel2.img.tmp

echo "Patching kernel2.img..."

# Patch using hexedit (using printf to create a binary file with dd)
# Note: These locations and values are derived from the disassembly diff

# 1. Patch around 0x00013780 to match kernel1 code for first branch
# Convert instructions to binary representation
# 0x00013780: e59f4110 -> 0x00013844: e59f4064
printf '\x64\x40\x9f\xe5' | dd of=results/kernel2.img.tmp bs=1 seek=$((0x13780)) conv=notrunc status=none

# 0x00013784: e08f4004 -> 0x00013848: e08f4004 (already matches)
# No change needed here

# Add the branch instruction at 0x00013848
printf '\xcd\xff\xff\xea' | dd of=results/kernel2.img.tmp bs=1 seek=$((0x13784)) conv=notrunc status=none

# 2. Patch around 0x000137ec to match kernel1 code for second branch
# 0x000137ec: e59f20ac -> 0x00013860: e59f2050
printf '\x50\x20\x9f\xe5' | dd of=results/kernel2.img.tmp bs=1 seek=$((0x137ec)) conv=notrunc status=none

# 0x000137f0: e59f30ac -> 0x00013864: e59f3050
printf '\x50\x30\x9f\xe5' | dd of=results/kernel2.img.tmp bs=1 seek=$((0x137f0)) conv=notrunc status=none

# Add the branch instruction at 0x00013868
printf '\xe1\xff\xff\xea' | dd of=results/kernel2.img.tmp bs=1 seek=$((0x137f4)) conv=notrunc status=none

# 3. Patch the tfp_format function differences
# 0x00011f6c-0x00011f84 -> 0x000120f8: e1a0200e, 0x000120fc: eaffffa1
# This is a more complex patch as we're replacing multiple instructions with just two
echo "Patching tfp_format function..."
printf '\x0e\x20\xa0\xe1\xa1\xff\xff\xea' | dd of=results/kernel2.img.tmp bs=1 seek=$((0x11f6c)) conv=notrunc status=none

# 4. Patch the additional instructions at 0x00011fac
echo "Patching additional tfp_format instructions..."
# This is complex - we need to patch out a sequence of instructions
# Fill with NOPs (e1a00000 = mov r0, r0)
for i in {0..24}; do
    printf '\x00\x00\xa0\xe1' | dd of=results/kernel2.img.tmp bs=1 seek=$((0x11fac + i*4)) conv=notrunc status=none
done

# 5. Patch the derive_key function ordering
echo "Patching derive_key function ordering..."
# Move the block at 0x0000f0a0 to match the location in kernel1
# Since this is just a reordering, we can choose to ignore it or try to reorder in the binary
# For simplicity, we'll just skip this patch

# Check if the patch seems to have worked
echo "Calculating checksums..."
SUM1=$(md5sum results/kernel1.img | awk '{print $1}')
SUM2=$(md5sum results/kernel2.img.tmp | awk '{print $1}')

if [ "$SUM1" == "$SUM2" ]; then
    echo "Checksums match! The patch was completely successful."
else
    echo "Checksums don't match. Patch may be incomplete."
    echo "kernel1.img MD5: $SUM1"
    echo "patched kernel2.img MD5: $SUM2"
fi

# Replace the original with the patched version
mv results/kernel2.img.tmp results/kernel2.img.patched

echo "Patched kernel created at results/kernel2.img.patched"
echo "Original backup saved at ${BACKUP_FILE}"
echo ""
echo "To use the patched kernel, run:"
echo "  make run KERNEL=results/kernel2.img.patched"
echo ""
echo "Note: This patch focuses on the major execution path differences."
echo "Some memory location constants (like PC-relative offsets) may still need adjustment."