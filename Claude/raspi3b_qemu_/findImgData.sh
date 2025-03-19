#!/bin/bash

# Check for correct number of arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <kernel_image> <header_file>"
    echo "Example: $0 build/kernel1.img src/header1.h"
    exit 1
fi

# Path to your kernel image and C header file from command-line arguments
KERNEL_IMAGE="$1"
HEADER_FILE="$2"
RESULTS_DIR="./kernel_search_results_$(date +%Y%m%d_%H%M%S)"

# Check if files exist
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "Error: Kernel image $KERNEL_IMAGE not found"
    exit 1
fi

if [ ! -f "$HEADER_FILE" ]; then
    echo "Error: Header file $HEADER_FILE not found"
    exit 1
fi

# Create results directory
mkdir -p "$RESULTS_DIR"
echo "Results will be saved to: $RESULTS_DIR"

echo "Analyzing header file and extracting byte patterns..."

# Extract all hex values into a file - more efficient pattern matching
grep -o "0x[0-9a-fA-F]\+" "$HEADER_FILE" | tr -d '0x' > "$RESULTS_DIR/hex_values.txt"

# Check if we got any hex data
if [ ! -s "$RESULTS_DIR/hex_values.txt" ]; then
    echo "Error: Could not extract hex values from header file"
    exit 1
fi

# Join hex values into a single string without newlines
cat "$RESULTS_DIR/hex_values.txt" | tr -d '\n' > "$RESULTS_DIR/all_hex.txt"

# Get total pattern size
TOTAL_PATTERN_SIZE=$(($(cat "$RESULTS_DIR/all_hex.txt" | wc -c) / 2))
echo "Total pattern size: $TOTAL_PATTERN_SIZE bytes"

# Create a binary representation of the pattern for faster searching
echo "Creating binary representation of the pattern..."
xxd -r -p "$RESULTS_DIR/all_hex.txt" > "$RESULTS_DIR/pattern.bin"

# Use 2-byte pairs for more efficient searching
PAIR_SIZE=2

echo "Using $PAIR_SIZE-byte pairs for efficient searching"

# Calculate the total number of pairs based on pattern size
TOTAL_PAIRS=$((TOTAL_PATTERN_SIZE / PAIR_SIZE))
if [ $((TOTAL_PATTERN_SIZE % PAIR_SIZE)) -ne 0 ]; then
    TOTAL_PAIRS=$((TOTAL_PAIRS + 1))
fi

echo "Pattern contains $TOTAL_PAIRS pairs of $PAIR_SIZE bytes"

# Create a more efficient byte-pair map
echo "Creating byte-pair map..."
{
    for i in $(seq 0 $((TOTAL_PAIRS - 1))); do
        offset=$((i * PAIR_SIZE))
        
        # Check if we've reached the end of the pattern
        if [ $offset -ge $TOTAL_PATTERN_SIZE ]; then
            break
        fi
        
        # Extract pair of bytes
        pair_hex=$(xxd -s $offset -l $PAIR_SIZE -p "$RESULTS_DIR/pattern.bin")
        
        # Save pair info
        echo "$i:$offset:$pair_hex"
    done
} > "$RESULTS_DIR/pair_map.txt"

# Get kernel size for progress calculation
KERNEL_SIZE=$(stat -c %s "$KERNEL_IMAGE")

echo "Searching for pairs in kernel image..."
echo "----------------------------------------------------------------------"
echo "Pair | Offset | Hex Pattern | Found At Offset(s)"
echo "----------------------------------------------------------------------"

# Process the kernel image more efficiently
{
    # Track positions where pairs were found
    declare -A pair_positions
    total_pairs_found=0
    
    # Process each pair with progress indicator
    total_pairs=$(wc -l < "$RESULTS_DIR/pair_map.txt")
    current_pair=0
    
    while IFS=: read -r pair_id pair_offset pair_hex; do
        # Update progress
        current_pair=$((current_pair + 1))
        percent=$((current_pair * 100 / total_pairs))
        printf "\rSearching pair %d/%d (%d%%)..." "$current_pair" "$total_pairs" "$percent" >&2
        
        # Use a more efficient search approach with grep on binary data
        hex_pattern=$(echo -n "$pair_hex" | xxd -r -p)
        locations=$(grep -a -b --only-matching "$hex_pattern" "$KERNEL_IMAGE" 2>/dev/null | cut -d: -f1)
        
        if [ -n "$locations" ]; then
            # Count matches
            match_count=$(echo "$locations" | wc -l)
            total_pairs_found=$((total_pairs_found + 1))
            
            # Store all positions for this pair
            pair_positions["$pair_id"]="$locations"
            
            # Limit display to first 3 matches if there are many
            if [ "$match_count" -gt 3 ]; then
                display_pos=$(echo "$locations" | head -3 | tr '\n' ' ' | sed 's/ /, 0x/g' | sed 's/^/0x/')
                display_pos="$display_pos, ... ($match_count total matches)"
            else
                display_pos=$(echo "$locations" | tr '\n' ' ' | sed 's/ /, 0x/g' | sed 's/^/0x/')
            fi
            
            # Print result with padding
            printf "%-4d | 0x%-4x | %-10s | %s\n" "$pair_id" "$pair_offset" "$pair_hex" "$display_pos"
        else
            printf "%-4d | 0x%-4x | %-10s | not found\n" "$pair_id" "$pair_offset" "$pair_hex"
        fi
    done < "$RESULTS_DIR/pair_map.txt"
    
    # Clear progress line
    printf "\r%-80s\r" " " >&2
    
    echo ""
    echo "Found $total_pairs_found pairs out of $total_pairs in the kernel image"
    
    # Find potential contiguous segments
    echo ""
    echo "Analyzing for contiguous segments..."
    echo "----------------------------------------------------------------------"
    
    # Create a data structure to track chains
    declare -A chains
    longest_chain_length=0
    longest_chain_start=""
    longest_chain_pos=0
    
    # Find pairs that appear sequentially in the kernel image
    for pair_id in $(seq 0 $((TOTAL_PAIRS - 2))); do
        next_id=$((pair_id + 1))
        
        # Skip if either pair wasn't found
        if [ -z "${pair_positions[$pair_id]}" ] || [ -z "${pair_positions[$next_id]}" ]; then
            continue
        fi
        
        # Check each position of current pair
        for pos in ${pair_positions[$pair_id]}; do
            expected_next=$((pos + PAIR_SIZE))
            
            # Check if the next pair appears at the expected position
            for next_pos in ${pair_positions[$next_id]}; do
                if [ "$next_pos" = "$expected_next" ]; then
                    # Found a connection
                    chain_key="$pos"
                    
                    if [ -z "${chains[$chain_key]}" ]; then
                        # Start a new chain
                        chains[$chain_key]="$pair_id,$next_id"
                        chain_length=2
                    else
                        # Extend existing chain
                        chains[$chain_key]="${chains[$chain_key]},$next_id"
                        chain_length=$(echo "${chains[$chain_key]}" | tr ',' '\n' | wc -l)
                    fi
                    
                    # Check if this is now the longest chain
                    if [ "$chain_length" -gt "$longest_chain_length" ]; then
                        longest_chain_length=$chain_length
                        longest_chain_start=$pair_id
                        longest_chain_pos=$pos
                    fi
                    
                    echo "Found contiguous pairs $pair_id->$next_id at kernel offset 0x$(printf '%x' $pos)->0x$(printf '%x' $next_pos)"
                fi
            done
        done
    done
    
    # Report on the longest contiguous chain
    echo ""
    echo "Largest contiguous segments found:"
    echo "----------------------------------------------------------------------"
    
    if [ "$longest_chain_length" -gt 0 ]; then
        # Calculate the byte length of the chain
        chain_byte_length=$((longest_chain_length * PAIR_SIZE))
        
        echo "Longest chain: $longest_chain_length consecutive pairs ($chain_byte_length bytes)"
        echo "Chain starts at kernel offset: 0x$(printf '%x' $longest_chain_pos)"
        echo "Chain starts with pair: $longest_chain_start"
        echo "Chain pairs: ${chains[$longest_chain_pos]}"
        
        # Extract the chain data
        echo ""
        echo "Data from longest chain:"
        dd if="$KERNEL_IMAGE" bs=1 skip=$longest_chain_pos count=$chain_byte_length 2>/dev/null | hexdump -C
    else
        echo "No contiguous chains found"
    fi
    
    # Analyze frequency of matches to find the most common offset differences
    echo ""
    echo "Analyzing match patterns to identify consistent offsets..."
    echo "----------------------------------------------------------------------"
    
    # Collect all pair locations
    all_locations=""
    for pair_id in "${!pair_positions[@]}"; do
        for pos in ${pair_positions[$pair_id]}; do
            all_locations="$all_locations $pos"
        done
    done
    
    # Sort locations for easier analysis
    sorted_locations=$(echo "$all_locations" | tr ' ' '\n' | sort -n | uniq)
    
    # Find common differences between locations
    declare -A difference_count
    prev_loc=""
    for loc in $sorted_locations; do
        if [ -n "$prev_loc" ]; then
            diff=$((loc - prev_loc))
            if [ -n "${difference_count[$diff]}" ]; then
                difference_count[$diff]=$((difference_count[$diff] + 1))
            else
                difference_count[$diff]=1
            fi
        fi
        prev_loc=$loc
    done
    
    # Report the most common differences
    echo "Most common offset differences between matches:"
    for diff in "${!difference_count[@]}"; do
        if [ "${difference_count[$diff]}" -gt 2 ]; then
            echo "Offset difference $diff bytes appears ${difference_count[$diff]} times"
        fi
    done
    
    # Extract sample data from most promising locations
    echo ""
    echo "Sample data from most promising locations:"
    echo "----------------------------------------------------------------------"
    
    # Get top 3 pairs that were found with consistent location patterns
    top_pair_locations=""
    for pair_id in "${!pair_positions[@]}"; do
        match_count=$(echo "${pair_positions[$pair_id]}" | wc -w)
        if [ "$match_count" -lt 10 ] && [ "$match_count" -gt 0 ]; then
            # This pair doesn't have too many matches (likely more specific)
            for pos in ${pair_positions[$pair_id]}; do
                top_pair_locations="$top_pair_locations $pair_id:$pos"
                break  # Just take the first position for each pair
            done
        fi
    done
    
    # Take top 3 from these locations
    top_pairs=$(echo "$top_pair_locations" | tr ' ' '\n' | head -3)
    
    # Extract data from those locations
    for pair_info in $top_pairs; do
        pair_id=$(echo "$pair_info" | cut -d: -f1)
        loc=$(echo "$pair_info" | cut -d: -f2)
        
        if [ -n "$loc" ]; then
            # Extract 32 bytes of data from this location
            echo "Data near pair $pair_id (offset 0x$(printf '%x' $loc)):"
            dd if="$KERNEL_IMAGE" bs=1 skip=$loc count=32 2>/dev/null | hexdump -C
            echo ""
        fi
    done
} > "$RESULTS_DIR/search_results.txt" 2> "$RESULTS_DIR/progress.log"

# Display the results
cat "$RESULTS_DIR/search_results.txt"

# Generate final report
{
    echo "=== KERNEL SEARCH REPORT ==="
    echo "Date: $(date)"
    echo "Kernel Image: $KERNEL_IMAGE ($(stat -c %s "$KERNEL_IMAGE") bytes)"
    echo "Header File: $HEADER_FILE"
    echo "Pattern Size: $TOTAL_PATTERN_SIZE bytes"
    echo ""
    echo "=== SEARCH SUMMARY ==="
    echo "Searched for $TOTAL_PAIRS pairs of $PAIR_SIZE bytes each"
    echo ""
    echo "=== HANDLING MULTIPLE MATCHES ==="
    echo "1. Contiguous Analysis: Checked if pairs appear next to each other in the expected order"
    echo "2. Frequency Analysis: Identified common offsets between matches"
    echo "3. Selective Sampling: Extracted data from locations with specific patterns"
    echo ""
    echo "=== NEXT STEPS ==="
    echo "1. Examine the longest contiguous chains identified"
    echo "2. Check for recurring patterns in the offset differences"
    echo "3. For detailed analysis, use hexdump to view specific regions:"
    echo "   hexdump -C $KERNEL_IMAGE | grep -A 10 -B 10 '<offset in hex>'"
} > "$RESULTS_DIR/final_report.txt"

echo ""
echo "Search complete. Final report saved to: $RESULTS_DIR/final_report.txt"