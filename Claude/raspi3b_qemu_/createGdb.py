#!/usr/bin/env python3
"""
This script analyzes a diff file between two kernel traces and generates a GDB script
with appropriate breakpoints, labels, and register display commands to help debug
the key differences.
"""

import re
import sys
import os
from collections import defaultdict

def extract_addresses(diff_file):
    """
    Extract interesting addresses and their context from the diff file.
    """
    addresses = []
    interesting_contexts = defaultdict(list)
    current_addr = None
    addr_pattern = re.compile(r'0x([0-9a-fA-F]+)')
    
    with open(diff_file, 'r') as f:
        lines = f.readlines()
        
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Skip legend and separator lines
        if line.startswith('#') or line == '---' or line == '':
            i += 1
            continue
            
        # Check if line contains an address
        if '0x' in line:
            # Extract address
            match = addr_pattern.search(line)
            if match:
                current_addr = int(match.group(1), 16)
                
                # Check if it's a change line (< or >)
                if line.startswith('<') or line.startswith('>'):
                    prefix = 'orig' if line.startswith('<') else 'patch'
                    instruction = line[line.find('0x'):]
                    comment = f"# {prefix}: {instruction}"
                    
                    # Extract branch targets if present
                    branch_match = re.search(r'b\s+(0x[0-9a-fA-F]+)', line)
                    if branch_match:
                        branch_target = int(branch_match.group(1)[2:], 16)
                        addresses.append(branch_target)
                        interesting_contexts[branch_target].append(f"# Branch target from {hex(current_addr)}")
                    
                    addresses.append(current_addr)
                    interesting_contexts[current_addr].append(comment)
                    
                    # Look ahead to collect context (next few instructions)
                    context_count = 0
                    j = i + 1
                    while j < len(lines) and context_count < 3:
                        context_line = lines[j].strip()
                        if context_line.startswith('<') or context_line.startswith('>'):
                            if context_line.startswith('<' if line.startswith('<') else '>'):
                                context_match = addr_pattern.search(context_line)
                                if context_match:
                                    context_addr = int(context_match.group(1), 16)
                                    if context_addr != current_addr:  # Skip duplicates
                                        addresses.append(context_addr)
                                        context_instr = context_line[context_line.find('0x'):]
                                        interesting_contexts[context_addr].append(f"# {prefix} context: {context_instr}")
                                        context_count += 1
                        j += 1
                
                # Find the leading and trailing instructions for each function block
                if "IN: " in line:
                    function_name = line.split("IN: ")[1].strip()
                    interesting_contexts[current_addr].append(f"# Function: {function_name}")
        
        i += 1
        
    # Add extra entries for key addresses +/- a few instructions
    surrounding_range = 3  # Instructions before and after
    extended_addresses = set(addresses)
    
    for addr in addresses:
        for offset in range(-surrounding_range, surrounding_range + 1):
            extended_addresses.add(addr + (offset * 4))  # ARM instructions are 4 bytes
    
    return sorted(list(extended_addresses)), interesting_contexts

def generate_gdb_script(addresses, contexts, output_file, original_log, patched_log):
    """
    Generate a GDB script with breakpoints and register display commands.
    """
    with open(output_file, 'w') as f:
        # GDB script header
        f.write("# GDB script generated for kernel diff analysis\n")
        f.write("# Original log: " + original_log + "\n")
        f.write("# Patched log: " + patched_log + "\n\n")
        
        # Initial setup commands
        f.write("# Initial setup\n")
        f.write("set pagination off\n")
        f.write("set confirm off\n")
        f.write("set disassembly-flavor arm\n\n")
        
        # Add function to display all registers
        f.write("define show_all_regs\n")
        f.write("  printf \"\\n============= Register State =============\\n\"\n")
        f.write("  info registers\n")
        f.write("  printf \"\\n============ Stack Inspection ============\\n\"\n")
        f.write("  x/10wx $sp\n")
        f.write("  printf \"\\n=========================================\\n\"\n")
        f.write("end\n\n")
        
        # Add function to show context
        f.write("define show_context\n")
        f.write("  printf \"\\n============= Code Context ==============\\n\"\n")
        f.write("  x/10i $pc-16\n")
        f.write("  printf \"\\n=========================================\\n\"\n")
        f.write("end\n\n")
        
        # Set breakpoints
        f.write("# Set breakpoints at key addresses\n")
        for addr in addresses:
            # Add any context comments first
            if addr in contexts:
                for comment in contexts[addr]:
                    f.write(comment + "\n")
            
            # Add the breakpoint command
            f.write(f"break *0x{addr:08x}\n")
            f.write(f"commands\n")
            f.write("  printf \"Hit breakpoint at %#x\\n\", $pc\n")
            f.write("  show_all_regs\n")
            f.write("  show_context\n")
            f.write("end\n\n")
        
        # Add some key locations as symbols for easier reference
        f.write("# Key memory locations for tracing\n")
        key_addrs = {addr: f"key_addr_{i}" for i, addr in enumerate(sorted(contexts.keys()))}
        
        for addr, name in key_addrs.items():
            f.write(f"set $%s = 0x{addr:08x}\n" % name)
        
        f.write("\n# Define key branch targets\n")
        # Find branch instructions
        branch_targets = {}
        for addr in contexts:
            for comment in contexts[addr]:
                branch_match = re.search(r'b\s+(0x[0-9a-fA-F]+)', comment)
                if branch_match:
                    target = int(branch_match.group(1)[2:], 16)
                    branch_targets[addr] = target
        
        # Create variables for branch targets
        for source, target in branch_targets.items():
            f.write(f"set $branch_{source:08x}_target = 0x{target:08x}\n")
        
        # Add monitoring for memory regions of interest
        f.write("\n# Memory Watchpoints for critical regions\n")
        f.write("# Uncomment these to track specific memory accesses\n")
        f.write("# watch *(int*)0xXXXXXXXX  # Replace with memory address of interest\n")
        
        # Add final convenience commands
        f.write("\n# Convenience commands\n")
        f.write("define check_path\n")
        f.write("  printf \"Checking execution path...\\n\"\n")
        for source, target in branch_targets.items():
            f.write(f"  if $pc == 0x{source:08x}\n")
            f.write(f"    printf \"At branch instruction 0x{source:08x}, will branch to 0x{target:08x}\\n\"\n")
            f.write("  end\n")
        f.write("end\n\n")
        
        # Add program continuation command
        f.write("# Continue program execution\n")
        f.write("# Comment this out if you want to start in a stopped state\n")
        f.write("# continue\n")

def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <diff_file> <original_log> <patched_log>")
        sys.exit(1)
    
    diff_file = sys.argv[1]
    original_log = sys.argv[2]
    patched_log = sys.argv[3]
    output_file = "kernel_debug.gdb"
    
    if not os.path.exists(diff_file):
        print(f"Error: Diff file '{diff_file}' not found.")
        sys.exit(1)
        
    print(f"Analyzing diff file: {diff_file}")
    addresses, contexts = extract_addresses(diff_file)
    print(f"Found {len(addresses)} interesting addresses with {len(contexts)} contextual notes")
    
    generate_gdb_script(addresses, contexts, output_file, original_log, patched_log)
    print(f"GDB script generated: {output_file}")
    
    # Bonus: Generate a summary of changes
    summary_file = "kernel_diff_summary.txt"
    with open(summary_file, 'w') as f:
        f.write("KERNEL MODIFICATION SUMMARY\n")
        f.write("=========================\n\n")
        
        for addr in sorted(contexts.keys()):
            f.write(f"Address: 0x{addr:08x}\n")
            for comment in contexts[addr]:
                f.write(f"  {comment}\n")
            f.write("\n")
            
    print(f"Summary of changes generated: {summary_file}")

if __name__ == "__main__":
    main()

