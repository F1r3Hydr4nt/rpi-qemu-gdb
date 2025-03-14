#!/bin/bash

# Default parameters
FILTER_MODE="crypto"
OUTPUT_DIR="analysis"
LOG1="results/kernel1.in_asm.log"
LOG2="results/kernel2.in_asm.log"

# Help function
function show_help {
    echo "Usage: $0 [OPTIONS]"
    echo "Compare execution logs from test runs"
    echo ""
    echo "Options:"
    echo "  -f, --filter MODE   Filter mode: crypto, decrypt, all (default: crypto)"
    echo "  -o, --output DIR    Output directory (default: analysis)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Using fixed log files:"
    echo "  Log1: $LOG1"
    echo "  Log2: $LOG2"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--filter)
            FILTER_MODE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if log files exist
if [ ! -f "$LOG1" ]; then
    echo "Error: Log file not found: $LOG1"
    exit 1
fi

if [ ! -f "$LOG2" ]; then
    echo "Error: Log file not found: $LOG2"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Extract function traces based on filter mode
case $FILTER_MODE in
    crypto)
        FUNCTIONS="decrypt_memory|SHA1|derive_key|proc_encryption|passphrase_to_dek"
        ;;
    decrypt)
        FUNCTIONS="decrypt_memory"
        ;;
    all)
        FUNCTIONS="."
        ;;
    *)
        echo "Invalid filter mode: $FILTER_MODE"
        show_help
        exit 1
        ;;
esac

echo "Analyzing logs with filter: $FILTER_MODE"

# Extract and format log sections - simplified version without complex awk processing
extract_log_sections() {
    local logfile="$1"
    local output="$2"
    local filter="$3"
    
    # Simple extraction without indentation
    grep -E "(IN: .*($filter)|$filter)" "$logfile" > "$output"
}

# Extract call sequences from each log
LOG1_EXTRACT="$OUTPUT_DIR/log1_extract.txt"
LOG2_EXTRACT="$OUTPUT_DIR/log2_extract.txt"

extract_log_sections "$LOG1" "$LOG1_EXTRACT" "$FUNCTIONS"
extract_log_sections "$LOG2" "$LOG2_EXTRACT" "$FUNCTIONS"

# Compare the two logs
DIFF_OUTPUT="$OUTPUT_DIR/diff_analysis.txt"
diff -u "$LOG1_EXTRACT" "$LOG2_EXTRACT" > "$DIFF_OUTPUT"

# Generate a summary of differences
SUMMARY_OUTPUT="$OUTPUT_DIR/summary.txt"
{
    echo "=== Analysis Summary ==="
    echo "Log1: $LOG1"
    echo "Log2: $LOG2"
    echo "Filter: $FILTER_MODE"
    echo ""
    
    echo "=== Key Differences ==="
    grep -E "^\+IN: |^-IN: " "$DIFF_OUTPUT" | sort | uniq -c | sort -nr
    
    echo ""
    echo "=== Function Call Counts ==="
    echo "Test 1 Function Calls:"
    grep -E "IN: " "$LOG1_EXTRACT" | cut -d' ' -f2 | sort | uniq -c | sort -nr
    
    echo ""
    echo "Test 2 Function Calls:"
    grep -E "IN: " "$LOG2_EXTRACT" | cut -d' ' -f2 | sort | uniq -c | sort -nr
    
    echo ""
    echo "=== Full diff available in: $DIFF_OUTPUT ==="
} > "$SUMMARY_OUTPUT"

# Extract specific crypto parameters
PARAMS_OUTPUT="$OUTPUT_DIR/crypto_params.txt"
{
    echo "=== Crypto Parameters from Log1 ==="
    grep -E "passphrase|session_key|key|PW:|password" "$LOG1" | sort | uniq
    
    echo ""
    echo "=== Crypto Parameters from Log2 ==="
    grep -E "passphrase|session_key|key|PW:|password" "$LOG2" | sort | uniq
} > "$PARAMS_OUTPUT"

# Extract interesting crypto lines
CRYPTO_LINES="$OUTPUT_DIR/crypto_lines.txt"
{
    echo "=== Test 1 Crypto Lines ==="
    grep -E "cipher|hash|decrypt|encrypt|session|key|passphrase|PW:|password" "$LOG1" | sort | uniq
    
    echo ""
    echo "=== Test 2 Crypto Lines ==="
    grep -E "cipher|hash|decrypt|encrypt|session|key|passphrase|PW:|password" "$LOG2" | sort | uniq
} > "$CRYPTO_LINES"

# Extract passwords and keys with more context
KEYS_OUTPUT="$OUTPUT_DIR/key_context.txt"
{
    echo "=== Test 1 Key and Password Context ==="
    grep -A 5 -B 5 "test_passphrase\|session_key\|password\|PW:" "$LOG1"
    
    echo ""
    echo "=== Test 2 Key and Password Context ==="
    grep -A 5 -B 5 "test_passphrase\|session_key\|password\|PW:" "$LOG2"
} > "$KEYS_OUTPUT"

# Create frequency analysis
FREQ_OUTPUT="$OUTPUT_DIR/function_frequency.txt"
{
    echo "=== Function Call Frequency Differences ==="
    
    echo "Test 1 Frequency:"
    grep -E "IN: " "$LOG1_EXTRACT" | cut -d' ' -f2 | sort | uniq -c | sort -nr > "$OUTPUT_DIR/temp1.txt"
    
    echo "Test 2 Frequency:"
    grep -E "IN: " "$LOG2_EXTRACT" | cut -d' ' -f2 | sort | uniq -c | sort -nr > "$OUTPUT_DIR/temp2.txt"
    
    # Compare the frequency files
    diff -y "$OUTPUT_DIR/temp1.txt" "$OUTPUT_DIR/temp2.txt"
    
    # Clean up temp files
    rm -f "$OUTPUT_DIR/temp1.txt" "$OUTPUT_DIR/temp2.txt"
} > "$FREQ_OUTPUT"

echo "Analysis complete!"
echo "Summary: $SUMMARY_OUTPUT"
echo "Function Frequencies: $FREQ_OUTPUT" 
echo "Crypto Parameters: $PARAMS_OUTPUT"
echo "Crypto Lines: $CRYPTO_LINES"
echo "Key Context: $KEYS_OUTPUT"
echo "Detailed diff: $DIFF_OUTPUT"