#!/bin/bash
# Default values
TEST_NUMBER=1
RUN_AFTER_BUILD=false
LOG_ENABLED=false
DIFF_OUTPUT=false

# Help text
function show_help {
echo "Usage: $0 [OPTIONS]"
echo "Options:"
echo " -t, --test NUM Set test number (default: 1)"
echo " -r, --run Run after building"
echo " -l, --log Run with logging enabled"
echo " -d, --diff Create diff with the other test dump file"
echo " -h, --help Show this help message"
echo ""
echo "Examples:"
echo " $0 -t 2 # Build with test number 2"
echo " $0 -t 1 -r # Build and run with test number 1"
echo " $0 -t 2 -l # Build and run with logging for test 2"
echo " $0 -t 2 -d # Build test 2 and create diff with test 1 dump"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
case $1 in
-t|--test)
TEST_NUMBER="$2"
shift 2
 ;;
-r|--run)
RUN_AFTER_BUILD=true
shift
 ;;
-l|--log)
LOG_ENABLED=true
shift
 ;;
-d|--diff)
DIFF_OUTPUT=true
shift
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

# Check if src/testNumber.h exists
if [ ! -f "src/testNumber.h" ]; then
echo "Error: src/testNumber.h not found in current directory."
exit 1
fi

# Create results directory if it doesn't exist
mkdir -p results

# Clean the build
echo "Cleaning previous build..."
make clean

# Generate new src/testNumber.h with specified test number
echo "Setting test number to $TEST_NUMBER..."
echo "int testNumber = $TEST_NUMBER;" > src/testNumber.h

# Build the project with the test number in the output filename
echo "Building kernel with test number $TEST_NUMBER..."
make TEST_NUM=$TEST_NUMBER

# Check if build was successful
if [ $? -ne 0 ]; then
echo "Build failed!"
exit 1
else
echo "Build successful! Output: $(ls build/kernel$TEST_NUMBER.img 2>/dev/null || echo 'build/kernel.img')"
fi

# Run or log if requested
if [ "$LOG_ENABLED" = true ]; then
echo "Running with logging for test $TEST_NUMBER..."
make log TEST_NUM=$TEST_NUMBER
elif [ "$RUN_AFTER_BUILD" = true ]; then
echo "Running kernel..."
make run TEST_NUM=$TEST_NUMBER
fi

# Copy the image and create disassembly
cp build/kernel$TEST_NUMBER.img results/kernel$TEST_NUMBER.img
echo "Creating disassembly..."
arm-none-eabi-objdump -d build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.dump

# Create diff if requested
if [ "$DIFF_OUTPUT" = true ]; then
    # Determine which is the other test number
    if [ "$TEST_NUMBER" -eq 1 ]; then
        OTHER_TEST=2
    else
        OTHER_TEST=1
    fi
    
    # Check if the other test dump exists
    if [ -f "results/kernel$OTHER_TEST.dump" ]; then
        echo "Creating diff between test $TEST_NUMBER and test $OTHER_TEST..."
        
        # Create a normal diff
        diff -u results/kernel$TEST_NUMBER.dump results/kernel$OTHER_TEST.dump > results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff
        
        # Create a context-focused diff showing only the decrypt_memory function
        echo "Creating focused diff of decrypt_memory function..."
        grep -A 500 "<decrypt_memory>:" results/kernel$TEST_NUMBER.dump > results/kernel${TEST_NUMBER}.decrypt_memory.txt
        grep -A 500 "<decrypt_memory>:" results/kernel$OTHER_TEST.dump > results/kernel${OTHER_TEST}.decrypt_memory.txt
        diff -u results/kernel${TEST_NUMBER}.decrypt_memory.txt results/kernel${OTHER_TEST}.decrypt_memory.txt > results/decrypt_memory_diff.txt
        
        # Create function list diff
        echo "Creating function list diff..."
        grep "<.*>:" results/kernel$TEST_NUMBER.dump | sort > results/kernel${TEST_NUMBER}.functions.txt
        grep "<.*>:" results/kernel$OTHER_TEST.dump | sort > results/kernel${OTHER_TEST}.functions.txt
        diff -u results/kernel${TEST_NUMBER}.functions.txt results/kernel${OTHER_TEST}.functions.txt > results/functions_diff.txt
        
        # Basic binary comparison
        echo "Performing binary comparison with cmp..."
        cmp results/kernel$TEST_NUMBER.img results/kernel$OTHER_TEST.img > results/kernel_binary_cmp.txt 2>&1
        
        # If both log files exist, diff them too
        if [ -f "results/kernel$TEST_NUMBER.in_asm.log" ] && [ -f "results/kernel$OTHER_TEST.in_asm.log" ]; then
            echo "Creating execution log diff..."
            diff -u results/kernel$TEST_NUMBER.in_asm.log results/kernel$OTHER_TEST.in_asm.log > results/in_asm_logs.diff
            
            # Create focused diff of crypto-related lines
            echo "Creating crypto lines diff..."
            grep -E "passphrase|session_key|key|PW:|password|decrypt|encrypt|cipher" results/kernel$TEST_NUMBER.in_asm.log > results/kernel${TEST_NUMBER}.crypto_lines.txt
            grep -E "passphrase|session_key|key|PW:|password|decrypt|encrypt|cipher" results/kernel$OTHER_TEST.in_asm.log > results/kernel${OTHER_TEST}.crypto_lines.txt
            diff -u results/kernel${TEST_NUMBER}.crypto_lines.txt results/kernel${OTHER_TEST}.crypto_lines.txt > results/crypto_lines.diff
        fi
        
        echo "Diff files created:"
        echo " - results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff (disassembly diff)"
        echo " - results/decrypt_memory_diff.txt (decrypt_memory function diff)"
        echo " - results/functions_diff.txt (function list diff)"
        echo " - results/kernel_binary_cmp.txt (binary comparison)"
        echo " - results/in_asm_logs.diff (execution log diff)"
        echo " - results/crypto_lines.diff (crypto-related log lines diff)"
    else
        echo "Cannot create diff: results/kernel$OTHER_TEST.dump does not exist."
        echo "Run $0 -t $OTHER_TEST first to generate the other dump file."
    fi
fi

# Create a summary of findings if both dumps exist
if [ -f "results/kernel1.dump" ] && [ -f "results/kernel2.dump" ]; then
    echo "Creating summary of differences..."
    
    # Compare file sizes
    SIZE1=$(stat -c %s "results/kernel1.img")
    SIZE2=$(stat -c %s "results/kernel2.img")
    
    # Count functions
    FUNCS1=$(grep -c "<.*>:" results/kernel1.dump)
    FUNCS2=$(grep -c "<.*>:" results/kernel2.dump)
    
    # Check if decrypt_memory function exists and compare its size
    if grep -q "<decrypt_memory>:" results/kernel1.dump && grep -q "<decrypt_memory>:" results/kernel2.dump; then
        DECRYPT1_START=$(grep -n "<decrypt_memory>:" results/kernel1.dump | cut -d':' -f1)
        DECRYPT1_END=$(tail -n +$DECRYPT1_START results/kernel1.dump | grep -n "<.*>:" | grep -v "<decrypt_memory>:" | head -1 | cut -d':' -f1)
        DECRYPT1_SIZE=$((DECRYPT1_END - 1))
        
        DECRYPT2_START=$(grep -n "<decrypt_memory>:" results/kernel2.dump | cut -d':' -f1)
        DECRYPT2_END=$(tail -n +$DECRYPT2_START results/kernel2.dump | grep -n "<.*>:" | grep -v "<decrypt_memory>:" | head -1 | cut -d':' -f1)
        DECRYPT2_SIZE=$((DECRYPT2_END - 1))
    else
        DECRYPT1_SIZE="N/A"
        DECRYPT2_SIZE="N/A"
    fi
    
    # Binary comparison with cmp
    echo "Performing binary comparison with cmp..."
    CMP_RESULT=$(cmp -l results/kernel1.img results/kernel2.img 2>&1 | head -5)
    
    # Create diff of in_asm logs if they both exist
    if [ -f "results/kernel1.in_asm.log" ] && [ -f "results/kernel2.in_asm.log" ]; then
        echo "Creating diff of execution logs..."
        diff -u results/kernel1.in_asm.log results/kernel2.in_asm.log > results/in_asm_logs.diff
        
        # Create a focused diff of crypto lines in the logs
        grep -E "passphrase|session_key|key|PW:|password|decrypt|encrypt|cipher" results/kernel1.in_asm.log > results/kernel1.crypto_lines.txt
        grep -E "passphrase|session_key|key|PW:|password|decrypt|encrypt|cipher" results/kernel2.in_asm.log > results/kernel2.crypto_lines.txt
        diff -u results/kernel1.crypto_lines.txt results/kernel2.crypto_lines.txt > results/crypto_lines.diff
    fi
    
    # Output to summary file
    {
        echo "=== Build Comparison Summary ==="
        echo "Test 1 binary size: $SIZE1 bytes"
        echo "Test 2 binary size: $SIZE2 bytes"
        echo "Size difference: $((SIZE2 - SIZE1)) bytes"
        echo ""
        echo "Test 1 function count: $FUNCS1"
        echo "Test 2 function count: $FUNCS2"
        echo "Function count difference: $((FUNCS2 - FUNCS1))"
        echo ""
        echo "decrypt_memory function in Test 1: $DECRYPT1_SIZE lines"
        echo "decrypt_memory function in Test 2: $DECRYPT2_SIZE lines"
        echo ""
        echo "=== Binary Comparison ==="
        echo "cmp result (first 5 differences):"
        echo "$CMP_RESULT"
        echo ""
        echo "=== Key differences may be found in the diff files ==="
        echo " - results/kernel1_vs_kernel2.dump.diff (disassembly diff)"
        echo " - results/decrypt_memory_diff.txt (decrypt_memory function diff)"
        echo " - results/functions_diff.txt (function list diff)"
        echo " - results/in_asm_logs.diff (execution log diff)"
        echo " - results/crypto_lines.diff (crypto-related log lines diff)"
    } > results/build_comparison.txt
    
    echo "Summary created: results/build_comparison.txt"
fi

echo "Done."