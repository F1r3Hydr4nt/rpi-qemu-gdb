#!/usr/bin/env python3
import sys
import os
import binascii

def read_binary_file(filename):
    """Read a binary file and return its contents"""
    with open(filename, 'rb') as f:
        data = f.read()
    return data

def find_best_offset(data, search_pattern, min_match_percent=80):
    """
    Find the best offset for a pattern in binary data based on partial matching
    
    Args:
        data: Binary data to search in
        search_pattern: Pattern to search for
        min_match_percent: Minimum percentage of bytes that must match
        
    Returns:
        Tuple of (best_offset, match_percent) or (None, 0) if no match found
    """
    best_offset = None
    best_match_percent = 0
    
    # Step through the file
    for i in range(len(data) - len(search_pattern) + 1):
        chunk = data[i:i+len(search_pattern)]
        matching_bytes = sum(a == b for a, b in zip(chunk, search_pattern))
        match_percent = (matching_bytes / len(search_pattern)) * 100
        
        if match_percent > best_match_percent:
            best_match_percent = match_percent
            best_offset = i
    
    if best_match_percent >= min_match_percent:
        return best_offset, best_match_percent
    else:
        return None, 0

def main():
    if len(sys.argv) < 5:
        print("Usage: auto_offset_kernel_patcher.py <input_kernel.img> <output_kernel.img> <new_gpg_file> <original_gpg_file> [key_offset] [data_offset]")
        print("Example: auto_offset_kernel_patcher.py kernel1.img patchedKernel.img new.gpg original.gpg")
        print("Example with offsets: auto_offset_kernel_patcher.py kernel1.img patchedKernel.img new.gpg original.gpg 0x14668 0x14C84")
        return 1
    
    # Parse command line arguments
    input_kernel = sys.argv[1]
    output_kernel = sys.argv[2]
    new_gpg_file = sys.argv[3]
    original_gpg_file = sys.argv[4]
    
    # Optional manual offsets
    key_offset = None
    data_offset = None
    
    if len(sys.argv) >= 6:
        key_offset = int(sys.argv[5], 0)  # Parse as hex if prefixed with 0x
    
    if len(sys.argv) >= 7:
        data_offset = int(sys.argv[6], 0)
    
    # Hardcoded key values
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
        
        # Auto-detect key offset if not specified
        if key_offset is None:
            print("\nAuto-detecting key offset...")
            key_offset, key_match_percent = find_best_offset(kernel_data, original_key)
            
            if key_offset is not None:
                print(f"✓ Found key at offset {key_offset} (0x{key_offset:X}) with {key_match_percent:.2f}% match")
            else:
                print("✗ Could not find key in kernel. Trying partial matches...")
                
                # Try finding partial matches by checking smaller chunks
                for i in range(0, len(original_key), 4):
                    chunk = original_key[i:i+min(4, len(original_key)-i)]
                    if len(chunk) < 4:  # Skip chunks that are too small
                        continue
                        
                    pos = 0
                    while True:
                        pos = kernel_data.find(chunk, pos)
                        if pos == -1:
                            break
                        
                        # Check the surrounding bytes to see if this could be our key
                        potential_key_offset = pos - i
                        if potential_key_offset >= 0 and potential_key_offset + len(original_key) <= len(kernel_data):
                            potential_key = kernel_data[potential_key_offset:potential_key_offset+len(original_key)]
                            matching_bytes = sum(a == b for a, b in zip(potential_key, original_key))
                            match_percent = (matching_bytes / len(original_key)) * 100
                            
                            if match_percent >= 50:  # At least 50% match
                                print(f"  Potential key at offset {potential_key_offset} (0x{potential_key_offset:X}) with {match_percent:.2f}% match")
                                print(f"    Found: {potential_key}")
                        
                        pos += 1
                
                print("\nEnter key offset manually (in hex, e.g. 0x14668) or leave empty to abort: ", end="")
                user_input = input().strip()
                if user_input:
                    try:
                        key_offset = int(user_input, 0)
                    except ValueError:
                        print("Invalid offset format.")
                        return 1
                else:
                    print("Aborting.")
                    return 1
        
        # Verify key
        kernel_key = kernel_data[key_offset:key_offset+len(original_key)]
        matching_key_bytes = sum(a == b for a, b in zip(kernel_key, original_key))
        key_match_percent = (matching_key_bytes / len(original_key)) * 100
        
        if kernel_key == original_key:
            print(f"✓ Key verification success at offset 0x{key_offset:X}")
            print(f"  Found: {kernel_key.decode('ascii')}")
        else:
            print(f"✗ Key verification partial match at offset 0x{key_offset:X}")
            print(f"  Expected: {original_key.decode('ascii')}")
            print(f"  Found: {kernel_key.decode('ascii', errors='replace')}")
            print(f"  Match: {key_match_percent:.2f}% ({matching_key_bytes}/{len(original_key)} bytes)")
            
            response = input("Continue anyway? (y/n): ")
            if response.lower() != 'y':
                return 1
        
        # Auto-detect GPG data offset if not specified
        if data_offset is None:
            print("\nAuto-detecting GPG data offset...")
            
            # Try using the first 32 bytes of the original GPG data as a signature
            gpg_signature = original_gpg_data[:min(32, len(original_gpg_data))]
            data_offset, data_match_percent = find_best_offset(kernel_data, gpg_signature)
            
            if data_offset is not None:
                print(f"✓ Found GPG data at offset {data_offset} (0x{data_offset:X}) with {data_match_percent:.2f}% match")
            else:
                print("✗ Could not find GPG data in kernel automatically with signature approach.")
                print("  Switching to comprehensive search using the entire GPG file...")
                
                # Use the entire GPG file contents to find the best match in the kernel
                best_offset = None
                best_match_percent = 0
                best_matching_bytes = 0
                
                # For larger files, we might want to use a sliding window approach
                window_size = min(1024, len(original_gpg_data))  # Use first 1KB or entire file
                
                # We'll check every potential offset in the kernel, but limit the search to reasonable bounds
                # This assumes GPG data is typically in the latter part of the kernel
                search_start = max(0, key_offset - 1024)  # Start a bit before the key if possible
                search_end = min(len(kernel_data) - window_size, len(kernel_data))
                
                print(f"  Searching from offset 0x{search_start:X} to 0x{search_end:X}...")
                
                # We'll check at increments to speed things up, then refine
                step = 16  # Check every 16 bytes initially
                for offset in range(search_start, search_end, step):
                    # Get a chunk of kernel data at this offset
                    kernel_chunk = kernel_data[offset:offset+window_size]
                    
                    # Compare with GPG data
                    matching_bytes = sum(a == b for a, b in zip(kernel_chunk, original_gpg_data[:window_size]))
                    match_percent = (matching_bytes / window_size) * 100
                    
                    # Keep track of best match
                    if match_percent > best_match_percent:
                        best_offset = offset
                        best_match_percent = match_percent
                        best_matching_bytes = matching_bytes
                
                # If we found a reasonable match, refine by checking nearby offsets
                if best_match_percent >= 50:
                    print(f"  Found potential match at 0x{best_offset:X} with {best_match_percent:.2f}% match, refining...")
                    
                    # Check nearby offsets more precisely
                    refine_start = max(0, best_offset - step)
                    refine_end = min(len(kernel_data) - window_size, best_offset + step)
                    
                    for offset in range(refine_start, refine_end):
                        kernel_chunk = kernel_data[offset:offset+window_size]
                        matching_bytes = sum(a == b for a, b in zip(kernel_chunk, original_gpg_data[:window_size]))
                        match_percent = (matching_bytes / window_size) * 100
                        
                        if match_percent > best_match_percent:
                            best_offset = offset
                            best_match_percent = match_percent
                            best_matching_bytes = matching_bytes
                    
                    print(f"  Refined match: offset 0x{best_offset:X} with {best_match_percent:.2f}% match ({best_matching_bytes}/{window_size} bytes)")
                    data_offset = best_offset
                else:
                    print(f"  Best match found was only {best_match_percent:.2f}% at offset 0x{best_offset:X}")
                    
                    # Try finding by looking for unique patterns in the GPG file
                    print("\n  Looking for unique patterns in the GPG file...")
                    # Find a reasonably unique sequence in the GPG file (first 16 bytes)
                    gpg_pattern = original_gpg_data[:16]
                    
                    positions = []
                    pos = 0
                    while True:
                        pos = kernel_data.find(gpg_pattern, pos)
                        if pos == -1:
                            break
                        positions.append(pos)
                        pos += 1
                    
                    if positions:
                        print(f"  Found {len(positions)} potential offsets for GPG data:")
                        potential_offsets = []
                        
                        for i, potential_offset in enumerate(positions[:5]):  # Show top 5
                            potential_data = kernel_data[potential_offset:potential_offset+min(128, len(original_gpg_data))]
                            matching_bytes = sum(a == b for a, b in zip(potential_data, original_gpg_data[:len(potential_data)]))
                            match_percent = (matching_bytes / len(potential_data)) * 100
                            print(f"    {i+1}. Offset: 0x{potential_offset:X} with {match_percent:.2f}% match in first {len(potential_data)} bytes")
                            potential_offsets.append((potential_offset, match_percent))
                        
                        # Ask the user to select one of the offsets
                        print("\n  Enter the number of the correct offset (1-5), or input a custom offset in hex, or leave empty to abort: ", end="")
                        user_input = input().strip()
                        
                        if user_input.isdigit() and 1 <= int(user_input) <= len(potential_offsets):
                            data_offset = potential_offsets[int(user_input)-1][0]
                        elif user_input:
                            try:
                                data_offset = int(user_input, 0)
                            except ValueError:
                                print("Invalid offset format.")
                                return 1
                        else:
                            print("Aborting.")
                            return 1
                    else:
                        print("  No exact patterns from GPG file found in kernel.")
                        print("\n  Enter GPG data offset manually (in hex, e.g. 0x14C84) or leave empty to abort: ", end="")
                        user_input = input().strip()
                        if user_input:
                            try:
                                data_offset = int(user_input, 0)
                            except ValueError:
                                print("Invalid offset format.")
                                return 1
                        else:
                            print("Aborting.")
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
        # Print the command that would use these offsets with the original script
        print(f"\nFor future reference, you can use these offsets with the original script:")
        print(f"python kernel-patcher.py {input_kernel} {output_kernel} {new_gpg_file} {original_gpg_file} 0x{key_offset:X} 0x{data_offset:X}")
        
        return 0
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())