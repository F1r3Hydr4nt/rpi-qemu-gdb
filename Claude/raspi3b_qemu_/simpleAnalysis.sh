#!/bin/bash
# Default values
TEST_NUMBER=1
DIFF_OUTPUT=false
LOG_ENABLED=false

# Help text
function show_help {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo " -t, --test NUM   Set test number (default: 1)"
    echo " -d, --diff       Create diff with the other test build"
    echo " -l, --log        Run with logging enabled"
    echo " -h, --help       Show this help message"
    echo ""
    echo "Examples:"
    echo " $0 -t 2          # Build and analyze test number 2"
    echo " $0 -t 2 -d       # Build test 2 and create diff with test 1"
    echo " $0 -t 2 -l       # Build and run with logging for test 2"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--test)
            TEST_NUMBER="$2"
            shift 2
            ;;
        -d|--diff)
            DIFF_OUTPUT=true
            shift
            ;;
        -l|--log)
            LOG_ENABLED=true
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

# Generate new src/testNumber.h with specified test number
echo "Setting test number to $TEST_NUMBER..."
echo "int testNumber = $TEST_NUMBER;" > src/testNumber.h

# Build the project
echo "Building kernel with test number $TEST_NUMBER..."

make clean
# Run or log if requested
if [ "$LOG_ENABLED" = true ]; then
    echo "Running with logging for test $TEST_NUMBER..."
    make log TEST_NUM=$TEST_NUMBER
elif [ "$RUN_AFTER_BUILD" = true ]; then
    echo "Running kernel..."
    make run TEST_NUM=$TEST_NUMBER
fi

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
else
    echo "Build successful!"
fi
    
    
mkdir -p results
# Copy the image
cp build/kernel$TEST_NUMBER.img results/kernel$TEST_NUMBER.img

# Perform analysis
echo "Performing binary analysis..."

# Create disassembly
echo "Creating disassembly..."
arm-none-eabi-objdump -d build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.dump

# Get symbol table analysis
echo "Analyzing symbol tables..."
arm-none-eabi-nm -S build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.symbols.txt
arm-none-eabi-nm -S --size-sort build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.symbols_by_size.txt

# Get ELF information
echo "Extracting ELF information..."
arm-none-eabi-readelf -h build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.elf_header.txt
arm-none-eabi-readelf -S build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.sections.txt

if [ "$TEST_NUMBER" -eq 1 ]; then
    echo "TEST_NUMBER is 1. Saving analysis for test 2..."
    exit 0
fi

# Perform diff if requested
if [ "$DIFF_OUTPUT" = true ]; then
    # Determine which is the other test number
    if [ "$TEST_NUMBER" -eq 1 ]; then
        OTHER_TEST=2
    else
        OTHER_TEST=1
    fi
    
    # Check if the other test file exists
    if [ -f "results/kernel$OTHER_TEST.dump" ]; then
        echo "Creating diffs between test $TEST_NUMBER and test $OTHER_TEST..."
        
        # Create a normal diff of disassembly
        diff -u results/kernel$TEST_NUMBER.dump results/kernel$OTHER_TEST.dump > results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff
        
        # Compare symbol tables
        echo "Comparing symbol tables..."
        diff -u results/kernel${TEST_NUMBER}.symbols.txt results/kernel${OTHER_TEST}.symbols.txt > results/symbol_diff.txt
        
        # Binary comparison
        echo "Performing binary comparison..."
        cmp results/kernel$TEST_NUMBER.img results/kernel$OTHER_TEST.img > results/kernel_binary_cmp.txt 2>&1
        
        # Check for log files and create diffs if they exist
        if [ -f "results/kernel$TEST_NUMBER.in_asm.log" ] && [ -f "results/kernel$OTHER_TEST.in_asm.log" ]; then
            echo "Creating execution log diff..."
            echo $OTHER_TEST
            diff -u results/kernel$TEST_NUMBER.in_asm.log results/kernel$OTHER_TEST.in_asm.log > results/in_asm_logs.diff
        fi
        
        # Generate summary report
        echo "Generating summary report..."
        {
            echo "=== Binary Comparison Summary ==="
            echo "Test $TEST_NUMBER vs Test $OTHER_TEST"
            echo "Generated on: $(date)"
            echo ""
            
            # File size comparison
            SIZE1=$(stat -c %s "results/kernel${TEST_NUMBER}.img")
            SIZE2=$(stat -c %s "results/kernel${OTHER_TEST}.img")
            echo "Binary sizes:"
            echo "- Test $TEST_NUMBER: $SIZE1 bytes"
            echo "- Test $OTHER_TEST: $SIZE2 bytes"
            echo "- Difference: $((SIZE2 - SIZE1)) bytes"
            echo ""
            
            # Binary comparison result
            echo "Binary comparison result:"
            if grep -q "differ" results/kernel_binary_cmp.txt; then
                echo "- Binaries are different"
            else
                echo "- Binaries are identical"
            fi
            echo ""
            
            echo "=== Diff files ==="
            echo "- results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff - Disassembly diff"
            echo "- results/symbol_diff.txt - Symbol table diff"
            echo "- results/kernel_binary_cmp.txt - Binary comparison"
            
            # Add log analysis if logs exist
            if [ -f "results/in_asm_logs.diff" ]; then
                echo ""
                echo "=== Execution Log Analysis ==="
                
                # Count differences in logs
                LOG_DIFF_LINES=$(grep -c "^[-+]" results/in_asm_logs.diff)
                
                echo "Execution logs have $LOG_DIFF_LINES different lines"
                
                echo ""
                echo "Additional log analysis files:"
                echo "- results/in_asm_logs.diff - Full execution log diff"
            fi
        } > results/comparison_report.txt
        
        echo "Analysis complete. See results/comparison_report.txt for the summary report."
    else
        echo "Cannot create diff: results/kernel$OTHER_TEST.dump does not exist."
        echo "Run $0 -t $OTHER_TEST first to generate the other dump file."
    fi
fi

echo "Done."