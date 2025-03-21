#!/usr/bin/env python3
"""
Kernel Diff Regions Calculator
Identifies different regions and their sizes between two kernel.img files
"""

import argparse
import os
import sys
from collections import defaultdict

def read_binary_file(file_path, start=None, size=None):
    """Read binary file into a bytearray, optionally with offset and size limits."""
    try:
        with open(file_path, 'rb') as f:
            if start is not None:
                f.seek(start)
            if size is not None:
                return bytearray(f.read(size))
            else:
                return bytearray(f.read())
    except Exception as e:
        print(f"Error reading {file_path}: {e}", file=sys.stderr)
        sys.exit(1)

def find_diff_regions(file1, file2):
    """Find contiguous regions of differences between two binary files."""
    data1 = read_binary_file(file1)
    data2 = read_binary_file(file2)
    
    max_length = max(len(data1), len(data2))
    diff_positions = []
    
    # First pass: find all differing byte positions
    for i in range(max_length):
        byte1 = data1[i] if i < len(data1) else None
        byte2 = data2[i] if i < len(data2) else None
        
        if byte1 != byte2:
            diff_positions.append(i)
    
    # Second pass: identify contiguous regions
    diff_regions = []
    if not diff_positions:
        return diff_regions  # No differences found
    
    # Start the first region
    region_start = diff_positions[0]
    last_pos = region_start
    
    # Process each differing position
    for pos in diff_positions[1:]:
        # If position is not consecutive, we found a new region
        if pos > last_pos + 1:
            # Save the previous region (start offset, size)
            diff_regions.append((region_start, last_pos - region_start + 1))
            # Start a new region
            region_start = pos
        
        last_pos = pos
    
    # Add the final region
    diff_regions.append((region_start, last_pos - region_start + 1))
    
    return diff_regions

def format_hex_dump(data, max_bytes=16):
    """Format a small hex dump of the data."""
    if not data:
        return "    (empty)"
    
    result = []
    bytes_to_show = min(len(data), max_bytes)
    
    # Generate the hex dump format
    offset_line = "    "
    hex_line = "    "
    ascii_line = "    "
    
    for i in range(bytes_to_show):
        byte = data[i]
        # Add hex representation
        hex_line += f"{byte:02x} "
        # Add ASCII representation (printable chars only)
        if 32 <= byte <= 126:  # Printable ASCII
            ascii_line += chr(byte)
        else:
            ascii_line += "."
    
    result.append(hex_line)
    result.append(ascii_line)
    
    return "\n".join(result)

def main():
    parser = argparse.ArgumentParser(description='Identify differing regions between two kernel image files.')
    parser.add_argument('file1', help='First kernel image file')
    parser.add_argument('file2', help='Second kernel image file')
    parser.add_argument('--verify', action='store_true', 
                        help='Verify if there are exactly two regions of 16 and 87212 bytes')
    args = parser.parse_args()
    
    # Check if files exist
    for f in [args.file1, args.file2]:
        if not os.path.isfile(f):
            print(f"Error: File not found: {f}", file=sys.stderr)
            sys.exit(1)
    
    # Display file information
    file1_size = os.path.getsize(args.file1)
    file2_size = os.path.getsize(args.file2)
    
    print("Analyzing differences between kernel image files...")
    print(f"File 1: {args.file1} ({file1_size} bytes)")
    print(f"File 2: {args.file2} ({file2_size} bytes)")
    print()
    
    # Find differing regions
    diff_regions = find_diff_regions(args.file1, args.file2)
    
    # Display summary
    total_diff_bytes = sum(size for _, size in diff_regions)
    
    print("=" * 50)
    print(f"DIFF REGIONS SUMMARY: Found {len(diff_regions)} differing regions totaling {total_diff_bytes} bytes")
    print("=" * 50)
    
    if not diff_regions:
        print("No differences found. Files are identical.")
        return
    
    # Display each region with formatted output
    for i, (start_pos, size) in enumerate(diff_regions, 1):
        print(f"\nRegion {i}:")
        print(f"  Start offset: 0x{start_pos:08x} (decimal: {start_pos})")
        print(f"  End offset:   0x{start_pos + size - 1:08x} (decimal: {start_pos + size - 1})")
        print(f"  Size:         {size} bytes")
        
        # Show a small hex dump of the beginning of the region
        print("  Preview of region in first file:")
        data1 = read_binary_file(args.file1, start_pos, min(size, 16))
        print(format_hex_dump(data1))
        
        print("  Preview of region in second file:")
        data2 = read_binary_file(args.file2, start_pos, min(size, 16))
        print(format_hex_dump(data2))
        if i > 10:
            break
    
    # Verify specific region sizes if requested
    if args.verify:
        expected_sizes = [16, 87212]
        actual_sizes = sorted([size for _, size in diff_regions])
        
        if len(diff_regions) == 2 and actual_sizes == expected_sizes:
            print("\n✓ VERIFICATION PASSED: Found exactly two regions with sizes 16 bytes and 87212 bytes as expected")
        else:
            print("\n✗ VERIFICATION FAILED:")
            print(f"  Expected: Two regions with sizes {expected_sizes}")
            print(f"  Found: {len(diff_regions)} regions with sizes {actual_sizes}")
    
    print("\nAnalysis complete.")

if __name__ == '__main__':
    main()