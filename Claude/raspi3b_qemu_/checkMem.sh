#!/bin/bash

# Check if args are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <kernel_elf_file>"
    exit 1
fi

KERNEL_ELF="$1"
OUTPUT_DIR="results/memory_analysis_$(basename $KERNEL_ELF)"

# Check if file exists
if [ ! -f "$KERNEL_ELF" ]; then
    echo "Error: ELF file $KERNEL_ELF not found"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Analyzing memory layout of $KERNEL_ELF..."

# Generate symbol map sorted by address
arm-none-eabi-nm -n "$KERNEL_ELF" > "$OUTPUT_DIR/symbols_by_address.txt"

# Generate symbol map sorted by size
arm-none-eabi-nm -S "$KERNEL_ELF" | sort -k2,2 > "$OUTPUT_DIR/symbols_by_size.txt"

# Generate section information
arm-none-eabi-readelf -S "$KERNEL_ELF" > "$OUTPUT_DIR/sections.txt"

# Generate detailed section headers
arm-none-eabi-objdump -h "$KERNEL_ELF" > "$OUTPUT_DIR/section_headers.txt"

# Generate memory map
arm-none-eabi-objdump -x "$KERNEL_ELF" > "$OUTPUT_DIR/memory_map.txt"

# Generate disassembly with source
arm-none-eabi-objdump -S "$KERNEL_ELF" > "$OUTPUT_DIR/disassembly.txt"

# Find potential gaps in memory layout
echo "Analyzing memory layout for gaps and fragmentation..."
{
    echo "Memory layout analysis:"
    echo "----------------------"
    
    # Use objdump for more reliable section information
    sections=$(arm-none-eabi-objdump -h "$KERNEL_ELF" | grep -A1 -E "^[0-9]+" | grep -v "^--" | sed 's/^ *//')
    
    # Process section info to find gaps
    prev_end=0
    prev_name=""
    
    echo "$sections" | while read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        
        # Extract section information
        section_num=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        size=$(echo "$line" | awk '{print $3}')
        vma=$(echo "$line" | awk '{print $4}')
        lma=$(echo "$line" | awk '{print $5}')
        
        # Skip sections with zero size
        if [ "$size" = "00000000" ]; then
            continue
        fi
        
        # Convert hex to decimal (removing 0x prefix if present)
        size="${size#0x}"
        vma="${vma#0x}"
        
        size_dec=$((16#$size))
        vma_dec=$((16#$vma))
        
        # Calculate gap
        if [ $prev_end -gt 0 ] && [ $vma_dec -gt $prev_end ]; then
            gap_size=$((vma_dec - prev_end))
            if [ $gap_size -gt 0 ]; then
                echo "Gap found: $gap_size bytes between $prev_name end (0x$(printf '%x' $prev_end)) and $name start (0x$vma)"
            fi
        fi
        
        # Update previous end
        prev_end=$((vma_dec + size_dec))
        prev_name=$name
    done
    
    echo -e "\nLargest contiguous blocks:"
    
    # Extract contiguous blocks of memory
    prev_section=""
    prev_end=0
    block_start=0
    block_size=0
    block_sections=""
    
    echo "$sections" | while read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        
        # Extract section information
        section_num=$(echo "$line" | awk '{print $1}')
        name=$(echo "$line" | awk '{print $2}')
        size=$(echo "$line" | awk '{print $3}')
        vma=$(echo "$line" | awk '{print $4}')
        
        # Skip sections with zero size
        if [ "$size" = "00000000" ]; then
            continue
        fi
        
        # Convert hex to decimal (removing 0x prefix if present)
        size="${size#0x}"
        vma="${vma#0x}"
        
        size_dec=$((16#$size))
        vma_dec=$((16#$vma))
        
        # If this section continues from the previous one
        if [ $prev_end -gt 0 ] && [ $vma_dec -eq $prev_end ]; then
            # Continue the current block
            block_size=$((block_size + size_dec))
            block_sections="$block_sections, $name"
        else
            # Output the previous block if it exists
            if [ $block_size -gt 0 ]; then
                echo "Contiguous block: $block_size bytes starting at 0x$(printf '%x' $block_start) including: $block_sections"
            fi
            
            # Start a new block
            block_start=$vma_dec
            block_size=$size_dec
            block_sections="$name"
        fi
        
        prev_end=$((vma_dec + size_dec))
        prev_section=$name
    done
    
    # Output the last block
    if [ $block_size -gt 0 ]; then
        echo "Contiguous block: $block_size bytes starting at 0x$(printf '%x' $block_start) including: $block_sections"
    fi
    
    # Find large data blocks that could be target for your search
    echo -e "\nLarge data blocks (potential search targets):"
    arm-none-eabi-objdump -h "$KERNEL_ELF" | grep -A1 -E "^[0-9]+" | grep -v "^--" | sed 's/^ *//' | 
    while read -r line; do
        # Skip empty lines
        if [ -z "$line" ]; then
            continue
        fi
        
        # Extract section information
        name=$(echo "$line" | awk '{print $2}')
        size=$(echo "$line" | awk '{print $3}')
        vma=$(echo "$line" | awk '{print $4}')
        
        # Convert hex to decimal (removing 0x prefix if present)
        size="${size#0x}"
        size_dec=$((16#$size))
        
        # Only show large sections (over 1KB)
        if [ $size_dec -gt 1024 ]; then
            echo "$name section: $size_dec bytes starting at $vma"
        fi
    done
    
} > "$OUTPUT_DIR/memory_analysis.txt"

echo "Memory analysis complete. Results saved to $OUTPUT_DIR/"
echo "Check $OUTPUT_DIR/memory_analysis.txt for gaps and contiguous blocks"