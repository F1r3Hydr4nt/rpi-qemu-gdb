#!/bin/bash
# Advanced Binary Analysis Script
# This script analyzes and compares ARM binaries (kernel1.img and kernel2.img) for security assessment

# Default values
LOG_ENABLED=false
VERBOSE=false
SECURITY_RISK=0
QEMU_RUN_RISK=0
# Function definitions
function show_help {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo " -l, --log         Process with logging enabled"
    echo " -v, --verbose     Generate detailed reports"
    echo " -h, --help        Show this help message"
}

function check_requirements {
    # Check if kernel image files exist
    if [ ! -f "build/kernel1.img" ]; then
        echo "Error: build/kernel1.img not found."
        exit 1
    fi
    
    if [ ! -f "build/kernel2.img" ]; then
        echo "Error: build/kernel2.img not found."
        exit 1
    fi
    
    # Check if required ARM tools are installed
    for tool in arm-none-eabi-objdump arm-none-eabi-nm arm-none-eabi-readelf; do
        if ! command -v $tool &> /dev/null; then
            echo "Error: $tool command not found. Please install ARM toolchain."
            exit 1
        fi
    done
}

function analyze_binary {
    # Create results directory if it doesn't exist
    mkdir -p results
    
    # Copy the image to results directory
    cp build/kernel${TEST_NUMBER}.img results/kernel${TEST_NUMBER}.img
    
    # Basic analysis
    echo "Creating core binary analysis..."
    arm-none-eabi-objdump -d build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.dump 2>/dev/null || \
    arm-none-eabi-objdump -D -b binary -m arm build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.dump
    
    arm-none-eabi-nm -S build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.symbols.txt 2>/dev/null || \
    echo "Warning: nm could not extract symbols. File may not have symbol table."
    
    arm-none-eabi-nm -S --size-sort build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.symbols_by_size.txt 2>/dev/null
    
    # Advanced analysis if verbose
    if [ "$VERBOSE" = true ]; then
        echo "Creating detailed binary analysis..."
        arm-none-eabi-readelf -h build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.elf_header.txt 2>/dev/null || \
        echo "Warning: readelf could not extract ELF header. File may not be in ELF format."
        
        arm-none-eabi-readelf -S build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.sections.txt 2>/dev/null || \
        echo "Warning: readelf could not extract section headers."
        
        arm-none-eabi-readelf -r build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.relocations.txt 2>/dev/null
        arm-none-eabi-readelf -l build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.segments.txt 2>/dev/null
    else
        # Still get basic section info for comparisons
        arm-none-eabi-readelf -S build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.sections.txt 2>/dev/null
    fi
    
    # Source-annotated disassembly if source available
    if [ -d "src" ]; then
        echo "Creating source-annotated disassembly..."
        arm-none-eabi-objdump -dS build/kernel${TEST_NUMBER}.img > results/kernel${TEST_NUMBER}.source_dump.txt 2>/dev/null
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
            refs=$(arm-none-eabi-nm -A build/kernel${TEST_NUMBER}.img 2>/dev/null | grep " U $func$" || echo "")
            if [ -n "$refs" ]; then
                echo "⚠️ WARNING: Reference to potentially unsafe function: $func"
                echo "$refs"
                echo ""
            fi
        done
        
        # Look for undefined symbols (potential external dependencies)
        echo "Undefined symbols (external dependencies):"
        arm-none-eabi-nm -u build/kernel${TEST_NUMBER}.img 2>/dev/null || echo "No undefined symbols found or unable to analyze"
        
        # Check for potentially weak cryptographic algorithms
        for weak_algo in MD5 DES RC4 SHA1; do
            refs=$(arm-none-eabi-nm -A build/kernel${TEST_NUMBER}.img 2>/dev/null | grep -i "$weak_algo" || echo "")
            if [ -n "$refs" ]; then
                echo "⚠️ NOTICE: Possible reference to weak cryptographic algorithm: $weak_algo"
                echo "$refs"
                echo ""
            fi
        done
        
        # Scan for strings related to crypto
        echo "Scanning for crypto-related strings:"
        strings build/kernel${TEST_NUMBER}.img | grep -i "crypt\|password\|key\|secret\|cipher\|hash\|decrypt\|encrypt" || echo "No crypto-related strings found"
        
    } > results/kernel${TEST_NUMBER}.security_function_analysis.txt
}

function create_symbol_section_diff {
    echo "Comparing symbol tables..."
    if [ -s results/kernel1.symbols.txt ] && [ -s results/kernel2.symbols.txt ]; then
        diff -u results/kernel1.symbols.txt results/kernel2.symbols.txt > results/symbol_diff.txt
        
        # Create a summary of symbol changes
        {
            echo "=== Symbol Table Comparison ==="
            echo "Symbols present in kernel2.img but not in kernel1.img:"
            grep "^>" results/symbol_diff.txt | sed 's/^> //' || echo "None found"
            
            echo ""
            echo "Symbols present in kernel1.img but not in kernel2.img:"
            grep "^<" results/symbol_diff.txt | sed 's/^< //' || echo "None found"
            
            echo ""
            echo "Symbols with different sizes or addresses:"
            grep "^[<>]" results/symbol_diff.txt | grep " [tT] " | sort || echo "None found"
        } > results/symbol_analysis.txt
    else
        echo "Warning: Symbol files are empty or missing. Cannot create symbol diff."
        touch results/symbol_diff.txt
        echo "No symbol information available for comparison." > results/symbol_analysis.txt
    fi
    
    # Add section size comparison
    echo "Comparing section sizes..."
    {
        echo "=== Section Size Comparison ==="
        echo "Section | kernel1.img Size | kernel2.img Size | Difference"
        echo "--------|------------|------------|------------"
        
        if [ -s results/kernel1.sections.txt ] && [ -s results/kernel2.sections.txt ]; then
            grep " \.[a-z]" results/kernel1.sections.txt 2>/dev/null | while read line; do
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
        else
            echo "No section information available for comparison."
        fi
    } > results/section_size_comparison.txt
}

function analyze_assembly_changes {
    echo "Analyzing machine code differences..."
    {
        echo "=== Assembly Code Difference Analysis ==="
        echo "This analysis shows patterns in the machine code differences between kernel1.img and kernel2.img"
        echo ""
        
        # Binary comparison
        echo "Binary comparison:"
        cmp build/kernel1.img build/kernel2.img > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "The binary files are identical."
        else
            echo "The binary files are different."
            
            # Count and show first few differences
            diff_count=$(cmp -l build/kernel1.img build/kernel2.img 2>/dev/null | wc -l)
            echo "Number of byte differences: $diff_count"
            echo ""
            echo "First 10 byte differences (byte position: kernel1 vs kernel2):"
            cmp -l build/kernel1.img build/kernel2.img 2>/dev/null | head -10 | 
            while read pos byte1 byte2; do
                printf "Position %d: 0x%02x vs 0x%02x\n" "$pos" "$byte1" "$byte2"
            done
        fi
        
        echo ""
        echo "Size comparison:"
        size1=$(wc -c < build/kernel1.img)
        size2=$(wc -c < build/kernel2.img)
        size_diff=$((size2 - size1))
        echo "kernel1.img: $size1 bytes"
        echo "kernel2.img: $size2 bytes"
        echo "Difference: $size_diff bytes"
        
        # Extract disassembly differences if available
        if [ -f "results/kernel1.dump" ] && [ -f "results/kernel2.dump" ]; then
            echo ""
            echo "Instruction pattern differences (sampling):"
            
            # Get instruction patterns from both dumps
            grep -o '^ *[0-9a-f]\+:.*' results/kernel1.dump | head -1000 > temp_k1_instr.txt
            grep -o '^ *[0-9a-f]\+:.*' results/kernel2.dump | head -1000 > temp_k2_instr.txt
            
            # Get unique instructions in kernel2 that aren't in kernel1
            grep -v -F -f temp_k1_instr.txt temp_k2_instr.txt | head -20 > temp_unique_instr.txt
            
            if [ -s temp_unique_instr.txt ]; then
                echo "Sample of instructions unique to kernel2.img:"
                cat temp_unique_instr.txt
            else
                echo "No unique instruction patterns found in the sample."
            fi
            
            # Cleanup
            rm -f temp_k1_instr.txt temp_k2_instr.txt temp_unique_instr.txt
        else
            echo ""
            echo "Disassembly files not available for instruction pattern analysis."
        fi
        
    } > results/binary_difference_analysis.txt
}
function create_in_asm_diff {
    echo "Analyzing QEMU in_asm execution logs..."
    
    # Create results directory if it doesn't exist
    mkdir -p results
    
    # Initialize QEMU_RUN_RISK
    local QEMU_RUN_RISK=0
    
    {
        echo "=== QEMU in_asm Execution Log Analysis ==="
        echo "This analysis compares instruction execution traces from QEMU logs"
        echo "between kernel1.img and kernel2.img runs"
        echo ""
        
        # Count total instructions in each log
        INSTR_COUNT1=$(wc -l < results/kernel1.in_asm.log 2>/dev/null || echo "0")
        INSTR_COUNT2=$(wc -l < results/kernel2.in_asm.log 2>/dev/null || echo "0")
        
        # Ensure variables are numeric
        INSTR_COUNT1=${INSTR_COUNT1//[^0-9]/}
        INSTR_COUNT2=${INSTR_COUNT2//[^0-9]/}
        
        # Set default values if empty
        INSTR_COUNT1=${INSTR_COUNT1:-0}
        INSTR_COUNT2=${INSTR_COUNT2:-0}
        
        echo "Instruction count comparison:"
        echo "kernel1.img: $INSTR_COUNT1 instructions executed"
        echo "kernel2.img: $INSTR_COUNT2 instructions executed"
        INSTR_DIFF=$((INSTR_COUNT2 - INSTR_COUNT1))
        echo "Difference: $INSTR_DIFF instructions"
        
        # Any instruction count difference should be considered suspicious for identical logic
        if [ $INSTR_DIFF -ne 0 ]; then
            INSTR_DIFF_ABS=${INSTR_DIFF#-}  # Get absolute value
            QEMU_RUN_RISK=$((QEMU_RUN_RISK + (INSTR_DIFF_ABS / 10)))
            echo "⚠️ WARNING: Instruction count difference detected in binaries that should be logically identical"
        fi
        
        # Calculate execution path variation
        echo ""
        echo "Execution path analysis:"
        
        # Create sorted unique instruction address lists
        sort -u results/kernel1.in_asm.log | grep -o "^0x[0-9a-f]\+" > results/kernel1.addresses.txt
        sort -u results/kernel2.in_asm.log | grep -o "^0x[0-9a-f]\+" > results/kernel2.addresses.txt
        
        # Count unique addresses in each log
        UNIQUE_ADDR1=$(wc -l < results/kernel1.addresses.txt 2>/dev/null || echo "0")
        UNIQUE_ADDR2=$(wc -l < results/kernel2.addresses.txt 2>/dev/null || echo "0")
        
        # Ensure variables are numeric
        UNIQUE_ADDR1=${UNIQUE_ADDR1//[^0-9]/}
        UNIQUE_ADDR2=${UNIQUE_ADDR2//[^0-9]/}
        
        # Set default values if empty
        UNIQUE_ADDR1=${UNIQUE_ADDR1:-0}
        UNIQUE_ADDR2=${UNIQUE_ADDR2:-0}
        
        echo "Unique addresses executed in kernel1.img: $UNIQUE_ADDR1"
        echo "Unique addresses executed in kernel2.img: $UNIQUE_ADDR2"
        
        # Find addresses in kernel2 but not in kernel1 (potentially new code paths)
        NOVEL_PATHS=$(comm -13 results/kernel1.addresses.txt results/kernel2.addresses.txt | wc -l || echo "0")
        echo "Novel execution paths in kernel2.img: $NOVEL_PATHS addresses"
        
        # Find addresses in kernel1 but not in kernel2 (potentially removed code paths)
        REMOVED_PATHS=$(comm -23 results/kernel1.addresses.txt results/kernel2.addresses.txt | wc -l || echo "0")
        echo "Removed execution paths from kernel1.img: $REMOVED_PATHS addresses"
        
        # Any differences in execution paths is suspicious for identical logic
        if [ $NOVEL_PATHS -gt 0 ] || [ $REMOVED_PATHS -gt 0 ]; then
            TOTAL_PATH_DIFF=$((NOVEL_PATHS + REMOVED_PATHS))
            QEMU_RUN_RISK=$((QEMU_RUN_RISK + (TOTAL_PATH_DIFF / 5)))
            echo "⚠️ WARNING: Execution path differences detected ($TOTAL_PATH_DIFF total paths) in binaries that should be logically identical"
        fi
        
        # Analyze memory address pattern changes
        echo ""
        echo "Memory address pattern analysis:"

        # Check for memory address constant differences in disassembly
        CONST_ADDR_CHANGES=0
        if [ -f "results/kernel2_vs_kernel1.dump.diff" ]; then
            # Count lines with .word pattern changes 
            CONST_ADDR_CHANGES=$(grep -c "\.word" results/kernel2_vs_kernel1.dump.diff)
            if [ $CONST_ADDR_CHANGES -gt 0 ]; then
                echo "⚠️ WARNING: $CONST_ADDR_CHANGES memory address constants differ between binaries"
                echo "Sample of address constant changes:"
                grep -A1 -B1 "\.word" results/kernel2_vs_kernel1.dump.diff | head -6
                
                # Pattern detection for consistent address offsets
                # Extract the constant values
                grep "\.word" results/kernel2_vs_kernel1.dump.diff | 
                grep -o "0x[0-9a-fA-F]\+" > results/address_constants.txt
                
                # Use awk to check if constants follow a pattern (e.g., all shifted by same amount)
                if [ -f "results/address_constants.txt" ] && [ $(wc -l < results/address_constants.txt) -gt 4 ]; then
                    echo "Analyzing address constant patterns..."
                    
                    # If more than 50% of changes are 0x44 to 0x48 (or vice versa)
                    PATTERN_44_48=$(grep -c "0x00000044\|0x00000048" results/address_constants.txt)
                    if [ $PATTERN_44_48 -gt $((CONST_ADDR_CHANGES / 2)) ]; then
                        echo "⚠️ HIGH RISK: Consistent pattern of memory address changes (0x44 <-> 0x48)"
                        echo "This suggests memory layout changes that could affect security boundaries"
                        QEMU_RUN_RISK=$((QEMU_RUN_RISK + 20))
                    fi
                fi
                
                # Any address constant changes are high risk for security
                QEMU_RUN_RISK=$((QEMU_RUN_RISK + (CONST_ADDR_CHANGES * 2)))
            else 
                echo "✓ No memory address constant differences detected"
            fi
        fi
        
        # Analyze frequency of instruction types
        echo ""
        echo "Instruction type frequency comparison:"
        
        # Extract instruction types
        grep -o " [a-z]\+[\.][a-z0-9]\+ " results/kernel1.in_asm.log | sort | uniq -c | sort -rn > results/kernel1.instr_types.txt
        grep -o " [a-z]\+[\.][a-z0-9]\+ " results/kernel2.in_asm.log | sort | uniq -c | sort -rn > results/kernel2.instr_types.txt
        
        # Compare top instruction types
        echo "Top 10 instruction types in kernel1.img:"
        head -10 results/kernel1.instr_types.txt
        
        echo ""
        echo "Top 10 instruction types in kernel2.img:"
        head -10 results/kernel2.instr_types.txt
        
        # Analyze differences in instruction type distributions
        INSTR_TYPE_DIFF_COUNT=$(diff results/kernel1.instr_types.txt results/kernel2.instr_types.txt | grep -c "^<\|^>")
        if [ $INSTR_TYPE_DIFF_COUNT -gt 0 ]; then
            QEMU_RUN_RISK=$((QEMU_RUN_RISK + (INSTR_TYPE_DIFF_COUNT / 2)))
            echo "⚠️ WARNING: Instruction type distribution differs between binaries ($INSTR_TYPE_DIFF_COUNT differences)"
        fi
        
        # Look for specific high-risk instructions (system calls, privileged instructions)
        echo ""
        echo "Security-sensitive instruction analysis:"
        
        # Check for system calls in kernel2 that weren't in kernel1
        K1_SYSCALLS=$(grep -c "svc " results/kernel1.in_asm.log 2>/dev/null || echo "0")
        K2_SYSCALLS=$(grep -c "svc " results/kernel2.in_asm.log 2>/dev/null || echo "0")
        
        # Ensure variables are numeric before arithmetic
        K1_SYSCALLS=${K1_SYSCALLS//[^0-9]/}
        K2_SYSCALLS=${K2_SYSCALLS//[^0-9]/}
        
        # Set default values if empty
        K1_SYSCALLS=${K1_SYSCALLS:-0}
        K2_SYSCALLS=${K2_SYSCALLS:-0}
        
        SYSCALL_DIFF=$((K2_SYSCALLS - K1_SYSCALLS))
        
        echo "System calls (svc) in kernel1.img: $K1_SYSCALLS"
        echo "System calls (svc) in kernel2.img: $K2_SYSCALLS"
        echo "Difference: $SYSCALL_DIFF"
        
        # Any difference in system call count is highly suspicious
        if [ $SYSCALL_DIFF -ne 0 ]; then
            SYSCALL_DIFF_ABS=${SYSCALL_DIFF#-}  # Get absolute value
            QEMU_RUN_RISK=$((QEMU_RUN_RISK + (SYSCALL_DIFF_ABS * 5)))
            echo "⚠️ WARNING: System call count difference in binaries that should be logically identical"
        fi
        
        # Check for privileged instructions
        PRIV_INSTRS="mrs msr cps wfi mcr"
        PRIV_DIFF_TOTAL=0
        for instr in $PRIV_INSTRS; do
            K1_COUNT=$(grep -c " $instr " results/kernel1.in_asm.log 2>/dev/null || echo "0")
            K2_COUNT=$(grep -c " $instr " results/kernel2.in_asm.log 2>/dev/null || echo "0")
            
            # Ensure variables are numeric
            K1_COUNT=${K1_COUNT//[^0-9]/}
            K2_COUNT=${K2_COUNT//[^0-9]/}
            
            # Set default values if empty
            K1_COUNT=${K1_COUNT:-0}
            K2_COUNT=${K2_COUNT:-0}
            
            DIFF=$((K2_COUNT - K1_COUNT))
            
            if [ $DIFF -ne 0 ]; then
                echo "Privileged instruction '$instr': $K1_COUNT vs $K2_COUNT (diff: $DIFF)"
                
                # Calculate absolute value of DIFF
                if [ $DIFF -lt 0 ]; then
                    ABS_DIFF=$((0 - DIFF))
                else
                    ABS_DIFF=$DIFF
                fi
                
                PRIV_DIFF_TOTAL=$((PRIV_DIFF_TOTAL + ABS_DIFF))
                
                # Each privileged instruction difference is significant
                QEMU_RUN_RISK=$((QEMU_RUN_RISK + (ABS_DIFF * 3)))
            fi
        done
        
        if [ $PRIV_DIFF_TOTAL -gt 0 ]; then
            echo "⚠️ WARNING: Privileged instruction differences detected ($PRIV_DIFF_TOTAL total) in binaries that should be logically identical"
        fi
        
        # Look for memory manipulation instructions
        echo ""
        echo "Memory manipulation instruction changes:"
        MEM_INSTRS="str ldr push pop strb ldrb stm ldm"
        MEM_DIFF_TOTAL=0
        for instr in $MEM_INSTRS; do
            K1_COUNT=$(grep -c " $instr " results/kernel1.in_asm.log 2>/dev/null || echo "0")
            K2_COUNT=$(grep -c " $instr " results/kernel2.in_asm.log 2>/dev/null || echo "0")
            
            # Ensure variables are numeric
            K1_COUNT=${K1_COUNT//[^0-9]/}
            K2_COUNT=${K2_COUNT//[^0-9]/}
            
            # Set default values if empty
            K1_COUNT=${K1_COUNT:-0}
            K2_COUNT=${K2_COUNT:-0}
            
            DIFF=$((K2_COUNT - K1_COUNT))
            
            # Calculate absolute value of DIFF
            if [ $DIFF -lt 0 ]; then
                ABS_DIFF=$((0 - DIFF))
            else
                ABS_DIFF=$DIFF
            fi
            
            DIFF_PERCENT=0
            
            # Calculate percentage difference if K1_COUNT is not zero
            if [ "$K1_COUNT" -ne 0 ]; then
                DIFF_PERCENT=$((ABS_DIFF * 100 / K1_COUNT))
            else
                if [ "$K2_COUNT" -ne 0 ]; then
                    # If K1_COUNT is 0 but K2_COUNT isn't, that's a 100% difference
                    DIFF_PERCENT=100
                fi
            fi
            
            MEM_DIFF_TOTAL=$((MEM_DIFF_TOTAL + ABS_DIFF))
            
            # Only show significant changes (more than 5%)
            if [ $DIFF_PERCENT -gt 5 ] || [ $ABS_DIFF -gt 10 ]; then
                echo "$instr instructions: $K1_COUNT vs $K2_COUNT (diff: $DIFF, $DIFF_PERCENT%)"
                
                # Memory operation differences contribute to risk
                QEMU_RUN_RISK=$((QEMU_RUN_RISK + (DIFF_PERCENT / 10)))
            fi
        done
        
        if [ $MEM_DIFF_TOTAL -gt 20 ]; then
            echo "⚠️ WARNING: Significant memory operation differences ($MEM_DIFF_TOTAL total) in binaries that should be logically identical"
            QEMU_RUN_RISK=$((QEMU_RUN_RISK + (MEM_DIFF_TOTAL / 10)))
        fi
        
        # Memory layout changes detected from disassembly analysis
        if [ $CONST_ADDR_CHANGES -gt 0 ]; then
            echo ""
            echo "=== Memory Layout Change Analysis ==="
            echo "Memory layout changes detected: $CONST_ADDR_CHANGES constants"
            echo ""
            echo "⚠️ SECURITY IMPLICATIONS:"
            echo "1. Changes in memory offsets can affect buffer boundaries and sizes"
            echo "2. Different memory layout may introduce buffer overflow vulnerabilities"
            echo "3. Potential format string vulnerabilities if string handling uses different offsets"
            echo "4. Possible ASLR bypass if memory layout changes are predictable"
            echo ""
            echo "RECOMMENDATION: Manual review required to ensure memory safety"
            
            # Serious security risk due to memory layout changes
            if [ $QEMU_RUN_RISK -lt 15 ]; then
                QEMU_RUN_RISK=15
                echo "Memory layout changes have resulted in elevated risk assessment"
            fi
        fi
        
        # For binaries with identical logic, any differences should raise minimum risk level
        if [ $QEMU_RUN_RISK -eq 0 ] && ( [ $INSTR_DIFF -ne 0 ] || [ $NOVEL_PATHS -gt 0 ] || [ $REMOVED_PATHS -gt 0 ] ); then
            QEMU_RUN_RISK=5
            echo "⚠️ WARNING: Binary differences detected in code that should be logically identical. This suggests compiler optimizations or misconfigurations."
        fi
        
        # Compiler misconfiguration risk - if there are significant differences
        # in builds that should be identical, assign a minimum risk
        if [ $INSTR_DIFF -ne 0 ] || [ $NOVEL_PATHS -gt 0 ] || [ $REMOVED_PATHS -gt 0 ] || [ $CONST_ADDR_CHANGES -gt 0 ]; then
            if [ $QEMU_RUN_RISK -lt 10 ]; then
                QEMU_RUN_RISK=10
                echo "⚠️ WARNING: Potential compiler misconfiguration detected - execution differences in binaries that should be logically identical"
            fi
        fi
        
        # Add QEMU risk score to global SECURITY_RISK
        echo ""
        echo "QEMU execution trace risk score: $QEMU_RUN_RISK"
        
        # Export the QEMU_RUN_RISK to be used by other functions
        echo "QEMU_RUN_RISK=$QEMU_RUN_RISK" > results/qemu_run_risk.txt
        
        # Update global SECURITY_RISK
        SECURITY_RISK=$((SECURITY_RISK + QEMU_RUN_RISK))
        echo "Updated overall security risk score: $SECURITY_RISK"
        
        # Summary of findings for identical logic binaries
        if [ $QEMU_RUN_RISK -gt 0 ]; then
            echo ""
            echo "=== Compiler Configuration Risk Assessment ==="
            echo "For binaries that should have identical logic, runtime differences may indicate:"
            echo "1. Different compiler optimization levels (-O0 vs -O2, etc.)"
            echo "2. Different compiler flags affecting code generation"
            echo "3. Different compiler versions or toolchains"
            echo "4. Potential security implications from behavior differences"
            
            if [ $CONST_ADDR_CHANGES -gt 0 ]; then
                echo "5. CRITICAL: Memory layout changes that could affect security boundaries"
            fi
            
            echo ""
            echo "Risk level: $([ $QEMU_RUN_RISK -gt 15 ] && echo "HIGH" || ([ $QEMU_RUN_RISK -gt 5 ] && echo "MEDIUM" || echo "LOW"))"
        fi
        
    } > results/qemu_execution_analysis.txt
    
    echo "QEMU execution trace analysis completed: results/qemu_execution_analysis.txt"
    
    # Update the consolidated report to include QEMU analysis and QEMU_RUN_RISK
    if [ -f "results/consolidated_report.txt" ]; then
        {
            echo ""
            echo "== QEMU Execution Trace Analysis =="
            echo "Instructions executed: $INSTR_COUNT1 vs $INSTR_COUNT2 (diff: $INSTR_DIFF)"
            echo "Novel execution paths in kernel2.img: $NOVEL_PATHS"
            echo "Removed execution paths from kernel1.img: $REMOVED_PATHS"
            
            if [ $CONST_ADDR_CHANGES -gt 0 ]; then
                echo "⚠️ CRITICAL: $CONST_ADDR_CHANGES memory address constants changed between binaries"
                echo "   Memory layout changes significantly increase security risk"
            fi
            
            if [ $INSTR_DIFF -ne 0 ] || [ $NOVEL_PATHS -gt 0 ] || [ $REMOVED_PATHS -gt 0 ]; then
                echo "⚠️ WARNING: Execution differences detected in binaries that should be logically identical"
                echo "This may indicate compiler misconfigurations or optimization differences with security implications"
            fi
            
            echo "QEMU execution risk score: $QEMU_RUN_RISK (contributes directly to overall security risk)"
            
            # Include more details on what factors contributed to the QEMU risk score
            if [ $QEMU_RUN_RISK -gt 15 ]; then
                echo "⚠️ HIGH QEMU RISK: Runtime behavior shows potentially dangerous changes"
                if [ $CONST_ADDR_CHANGES -gt 0 ]; then
                    echo "   - Memory layout changes with significant security implications"
                fi
            elif [ $QEMU_RUN_RISK -gt 5 ]; then
                echo "⚠️ MEDIUM QEMU RISK: Runtime behavior shows notable changes requiring investigation"
            fi
            
            echo ""
            echo "- results/qemu_execution_analysis.txt - QEMU execution trace analysis"
        } >> results/consolidated_report.txt
    fi
}

function create_security_assessment {
    echo "Creating security assessment report..."
    
    # Reset security risk
    SECURITY_RISK=0
    
    # Import QEMU_RUN_RISK if available
    if [ -f "results/qemu_run_risk.txt" ]; then
        source results/qemu_run_risk.txt
    else
        QEMU_RUN_RISK=0
    fi
    
    {
        echo "=== Security Assessment Report ==="
        echo "This report analyzes potential security implications of the differences between kernel1.img and kernel2.img"
        echo ""
        
        # Check file sizes for significant differences
        SIZE1=$(wc -c < build/kernel1.img)
        SIZE2=$(wc -c < build/kernel2.img)
        SIZE_DIFF=$((SIZE2 - SIZE1))
        SIZE_DIFF_ABS=${SIZE_DIFF#-}  # Absolute value
        
        echo "Key security indicators:"
        
        if [ $SIZE_DIFF_ABS -gt 1024 ]; then
            echo "- ⚠️ WARNING: Significant binary size difference of $SIZE_DIFF bytes"
            echo "  Large size differences could indicate added functionality or code"
            SECURITY_RISK=$((SECURITY_RISK + (SIZE_DIFF_ABS / 1024)))
        else
            echo "- ✓ Binary size difference is minimal ($SIZE_DIFF bytes)"
        fi
        
        # Check for crypto-related strings
        CRYPTO_STRINGS1=$(strings build/kernel1.img | grep -i "crypt\|password\|key\|secret\|cipher\|hash" | wc -l)
        CRYPTO_STRINGS2=$(strings build/kernel2.img | grep -i "crypt\|password\|key\|secret\|cipher\|hash" | wc -l)
        CRYPTO_DIFF=$((CRYPTO_STRINGS2 - CRYPTO_STRINGS1))
        
        if [ $CRYPTO_DIFF -ne 0 ]; then
            echo "- ⚠️ NOTICE: Change in number of crypto-related strings: $CRYPTO_DIFF"
            SECURITY_RISK=$((SECURITY_RISK + (${CRYPTO_DIFF#-} * 2)))
            
            # Show some of the different strings
            echo "  Crypto strings in kernel2.img not in kernel1.img:"
            comm -13 <(strings build/kernel1.img | grep -i "crypt\|password\|key\|secret\|cipher\|hash" | sort) \
                   <(strings build/kernel2.img | grep -i "crypt\|password\|key\|secret\|cipher\|hash" | sort) | head -5
        else
            echo "- ✓ No change in number of crypto-related strings"
        fi
        
        # Look for potential backdoor indicators
        BACKDOOR_STRINGS=$(strings build/kernel2.img | grep -i "backdoor\|shell\|root\|admin\|sudo\|superuser\|telnet\|netcat\|nc -l\|remote\|connect back" | wc -l)
        if [ $BACKDOOR_STRINGS -gt 0 ]; then
            echo "- ⚠️ WARNING: Potential backdoor-related strings found: $BACKDOOR_STRINGS"
            strings build/kernel2.img | grep -i "backdoor\|shell\|root\|admin\|sudo\|superuser\|telnet\|netcat\|nc -l\|remote\|connect back" | head -5
            SECURITY_RISK=$((SECURITY_RISK + (BACKDOOR_STRINGS * 5)))
        else
            echo "- ✓ No obvious backdoor-related strings detected"
        fi
        
        # Look for URL or IP address patterns
        URL_STRINGS=$(strings build/kernel2.img | grep -E '(https?://|www\.|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | wc -l)
        if [ $URL_STRINGS -gt 0 ]; then
            echo "- ⚠️ NOTICE: URL or IP address patterns found: $URL_STRINGS"
            strings build/kernel2.img | grep -E '(https?://|www\.|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | head -5
            SECURITY_RISK=$((SECURITY_RISK + URL_STRINGS))
        else
            echo "- ✓ No URL or IP address patterns detected"
        fi
        
        # Check for entropy differences (indication of encryption/obfuscation)
        ENTROPY1=$(ent build/kernel1.img 2>/dev/null | grep "Entropy" | awk '{print $3}' || echo "N/A")
        ENTROPY2=$(ent build/kernel2.img 2>/dev/null | grep "Entropy" | awk '{print $3}' || echo "N/A")
        
        if [ "$ENTROPY1" != "N/A" ] && [ "$ENTROPY2" != "N/A" ]; then
            # Compare entropy values (this is somewhat complex with floating point in bash, so keeping it simple)
            echo "- Entropy comparison: kernel1.img: $ENTROPY1, kernel2.img: $ENTROPY2"
            
            # Crude comparison using string comparison
            if [ "$ENTROPY2" \> "$ENTROPY1" ]; then
                echo "  ⚠️ NOTICE: kernel2.img has higher entropy, possible encryption/obfuscation added"
                SECURITY_RISK=$((SECURITY_RISK + 5))
            elif [ "$ENTROPY1" \> "$ENTROPY2" ]; then
                echo "  ⚠️ NOTICE: kernel2.img has lower entropy, possible encryption/obfuscation removed"
                SECURITY_RISK=$((SECURITY_RISK + 5))
            else
                echo "  ✓ No significant entropy difference detected"
            fi
        else
            echo "- Entropy analysis not available (install 'ent' tool for this feature)"
        fi
        
        # Add QEMU runtime risk assessment into overall security risk
        if [ $QEMU_RUN_RISK -gt 0 ]; then
            echo "- QEMU runtime analysis risk score: $QEMU_RUN_RISK"
            if [ $QEMU_RUN_RISK -gt 15 ]; then
                echo "  ⚠️ HIGH RISK: Runtime behavior shows potentially dangerous changes"
            elif [ $QEMU_RUN_RISK -gt 5 ]; then
                echo "  ⚠️ MEDIUM RISK: Runtime behavior shows notable changes requiring investigation"
            else
                echo "  ✓ Low risk in runtime behavior"
            fi
            
            # Incorporate QEMU_RUN_RISK into overall SECURITY_RISK
            SECURITY_RISK=$((SECURITY_RISK + QEMU_RUN_RISK))
        fi
        
        # Calculate overall security risk score
        echo ""
        echo "Overall security risk assessment:"
        if [ $SECURITY_RISK -gt 20 ]; then
            echo "⚠️ HIGH RISK: Score $SECURITY_RISK/100"
            echo "Significant indicators of security-relevant changes"
            echo "Manual inspection strongly recommended"
        elif [ $SECURITY_RISK -gt 10 ]; then
            echo "⚠️ MEDIUM RISK: Score $SECURITY_RISK/100"
            echo "Notable indicators of potential security changes"
            echo "Further investigation recommended"
        else
            echo "✓ LOW RISK: Score $SECURITY_RISK/100"
            echo "Few or no security-relevant indicators detected"
        fi
        
        echo ""
        echo "Disclaimer: This is an automated assessment and cannot detect all"
        echo "security issues. Manual code review is always recommended for security-critical code."
    } > results/security_assessment.txt
}

function create_diff_analysis {
    # Determine which is the other test number
    if [ "$TEST_NUMBER" -eq 1 ]; then
        OTHER_TEST=2
    else
        OTHER_TEST=1
    fi
    
    echo "Creating diff between kernel$TEST_NUMBER.img and kernel$OTHER_TEST.img..."
    
    # Basic binary diffs
    if [ -f "results/kernel$TEST_NUMBER.dump" ] && [ -f "results/kernel$OTHER_TEST.dump" ]; then
        diff -u results/kernel$TEST_NUMBER.dump results/kernel$OTHER_TEST.dump > results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff
    fi
    
    # Binary comparison
    cmp build/kernel$TEST_NUMBER.img build/kernel$OTHER_TEST.img > results/kernel_binary_cmp.txt 2>&1
    
    # Create more detailed analysis
    if [ -f "results/kernel1.symbols.txt" ] && [ -f "results/kernel2.symbols.txt" ]; then
        create_symbol_section_diff
    fi
    
    # Create more detailed analysis
    if [ -f "results/kernel1.in_asm.log" ] && [ -f "results/kernel2.in_asm.log" ]; then
        create_in_asm_diff
    fi
    
    # Analyze assembly changes
    analyze_assembly_changes
    
    # Create security assessment
    create_security_assessment
    
    # Create summary reports
    create_summary_report
    
    # Print summary of diff files created
    echo "Diff files created:"
    if [ -f "results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff" ]; then
        echo " - results/kernel${TEST_NUMBER}_vs_kernel${OTHER_TEST}.dump.diff (disassembly diff)"
    fi
    echo " - results/kernel_binary_cmp.txt (binary comparison)"
    
    if [ -f "results/symbol_diff.txt" ]; then
        echo " - results/symbol_diff.txt (symbol table diff)"
        echo " - results/section_size_comparison.txt (section size comparison)"
    fi

    echo " - results/binary_difference_analysis.txt - Binary level differences"
    echo " - results/security_assessment.txt - Security implications"
    
    echo "Analysis complete. See results/consolidated_report.txt for the full summary."
}
function create_summary_report {
    echo "Creating summary of differences..."
    
    # Get basic binary stats
    SIZE1=$(wc -c < build/kernel1.img)
    SIZE2=$(wc -c < build/kernel2.img)
    
    # Count functions if available
    if [ -f "results/kernel1.dump" ]; then
        FUNCS1=$(grep -c "<.*>:" results/kernel1.dump 2>/dev/null || echo "N/A")
    else
        FUNCS1="N/A"
    fi
    
    if [ -f "results/kernel2.dump" ]; then
        FUNCS2=$(grep -c "<.*>:" results/kernel2.dump 2>/dev/null || echo "N/A")
    else
        FUNCS2="N/A"
    fi
    
    # Import QEMU_RUN_RISK if available
    if [ -f "results/qemu_run_risk.txt" ]; then
        source results/qemu_run_risk.txt
    else
        QEMU_RUN_RISK=0
    fi
    
    # Binary comparison with cmp
    echo "Performing binary comparison with cmp..."
    CMP_RESULT=$(cmp -l build/kernel1.img build/kernel2.img 2>&1 | head -5)
    
    # Output to build comparison summary file
    {
        echo "=== Binary Comparison Summary ==="
        echo "kernel1.img size: $SIZE1 bytes"
        echo "kernel2.img size: $SIZE2 bytes"
        echo "Size difference: $((SIZE2 - SIZE1)) bytes"
        echo ""
        
        if [ "$FUNCS1" != "N/A" ] && [ "$FUNCS2" != "N/A" ]; then
            echo "kernel1.img function count: $FUNCS1"
            echo "kernel2.img function count: $FUNCS2"
            echo "Function count difference: $((FUNCS2 - FUNCS1))"
            echo ""
        fi
        
        echo "=== Binary Comparison ==="
        echo "cmp result (first 5 differences):"
        echo "$CMP_RESULT"
        
        # Add symbol and section analysis information to the build summary
        if [ -f "results/symbol_analysis.txt" ] && [ -f "results/section_size_comparison.txt" ]; then
            echo ""
            echo "=== Symbol Analysis Summary ==="
            echo "Symbols added in kernel2.img: $(grep -A50 "Symbols present in kernel2.img but not in kernel1.img" results/symbol_analysis.txt | grep -v "^--" | grep -v "^$" | grep -v "None found" | wc -l)"
            echo "Symbols removed from kernel1.img: $(grep -A50 "Symbols present in kernel1.img but not in kernel2.img" results/symbol_analysis.txt | grep -v "^--" | grep -v "^$" | grep -v "None found" | wc -l)"
            
            # Extract the most significant section size changes
            echo ""
            echo "Most significant section size changes:"
            grep -A20 "Section |" results/section_size_comparison.txt | grep -v "^--" | \
            awk -F"|" '{if ($4 && $4 != " Difference" && ($4+0 > 100 || $4+0 < -100)) print $0}' | head -5
        fi
        
        # Add QEMU runtime risk assessment information
        if [ $QEMU_RUN_RISK -gt 0 ]; then
            echo ""
            echo "=== QEMU Runtime Analysis ==="
            echo "QEMU runtime risk score: $QEMU_RUN_RISK"
            if [ $QEMU_RUN_RISK -gt 15 ]; then
                echo "⚠️ HIGH RISK in runtime behavior"
            elif [ $QEMU_RUN_RISK -gt 5 ]; then
                echo "⚠️ MEDIUM RISK in runtime behavior"
            else
                echo "✓ Low risk in runtime behavior"
            fi
        fi

        # Add security assessment summary
        if [ -f "results/security_assessment.txt" ]; then
            echo ""
            echo "=== Security Assessment Summary ==="
            grep "Overall security risk assessment:" -A5 results/security_assessment.txt
        fi
    } > results/build_comparison.txt
    
    # Create consolidated analysis report
    {
        echo "=== Consolidated Analysis Report ==="
        echo "kernel1.img vs. kernel2.img Comparison"
        echo "Generated on: $(date)"
        echo ""
        
        echo "== Summary =="
        echo "Binary size: $SIZE1 vs $SIZE2 bytes (diff: $((SIZE2-SIZE1)) bytes)"
        
        if [ "$FUNCS1" != "N/A" ] && [ "$FUNCS2" != "N/A" ]; then
            echo "Functions: $FUNCS1 vs $FUNCS2 (diff: $((FUNCS2-FUNCS1)))"
        fi
        
        echo ""
        echo "== Binary Differences =="
        cmp build/kernel1.img build/kernel2.img > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "The binary files are identical."
        else
            echo "The binary files are different."
            diff_count=$(cmp -l build/kernel1.img build/kernel2.img 2>/dev/null | wc -l)
            echo "Number of byte differences: $diff_count"
        fi
        
        # Add QEMU runtime risk assessment
        if [ $QEMU_RUN_RISK -gt 0 ]; then
            echo ""
            echo "== QEMU Runtime Risk Assessment =="
            echo "QEMU runtime risk score: $QEMU_RUN_RISK/100"
            if [ $QEMU_RUN_RISK -gt 15 ]; then
                echo "⚠️ HIGH RISK: Runtime analysis indicates potentially dangerous behavior changes"
                echo "Key factors that contributed to this risk assessment:"
                if [ -f "results/qemu_execution_analysis.txt" ]; then
                    grep "⚠️ WARNING" results/qemu_execution_analysis.txt | head -3
                fi
            elif [ $QEMU_RUN_RISK -gt 5 ]; then
                echo "⚠️ MEDIUM RISK: Runtime analysis shows notable changes requiring investigation"
            else
                echo "✓ Low risk in runtime behavior changes"
            fi
        fi
        
        # Add security assessment
        if [ -f "results/security_assessment.txt" ]; then
            echo ""
            echo "== Security Assessment =="
            grep "Key security indicators:" -A15 results/security_assessment.txt | head -10
            echo "..."
            grep "Overall security risk assessment:" -A5 results/security_assessment.txt
        fi
        
        # Add symbol analysis if available
        if [ -f "results/symbol_analysis.txt" ]; then
            echo ""
            echo "== Symbol Changes =="
            grep -A5 "Symbols present in kernel2.img but not in kernel1.img:" results/symbol_analysis.txt | grep -v "None found" | head -10
            echo "..."
        fi
        
        echo ""
        echo "For detailed information, refer to the following reports:"
        echo "- results/build_comparison.txt - Overall build differences"
        echo "- results/binary_difference_analysis.txt - Binary-level differences"
        echo "- results/security_assessment.txt - Security implications"
        if [ -f "results/qemu_execution_analysis.txt" ]; then
            echo "- results/qemu_execution_analysis.txt - QEMU runtime behavior analysis"
        fi
        if [ -f "results/symbol_diff.txt" ]; then
            echo "- results/symbol_diff.txt - Symbol table differences"
        fi
    } > results/consolidated_report.txt
    
    echo "Summary created: results/build_comparison.txt"
    echo "Consolidated report: results/consolidated_report.txt"
}
# Main script execution starts here
# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--log)
            LOG_ENABLED=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
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

# Check required files and tools
check_requirements

# Create results directory if it doesn't exist
mkdir -p results

# Main execution flow
echo "=== Starting Analysis ==="
echo "Step 1: Analyzing kernel1.img..."
TEST_NUMBER=1
analyze_binary

echo "Step 2: Analyzing kernel2.img..."
TEST_NUMBER=2
analyze_binary

echo "Step 3: Creating comparison between kernel1.img and kernel2.img..."
create_diff_analysis

echo "=== Analysis completed ==="
echo "See results directory for analysis reports and comparisons."
echo "Done."