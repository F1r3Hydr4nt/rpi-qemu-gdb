#!/usr/bin/env python3
import sys
import os

def read_binary_file(filename):
    """Read a binary file and return its contents"""
    with open(filename, 'rb') as f:
        data = f.read()
    return data

def main():
    if len(sys.argv) != 7:
        print("Usage: verify-patcher.py <input_kernel.img> <output_kernel.img> <new_gpg_file> <original_gpg_file> <key_offset> <data_offset>")
        print("Example: verify-patcher.py kernel1.img patchedKernel.img new.gpg original.gpg 0x14668 0x14C84")
        return 1
    
    # Parse command line arguments
    input_kernel = sys.argv[1]
    output_kernel = sys.argv[2]
    new_gpg_file = sys.argv[3]
    original_gpg_file = sys.argv[4]
    key_offset = int(sys.argv[5], 0)  # Parse as hex if prefixed with 0x
    data_offset = int(sys.argv[6], 0)
    
    # Hardcoded values
    original_key = b"aa26542afd6f970982eedb0ca8477fd7"
    new_key = b"427c028e28eeb15464c376d7dcca6ca2"
    
    print(f"Reading files...")
    try:
        # Read all required files
        kernel_data = bytearray(read_binary_file(input_kernel))
        new_gpg_data = read_binary_file(new_gpg_file)
        original_gpg_data = read_binary_file(original_gpg_file)
        
        print(f"Input kernel size: {len(kernel_data)} bytes")
        print(f"New GPG file size: {len(new_gpg_data)} bytes")
        print(f"Original GPG file size: {len(original_gpg_data)} bytes")
        
        # Verify key
        kernel_key = kernel_data[key_offset:key_offset+len(original_key)]
        if kernel_key == original_key:
            print(f"✓ Key verification success at offset 0x{key_offset:X}")
            print(f"  Found: {kernel_key.decode('ascii')}")
        else:
            print(f"✗ Key verification failed at offset 0x{key_offset:X}")
            print(f"  Expected: {original_key.decode('ascii')}")
            print(f"  Found: {kernel_key.decode('ascii', errors='replace')}")
            response = input("Continue anyway? (y/n): ")
            if response.lower() != 'y':
                return 1
        
        # Verify GPG data
        kernel_gpg = kernel_data[data_offset:data_offset+len(original_gpg_data)]
        
        if len(kernel_gpg) != len(original_gpg_data):
            print(f"✗ Data length mismatch at offset 0x{data_offset:X}")
            print(f"  Kernel data: {len(kernel_gpg)} bytes")
            print(f"  Original GPG: {len(original_gpg_data)} bytes")
        
        # Count matching bytes
        matching_bytes = sum(a == b for a, b in zip(kernel_gpg, original_gpg_data))
        match_percent = (matching_bytes / min(len(kernel_gpg), len(original_gpg_data))) * 100
        
        if kernel_gpg == original_gpg_data:
            print(f"✓ GPG data verification success at offset 0x{data_offset:X}")
            print(f"  100% match ({matching_bytes}/{len(original_gpg_data)} bytes)")
        else:
            print(f"✗ GPG data verification failed at offset 0x{data_offset:X}")
            print(f"  Match: {match_percent:.2f}% ({matching_bytes}/{min(len(kernel_gpg), len(original_gpg_data))} bytes)")
            
            # Show the first bytes for comparison
            preview_len = min(20, len(kernel_gpg), len(original_gpg_data))
            print(f"\nFirst {preview_len} bytes comparison:")
            print(f"  Kernel: {kernel_gpg[:preview_len].hex()}")
            print(f"  Expected: {original_gpg_data[:preview_len].hex()}")
            
            response = input("Continue with patching anyway? (y/n): ")
            if response.lower() != 'y':
                return 1
        
        # Apply patches
        print("\nApplying patches...")
        
        # Patch key
        print(f"Patching key at offset 0x{key_offset:X}")
        kernel_data[key_offset:key_offset+len(new_key)] = new_key
        
        # Patch GPG data
        print(f"Patching GPG data at offset 0x{data_offset:X}")
        kernel_data[data_offset:data_offset+len(new_gpg_data)] = new_gpg_data
        
        # Write output file
        with open(output_kernel, 'wb') as f:
            f.write(kernel_data)
        
        print(f"\n✓ Successfully created patched kernel: {output_kernel}")
        return 0
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())