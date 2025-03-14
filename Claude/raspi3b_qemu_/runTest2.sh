#!/bin/bash
# Advanced Binary Analysis Script
# This script builds, analyzes and compares ARM binaries for security assessment

# Default values
TEST_NUMBER=1
RUN_AFTER_BUILD=false
LOG_ENABLED=false
DIFF_OUTPUT=false
VERBOSE=false
OUTPUT_FORMAT="text"  # Can be "text" or "html"
SECURITY_RISK=0

# Function definitions
function show_help {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo " -t, --test NUM    Set test number (default: 1)"
    echo " -r, --run         Run after building"
    echo " -l, --log         Run with logging enabled"
    echo " -d, --diff        Create diff with the other test dump file"
    echo " -v, --verbose     Generate detailed reports"
    echo " -f, --format FMT  Output format: text or html (default: text)"
    echo " -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo " $0 -t 2           # Build with test number 2"
    echo " $0 -t 1 -r        # Build and run with test number 1"
    echo " $0 -t 2 -l        # Build and run with logging for test 2"
    echo " $0 -t 2 -d        # Build test 2 and create diff with test 1 dump"
    echo " $0 -t 2 -d -f html # Create HTML report comparing test 2 with test 1"
}

function build_kernel {
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
}

function run_kernel {
    if [ "$LOG_ENABLED" = true ]; then
        echo "Running with logging for test $TEST_NUMBER..."
        make log TEST_NUM=$TEST_NUMBER
    elif [ "$RUN_AFTER_BUILD" = true ]; then
        echo "Running kernel..."
        make run TEST_NUM=$TEST_NUMBER
    fi
}

function analyze_binary {
    # Copy the image and create core analysis files
    cp build/kernel$TEST_NUMBER.img results/kernel$TEST_NUMBER.img
    
    # Basic analysis
    echo "Creating core binary analysis..."
    arm-none-eabi-objdump -d build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.dump
    arm-none-eabi-nm -S build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.symbols.txt
    arm-none-eabi-nm -S --size-sort build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.symbols_by_size.txt
    
    # Advanced analysis if verbose
    if [ "$VERBOSE" = true ]; then
        echo "Creating detailed binary analysis..."
        arm-none-eabi-readelf -h build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.elf_header.txt
        arm-none-eabi-readelf -S build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.sections.txt
        arm-none-eabi-readelf -r build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.relocations.txt
        arm-none-eabi-readelf -l build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.segments.txt
    else
        # Still get basic section info for comparisons
        arm-none-eabi-readelf -S build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.sections.txt
    fi
    
    # Source-annotated disassembly if source available
    if [ -d "src" ]; then
        echo "Creating source-annotated disassembly..."
        arm-none-eabi-objdump -dS build/kernel$TEST_NUMBER.img > results/kernel$TEST_NUMBER.source_dump.txt
    fi
    
    # Generate callgraph information if addr2line is available
    if command -v arm-none-eabi-addr2line >/dev/null 2>&1; then
        echo "Generating basic call graph for key functions..."
        {
            echo "=== Basic Call Graph Analysis ==="
            echo "Functions that reference decrypt_memory:"
            grep -B 2 -A 2 "<decrypt_memory>" results/kernel$TEST_NUMBER.dump | grep "bl" | \
            while read line; do
                echo "$line" | sed -n 's/.*bl.*<\(.*\)>.*/\1 -> decrypt_memory/p'
            done
            
            echo ""
            echo "Functions called by decrypt_memory:"
            grep -A 50 "<decrypt_memory>:" results/kernel$TEST_NUMBER.dump | grep "bl" | \
            while read line; do
                echo "$line" | sed -n 's/.*bl.*<\(.*\)>.*/decrypt_memory -> \1/p'
            done
        } > results/kernel$TEST_NUMBER.callgraph.txt
    fi
    
    # Security function analysis
    analyze_security_functions
}

function analyze_security_functions {
    echo "Checking for potentially suspicious function calls..."
    {
        echo "=== Security Function Reference Analysis ==="
        echo "This analysis looks for references to potentially security-sensitive functions"
        echo ""
        
        # Check for references to potentially dangerous functions
        for func in system exec fork memcpy strcpy sprintf gets; do
            refs=$(arm-none-eabi-nm -A build/kernel$TEST_NUMBER.img | grep " U $func$" || echo "")
            if [ -n "$refs" ]; then
                echo "⚠️ WARNING: Reference to potentially unsafe function: $func"
                echo "$refs"
                echo ""
            fi
        done
        
        # Look for undefined symbols (potential external dependencies)
        echo "Undefined symbols (external dependencies):"
        arm-none-eabi-nm -u build/kernel$TEST_NUMBER.img
        
        # Check for potentially weak cryptographic algorithms
        for weak_algo in MD5 DES RC4 SHA1; do
            refs=$(arm-none-eabi-nm -A build/kernel$TEST_NUMBER.img | grep -i "$weak_algo" || echo "")
            if [ -n "$refs" ]; then
                echo "⚠️ NOTICE: Possible reference to weak cryptographic algorithm: $weak_algo"
                echo "$refs"
                echo ""
            fi
        done
    } > results/kernel$TEST_NUMBER.security_function_analysis.txt
}

function create_symbol_section_diff {
    echo "Comparing symbol tables..."
    diff -u results/kernel1.symbols.txt results/kernel2.symbols.txt > results/symbol_diff.txt
    
    # Create a summary of symbol changes
    {
        echo "=== Symbol Table Comparison ==="
        echo "Symbols present in Test 2 but not in Test 1:"
        grep "^>" results/symbol_diff.txt | sed 's/^> //'
        
        echo ""
        echo "Symbols present in Test 1 but not in Test 2:"
        grep "^<" results/symbol_diff.txt | sed 's/^< //'
        
        echo ""
        echo "Symbols with different sizes or addresses:"
        grep "^[<>]" results/symbol_diff.txt | grep " [tT] " | sort
    } > results/symbol_analysis.txt
    
    # Add section size comparison
    echo "Comparing section sizes..."
    {
        echo "=== Section Size Comparison ==="
        echo "Section | Test 1 Size | Test 2 Size | Difference"
        echo "--------|------------|------------|------------"
        
        grep " \.[a-z]" results/kernel1.sections.txt | while read line; do
            section_name=$(echo "$line" | awk '{print $2}')
            section1_size=$(grep " $section_name " results/kernel1.sections.txt | awk '{print $7}')
            section2_size=$(grep " $section_name " results/kernel2.sections.txt | awk '{print $7}')
            
            # Convert hex to decimal for calculation
            if [[ $section1_size == 0x* ]]; then
                section1_dec=$((section1_size))
            else
                # Handle hex values without 0x prefix
                if [[ $section1_size =~ ^[0-9a-fA-F]+$ ]]; then
                    section1_dec=$((16#$section1_size))
                else
                    section1_dec=$section1_size
                fi
            fi
            
            if [[ $section2_size == 0x* ]]; then
                section2_dec=$((section2_size))
            else
                # Handle hex values without 0x prefix
                if [[ $section2_size =~ ^[0-9a-fA-F]+$ ]]; then
                    section2_dec=$((16#$section2_size))
                else
                    section2_dec=$section2_size
                fi
            fi
            
            # Handle case where one section might exist in one file but not the other
            if [ -z "$section1_dec" ]; then
                section1_dec=0
            fi
            if [ -z "$section2_dec" ]; then
                section2_dec=0
            fi
            
            diff=$((section2_dec - section1_dec))
            
            echo "$section_name | $section1_size | $section2_size | $diff"
        done
    } > results/section_size_comparison.txt
}

function create_log_diff_analysis {
    echo "Creating execution log diff..."
    diff -u results/kernel1.in_asm.log results/kernel2.in_asm.log > results/in_asm_logs.diff
    
    # Create focused diff of crypto-related lines
    echo "Creating crypto lines diff..."
    grep -E "passphrase|session_key|key|PW:|password|decrypt|encrypt|cipher" results/kernel1.in_asm.log > results/kernel1.crypto_lines.txt
    grep -E "passphrase|session_key|key|PW:|password|decrypt|encrypt|cipher" results/kernel2.in_asm.log > results/kernel2.crypto_lines.txt
    diff -u results/kernel1.crypto_lines.txt results/kernel2.crypto_lines.txt > results/crypto_lines.diff
    
    # Count diff statistics
    DIFF_CHUNKS=$(grep -c "^@@" results/in_asm_logs.diff)
    LINES_ADDED=$(grep -c "^+" results/in_asm_logs.diff)
    LINES_REMOVED=$(grep -c "^-" results/in_asm_logs.diff)
    
    # Count unique functions that appear in diffs
    FUNCS_AFFECTED=$(grep -A 1 "^@@" results/in_asm_logs.diff | grep "IN: " | awk '{print $2}' | sort -u | wc -l)
    
    # Get list of functions affected
    AFFECTED_FUNC_LIST=$(grep -A 1 "^@@" results/in_asm_logs.diff | grep "IN: " | awk '{print $2}' | sort -u | tr '\n' ' ')
    
    analyze_function_diffs
    analyze_assembly_changes
    analyze_instruction_patterns
    create_security_assessment
}

function analyze_function_diffs {
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
}

function analyze_assembly_changes {
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
    } > results/code_change_analysis.txt
}

function analyze_instruction_patterns {
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
        
        # Categorize changes by instruction type
        echo ""
        echo "Types of machine code changes detected:"
        
        # Look for specific patterns in changed instructions
        BRANCH_CHANGES=$(grep -c "e[abcdef]" temp_objd_new.txt 2>/dev/null || echo 0)
        LOAD_STORE_CHANGES=$(grep -c "[89a][0-9a-f]e[0-5]" temp_objd_new.txt 2>/dev/null || echo 0)
        ALU_CHANGES=$(grep -c "[0-3][0-9a-f]e[0-9a]" temp_objd_new.txt 2>/dev/null || echo 0)
        MOVE_CHANGES=$(grep -c "[01][0-9a-f]a0e[13]" temp_objd_new.txt 2>/dev/null || echo 0)
        
        echo "- Branch instruction changes: $BRANCH_CHANGES"
        echo "- Load/Store instruction changes: $LOAD_STORE_CHANGES"
        echo "- ALU operation changes: $ALU_CHANGES"
        echo "- Move/Copy operation changes: $MOVE_CHANGES"
        
        # Enhanced ARM disassembly analysis - try to interpret some common patterns
        echo ""
        echo "Common ARM instruction patterns detected in changes:"
        
        # Count specific ARM instruction patterns
        LDR_COUNT=$(grep -c "..5[0-9a-f]e5" temp_objd_new.txt 2>/dev/null || echo 0)
        STR_COUNT=$(grep -c "..4[0-9a-f]e5" temp_objd_new.txt 2>/dev/null || echo 0)
        B_COUNT=$(grep -c "....ea" temp_objd_new.txt 2>/dev/null || echo 0)     # Unconditional branches
        BL_COUNT=$(grep -c "....eb" temp_objd_new.txt 2>/dev/null || echo 0)    # Branch with link
        MOV_COUNT=$(grep -c "[01][0-9a-f]a0e[13]" temp_objd_new.txt 2>/dev/null || echo 0)
        
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
            STACK_ACCESSES=$(grep -c "[89][0-9a-f]e[0-5]d" temp_objd_new.txt 2>/dev/null || echo 0)
            GLOBAL_ACCESSES=$(grep -c "[89][0-9a-f]e[0-5][^d]" temp_objd_new.txt 2>/dev/null || echo 0)
            
            echo "- Stack-relative memory accesses: $STACK_ACCESSES"
            echo "- Global/static memory accesses: $GLOBAL_ACCESSES"
            
            # List the top 5 memory addresses accessed
            echo "- Top memory address patterns:"
            grep -o "[89][0-9a-f]e[0-5]......" temp_objd_new.txt 2>/dev/null | sort | uniq -c | sort -nr | head -5 | \
                while read count pattern; do
                    echo "  $pattern: $count occurrences"
                done
        else
            echo "- No significant memory access pattern changes detected"
        fi
        
        # Analyze suspicious patterns that might indicate backdoors or other security issues
        analyze_security_patterns
        
        # Don't remove the temp files yet - needed for security assessment
    } > results/instruction_analysis.txt
}

function analyze_security_patterns {
    echo ""
    echo "Security analysis:"
    
    # Look for uncommon instruction patterns that might be suspicious
    SUSPICIOUS_PATTERNS=0
    
    # Self-modifying code patterns
    if grep -q "f000f[0-9a-f]" temp_objd_new.txt 2>/dev/null; then
        echo "- WARNING: Potentially suspicious SMC (Self-Modifying Code) instruction patterns detected"
        SUSPICIOUS_PATTERNS=$((SUSPICIOUS_PATTERNS + 1))
    fi
    
    # Mode switch patterns
    if grep -q "00f020e3" temp_objd_new.txt 2>/dev/null; then
        echo "- WARNING: Potentially suspicious privileged mode switches detected"
        SUSPICIOUS_PATTERNS=$((SUSPICIOUS_PATTERNS + 1))
    fi
    
    # Unexpected system calls
    if grep -q "0[0-9]0000ef" temp_objd_new.txt 2>/dev/null; then
        echo "- WARNING: System call instructions detected in changes"
        SUSPICIOUS_PATTERNS=$((SUSPICIOUS_PATTERNS + 1))
    fi
    
    # Unexpected coprocessor access
    if grep -q "ee[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]" temp_objd_new.txt 2>/dev/null; then
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
}

function create_security_assessment {
    echo "Creating security assessment report..."
    
    # Reset security risk
    SECURITY_RISK=0
    
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
        SIZE1=$(stat -c %s "results/kernel1.img")
        SIZE2=$(stat -c %s "results/kernel2.img")
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

        # Symbol-based security analysis
        echo ""
        echo "== Symbol-based security analysis =="
        if [ -f "results/kernel$TEST_NUMBER.security_function_analysis.txt" ]; then
            # Extract information about potentially risky function usage
            grep -A2 "potentially unsafe function\|weak cryptographic algorithm" results/kernel$TEST_NUMBER.security_function_analysis.txt
        fi
        
        echo ""
        echo "Disclaimer: This is an automated assessment and cannot detect all"
        echo "security issues. Manual code review is always recommended for security-critical code."
    } > results/security_assessment.txt
    
    # Clean up temporary files
    rm -f temp_objd_old.txt temp_objd_new.txt temp_old_instr.txt temp_new_instr.txt temp_old_pattern.txt temp_new_pattern.txt
}

function create_diff_analysis {
    # Determine which is the other test number
    if [ "$TEST_NUMBER" -eq 1 ]; then
        OTHER_TEST=2
    else
        OTHER_TEST=1
    fi
    
    # Check if the other test dump exists
    if [ ! -f "results/kernel$OTHER_TEST.dump" ]; then
        echo "Cannot create diff: results/kernel$OTHER_TEST.dump does not exist."
        echo "Run $0 -t $OTHER_TEST first to generate the other dump file."
        return 1
    fi
    
    echo "Creating diff between test $TEST_NUMBER and test $OTHER_TEST..."
    
    # Basic binary diffs
    diff -u results/kernel$TEST_NUMBER.dump results/kernel$OTHER_TEST.dump > results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff
    grep -A 500 "<decrypt_memory>:" results/kernel$TEST_NUMBER.dump > results/kernel${TEST_NUMBER}.decrypt_memory.txt
    grep -A 500 "<decrypt_memory>:" results/kernel$OTHER_TEST.dump > results/kernel${OTHER_TEST}.decrypt_memory.txt
    diff -u results/kernel${TEST_NUMBER}.decrypt_memory.txt results/kernel${OTHER_TEST}.decrypt_memory.txt > results/decrypt_memory_diff.txt
    
    # Function list diff
    grep "<.*>:" results/kernel$TEST_NUMBER.dump | sort > results/kernel${TEST_NUMBER}.functions.txt
    grep "<.*>:" results/kernel$OTHER_TEST.dump | sort > results/kernel${OTHER_TEST}.functions.txt
    diff -u results/kernel${TEST_NUMBER}.functions.txt results/kernel${OTHER_TEST}.functions.txt > results/functions_diff.txt
    
    # Binary comparison
    cmp results/kernel$TEST_NUMBER.img results/kernel$OTHER_TEST.img > results/kernel_binary_cmp.txt 2>&1
    
    # Create more detailed analysis
    if [ -f "results/kernel1.symbols.txt" ] && [ -f "results/kernel2.symbols.txt" ]; then
        create_symbol_section_diff
    fi
    
    # Compare log files if they exist
    if [ -f "results/kernel$TEST_NUMBER.in_asm.log" ] && [ -f "results/kernel$OTHER_TEST.in_asm.log" ]; then
        create_log_diff_analysis
    fi
    
    # Create summary reports
    create_summary_report
    
    # Create HTML report if needed
    if [ "$OUTPUT_FORMAT" = "html" ]; then
        create_html_report
    fi
    
    # Print summary of diff files created
    echo "Diff files created:"
    echo " - results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff (disassembly diff)"
    echo " - results/decrypt_memory_diff.txt (decrypt_memory function diff)"
    echo " - results/functions_diff.txt (function list diff)"
    echo " - results/kernel_binary_cmp.txt (binary comparison)"
    
    if [ -f "results/in_asm_logs.diff" ]; then
        echo " - results/in_asm_logs.diff (execution log diff)"
        echo " - results/crypto_lines.diff (crypto-related log lines diff)"
    fi
    
    if [ -f "results/symbol_diff.txt" ]; then
        echo " - results/symbol_diff.txt (symbol table diff)"
        echo " - results/section_size_comparison.txt (section size comparison)"
    fi

    echo "- results/build_comparison.txt - Overall build differences"
    echo "- results/function_diff_analysis.txt - Function-specific changes"
    echo "- results/instruction_analysis.txt - Low-level instruction analysis"
    echo "- results/security_assessment.txt - Security implications"
    echo "- results/decrypt_memory_diff.txt - Focused analysis of decrypt_memory function"
    
    echo "Analysis complete. See results/consolidated_report.txt for the full summary."
    echo "Security assessment available in results/security_assessment.txt"
}

function create_summary_report {
    echo "Creating summary of differences..."
    
    # Get basic binary stats
    SIZE1=$(stat -c %s "results/kernel1.img")
    SIZE2=$(stat -c %s "results/kernel2.img")
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
    
    # Output to build comparison summary file
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
        
        # Add symbol and section analysis information to the build summary
        if [ -f "results/symbol_analysis.txt" ] && [ -f "results/section_size_comparison.txt" ]; then
            echo ""
            echo "=== Symbol Analysis Summary ==="
            echo "Symbols added in Test 2: $(grep -A50 "Symbols present in Test 2 but not in Test 1" results/symbol_analysis.txt | grep -v "^--" | grep -v "^$" | wc -l)"
            echo "Symbols removed from Test 1: $(grep -A50 "Symbols present in Test 1 but not in Test 2" results/symbol_analysis.txt | grep -v "^--" | grep -v "^$" | wc -l)"
            
            # Extract the most significant section size changes
            echo ""
            echo "Most significant section size changes:"
            grep -A20 "Section |" results/section_size_comparison.txt | grep -v "^--" | \
            awk -F"|" '{if ($4 && $4 != " Difference" && ($4+0 > 100 || $4+0 < -100)) print $0}' | head -5
            
            # Add security-relevant findings
            if [ -f "results/kernel$TEST_NUMBER.security_function_analysis.txt" ]; then
                echo ""
                echo "=== Security Function Summary ==="
                grep "WARNING\|NOTICE" results/kernel$TEST_NUMBER.security_function_analysis.txt | head -5
            fi
        fi

        # Add largest functions information
        if [ -f "results/kernel$TEST_NUMBER.symbols_by_size.txt" ]; then
            echo ""
            echo "=== Largest Functions in Test $TEST_NUMBER ==="
            head -10 results/kernel$TEST_NUMBER.symbols_by_size.txt
        fi
        
        echo ""
        echo "=== Key differences may be found in the diff files ==="
        echo " - results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff (disassembly diff)"
        echo " - results/decrypt_memory_diff.txt (decrypt_memory function diff)"
        echo " - results/functions_diff.txt (function list diff)"
        if [ -f "results/in_asm_logs.diff" ]; then
            echo " - results/in_asm_logs.diff (execution log diff)"
            echo " - results/crypto_lines.diff (crypto-related log lines diff)"
        fi
        
        # Add references to all analysis files
        echo ""
        echo "=== Additional Analysis Reports ==="
        echo "- results/function_diff_analysis.txt - Function-specific changes"
        echo "- results/code_change_analysis.txt - Assembly code change patterns"
        echo "- results/instruction_analysis.txt - Detailed instruction-level analysis"
        echo "- results/security_assessment.txt - Security implications assessment"
        echo "- results/consolidated_report.txt - Complete analysis summary"
        echo "- results/kernel${TEST_NUMBER}.symbols.txt - Symbol table analysis"
        echo "- results/kernel${TEST_NUMBER}.symbols_by_size.txt - Symbols sorted by size"
        echo "- results/kernel${TEST_NUMBER}.elf_header.txt - ELF header information"
        echo "- results/kernel${TEST_NUMBER}.sections.txt - Section headers"
        echo "- results/kernel${TEST_NUMBER}.security_function_analysis.txt - Security analysis of function references"
        echo "- results/kernel${TEST_NUMBER}.callgraph.txt - Basic call graph for key functions"
        echo "- results/symbol_diff.txt - Symbol differences between tests"
        echo "- results/symbol_analysis.txt - Analysis of symbol changes"
        echo "- results/section_size_comparison.txt - Section size differences"
    } > results/build_comparison.txt
    
    # Create consolidated analysis report
    {
        echo "=== Consolidated Analysis Report ==="
        echo "Test 1 vs. Test 2 Comparison"
        echo "Generated on: $(date)"
        echo ""
        
        echo "== Summary =="
        echo "Binary size: $SIZE1 vs $SIZE2 bytes (diff: $((SIZE2-SIZE1)) bytes)"
        echo "Functions: $FUNCS1 vs $FUNCS2 (diff: $((FUNCS2-FUNCS1)))"
        echo "decrypt_memory size: $DECRYPT1_SIZE vs $DECRYPT2_SIZE lines"
        
        if [ -f "results/in_asm_logs.diff" ]; then
            echo "Execution log differences: $DIFF_CHUNKS chunks, $LINES_ADDED lines added, $LINES_REMOVED lines removed"
            echo "Functions modified: $FUNCS_AFFECTED"
            echo "Machine code changes: $OBJD_CHANGES blocks"
        fi
        echo ""
        
        echo "== Top Modified Functions =="
        if [ -f "results/in_asm_logs.diff" ] && [ -n "$AFFECTED_FUNC_LIST" ]; then
            # List top 5 most modified functions
            for func in $(echo "$AFFECTED_FUNC_LIST"); do
                FUNC_OBJD_CHANGES=$(grep -B 5 -A 5 "IN: $func" results/in_asm_logs.diff | grep "OBJD-T:" | grep "^[+-]" | wc -l)
                echo "$func: $FUNC_OBJD_CHANGES changes" >> temp_func_changes.txt
            done

            # Check if the file exists before sorting
            if [ -f "temp_func_changes.txt" ]; then
                sort -t: -k2 -nr temp_func_changes.txt | head -5
                rm -f temp_func_changes.txt
            else
                echo "No function changes detected."
            fi
        else
            echo "No execution logs available for comparison."
        fi
        echo ""
        
        echo "== Security Assessment =="
        if [ -f "results/security_assessment.txt" ]; then
            tail -n 12 results/security_assessment.txt | head -n 7
        else
            echo "No security assessment available."
        fi
        echo ""
        
        echo "== Symbol and Section Analysis =="
        if [ -f "results/symbol_analysis.txt" ]; then
            # Extract key findings from symbol analysis
            echo "Symbol changes:"
            NEW_SYMBOLS=$(grep -c "^Symbols present in Test 2 but not in Test 1" -A5 results/symbol_analysis.txt | grep -v "^--" | head -3)
            REMOVED_SYMBOLS=$(grep -c "^Symbols present in Test 1 but not in Test 2" -A5 results/symbol_analysis.txt | grep -v "^--" | head -3)
            echo "- New symbols in Test 2: $(echo "$NEW_SYMBOLS" | wc -l)"
            echo "- Removed symbols in Test 1: $(echo "$REMOVED_SYMBOLS" | wc -l)"
            
            # Extract significant section size changes
            echo ""
            echo "Section size changes:"
            grep -A10 "Section |" results/section_size_comparison.txt | grep -v "^--" | awk -F"|" '{if ($4 && $4 != " Difference" && $4+0 != 0) print $0}' | head -5
        fi

        # Check for suspicious functions found
        if [ -f "results/kernel$TEST_NUMBER.security_function_analysis.txt" ]; then
            echo ""
            echo "Security function findings:"
            grep "WARNING\|NOTICE" results/kernel$TEST_NUMBER.security_function_analysis.txt | head -3
        fi

        # Add callgraph analysis information
        if [ -f "results/kernel$TEST_NUMBER.callgraph.txt" ]; then
            echo ""
            echo "Call graph analysis for decrypt_memory:"
            grep "decrypt_memory ->" results/kernel$TEST_NUMBER.callgraph.txt | head -5
        fi
        
        echo ""
        echo "== Key Code Changes =="
        # Extract the most significant instruction changes
        if [ -f "results/instruction_analysis.txt" ]; then
            grep "Complete Instruction Change" results/instruction_analysis.txt | head -5
            echo "..."
        else
            echo "No instruction analysis available."
        fi
        echo ""
        
        echo "== Interpretation =="
        echo "The differences between Test 1 (password: \"password\") and"
        echo "Test 2 (password: \"2af14ef19220d275b0f87907f4ab5075dc9b75b574ef8c2e06e32e8311776945\")"
        echo "appear to primarily affect the following areas:"
        echo ""
        
        # Try to interpret what the changes mean
        if [ -f "results/in_asm_logs.diff" ]; then
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
        else
            echo "No execution log differences available to interpret changes."
        fi
        
        echo ""
        echo "For detailed information, refer to the following reports:"
        echo "- results/build_comparison.txt - Overall build differences"
        echo "- results/function_diff_analysis.txt - Function-specific changes"
        echo "- results/instruction_analysis.txt - Low-level instruction analysis"
        echo "- results/security_assessment.txt - Security implications"
        echo "- results/decrypt_memory_diff.txt - Focused analysis of decrypt_memory function"
    } > results/consolidated_report.txt
    
    echo "Summary created: results/build_comparison.txt"
}

function create_html_report {
    echo "Generating HTML report..."
    
    # Create HTML summary file with all results
    {
        echo "<!DOCTYPE html>"
        echo "<html lang=\"en\">"
        echo "<head>"
        echo "  <meta charset=\"UTF-8\">"
        echo "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
        echo "  <title>Binary Analysis Report</title>"
        echo "  <style>"
        echo "    body { font-family: Arial, sans-serif; margin: 0; padding: 20px; line-height: 1.6; }"
        echo "    .container { max-width: 1200px; margin: 0 auto; }"
        echo "    h1, h2, h3 { color: #333; }"
        echo "    h2 { border-bottom: 1px solid #eee; padding-bottom: 10px; margin-top: 30px; }"
        echo "    pre { background: #f5f5f5; padding: 15px; overflow-x: auto; border-radius: 4px; }"
        echo "    table { border-collapse: collapse; width: 100%; }"
        echo "    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }"
        echo "    th { background-color: #f2f2f2; }"
        echo "    tr:nth-child(even) { background-color: #f9f9f9; }"
        echo "    .warning { color: #d9534f; }"
        echo "    .success { color: #5cb85c; }"
        echo "    .notice { color: #f0ad4e; }"
        echo "    .collapsible { background-color: #f1f1f1; color: #333; cursor: pointer; padding: 10px; width: 100%; border: none; text-align: left; outline: none; font-size: 15px; margin: 2px 0; }"
        echo "    .active, .collapsible:hover { background-color: #ddd; }"
        echo "    .content { padding: 0 18px; display: none; overflow: hidden; background-color: #f9f9f9; }"
        echo "  </style>"
        echo "</head>"
        echo "<body>"
        echo "  <div class=\"container\">"
        echo "    <h1>Binary Analysis Report</h1>"
        echo "    <p>Comparison between Test 1 and Test 2</p>"
        echo "    <p>Generated on: $(date)</p>"
        
        # Basic summary
        echo "    <h2>Summary</h2>"
        echo "    <table>"
        echo "      <tr><th>Metric</th><th>Test 1</th><th>Test 2</th><th>Difference</th></tr>"
        echo "      <tr><td>Binary Size</td><td>$SIZE1 bytes</td><td>$SIZE2 bytes</td><td>$((SIZE2 - SIZE1)) bytes</td></tr>"
        echo "      <tr><td>Function Count</td><td>$FUNCS1</td><td>$FUNCS2</td><td>$((FUNCS2 - FUNCS1))</td></tr>"
        echo "      <tr><td>decrypt_memory Size</td><td>$DECRYPT1_SIZE lines</td><td>$DECRYPT2_SIZE lines</td><td>-</td></tr>"
        echo "    </table>"
        
        # Security Assessment (Collapsible)
        echo "    <h2>Security Assessment</h2>"
        echo "    <button class=\"collapsible\">View Security Assessment</button>"
        echo "    <div class=\"content\">"
        if [ -f "results/security_assessment.txt" ]; then
            echo "      <pre>"
            cat results/security_assessment.txt
            echo "      </pre>"
        else
            echo "      <p>No security assessment available.</p>"
        fi
        echo "    </div>"
        
        # Top Modified Functions (Collapsible)
        echo "    <h2>Modified Functions</h2>"
        echo "    <button class=\"collapsible\">View Top Modified Functions</button>"
        echo "    <div class=\"content\">"
        if [ -f "results/function_diff_analysis.txt" ]; then
            echo "      <pre>"
            cat results/function_diff_analysis.txt
            echo "      </pre>"
        else
            echo "      <p>No function analysis available.</p>"
        fi
        echo "    </div>"
        
        # Symbol Analysis (Collapsible)
        echo "    <h2>Symbol Analysis</h2>"
        echo "    <button class=\"collapsible\">View Symbol Analysis</button>"
        echo "    <div class=\"content\">"
        if [ -f "results/symbol_analysis.txt" ]; then
            echo "      <pre>"
            cat results/symbol_analysis.txt
            echo "      </pre>"
        else
            echo "      <p>No symbol analysis available.</p>"
        fi
        echo "    </div>"
        
        # Section Size Comparison (Collapsible)
        echo "    <h2>Section Size Comparison</h2>"
        echo "    <button class=\"collapsible\">View Section Size Comparison</button>"
        echo "    <div class=\"content\">"
        if [ -f "results/section_size_comparison.txt" ]; then
            echo "      <pre>"
            cat results/section_size_comparison.txt
            echo "      </pre>"
        else
            echo "      <p>No section size comparison available.</p>"
        fi
        echo "    </div>"
        
        # Add more collapsible sections for other analyses
        
        # JavaScript for collapsible sections
        echo "    <script>"
        echo "      var coll = document.getElementsByClassName(\"collapsible\");"
        echo "      for (var i = 0; i < coll.length; i++) {"
        echo "        coll[i].addEventListener(\"click\", function() {"
        echo "          this.classList.toggle(\"active\");"
        echo "          var content = this.nextElementSibling;"
        echo "          if (content.style.display === \"block\") {"
        echo "            content.style.display = \"none\";"
        echo "          } else {"
        echo "            content.style.display = \"block\";"
        echo "          }"
        echo "        });"
        echo "      }"
        echo "    </script>"
        echo "  </div>"
        echo "</body>"
        echo "</html>"
    } > results/report.html
    
    echo "HTML report created: results/report.html"
}

# Main script execution starts here
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
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
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

# Check if src/testNumber.h exists
if [ ! -f "src/testNumber.h" ]; then
    echo "Error: src/testNumber.h not found in current directory."
    exit 1
fi

# Create results directory if it doesn't exist
mkdir -p results

# Main execution flow
build_kernel
run_kernel
analyze_binary

if [ "$DIFF_OUTPUT" = true ]; then
    create_diff_analysis
fi

if [ "$TEST_NUMBER" -eq 1 ]; then
    echo "TEST_NUMBER is 1. Saving analysis for test 2..."
fi

echo "=== Testing completed ==="
echo "See results directory for analysis reports and comparisons."
echo "Done."