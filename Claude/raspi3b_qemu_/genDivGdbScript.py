#!/usr/bin/env python3

import re
import sys
import os
import argparse
from collections import defaultdict

def parse_args():
    parser = argparse.ArgumentParser(description='Generate GDB divergence detection script from ASM diff logs')
    parser.add_argument('diff_file', help='Path to the assembly diff log file')
    parser.add_argument('-o', '--output', default='divergence_detector.gdb', help='Output GDB script filename')
    parser.add_argument('-t', '--target', default='localhost:1234', help='GDB target (default: localhost:1234)')
    parser.add_argument('-s', '--symbols', help='Path to symbol file (e.g., kernel1.img with debug symbols)')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose output')
    return parser.parse_args()

def parse_diff_file(diff_file):
    """Parse the diff file to extract addresses and function information."""
    breakpoints = []
    functions = defaultdict(list)
    current_function = "unknown"
    
    # Regular expressions for address and function matching
    addr_pattern = re.compile(r'0x([0-9a-fA-F]+):\s+([0-9a-fA-F]+)\s+(.*)')
    func_pattern = re.compile(r'IN:\s+([\w.]+)')
    
    with open(diff_file, 'r') as f:
        for line in f:
            # Check if this is a function header
            func_match = func_pattern.search(line)
            if func_match:
                current_function = func_match.group(1)
                continue
                
            # Check if this is an instruction
            addr_match = addr_pattern.search(line)
            if addr_match:
                addr = int(addr_match.group(1), 16)
                instr = addr_match.group(3).strip()
                
                # We're especially interested in branch instructions and memory operations
                if ('b ' in instr or 'bl ' in instr or 'beq ' in instr or 'bne ' in instr or 
                    'bls ' in instr or 'bcs ' in instr or 'bhi ' in instr or 
                    'str' in instr or 'ldr' in instr or 'cmp' in instr or 
                    'sub' in instr or 'eor' in instr):
                    
                    breakpoints.append((addr, instr, current_function))
                    functions[current_function].append((addr, instr))
    
    # Identify unique breakpoints
    unique_bps = list(set(breakpoints))
    return unique_bps, dict(functions)
def generate_gdb_script(breakpoints, functions, output_file, target, symbol_file=None):
    """Generate a GDB script with breakpoints and analysis functions."""
    with open(output_file, 'w') as f:
        # Script header
        f.write("# divergence_detector.gdb - Automatically generated from diff log\n")
        f.write("# Generated script for detecting divergence points\n\n")

        # Initial setup
        f.write("# Initial setup\n")
        f.write(f"target remote {target}\n\n")

        # Load symbols if available
        f.write("# Load symbols if available\n")
        if symbol_file:
            f.write("# Load symbols from provided symbol file\n")
            f.write("set confirm off\n")
            f.write("symbol-file\n")
            f.write(f"symbol-file {symbol_file}\n")
            f.write("set confirm on\n")
            f.write(f"printf \"Loaded debug symbols from {symbol_file}\\n\"\n\n")
        else:
            f.write("# No symbol file specified\n")
            f.write("printf \"Warning: No symbol file specified. Using raw addresses only.\\n\"\n")
            f.write("printf \"You can add symbols with 'symbol-file path/to/symbols.img'\\n\"\n\n")

        # Basic breakpoints
        f.write("# Basic breakpoints\n")
        f.write("break *_start\n")
        f.write("break *main\n\n")

        # History settings
        f.write("# History settings\n")
        f.write("set history save on\n")
        f.write("set history filename ~/.gdb_history\n")
        f.write("set history size 10000\n\n")

        # Breakpoints at detected divergence points
        f.write("# Breakpoints at detected divergence points\n")

        # Add breakpoints for all functions
        for func_name in functions:
            f.write(f"\n# Breakpoints for {func_name}\n")
            if func_name != "unknown" and symbol_file:
                f.write(f"break {func_name}\n")
            
            for addr, instr in functions[func_name]:
                f.write(f"break *0x{addr:x}\n")
                f.write(f"# {instr}\n")  # Comment on its own line

        # Add utility functions
        f.write("\n# Utility commands for divergence analysis\n")
        f.write("define examine_state\n")
        f.write("  printf \"Examining execution state at 0x%x:\\n\", $pc\n")
        f.write("  info registers\n")
        f.write("  x/10i $pc\n")
        f.write("  printf \"Memory around key registers:\\n\"\n")
        f.write("  x/64xb $r0\n")
        f.write("  printf \"Memory around r1:\\n\"\n")
        f.write("  x/64xb $r1\n")
        f.write("  printf \"Memory around r2:\\n\"\n")
        f.write("  x/64xb $r2\n")
        f.write("  printf \"Memory around r3:\\n\"\n")
        f.write("  x/64xb $r3\n")
        f.write("  if $r4 != 0\n")
        f.write("    printf \"Memory around r4:\\n\"\n")
        f.write("    x/64xb $r4\n")
        f.write("  end\n")
        f.write("  if $r5 != 0\n")
        f.write("    printf \"Memory around r5:\\n\"\n")
        f.write("    x/64xb $r5\n")
        f.write("  end\n")
        f.write("end\n\n")

        # Continue with other functions similarly...
        f.write("# Command to track register changes between breakpoints\n")
        f.write("define track_regs\n")
        f.write("  set $old_r0 = $r0\n")
        f.write("  set $old_r1 = $r1\n")
        f.write("  set $old_r2 = $r2\n")
        f.write("  set $old_r3 = $r3\n")
        f.write("  set $old_r4 = $r4\n")
        f.write("  set $old_r5 = $r5\n")
        f.write("  set $old_r6 = $r6\n")
        f.write("  set $old_r7 = $r7\n")
        f.write("  cont\n")
        f.write("  printf \"Register changes:\\n\"\n")
        f.write("  printf \"R0: 0x%x -> 0x%x\\n\", $old_r0, $r0\n")
        f.write("  printf \"R1: 0x%x -> 0x%x\\n\", $old_r1, $r1\n")
        f.write("  printf \"R2: 0x%x -> 0x%x\\n\", $old_r2, $r2\n")
        f.write("  printf \"R3: 0x%x -> 0x%x\\n\", $old_r3, $r3\n")
        f.write("  printf \"R4: 0x%x -> 0x%x\\n\", $old_r4, $r4\n")
        f.write("  printf \"R5: 0x%x -> 0x%x\\n\", $old_r5, $r5\n")
        f.write("  printf \"R6: 0x%x -> 0x%x\\n\", $old_r6, $r6\n")
        f.write("  printf \"R7: 0x%x -> 0x%x\\n\", $old_r7, $r7\n")
        f.write("end\n\n")

        # Fix for the shell script creation - using separate lines
        f.write("# Create a shell script to find differences between memory dumps\n")
        f.write("shell echo '#!/bin/bash' > find_difference.sh\n")
        f.write("shell echo 'if [ $# -ne 2 ]; then' >> find_difference.sh\n")
        f.write("shell echo '  echo \"Usage: $0 file1 file2\"' >> find_difference.sh\n")
        f.write("shell echo '  exit 1' >> find_difference.sh\n")
        f.write("shell echo 'fi' >> find_difference.sh\n")
        f.write("shell echo 'cmp -l \"$1\" \"$2\" | awk \\''{printf \"Byte %d: %02x vs %02x\\\\n\", $1, strtonum(\"0\"$2), strtonum(\"0\"$3)}\\'' >> find_difference.sh\n")
        f.write("shell chmod +x find_difference.sh\n\n")

        # Print help information
        f.write("# Print help information\n")
        f.write("printf \"Divergence detection script loaded.\\n\"\n")
        f.write("printf \"Commands available:\\n\"\n")
        f.write("printf \"  find_divergence - Start tracking at breakpoints\\n\"\n")
        f.write("printf \"  examine_state - Display current execution state\\n\"\n")
        f.write("printf \"  track_regs - Continue execution and track register changes\\n\"\n")
        f.write("printf \"  capture_state <run_id> <addr_label> - Capture full state\\n\"\n")
        f.write("printf \"  watch_region <addr> <size> - Set watchpoints on memory region\\n\"\n")
        f.write("printf \"  compare_memory - Save memory region for later comparison\\n\"\n\n")

        f.write("continue\n")

        print(f"GDB script generated: {output_file}")
def main():
    args = parse_args()
    
    if not os.path.exists(args.diff_file):
        print(f"Error: Could not find diff file '{args.diff_file}'")
        return 1
    
    print(f"Parsing diff file: {args.diff_file}")
    breakpoints, functions = parse_diff_file(args.diff_file)
    
    if args.verbose:
        print(f"Found {len(breakpoints)} potential breakpoints in {len(functions)} functions")
        for func, addrs in functions.items():
            print(f"  Function {func}: {len(addrs)} points of interest")
    
    generate_gdb_script(breakpoints, functions, args.output, args.target, args.symbols)
    print(f"GDB script generated successfully: {args.output}")
    print(f"Use it with: gdb -x {args.output}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())