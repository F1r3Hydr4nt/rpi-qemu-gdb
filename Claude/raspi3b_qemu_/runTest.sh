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

if [ "$TEST_NUMBER" -eq 1 ]; then
    echo "TEST_NUMBER is 1. Saving analysis for test 2..."
    exit 0
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

# Add detailed analysis of in_asm_logs.diff if it exists
if [ -f "results/in_asm_logs.diff" ]; then
    echo "Analyzing in_asm_logs.diff file..."
    
    # Count total diff chunks and lines changed
    DIFF_CHUNKS=$(grep -c "^@@" results/in_asm_logs.diff)
    LINES_ADDED=$(grep -c "^+" results/in_asm_logs.diff)
    LINES_REMOVED=$(grep -c "^-" results/in_asm_logs.diff)
    
    # Count unique functions that appear in diffs
    FUNCS_AFFECTED=$(grep -A 1 "^@@" results/in_asm_logs.diff | grep "IN: " | awk '{print $2}' | sort -u | wc -l)
    
    # Get list of functions affected
    AFFECTED_FUNC_LIST=$(grep -A 1 "^@@" results/in_asm_logs.diff | grep "IN: " | awk '{print $2}' | sort -u | tr '\n' ' ')
    
    # Calculate diff distribution by function
    echo "Calculating diff distribution by function..."
    {
        echo "=== Function-specific diff analysis ==="
        echo "Function name | Diff chunks | Lines added | Lines removed"
        echo "-------------|-------------|------------|-------------"
        
        for func in $(echo "$AFFECTED_FUNC_LIST"); do
            # Create temporary file with just sections for this function
            grep -n "IN: $func" results/in_asm_logs.diff > temp_func_lines.txt
            
            FUNC_CHUNKS=0
            FUNC_ADDED=0
            FUNC_REMOVED=0
            
            if [ -s temp_func_lines.txt ]; then
                # Extract line numbers where this function appears
                LINE_NUMS=$(awk -F: '{print $1}' temp_func_lines.txt)
                
                for line in $LINE_NUMS; do
                    # Check if this function mention is part of a diff chunk
                    PREV_LINES=15  # Look back this many lines for @@ marker
                    CHUNK_START=$((line - PREV_LINES))
                    [ $CHUNK_START -lt 1 ] && CHUNK_START=1
                    
                    if head -n "$line" results/in_asm_logs.diff | tail -n "$PREV_LINES" | grep -q "^@@"; then
                        FUNC_CHUNKS=$((FUNC_CHUNKS + 1))
                        
                        # Find the next function or end of file
                        NEXT_FUNC=$(tail -n +"$line" results/in_asm_logs.diff | grep -n "IN: " | grep -v "IN: $func" | head -1 | cut -d: -f1)
                        if [ -z "$NEXT_FUNC" ]; then
                            NEXT_FUNC=999999  # Large number to reach EOF
                        else
                            NEXT_FUNC=$((line + NEXT_FUNC - 1))
                        fi
                        
                        # Count added/removed lines in this chunk
                        FUNC_ADDED=$((FUNC_ADDED + $(sed -n "${line},${NEXT_FUNC}p" results/in_asm_logs.diff | grep -c "^+")))
                        FUNC_REMOVED=$((FUNC_REMOVED + $(sed -n "${line},${NEXT_FUNC}p" results/in_asm_logs.diff | grep -c "^-")))
                    fi
                done
            fi
            
            echo "$func | $FUNC_CHUNKS | $FUNC_ADDED | $FUNC_REMOVED"
        done
        
        rm -f temp_func_lines.txt
    } > results/function_diff_analysis.txt
    
    # Create a summary of the OBJD-T code changes
    echo "Analyzing machine code changes..."
    {
        echo "=== Assembly Code Change Analysis ==="
        echo "This analysis shows patterns in the machine code changes between test cases"
        echo ""
        
        # Extract all OBJD-T lines that changed
        grep "OBJD-T: " results/in_asm_logs.diff | grep "^[+-]" > temp_objd_changes.txt
        
        # Count total OBJD-T changes
        OBJD_CHANGES=$(wc -l < temp_objd_changes.txt)
        echo "Total OBJD-T code changes: $OBJD_CHANGES"
        echo ""
        
        # Check if any lines were completely added or removed (not just changed)
        ADDED_BLOCKS=$(grep -c "^+OBJD-T: " temp_objd_changes.txt)
        REMOVED_BLOCKS=$(grep -c "^-OBJD-T: " temp_objd_changes.txt)
        
        echo "Completely new code blocks: $ADDED_BLOCKS"
        echo "Completely removed code blocks: $REMOVED_BLOCKS"
        echo ""
        
        # Analyze specific functions with the most changes
        echo "Top functions with most code changes:"
        for func in $(echo "$AFFECTED_FUNC_LIST"); do
            # Fix: Properly count OBJD-T changes per function
            FUNC_OBJD_CHANGES=$(grep -B 5 -A 5 "IN: $func" results/in_asm_logs.diff | grep "OBJD-T: " | grep "^[+-]" | wc -l)
            if [ $FUNC_OBJD_CHANGES -gt 0 ]; then
                echo "$func: $FUNC_OBJD_CHANGES changes"
            fi
        done
        
        # Add hexadecimal code frequency analysis
        echo ""
        echo "Most frequent instruction patterns in changes:"
        # Extract 8-char instruction sequences and count frequencies
        for pattern in $(grep "^+" temp_objd_changes.txt | sed 's/^+.*OBJD-T: //' | grep -o '..........' | sort | uniq -c | sort -nr | head -10 | awk '{print $2}'); do
            COUNT=$(grep -o "$pattern" <(grep "^+" temp_objd_changes.txt | sed 's/^+.*OBJD-T: //') | wc -l)
            echo "  $pattern: $COUNT occurrences"
        done
        
        # Clean up
        rm -f temp_objd_changes.txt
    } > results/code_change_analysis.txt
    
    # Add instruction pattern analysis for OBJD-T code
    echo "Analyzing instruction pattern differences..."
    {
        echo "=== Instruction Pattern Analysis ==="
        echo "This analysis identifies actual instruction changes, not just relocations"
        echo ""
        
        # Create temporary files with extracted OBJD-T values
        grep "^-.*OBJD-T: " results/in_asm_logs.diff | sed 's/^-.*OBJD-T: //' > temp_objd_old.txt
        grep "^+.*OBJD-T: " results/in_asm_logs.diff | sed 's/^+.*OBJD-T: //' > temp_objd_new.txt
        
        # Count instructions that are completely new (not just relocated)
        PATTERN_CHANGES=0
        RELOCATION_CHANGES=0
        NEW_INSTRUCTIONS=0
        
        # Process the OBJD-T code sequences
        echo "Detailed instruction changes:"
        echo "Function | Address Old → New | Instruction Change | Type"
        echo "---------|-------------------|-------------------|------"

        # Process each diff chunk to identify actual instruction differences
        grep -n "^@@" results/in_asm_logs.diff | while read -r diff_line; do
            # Extract line number where this chunk starts
            CHUNK_START=$(echo "$diff_line" | cut -d: -f1)
            
            # Extract chunk info for context
            CHUNK_INFO=$(echo "$diff_line" | cut -d' ' -f2-3)
            
            # Find function name for this chunk (5 lines after chunk start to catch the function name)
            FUNC_NAME=$(tail -n +$CHUNK_START results/in_asm_logs.diff | head -n 10 | grep "IN: " | head -1 | awk '{print $2}')
            
            # Default to "Unknown" if no function name found
            if [ -z "$FUNC_NAME" ]; then
                FUNC_NAME="Unknown"
            fi
            
            # Extract address changes (improved to handle multiple formats)
            OLD_ADDR=$(tail -n +$CHUNK_START results/in_asm_logs.diff | grep -m 1 "^-0x" | sed 's/^-\(0x[0-9a-f]*\):.*/\1/')
            NEW_ADDR=$(tail -n +$CHUNK_START results/in_asm_logs.diff | grep -m 1 "^+0x" | sed 's/^+\(0x[0-9a-f]*\):.*/\1/')
            
            # Extract OBJD-T lines
            OLD_OBJD=$(tail -n +$CHUNK_START results/in_asm_logs.diff | grep -m 1 "^-.*OBJD-T: " | sed 's/^-.*OBJD-T: //')
            NEW_OBJD=$(tail -n +$CHUNK_START results/in_asm_logs.diff | grep -m 1 "^+.*OBJD-T: " | sed 's/^+.*OBJD-T: //')
            
            if [ -n "$OLD_OBJD" ] && [ -n "$NEW_OBJD" ]; then
                # Split into 8-character instruction chunks (ARM instructions are 4 bytes/8 hex chars)
                # Use proper regex for matching 8-char patterns
                echo "$OLD_OBJD" | grep -o '.\{8\}' > temp_old_instr.txt
                echo "$NEW_OBJD" | grep -o '.\{8\}' > temp_new_instr.txt
                
                # Compare instruction patterns
                if diff -q temp_old_instr.txt temp_new_instr.txt >/dev/null; then
                    CHANGE_TYPE="Relocation Only"
                    RELOCATION_CHANGES=$((RELOCATION_CHANGES + 1))
                else
                    # Check for similar patterns with potential register/constant changes
                    # Extract instruction patterns (first 4 chars of each 8-char instruction)
                    cut -c1-4 temp_old_instr.txt > temp_old_pattern.txt
                    cut -c1-4 temp_new_instr.txt > temp_new_pattern.txt
                    
                    if diff -q temp_old_pattern.txt temp_new_pattern.txt >/dev/null; then
                        CHANGE_TYPE="Register/Immediate Changes"
                        PATTERN_CHANGES=$((PATTERN_CHANGES + 1))
                    else
                        CHANGE_TYPE="Complete Instruction Change"
                        NEW_INSTRUCTIONS=$((NEW_INSTRUCTIONS + 1))
                    fi
                    
                    # List the differing instructions for detailed analysis
                    INSTR_DIFFS=$(paste temp_old_instr.txt temp_new_instr.txt | awk '{if ($1 != $2) print $1 " → " $2}' | tr '\n' ' ')
                    if [ -n "$INSTR_DIFFS" ]; then
                        echo "$FUNC_NAME | $OLD_ADDR → $NEW_ADDR | $INSTR_DIFFS | $CHANGE_TYPE"
                    fi
                fi
            # Handle cases where there's only an addition or removal
            elif [ -n "$OLD_OBJD" ]; then
                echo "$FUNC_NAME | $OLD_ADDR → (removed) | $OLD_OBJD → (removed) | Complete Removal"
                NEW_INSTRUCTIONS=$((NEW_INSTRUCTIONS + 1))
            elif [ -n "$NEW_OBJD" ]; then
                echo "$FUNC_NAME | (added) → $NEW_ADDR | (added) → $NEW_OBJD | Complete Addition"
                NEW_INSTRUCTIONS=$((NEW_INSTRUCTIONS + 1))
            fi
        done
        
        echo ""
        echo "Summary of instruction changes:"
        echo "- Relocation only (same code, different address): $RELOCATION_CHANGES chunks"
        echo "- Register/immediate value changes: $PATTERN_CHANGES chunks"
        echo "- Complete instruction changes: $NEW_INSTRUCTIONS chunks"
        
        # Try to categorize the types of changes
        echo ""
        echo "Types of machine code changes detected:"
        
        # Look for specific patterns in changed instructions
        BRANCH_CHANGES=$(grep -c "e[abcdef]" temp_objd_new.txt)
        LOAD_STORE_CHANGES=$(grep -c "[89a][0-9a-f]e[0-5]" temp_objd_new.txt)
        ALU_CHANGES=$(grep -c "[0-3][0-9a-f]e[0-9a]" temp_objd_new.txt)
        MOVE_CHANGES=$(grep -c "[01][0-9a-f]a0e[13]" temp_objd_new.txt)
        
        echo "- Branch instruction changes: $BRANCH_CHANGES"
        echo "- Load/Store instruction changes: $LOAD_STORE_CHANGES"
        echo "- ALU operation changes: $ALU_CHANGES"
        echo "- Move/Copy operation changes: $MOVE_CHANGES"
        
        # Enhanced ARM disassembly analysis - try to interpret some common patterns
        echo ""
        echo "Common ARM instruction patterns detected in changes:"
        
        # Count specific ARM instruction patterns
        LDR_COUNT=$(grep -c "..5[0-9a-f]e5" temp_objd_new.txt)
        STR_COUNT=$(grep -c "..4[0-9a-f]e5" temp_objd_new.txt)
        B_COUNT=$(grep -c "....ea" temp_objd_new.txt)  # Unconditional branches
        BL_COUNT=$(grep -c "....eb" temp_objd_new.txt) # Branch with link
        MOV_COUNT=$(grep -c "[01][0-9a-f]a0e[13]" temp_objd_new.txt)
        
        echo "- LDR (load) instructions: $LDR_COUNT"
        echo "- STR (store) instructions: $STR_COUNT"
        echo "- B (branch) instructions: $B_COUNT"
        echo "- BL (branch with link) instructions: $BL_COUNT"
        echo "- MOV instructions: $MOV_COUNT"

        # Analyze memory access patterns
        echo ""
        echo "Memory access pattern changes:"
        # Crude analysis of memory access offsets
        if [ $LOAD_STORE_CHANGES -gt 0 ]; then
            # Count stack vs. global memory accesses
            STACK_ACCESSES=$(grep -c "[89][0-9a-f]e[0-5]d" temp_objd_new.txt)
            GLOBAL_ACCESSES=$(grep -c "[89][0-9a-f]e[0-5][^d]" temp_objd_new.txt)
            
            echo "- Stack-relative memory accesses: $STACK_ACCESSES"
            echo "- Global/static memory accesses: $GLOBAL_ACCESSES"
            
            # List the top 5 memory addresses accessed
            echo "- Top memory address patterns:"
            grep -o "[89][0-9a-f]e[0-5]......" temp_objd_new.txt | sort | uniq -c | sort -nr | head -5 | \
                while read count pattern; do
                    echo "  $pattern: $count occurrences"
                done
        else
            echo "- No significant memory access pattern changes detected"
        fi
        
        # Analyze suspicious patterns that might indicate backdoors or other security issues
        echo ""
        echo "Security analysis:"
        
        # Look for uncommon instruction patterns that might be suspicious
        SUSPICIOUS_PATTERNS=0
        
        # Self-modifying code patterns
        if grep -q "f000f[0-9a-f]" temp_objd_new.txt; then
            echo "- WARNING: Potentially suspicious SMC (Self-Modifying Code) instruction patterns detected"
            SUSPICIOUS_PATTERNS=$((SUSPICIOUS_PATTERNS + 1))
        fi
        
        # Mode switch patterns
        if grep -q "00f020e3" temp_objd_new.txt; then
            echo "- WARNING: Potentially suspicious privileged mode switches detected"
            SUSPICIOUS_PATTERNS=$((SUSPICIOUS_PATTERNS + 1))
        fi
        
        # Unexpected system calls
        if grep -q "0[0-9]0000ef" temp_objd_new.txt; then
            echo "- WARNING: System call instructions detected in changes"
            SUSPICIOUS_PATTERNS=$((SUSPICIOUS_PATTERNS + 1))
        fi
        
        # Unexpected coprocessor access
        if grep -q "ee[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]" temp_objd_new.txt; then
            echo "- WARNING: Coprocessor instructions detected in changes"
            SUSPICIOUS_PATTERNS=$((SUSPICIOUS_PATTERNS + 1))
        fi
        
        # Check if any code blocks in crypto-related functions have changed
        CRYPTO_FUNC_CHANGES=$(grep -B 5 -A 5 "IN: \(decrypt\|encrypt\|derive_key\|SHA1\|AES\)" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
        if [ $CRYPTO_FUNC_CHANGES -gt 0 ]; then
            echo "- INFO: $CRYPTO_FUNC_CHANGES changes detected in crypto-related functions"
            
            # List the affected crypto functions
            echo "- Affected crypto functions:"
            for crypto_func in $(grep -B 5 -A 5 "IN: \(decrypt\|encrypt\|derive_key\|SHA1\|AES\)" results/in_asm_logs.diff | grep "IN: " | awk '{print $2}' | sort -u); do
                FUNC_CHANGES=$(grep -B 5 -A 5 "IN: $crypto_func" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
                echo "  $crypto_func: $FUNC_CHANGES changes"
            done
        fi
        
        if [ "$SUSPICIOUS_PATTERNS" -eq 0 ]; then
            echo "- No obviously suspicious instruction patterns detected"
        fi
        
        # Clean up temporary files
        rm -f temp_objd_old.txt temp_objd_new.txt temp_old_instr.txt temp_new_instr.txt temp_old_pattern.txt temp_new_pattern.txt
    } > results/instruction_analysis.txt
    
    # Create a consolidated security report
    echo "Creating security assessment report..."
    {
        echo "=== Security Assessment Report ==="
        echo "This report analyzes potential security implications of the code differences"
        echo ""
        
        # Check for key security indicators
        echo "Key security indicators:"
        
        # 1. Were crypto functions modified?
        CRYPTO_CHANGES=$(grep -B 5 -A 5 "IN: \(decrypt\|encrypt\|derive_key\|SHA1\|AES\)" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
        if [ $CRYPTO_CHANGES -gt 0 ]; then
            echo "- ⚠️ WARNING: $CRYPTO_CHANGES changes detected in cryptographic functions"
            echo "  This could indicate legitimate algorithm changes or potential tampering"
            SECURITY_RISK=$((SECURITY_RISK + CRYPTO_CHANGES))
        else
            echo "- ✓ No changes detected in cryptographic functions"
        fi
        
        # 2. Were there changes to memory access patterns?
        MEM_CHANGES=$(grep -c "[89][0-9a-f]e[0-5]" temp_objd_new.txt 2>/dev/null || echo 0)
        GLOBAL_MEM_CHANGES=$(grep -c "[89][0-9a-f]e[0-5][^d]" temp_objd_new.txt 2>/dev/null || echo 0)
        
        if [ $MEM_CHANGES -gt 10 ]; then
            echo "- ⚠️ NOTICE: $MEM_CHANGES memory access instruction changes detected"
            echo "  $GLOBAL_MEM_CHANGES of these access global/static memory"
            
            # Look for suspicious memory address patterns
            SUSPICIOUS_ADDRESSES=$(grep -o "[89][0-9a-f]e[0-5]f[0-9a-f][0-9a-f][0-9a-f][0-9a-f]" temp_objd_new.txt 2>/dev/null | wc -l)
            if [ $SUSPICIOUS_ADDRESSES -gt 0 ]; then
                echo "  ⚠️ WARNING: $SUSPICIOUS_ADDRESSES suspicious memory address patterns detected"
                SECURITY_RISK=$((SECURITY_RISK + SUSPICIOUS_ADDRESSES))
            fi
        else
            echo "- ✓ Minor or no changes to memory access patterns"
        fi
        
        # 3. Were there changes to control flow?
        BRANCH_CHANGES=$(grep -c "e[abcdef]" temp_objd_new.txt 2>/dev/null || echo 0)
        if [ $BRANCH_CHANGES -gt 5 ]; then
            echo "- ⚠️ NOTICE: $BRANCH_CHANGES branch instruction changes detected"
            echo "  This could indicate significant logic flow changes"
            
            # Check for conditional execution changes
            COND_CHANGES=$(grep -c "[^e][abcdef]" temp_objd_new.txt 2>/dev/null || echo 0)
            if [ $COND_CHANGES -gt 3 ]; then
                echo "  ⚠️ NOTICE: $COND_CHANGES conditional execution changes detected"
            fi
        else
            echo "- ✓ Minor or no changes to control flow"
        fi
        
        # 4. Is there a significant size difference between binaries?
        SIZE_DIFF=$(($SIZE2 - $SIZE1))
        SIZE_DIFF_ABS=${SIZE_DIFF#-}  # Absolute value
        
        if [ $SIZE_DIFF_ABS -gt 1024 ]; then
            echo "- ⚠️ WARNING: Significant binary size difference of $SIZE_DIFF bytes"
            echo "  Large size differences could indicate added functionality or code"
            SECURITY_RISK=$((SECURITY_RISK + (SIZE_DIFF_ABS / 1024)))
        else
            echo "- ✓ Binary size difference is minimal ($SIZE_DIFF bytes)"
        fi
        
        # 5. Check if decrypt_memory function was modified
        DECRYPT_CHANGES=$(grep -B 5 -A 5 "IN: decrypt_memory" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
        if [ $DECRYPT_CHANGES -gt 0 ]; then
            echo "- ⚠️ CRITICAL: decrypt_memory function was modified with $DECRYPT_CHANGES changes"
            echo "  Direct modifications to decryption logic are high-risk indicators"
            SECURITY_RISK=$((SECURITY_RISK + (DECRYPT_CHANGES * 2)))
            
            # Further analyze decrypt_memory changes
            DECRYPT_NEW_INSTR=$(grep -B 5 -A 5 "IN: decrypt_memory" results/in_asm_logs.diff | grep "^+.*OBJD-T: " | sed 's/^+.*OBJD-T: //' | grep -o '.\{8\}' | wc -l)
            echo "  - $DECRYPT_NEW_INSTR new instructions in decrypt_memory"
        else
            echo "- ✓ decrypt_memory function was not modified"
        fi
        
        # 6. Analyze key derivation modifications
        DERIVE_KEY_CHANGES=$(grep -B 5 -A 5 "IN: derive_key" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
        if [ $DERIVE_KEY_CHANGES -gt 0 ]; then
            echo "- ⚠️ WARNING: derive_key function was modified with $DERIVE_KEY_CHANGES changes"
            echo "  Modifications to key derivation could affect cryptographic security"
            SECURITY_RISK=$((SECURITY_RISK + DERIVE_KEY_CHANGES))
        else
            echo "- ✓ No changes to key derivation functions"
        fi
        
        # Calculate overall security risk score (crude metric)
        echo ""
        echo "Overall security risk assessment:"
        if [ $SECURITY_RISK -gt 20 ]; then
            echo "⚠️ HIGH RISK: Score $SECURITY_RISK/100"
            echo "Significant modifications detected in security-critical code"
            echo "Manual inspection strongly recommended"
        elif [ $SECURITY_RISK -gt 10 ]; then
            echo "⚠️ MEDIUM RISK: Score $SECURITY_RISK/100"
            echo "Notable changes in security-sensitive areas"
            echo "Further investigation recommended"
        else
            echo "✓ LOW RISK: Score $SECURITY_RISK/100"
            echo "Changes appear consistent with expected test differences"
        fi
        
        echo ""
        echo "Disclaimer: This is an automated assessment and cannot detect all"
        echo "security issues. Manual code review is always recommended for security-critical code."
    } > results/security_assessment.txt
    
    # Generate a consolidated analysis report
    echo "Generating consolidated analysis report..."
    {
        echo "=== Consolidated Analysis Report ==="
        echo "Test 1 vs. Test 2 Comparison"
        echo "Generated on: $(date)"
        echo ""
        
        echo "== Summary =="
        echo "Binary size: $SIZE1 vs $SIZE2 bytes (diff: $((SIZE2-SIZE1)) bytes)"
        echo "Functions: $FUNCS1 vs $FUNCS2 (diff: $((FUNCS2-FUNCS1)))"
        echo "decrypt_memory size: $DECRYPT1_SIZE vs $DECRYPT2_SIZE lines"
        echo "Execution log differences: $DIFF_CHUNKS chunks, $LINES_ADDED lines added, $LINES_REMOVED lines removed"
        echo "Functions modified: $FUNCS_AFFECTED"
        echo "Machine code changes: $OBJD_CHANGES blocks"
        echo ""
        
        echo "== Top Modified Functions =="
        # List top 5 most modified functions
        for func in $(echo "$AFFECTED_FUNC_LIST"); do
            FUNC_OBJD_CHANGES=$(grep -B 5 -A 5 "IN: $func" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
            echo "$func: $FUNC_OBJD_CHANGES changes" >> temp_func_changes.txt
        done
        sort -t: -k2 -nr temp_func_changes.txt | head -5
        rm -f temp_func_changes.txt
        echo ""
        
        echo "== Security Assessment =="
        tail -n 12 results/security_assessment.txt | head -n 7
        echo ""
        
        echo "== Key Code Changes =="
        # Extract the most significant instruction changes
        grep "Complete Instruction Change" results/instruction_analysis.txt | head -5
        echo "..."
        echo ""
        
        echo "== Interpretation =="
        echo "The differences between Test 1 (password: \"password\") and"
        echo "Test 2 (password: \"2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945\")"
        echo "appear to primarily affect the following areas:"
        echo ""
        
        # Try to interpret what the changes mean
        if grep -q "tfp_format" <<< "$AFFECTED_FUNC_LIST"; then
            PRINTF_CHANGES=$(grep -B 5 -A 5 "IN: tfp_format" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
            echo "1. printf/formatting functions ($PRINTF_CHANGES changes)"
            echo "   - Likely due to different string length handling requirements"
        fi
        
        if grep -q "main" <<< "$AFFECTED_FUNC_LIST"; then
            MAIN_CHANGES=$(grep -B 5 -A 5 "IN: main" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
            echo "2. main function ($MAIN_CHANGES changes)"
            echo "   - Different test path execution"
        fi
        
        if grep -q "decrypt_memory\|derive_key" <<< "$AFFECTED_FUNC_LIST"; then
            CRYPTO_CHANGES=$(grep -B 5 -A 5 "IN: \(decrypt_memory\|derive_key\)" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
            echo "3. Cryptographic functions ($CRYPTO_CHANGES changes)"
            echo "   - Different handling of the longer key material"
        fi
        
        echo ""
        echo "For detailed information, refer to the following reports:"
        echo "- results/build_comparison.txt - Overall build differences"
        echo "- results/function_diff_analysis.txt - Function-specific changes"
        echo "- results/instruction_analysis.txt - Low-level instruction analysis"
        echo "- results/security_assessment.txt - Security implications"
        echo "- results/decrypt_memory_diff.txt - Focused analysis of decrypt_memory function"
    } > results/consolidated_report.txt
    
    # Update the main summary file with references
    {
        echo ""
        echo "=== Additional Analysis Reports ==="
        echo "- results/function_diff_analysis.txt - Function-specific changes"
        echo "- results/code_change_analysis.txt - Assembly code change patterns"
        echo "- results/instruction_analysis.txt - Detailed instruction-level analysis"
        echo "- results/security_assessment.txt - Security implications assessment"
        echo "- results/consolidated_report.txt - Complete analysis summary"
    } >> results/build_comparison.txt
    
    echo "Analysis complete. See results/consolidated_report.txt for the full summary."
    echo "Security assessment available in results/security_assessment.txt"
fi

echo "Done."