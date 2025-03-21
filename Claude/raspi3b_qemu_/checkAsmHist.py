#!/usr/bin/env python3
"""
Script to find the divergence point in the parse.constprop.0 function
between two kernel execution traces.
"""

import re
import sys
from collections import defaultdict

def parse_instruction(line):
    """Parse an instruction line from QEMU in_asm log."""
    match = re.match(r'(0x[0-9a-f]+):\s+([0-9a-f]+)\s+(.+)', line)
    if not match:
        return None
    
    addr, opcode, instr = match.groups()
    return {
        'addr': addr,
        'opcode': opcode,
        'instr': instr.strip(),
        'mnemonic': instr.strip().split()[0],
        'operands': ' '.join(instr.strip().split()[1:]) if len(instr.strip().split()) > 1 else ''
    }

def extract_function_trace(filename, function_name):
    """Extract execution trace for a specific function from the log file."""
    traces = []
    current_trace = []
    in_target_function = False
    
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            
            # Check for function context marker
            if line.startswith("IN: "):
                current_function = line[4:].strip()
                if current_function == function_name:
                    if not in_target_function:
                        # Start of a new execution of the target function
                        in_target_function = True
                        current_trace = []
                else:
                    if in_target_function:
                        # End of the target function execution
                        in_target_function = False
                        if current_trace:
                            traces.append(current_trace)
                continue
            
            # Skip separator lines
            if line == "----------------":
                continue
                
            # Parse instruction if we're in the target function
            if in_target_function:
                instr = parse_instruction(line)
                if instr:
                    current_trace.append(instr)
    
    # Add the last trace if we were still in the function
    if in_target_function and current_trace:
        traces.append(current_trace)
        
    return traces

def compare_execution_traces(trace1, trace2, max_common=20):
    """Compare two execution traces to find the divergence point."""
    min_len = min(len(trace1), len(trace2))
    
    # Find the first difference
    for i in range(min_len):
        if trace1[i]['addr'] != trace2[i]['addr']:
            # Found a divergence
            common_prefix = i
            
            # Print common code before divergence
            print(f"\nLast {min(common_prefix, max_common)} common instructions before divergence:")
            start_idx = max(0, common_prefix - max_common)
            for j in range(start_idx, common_prefix):
                print(f"  {trace1[j]['addr']}: {trace1[j]['instr']}")
            
            # Print the divergence point
            print("\nDIVERGENCE POINT:")
            print(f"  Kernel 1: {trace1[i]['addr']}: {trace1[i]['instr']}")
            print(f"  Kernel 2: {trace2[i]['addr']}: {trace2[i]['instr']}")
            
            # Print a few instructions after the divergence
            print("\nNext few instructions after divergence in Kernel 1:")
            for j in range(i+1, min(i+6, len(trace1))):
                print(f"  {trace1[j]['addr']}: {trace1[j]['instr']}")
                
            print("\nNext few instructions after divergence in Kernel 2:")
            for j in range(i+1, min(i+6, len(trace2))):
                print(f"  {trace2[j]['addr']}: {trace2[j]['instr']}")
                
            return i
    
    # If we get here, one trace is a prefix of the other
    if len(trace1) != len(trace2):
        print(f"\nOne trace is a prefix of the other. First {min_len} instructions match.")
        if len(trace1) > len(trace2):
            print(f"Kernel 1 continues with: {trace1[min_len]['addr']}: {trace1[min_len]['instr']}")
        else:
            print(f"Kernel 2 continues with: {trace2[min_len]['addr']}: {trace2[min_len]['instr']}")
        return min_len
    else:
        print("\nBoth traces are identical!")
        return -1

def find_conditional_logic_before_divergence(trace, div_idx, window=20):
    """Find conditional logic instructions before the divergence point."""
    conditionals = []
    
    start_idx = max(0, div_idx - window)
    for i in range(start_idx, div_idx):
        instr = trace[i]
        
        # Look for comparisons, tests, and conditional branches
        if instr['mnemonic'] in ['cmp', 'cmn', 'tst', 'teq'] or (
            instr['mnemonic'].startswith('b') and 
            instr['mnemonic'] not in ['b', 'bl', 'blx', 'bx']):
            
            conditionals.append({
                'addr': instr['addr'],
                'instr': instr['instr']
            })
    
    return conditionals

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <kernel1_log> <kernel2_log>")
        sys.exit(1)
    
    target_function = "parse.constprop.0"
    
    print(f"Extracting execution traces for function '{target_function}'...")
    traces1 = extract_function_trace(sys.argv[1], target_function)
    traces2 = extract_function_trace(sys.argv[2], target_function)
    
    print(f"Found {len(traces1)} executions in kernel 1")
    print(f"Found {len(traces2)} executions in kernel 2")
    
    if not traces1 or not traces2:
        print("Error: Could not find the target function in one or both logs")
        sys.exit(1)
    
    # Compare the first execution of the function in each kernel
    print("\nComparing the first execution of the function in each kernel:")
    div_idx = compare_execution_traces(traces1[0], traces2[0])
    
    if div_idx >= 0:
        print("\nAnalyzing conditional logic before the divergence point:")
        conditionals = find_conditional_logic_before_divergence(traces1[0], div_idx)
        
        if conditionals:
            print("Conditional instructions that may affect the branch decision:")
            for cond in conditionals:
                print(f"  {cond['addr']}: {cond['instr']}")
        else:
            print("No conditional logic found in the window before divergence")
    
if __name__ == "__main__":
    main()