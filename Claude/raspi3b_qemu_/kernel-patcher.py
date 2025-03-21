#!/usr/bin/env python3
import sys
import os
import binascii
import shutil

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

def find_key_chunks(data, original_key, chunk_size=4, min_match_percent=50):
    """
    Find chunks of a key that might be stored non-contiguously
    
    Args:
        data: Binary data to search in
        original_key: Complete key to look for
        chunk_size: Size of each key chunk in bytes
        min_match_percent: Minimum percentage match required for a chunk
        
    Returns:
        List of tuples (chunk_offset, chunk_data) or empty list if not found
    """
    key_chunks = []
    
    # Divide the key into chunks
    total_chunks = (len(original_key) + chunk_size - 1) // chunk_size
    
    for i in range(total_chunks):
        start_idx = i * chunk_size
        end_idx = min(start_idx + chunk_size, len(original_key))
        chunk = original_key[start_idx:end_idx]
        
        # Find this chunk in the data - use a lower threshold for initial detection
        # We'll sort through potential matches after
        chunk_offset, match_percent = find_best_offset(data, chunk, 30)  # Lower threshold to catch more potential matches
        
        if chunk_offset is not None:
            key_chunks.append((chunk_offset, chunk))
            print(f"  Found key chunk {i+1}/{total_chunks} at offset {chunk_offset} (0x{chunk_offset:X}) with {match_percent:.2f}% match")
            # Also print the actual bytes found for debugging
            actual_chunk = data[chunk_offset:chunk_offset+len(chunk)]
            print(f"    Expected: {chunk.hex()}")
            print(f"    Found: {actual_chunk.hex()}")
        else:
            print(f"  Could not find key chunk {i+1}/{total_chunks}")
            
            # Try a byte-by-byte search for partial matches
            print(f"    Trying byte-by-byte search for partial matches...")
            potential_matches = []
            
            # Use a sliding window approach with a step size to speed up the search
            step_size = 16  # Check every 16 bytes initially
            for i in range(0, len(data) - len(chunk), step_size):
                actual_bytes = data[i:i+len(chunk)]
                matching_bytes = sum(a == b for a, b in zip(actual_bytes, chunk))
                match_percent = (matching_bytes / len(chunk)) * 100
                
                if matching_bytes >= 1:  # At least one byte matches - collect for further analysis
                    potential_matches.append((i, matching_bytes, match_percent))
            
            # Sort by match quality and show top matches
            if potential_matches:
                potential_matches.sort(key=lambda x: x[1], reverse=True)
                print(f"    Found {len(potential_matches)} potential partial matches. Top 5:")
                for j, (offset, matching, percent) in enumerate(potential_matches[:5]):
                    actual_bytes = data[offset:offset+len(chunk)]
                    print(f"      {j+1}. Offset 0x{offset:X} with {matching}/{len(chunk)} bytes matching ({percent:.2f}%)")
                    print(f"         Expected: {chunk.hex()}")
                    print(f"         Found: {actual_bytes.hex()}")
            else:
                print("    No potential matches found.")
    
    return key_chunks

def main():
    if len(sys.argv) < 5:
        print("Usage: chunked_key_kernel_patcher.py <input_kernel.img> <output_kernel.img> <new_gpg_file> <original_gpg_file> [chunk_size] [key_offsets] [data_offset]")
        print("Example: chunked_key_kernel_patcher.py kernel1.img patchedKernel.img new.gpg original.gpg")
        print("Example with chunk size: chunked_key_kernel_patcher.py kernel1.img patchedKernel.img new.gpg original.gpg 4")
        print("Example with offsets: chunked_key_kernel_patcher.py kernel1.img patchedKernel.img new.gpg original.gpg 4 \"0x14668,0x14A20,0x15B30,0x16C40\" 0x14C84")
        return 1
    
    # Parse command line arguments
    input_kernel = sys.argv[1]
    output_kernel = sys.argv[2]
    new_gpg_file = sys.argv[3]
    original_gpg_file = sys.argv[4]
    
    # Optional chunk size
    chunk_size = 4  # Default chunk size (4 bytes per chunk)
    if len(sys.argv) >= 6:
        try:
            chunk_size = int(sys.argv[5])
        except ValueError:
            print(f"Invalid chunk size: {sys.argv[5]}. Using default: {chunk_size}")
    
    # Optional manual key offsets
    key_offsets = None
    if len(sys.argv) >= 7:
        try:
            # Parse comma-separated list of hex offsets
            key_offsets = [int(offset.strip(), 0) for offset in sys.argv[6].split(',')]
        except ValueError:
            print(f"Invalid key offsets format: {sys.argv[6]}")
            return 1
    
    # Optional manual data offset
    data_offset = None
    if len(sys.argv) >= 8:
        try:
            data_offset = int(sys.argv[7], 0)
        except ValueError:
            print(f"Invalid data offset: {sys.argv[7]}")
            return 1
    
    # Hardcoded key values
    original_key = b"aa26542afd6f970982eedb0ca8477fd7"
    new_key = b"427c028e28eeb15464c376d7dcca6ca2"
    
    # Check if the keys need to be decoded from hex strings to binary
    if all(c in b'0123456789abcdefABCDEF' for c in original_key):
        try:
            original_key = binascii.unhexlify(original_key)
            print("Note: Original key was in hex format, converted to binary")
        except:
            print("Note: Original key appears to be in hex format but couldn't be converted")
    
    if all(c in b'0123456789abcdefABCDEF' for c in new_key):
        try:
            new_key = binascii.unhexlify(new_key)
            print("Note: New key was in hex format, converted to binary")
        except:
            print("Note: New key appears to be in hex format but couldn't be converted")
    
    print(f"Reading files...")
    try:
        # Read all required files
        kernel_data = read_binary_file(input_kernel)
        new_gpg_data = read_binary_file(new_gpg_file)
        original_gpg_data = read_binary_file(original_gpg_file)
        
        print(f"Input kernel size: {len(kernel_data)} bytes")
        print(f"New GPG file size: {len(new_gpg_data)} bytes")
        print(f"Original GPG file size: {len(original_gpg_data)} bytes")
        
        # Calculate total chunks needed
        total_chunks = (len(original_key) + chunk_size - 1) // chunk_size
        print(f"Key will be divided into {total_chunks} chunks of {chunk_size} bytes each")
        
        # Auto-detect key chunk offsets if not specified
        if key_offsets is None:
            print("\nAuto-detecting key chunk offsets...")
            key_chunks = find_key_chunks(kernel_data, original_key, chunk_size)
            
            if len(key_chunks) == 0:
                print("✗ Could not find any key chunks in kernel.")
                print("  Please specify key offsets manually.")
                return 1
            elif len(key_chunks) < total_chunks:
                print(f"✗ Only found {len(key_chunks)}/{total_chunks} key chunks.")
                
                # Ask user to provide missing chunks manually
                print("\nEnter key chunk offsets manually (comma-separated hex values, e.g. 0x14668,0x14A20) or leave empty to abort: ", end="")
                user_input = input().strip()
                if user_input:
                    try:
                        key_offsets = [int(offset.strip(), 0) for offset in user_input.split(',')]
                        if len(key_offsets) != total_chunks:
                            print(f"Warning: Expected {total_chunks} offsets but received {len(key_offsets)}.")
                    except ValueError:
                        print("Invalid offset format.")
                        return 1
                else:
                    print("Aborting.")
                    return 1
            else:
                # Use the offsets found by auto-detection
                key_offsets = [offset for offset, _ in key_chunks]
                print(f"✓ Found all {total_chunks} key chunks")
        
        # Convert kernel_data to bytearray for modification (at this point it's still a bytes object)
        kernel_data = bytearray(kernel_data)
        
        # Verify key chunks
        key_chunks_data = []
        key_chunks_verified = True
        
        print("\nVerifying key chunks:")
        for i, offset in enumerate(key_offsets):
            start_idx = i * chunk_size
            end_idx = min(start_idx + chunk_size, len(original_key))
            expected_chunk = original_key[start_idx:end_idx]
            
            actual_chunk = kernel_data[offset:offset+len(expected_chunk)]
            key_chunks_data.append(actual_chunk)
            
            matching_bytes = sum(a == b for a, b in zip(actual_chunk, expected_chunk))
            match_percent = (matching_bytes / len(expected_chunk)) * 100
            
            if actual_chunk == expected_chunk:
                print(f"✓ Chunk {i+1}/{total_chunks} verification success at offset 0x{offset:X}")
                print(f"  Expected: {expected_chunk.hex()}")
                print(f"  Found: {actual_chunk.hex()}")
            else:
                print(f"✗ Chunk {i+1}/{total_chunks} verification partial match at offset 0x{offset:X}")
                print(f"  Expected: {expected_chunk.hex()}")
                print(f"  Found: {actual_chunk.hex()}")
                print(f"  Match: {match_percent:.2f}% ({matching_bytes}/{len(expected_chunk)} bytes)")
                key_chunks_verified = False
        
        if not key_chunks_verified:
            response = input("\nNot all key chunks verified. Continue anyway? (y/n): ")
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
                
                # Start search around the key chunks
                search_start = max(0, min(key_offsets) - 1024)  # Start a bit before the first key chunk
                search_end = min(len(kernel_data) - window_size, max(key_offsets) + 1024)  # End a bit after the last key chunk
                
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
        
        # Instead of modifying the kernel_data in-place, first copy the entire input kernel to the output file
        print(f"\nCopying full kernel from {input_kernel} to {output_kernel}...")
        shutil.copy2(input_kernel, output_kernel)
        
        # Now open the output file for binary read/write to apply the patches
        with open(output_kernel, 'r+b') as f:
            # Divide new key into chunks
            new_key_chunks = []
            for i in range(total_chunks):
                start_idx = i * chunk_size
                end_idx = min(start_idx + chunk_size, len(new_key))
                new_key_chunks.append(new_key[start_idx:end_idx])
            
            print("\nApplying patches to the copied kernel...")
            
            # Patch key chunks
            for i, (offset, chunk) in enumerate(zip(key_offsets, new_key_chunks)):
                print(f"Patching key chunk {i+1}/{total_chunks} at offset 0x{offset:X}")
                original_bytes = kernel_data[offset:offset+len(chunk)]
                try:
                    print(f"  Original: {original_bytes.decode('ascii', errors='replace')}")
                    print(f"  New: {chunk.decode('ascii', errors='replace')}")
                except:
                    print(f"  Original (hex): {original_bytes.hex()}")
                    print(f"  New (hex): {chunk.hex()}")
                
                # Seek to the position and write the chunk
                f.seek(offset)
                f.write(chunk)
            
            # Patch GPG data
            print(f"Patching GPG data at offset 0x{data_offset:X}")
            f.seek(data_offset)
            f.write(new_gpg_data)
        
        print(f"\n✓ Successfully created patched kernel: {output_kernel}")
        
        # Print all detected offsets for reference
        print("\nDetected Offsets Summary:")
        print(f"  GPG Data offset: 0x{data_offset:X}")
        print("  Key chunk offsets:")
        for i, offset in enumerate(key_offsets):
            print(f"    Chunk {i+1}/{total_chunks}: 0x{offset:X}")
        
        # Print the command that would use these offsets with this script for future reference
        key_offsets_str = ",".join([f"0x{offset:X}" for offset in key_offsets])
        print(f"\nFor future reference, you can use these offsets with this script:")
        print(f"python chunked_key_kernel_patcher.py {input_kernel} {output_kernel} {new_gpg_file} {original_gpg_file} {chunk_size} \"{key_offsets_str}\" 0x{data_offset:X}")
        
        return 0
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
    