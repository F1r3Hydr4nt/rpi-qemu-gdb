#!/usr/bin/env python3
# Fix for Python 3.7.9 compatibility
"""
Kernel Constprop Optimization Patcher

This script analyzes QEMU assembly logs to identify compiler optimizations 
that alter execution flow due to constant propagation, then proposes and 
applies patches to the kernel binary to restore proper execution paths.

Usage:
    python kernel_patcher.py --diff <qemu_asm_diff.log> --kernel <kernel_binary> --output <patched_kernel>

Requirements:
    - Python 3.6+
    - ghidra_bridge (pip install ghidra_bridge)
    - elftools (pip install pyelftools) 
"""

import argparse
import os
import re
import tempfile
import logging
import shutil
import subprocess
from typing import Dict, List, Tuple, Set, Optional
from ghidra_bridge import GhidraBridge
from elftools.elf.elffile import ELFFile

# Configure logging
logging.basicConfig(level=logging.INFO, 
                    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class GhidraAnalyzer:
    """Interface with Ghidra for analyzing and patching the kernel binary."""
    
    def __init__(self, kernel_path: str):
        self.kernel_path = kernel_path
        self.bridge = None
        self.program = None
        self.project = None
        self.project_dir = None
        
    def initialize(self):
        """Initialize Ghidra and load the kernel binary."""
        try:
            logger.info("Starting Ghidra and loading kernel binary...")
            
            # Initialize the bridge
            self.bridge = GhidraBridge(connect_to_port=None, response_timeout=300)  # Longer timeout for large binaries
            
            # Import Ghidra modules via bridge
            gh_app = self.bridge.remote_import("ghidra.framework.Application")
            gh_script = self.bridge.remote_import("ghidra.app.script.GhidraScript")
            gh_headless = self.bridge.remote_import("ghidra.app.util.headless.HeadlessAnalyzer")
            
            # Version check to ensure compatibility
            version = self.bridge.remote_eval("ghidra.framework.Application.getApplicationVersion()")
            logger.info(f"Connected to Ghidra version: {version}")
            
            # Create project directory
            self.project_dir = tempfile.mkdtemp()
            logger.info(f"Created temporary project directory: {self.project_dir}")
            
            # Connect to project manager
            try:
                project_manager = self.bridge.remote_eval(
                    "ghidra.framework.project.ProjectManager.getInstance()"
                )
            except Exception:
                # Fallback for older Ghidra versions
                project_manager = self.bridge.remote_eval(
                    "ghidra.app.ProjectAnalysisContext.getProjectManager()"
                )
            
            # Create project
            self.project = project_manager.createProject(
                self.project_dir, "KernelAnalysis", True
            )
            
            if not self.project:
                logger.error("Failed to create Ghidra project")
                return False
                
            logger.info("Created Ghidra project")
            
            # Import kernel binary
            program_manager = self.project.getProjectData().getProjectManager()
            
            import_options = self.bridge.remote_eval(
                "ghidra.app.util.opinion.ImportOptions()"
            )
            
            logger.info(f"Importing kernel binary: {self.kernel_path}")
            file_to_import = self.bridge.remote_eval(
                f"java.io.File(\"{self.kernel_path}\")"
            )
            
            self.program = program_manager.importFile(file_to_import, import_options)
            
            if not self.program:
                logger.error("Failed to import kernel binary")
                return False
                
            logger.info("Kernel binary imported, starting analysis...")
            
            # Start analysis
            analyzer = self.bridge.remote_eval(
                f"ghidra.app.cmd.analysis.AutoAnalysisCommand(program, None, true)"
            )
            
            # Get a tool reference for running the analyzer
            tool = self.bridge.remote_eval(
                "ghidra.app.plugin.core.analysis.AutoAnalysisManager.getAnalysisTool(program)"
            )
            
            # Run the analysis
            tool.execute(analyzer, self.program)
            
            logger.info("Kernel binary loaded and analyzed in Ghidra")
            return True
        except Exception as e:
            logger.error(f"Failed to initialize Ghidra: {e}")
            import traceback
            logger.error(traceback.format_exc())
            self.close()  # Clean up resources
            return False
            
    def find_function_containing_address(self, address: int) -> Optional[str]:
        """Find the function containing the given address."""
        try:
            address_space = self.program.getAddressSpace()
            addr = address_space.getAddress(hex(address))
            
            function_manager = self.program.getFunctionManager()
            function = function_manager.getFunctionContaining(addr)
            
            if function:
                return function.getName()
            return None
        except Exception as e:
            logger.error(f"Error finding function at address {hex(address)}: {e}")
            return None
            
    def get_decompiled_function(self, function_name: str) -> str:
        """Get the decompiled C code for a function."""
        try:
            decompiler = self.bridge.remote_import("ghidra.app.decompiler")
            decompiler_api = decompiler.DecompInterface()
            decompiler_api.openProgram(self.program)
            
            function_manager = self.program.getFunctionManager()
            function = function_manager.getFunctionByName(function_name)
            
            if not function:
                logger.error(f"Function {function_name} not found")
                return ""
                
            result = decompiler_api.decompileFunction(function, 30, None)
            if result.decompileCompleted():
                return result.getDecompiledFunction().getC()
            else:
                logger.error(f"Failed to decompile {function_name}")
                return ""
        except Exception as e:
            logger.error(f"Error decompiling function {function_name}: {e}")
            return ""
            
    def analyze_execution_paths(self, address: int) -> Dict:
        """Analyze possible execution paths from the given address."""
        try:
            address_space = self.program.getAddressSpace()
            addr = address_space.getAddress(hex(address))
            
            # Get basic blocks
            listing = self.program.getListing()
            code_unit = listing.getCodeUnitContaining(addr)
            if not code_unit:
                return {}
                
            function_manager = self.program.getFunctionManager()
            function = function_manager.getFunctionContaining(addr)
            
            if not function:
                return {}
                
            # Get flow graph
            model = self.bridge.remote_eval(
                "ghidra.program.model.block.BasicBlockModel(program)"
            )
            flow_graph = model.getCodeBlocksContaining(function.getBody(), None)
            
            # Analyze paths
            paths = {}
            while flow_graph.hasNext():
                block = flow_graph.next()
                start_addr = block.getFirstStartAddress().getOffset()
                end_addr = block.getMaxAddress().getOffset()
                
                # Get destinations
                dests = []
                destinations = block.getDestinations(None)
                while destinations.hasNext():
                    ref = destinations.next()
                    dest_addr = ref.getDestinationAddress().getOffset()
                    dests.append(dest_addr)
                    
                paths[start_addr] = {
                    "end": end_addr,
                    "destinations": dests
                }
                
            return paths
        except Exception as e:
            logger.error(f"Error analyzing execution paths at {hex(address)}: {e}")
            return {}
            
    def identify_constprop_optimizations(self, function_name: str) -> List[Dict]:
        """Identify possible constant propagation optimizations in the function."""
        # Get decompiled code
        decompiled_code = self.get_decompiled_function(function_name)
        if not decompiled_code:
            return []
            
        optimizations = []
        
        # Look for hardcoded conditionals - common constprop pattern
        hardcoded_patterns = [
            r'if \(true\)',
            r'if \(false\)',
            r'if \(0x[0-9a-f]+ != 0\)',
            r'if \(0x[0-9a-f]+ == 0\)'
        ]
        
        for pattern in hardcoded_patterns:
            matches = re.finditer(pattern, decompiled_code)
            for match in matches:
                line_num = decompiled_code[:match.start()].count('\n') + 1
                optimizations.append({
                    "function": function_name,
                    "type": "hardcoded_conditional",
                    "line": line_num,
                    "pattern": match.group(),
                    "decompiled_snippet": self._get_code_snippet(decompiled_code, match.start())
                })
                
        # Look for missing variable checks
        var_assignments = re.finditer(r'(\w+) = ([^;]+);', decompiled_code)
        for match in var_assignments:
            var_name = match.group(1)
            # Check if variable is used in conditions
            if re.search(fr'if \({var_name}\)', decompiled_code) is None and \
               re.search(fr'if \({var_name} [!=<>]', decompiled_code) is None and \
               re.search(fr'if \([^)]*{var_name}[!=<>]', decompiled_code) is None:
                # Variable assigned but not used in conditions - potential optimization
                line_num = decompiled_code[:match.start()].count('\n') + 1
                optimizations.append({
                    "function": function_name,
                    "type": "unused_variable_in_condition",
                    "line": line_num,
                    "variable": var_name,
                    "decompiled_snippet": self._get_code_snippet(decompiled_code, match.start())
                })
                
        return optimizations
        
    def _get_code_snippet(self, code: str, pos: int, context_lines: int = 5) -> str:
        """Extract a code snippet with context around a position."""
        lines = code.splitlines()
        line_num = code[:pos].count('\n')
        
        start_line = max(0, line_num - context_lines)
        end_line = min(len(lines), line_num + context_lines + 1)
        
        return '\n'.join(lines[start_line:end_line])
        
    def generate_patch(self, optimization: Dict) -> Dict:
        """Generate a patch for the identified optimization."""
        patch_info = {
            "function": optimization["function"],
            "type": optimization["type"],
            "patch_strategy": "",
            "patch_code": "",
            "addresses": []
        }
        
        if optimization["type"] == "hardcoded_conditional":
            # Generate patch for hardcoded conditional
            patch_info["patch_strategy"] = "volatile_barrier"
            
            # Example patch code for hardcoded conditionals
            if "true" in optimization["pattern"] or "!= 0" in optimization["pattern"]:
                patch_info["patch_code"] = (
                    "// Original (optimized): " + optimization["pattern"] + "\n"
                    "volatile int guard_value = 1; // Force runtime evaluation\n"
                    "if (guard_value != 0) {\n"
                    "    // Original true branch code\n"
                    "}"
                )
            elif "false" in optimization["pattern"] or "== 0" in optimization["pattern"]:
                patch_info["patch_code"] = (
                    "// Original (optimized): " + optimization["pattern"] + "\n"
                    "volatile int guard_value = 0; // Force runtime evaluation\n"
                    "if (guard_value != 0) {\n"
                    "    // Original true branch code that was optimized away\n"
                    "}"
                )
                
        elif optimization["type"] == "unused_variable_in_condition":
            # Generate patch for unused variable
            patch_info["patch_strategy"] = "volatile_variable"
            patch_info["patch_code"] = (
                "// Original: " + optimization["variable"] + " is assigned but not used in conditions\n"
                "volatile " + optimization["variable"] + "; // Make variable volatile to prevent optimization\n"
                "// Add condition based on variable:\n"
                "if (" + optimization["variable"] + " != expected_value) {\n"
                "    // Alternative execution path\n"
                "}"
            )
            
        # Find addresses to patch
        # This would need to be expanded with actual binary patching logic
        # For now, just a placeholder
        patch_info["addresses"] = self._find_addresses_to_patch(optimization)
        
        return patch_info
        
    def _find_addresses_to_patch(self, optimization: Dict) -> List[int]:
        """Find the actual binary addresses that need patching."""
        # This is a simplified placeholder
        # In a real implementation, you would need to map the decompiled code
        # back to the binary and identify the exact instructions to patch
        
        # For demonstration, return an empty list
        return []
        
    def apply_patch(self, patch_info: Dict, output_kernel: str) -> bool:
        """Apply a patch to the kernel binary and save as a new file."""
        try:
            # Copy the original kernel to the output path
            shutil.copy(self.kernel_path, output_kernel)
            
            # For each address to patch
            for address in patch_info["addresses"]:
                # Apply the specific patch
                # This would need to be expanded with actual binary patching logic
                pass
                
            logger.info(f"Patch applied and saved to {output_kernel}")
            return True
        except Exception as e:
            logger.error(f"Failed to apply patch: {e}")
            return False
            
    def close(self):
        """Close Ghidra and clean up resources."""
        try:
            # Release program if it exists
            if self.program:
                try:
                    self.bridge.remote_eval("program.release(ghidra.util.task.TaskMonitor.DUMMY)")
                    logger.info("Released Ghidra program")
                except Exception as e:
                    logger.warning(f"Error releasing program: {e}")
            
            # Close project if it exists
            if self.project:
                try:
                    self.project.close()
                    logger.info("Closed Ghidra project")
                except Exception as e:
                    logger.warning(f"Error closing project: {e}")
            
            # Shutdown bridge if it exists
            if self.bridge:
                try:
                    self.bridge.shutdown()
                    logger.info("Shutdown Ghidra bridge")
                except Exception as e:
                    logger.warning(f"Error shutting down bridge: {e}")
            
            # Remove temporary project directory if it exists
            if self.project_dir and os.path.exists(self.project_dir):
                try:
                    shutil.rmtree(self.project_dir)
                    logger.info(f"Removed temporary project directory: {self.project_dir}")
                except Exception as e:
                    logger.warning(f"Error removing project directory: {e}")
        except Exception as e:
            logger.error(f"Error during Ghidra cleanup: {e}")
            import traceback
            logger.error(traceback.format_exc())

class QemuLogAnalyzer:
    """Analyze QEMU assembly log diff files to identify problematic execution paths."""
    
    def __init__(self, diff_path: str):
        self.diff_path = diff_path
        
    def parse_diff(self) -> List[Dict]:
        """Parse the QEMU assembly log diff file."""
        divergences = []
        
        try:
            with open(self.diff_path, 'r') as f:
                diff_content = f.readlines()
            
            logger.info(f"Read {len(diff_content)} lines from diff file")
            
            # For standard Unix diff format
            current_function = None
            removed_instructions = []
            added_instructions = []
            
            i = 0
            while i < len(diff_content):
                line = diff_content[i].strip()
                
                # Skip empty lines
                if not line:
                    i += 1
                    continue
                
                # Check for function markers
                if line.startswith("IN: "):
                    current_function = line[4:].strip()
                    logger.debug(f"Found function: {current_function}")
                    i += 1
                    continue
                
                # Check for separator
                if line.startswith("----------------"):
                    i += 1
                    continue
                
                # Check for diff line number indicators (like "2395,2406d2394")
                if re.match(r'^[0-9]+,[0-9]+[adc][0-9]+', line) or re.match(r'^[0-9]+[adc][0-9]+', line):
                    i += 1
                    continue
                
                # Check for diff markers (< for removed, > for added)
                if line.startswith("<"):
                    # This is a removed instruction
                    instruction_line = line[2:].strip()
                    addr_match = re.match(r'0x([0-9a-f]+):\s+([0-9a-f]+)\s+(\w+)\s+(.*)', instruction_line)
                    if addr_match:
                        addr = int(addr_match.group(1), 16)
                        instr_hex = addr_match.group(2)
                        instr_name = addr_match.group(3)
                        instr_args = addr_match.group(4)
                        
                        removed_instructions.append({
                            "address": addr,
                            "hex": instr_hex,
                            "mnemonic": instr_name,
                            "args": instr_args,
                            "raw": instruction_line
                        })
                    i += 1
                    continue
                
                if line.startswith(">"):
                    # This is an added instruction
                    instruction_line = line[2:].strip()
                    addr_match = re.match(r'0x([0-9a-f]+):\s+([0-9a-f]+)\s+(\w+)\s+(.*)', instruction_line)
                    if addr_match:
                        addr = int(addr_match.group(1), 16)
                        instr_hex = addr_match.group(2)
                        instr_name = addr_match.group(3)
                        instr_args = addr_match.group(4)
                        
                        added_instructions.append({
                            "address": addr,
                            "hex": instr_hex,
                            "mnemonic": instr_name,
                            "args": instr_args,
                            "raw": instruction_line
                        })
                    i += 1
                    continue
                
                # Check for plain instruction lines (not prefixed with < or >)
                addr_match = re.match(r'0x([0-9a-f]+):\s+([0-9a-f]+)\s+(\w+)\s+(.*)', line)
                if addr_match:
                    addr = int(addr_match.group(1), 16)
                    instr_hex = addr_match.group(2)
                    instr_name = addr_match.group(3)
                    instr_args = addr_match.group(4)
                    
                    # Determine if it's added or removed based on context
                    # This is for regular diff format without < or > markers
                    # Instruction lines are typically part of a block that starts with < or >
                    # If we can't determine, we'll add it to both for safety
                    i += 1
                    continue
                
                # Check for diff separator ("---")
                if line.startswith("---"):
                    # If we have accumulated instructions, record the divergence
                    if current_function and (removed_instructions or added_instructions):
                        addr = None
                        if removed_instructions:
                            addr = removed_instructions[0]["address"]
                        elif added_instructions:
                            addr = added_instructions[0]["address"]
                            
                        if addr:
                            divergences.append({
                                "address": addr,
                                "function": current_function,
                                "expected_path": {"instructions": removed_instructions.copy()},
                                "actual_path": {"instructions": added_instructions.copy()}
                            })
                            logger.debug(f"Recorded divergence in {current_function} at 0x{addr:x}")
                            
                        # Reset for next divergence
                        removed_instructions = []
                        added_instructions = []
                    
                    i += 1
                    continue
                
                # If we get here, the line doesn't match any expected format
                logger.debug(f"Unrecognized line format: {line}")
                i += 1
            
            # Process any remaining divergence at the end of the file
            if current_function and (removed_instructions or added_instructions):
                addr = None
                if removed_instructions:
                    addr = removed_instructions[0]["address"]
                elif added_instructions:
                    addr = added_instructions[0]["address"]
                    
                if addr:
                    divergences.append({
                        "address": addr,
                        "function": current_function,
                        "expected_path": {"instructions": removed_instructions},
                        "actual_path": {"instructions": added_instructions}
                    })
            
            # Now try to directly parse non-traditional diff format by looking for patterns
            if not divergences:
                logger.info("No divergences found in standard diff format, trying alternative parsing...")
                
                # Look for sequences of instruction blocks separated by function markers
                current_function = None
                current_block = []
                function_blocks = {}  # Map of function name to list of instruction blocks
                
                for line in diff_content:
                    line = line.strip()
                    if not line:
                        continue
                        
                    # Check for function context
                    if line.startswith("IN: "):
                        # If we've been collecting instructions, save them
                        if current_function and current_block:
                            if current_function not in function_blocks:
                                function_blocks[current_function] = []
                            function_blocks[current_function].append(current_block)
                            current_block = []
                            
                        current_function = line[4:].strip()
                        continue
                        
                    # Check for separators
                    if line.startswith("----------------"):
                        # End of a block
                        if current_function and current_block:
                            if current_function not in function_blocks:
                                function_blocks[current_function] = []
                            function_blocks[current_function].append(current_block)
                            current_block = []
                        continue
                        
                    # Skip diff line markers
                    if re.match(r'^[0-9]+,[0-9]+[adc][0-9]+', line) or re.match(r'^[0-9]+[adc][0-9]+', line) or line.startswith("<") or line.startswith(">") or line.startswith("---"):
                        continue
                        
                    # Check for instruction lines
                    addr_match = re.match(r'0x([0-9a-f]+):\s+([0-9a-f]+)\s+(\w+)\s+(.*)', line)
                    if addr_match and current_function:
                        addr = int(addr_match.group(1), 16)
                        instr_hex = addr_match.group(2)
                        instr_name = addr_match.group(3)
                        instr_args = addr_match.group(4)
                        
                        current_block.append({
                            "address": addr,
                            "hex": instr_hex,
                            "mnemonic": instr_name,
                            "args": instr_args,
                            "raw": line
                        })
                
                # Add any final block
                if current_function and current_block:
                    if current_function not in function_blocks:
                        function_blocks[current_function] = []
                    function_blocks[current_function].append(current_block)
                
                # Now create divergences based on function blocks
                for function_name, blocks in function_blocks.items():
                    if len(blocks) >= 2:  # Need at least 2 blocks to have a divergence
                        # Assuming first block is expected and others are changes
                        removed_instrs = blocks[0]
                        added_instrs = []
                        for i in range(1, len(blocks)):
                            added_instrs.extend(blocks[i])
                            
                        if removed_instrs:
                            addr = removed_instrs[0]["address"]
                            divergences.append({
                                "address": addr,
                                "function": function_name,
                                "expected_path": {"instructions": removed_instrs},
                                "actual_path": {"instructions": added_instrs}
                            })
                            logger.debug(f"Found divergence in function {function_name} at 0x{addr:x}")
            
            # If we still have no divergences, try one more approach by looking at the diff changes directly
            if not divergences:
                logger.info("Still no divergences found, attempting final parsing approach...")
                
                removed_sections = []
                added_sections = []
                current_section = None
                
                # First pass: identify removed and added sections
                for line in diff_content:
                    line = line.strip()
                    if not line:
                        continue
                        
                    # Check for diff markers
                    if re.match(r'^[0-9]+,[0-9]+d[0-9]+', line):
                        # This indicates lines that were removed
                        current_section = {"type": "removed", "lines": []}
                        removed_sections.append(current_section)
                        continue
                        
                    if re.match(r'^[0-9]+a[0-9]+,[0-9]+', line) or re.match(r'^[0-9]+a[0-9]+', line):
                        # This indicates lines that were added
                        current_section = {"type": "added", "lines": []}
                        added_sections.append(current_section)
                        continue
                        
                    if re.match(r'^[0-9]+c[0-9]+', line):
                        # This indicates lines that were changed
                        continue
                        
                    # Check for actual content
                    if line.startswith("<") and current_section and current_section["type"] == "removed":
                        current_section["lines"].append(line[2:].strip())
                    elif line.startswith(">") and current_section and current_section["type"] == "added":
                        current_section["lines"].append(line[2:].strip())
                
                # Second pass: organize by function
                for section_type, sections in [("removed", removed_sections), ("added", added_sections)]:
                    for section in sections:
                        function_instructions = {}
                        current_function = None
                        
                        for line in section["lines"]:
                            if line.startswith("IN: "):
                                current_function = line[4:].strip()
                                if current_function not in function_instructions:
                                    function_instructions[current_function] = []
                                continue
                                
                            if line.startswith("----------------"):
                                continue
                                
                            addr_match = re.match(r'0x([0-9a-f]+):\s+([0-9a-f]+)\s+(\w+)\s+(.*)', line)
                            if addr_match and current_function:
                                addr = int(addr_match.group(1), 16)
                                instr_hex = addr_match.group(2)
                                instr_name = addr_match.group(3)
                                instr_args = addr_match.group(4)
                                
                                function_instructions[current_function].append({
                                    "address": addr,
                                    "hex": instr_hex,
                                    "mnemonic": instr_name,
                                    "args": instr_args,
                                    "raw": line
                                })
                        
                        # Create divergences from the function instructions
                        for function_name, instructions in function_instructions.items():
                            if instructions:
                                addr = instructions[0]["address"]
                                
                                found = False
                                # Try to find and update an existing divergence
                                for div in divergences:
                                    if div["function"] == function_name:
                                        found = True
                                        if section_type == "removed":
                                            div["expected_path"]["instructions"].extend(instructions)
                                        else:
                                            div["actual_path"]["instructions"].extend(instructions)
                                        break
                                        
                                # If not found, create a new divergence
                                if not found:
                                    if section_type == "removed":
                                        divergences.append({
                                            "address": addr,
                                            "function": function_name,
                                            "expected_path": {"instructions": instructions},
                                            "actual_path": {"instructions": []}
                                        })
                                    else:
                                        divergences.append({
                                            "address": addr,
                                            "function": function_name,
                                            "expected_path": {"instructions": []},
                                            "actual_path": {"instructions": instructions}
                                        })
            
            # Final organization: Group by function and create clean divergences
            if divergences:
                # Group by function
                function_divergences = {}
                for div in divergences:
                    function = div["function"]
                    if function not in function_divergences:
                        function_divergences[function] = {
                            "expected_instructions": [],
                            "actual_instructions": []
                        }
                    
                    function_divergences[function]["expected_instructions"].extend(
                        div["expected_path"]["instructions"]
                    )
                    function_divergences[function]["actual_instructions"].extend(
                        div["actual_path"]["instructions"]
                    )
                
                # Create final divergences
                final_divergences = []
                for function, instr_sets in function_divergences.items():
                    if instr_sets["expected_instructions"] or instr_sets["actual_instructions"]:
                        # Find a representative address
                        addr = None
                        if instr_sets["expected_instructions"]:
                            addr = instr_sets["expected_instructions"][0]["address"]
                        elif instr_sets["actual_instructions"]:
                            addr = instr_sets["actual_instructions"][0]["address"]
                        
                        if addr:
                            final_divergences.append({
                                "address": addr,
                                "function": function,
                                "expected_path": {"instructions": instr_sets["expected_instructions"]},
                                "actual_path": {"instructions": instr_sets["actual_instructions"]}
                            })
                
                divergences = final_divergences
            
            logger.info(f"Found {len(divergences)} execution path divergences")
            return divergences
            
        except Exception as e:
            logger.error(f"Error parsing diff file: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return []

    def _find_divergence_point(self, diff_section: str) -> Optional[Dict]:
        """Find the point where execution paths diverge in a diff section."""
        # Look for lines with '+' and '-' prefixes which indicate divergence
        lines = diff_section.splitlines()
        
        expected_lines = []
        actual_lines = []
        context_lines = []
        
        in_divergence = False
        
        for line in lines:
            if line.startswith('-') and not line.startswith('---'):
                in_divergence = True
                expected_lines.append(line[1:].strip())
            elif line.startswith('+') and not line.startswith('+++'):
                in_divergence = True
                actual_lines.append(line[1:].strip())
            elif in_divergence and line.startswith(' '):
                context_lines.append(line[1:].strip())
                
        if expected_lines or actual_lines:
            # Extract instruction addresses if available
            expected_addr = self._extract_instruction_address(expected_lines[0]) if expected_lines else None
            actual_addr = self._extract_instruction_address(actual_lines[0]) if actual_lines else None
            
            return {
                "expected": {
                    "instructions": expected_lines,
                    "address": expected_addr
                },
                "actual": {
                    "instructions": actual_lines,
                    "address": actual_addr
                },
                "context": context_lines
            }
            
        return None
        
    def _extract_instruction_address(self, instruction_line: str) -> Optional[int]:
        """Extract the address from an assembly instruction line."""
        addr_match = re.search(r'0x([0-9a-f]+):', instruction_line)
        if addr_match:
            return int(addr_match.group(1), 16)
        return None

class ARMBinaryPatcher:
    """Class to handle patching ARM binary files."""
    
    def __init__(self, input_path: str, output_path: str):
        self.input_path = input_path
        self.output_path = output_path
        self.patches = []
        
        # Copy the input file to output path first
        shutil.copy(input_path, output_path)
        
        # Store the ELF file data for faster lookup
        self._analyze_elf_file()
        
    def _analyze_elf_file(self):
        """Analyze the ELF file to build a mapping of virtual addresses to file offsets."""
        self.addr_to_offset_map = {}
        
        try:
            with open(self.output_path, 'rb') as elf_file:
                elffile = ELFFile(elf_file)
                
                # Map each loadable segment
                for segment in elffile.iter_segments():
                    if segment['p_type'] == 'PT_LOAD':
                        vaddr_start = segment['p_vaddr']
                        vaddr_end = segment['p_vaddr'] + segment['p_memsz']
                        offset = segment['p_offset']
                        
                        # Store the mapping info
                        self.addr_to_offset_map[vaddr_start] = {
                            'offset_start': offset,
                            'vaddr_end': vaddr_end,
                            'offset_delta': offset - vaddr_start  # To calculate file offset from vaddr
                        }
                        
                logger.info(f"Analyzed ELF file: found {len(self.addr_to_offset_map)} loadable segments")
        except Exception as e:
            logger.error(f"Error analyzing ELF file: {e}")
            # Create an empty map as fallback
            self.addr_to_offset_map = {}
            
    def _vaddr_to_file_offset(self, vaddr: int) -> Optional[int]:
        """Convert a virtual address to a file offset."""
        for segment_start, segment_info in self.addr_to_offset_map.items():
            if segment_start <= vaddr < segment_info['vaddr_end']:
                # Calculate the file offset
                return segment_info['offset_delta'] + vaddr
                
        return None
        
    def patch_bytes(self, address: int, new_bytes: bytes):
        """Register a patch to be applied at the specified address."""
        self.patches.append((address, new_bytes))
        
    def save(self):
        """Apply all registered patches to the output file."""
        try:
            # Check if we have any patches
            if not self.patches:
                logger.info(f"No patches to apply to {self.output_path}")
                return True
                
            # Open the output file in binary mode
            with open(self.output_path, 'r+b') as f:
                # Apply each patch
                for address, new_bytes in self.patches:
                    # Get the file offset for the address
                    offset = self._vaddr_to_file_offset(address)
                    
                    if offset is None:
                        logger.error(f"Could not find file offset for address 0x{address:x}")
                        continue
                    
                    # Seek to the offset and write the bytes
                    f.seek(offset)
                    f.write(new_bytes)
                    logger.info(f"Patched 0x{len(new_bytes):x} bytes at address 0x{address:x} (file offset 0x{offset:x})")
                    
            logger.info(f"Applied {len(self.patches)} patches to {self.output_path}")
            return True
        except Exception as e:
            logger.error(f"Error applying patches: {e}")
            return False

class KernelPatcher:
    """Main class to coordinate analyzing and patching the kernel."""
    
    def __init__(self, diff_path: str, kernel_path: str, output_path: str):
        self.diff_path = diff_path
        self.kernel_path = kernel_path
        self.output_path = output_path
        self.qemu_analyzer = QemuLogAnalyzer(diff_path)
        self.ghidra_analyzer = None  # Only initialize when needed
        
    def run(self):
        """Run the full analysis and patching process."""
        try:
            logger.info("Starting kernel analysis and patching process")
            
            # Parse the QEMU diff file
            divergences = self.qemu_analyzer.parse_diff()
            if not divergences:
                logger.error("No execution path divergences found in the QEMU log")
                return False
                
            logger.info(f"Found {len(divergences)} divergent execution paths to analyze")
            
            # Create a binary patcher specific to ARM code
            binary_patcher = ARMBinaryPatcher(self.kernel_path, self.output_path)
            patched = False
            
            # Analyze each divergence
            for i, divergence in enumerate(divergences, 1):
                function_name = divergence.get('function', 'unknown')
                address = divergence.get('address', 0)
                logger.info(f"[{i}/{len(divergences)}] Analyzing divergence at address 0x{address:x} in function {function_name}")
                
                # Create patches based on the divergence pattern
                patch_info = self.create_patch_for_divergence(divergence, binary_patcher)
                
                if patch_info:
                    patched = True
                    logger.info(f"Created patch for {function_name} at 0x{address:x}")
                else:
                    logger.warning(f"Could not create patch for {function_name} at 0x{address:x}")
                    
            if not patched:
                logger.warning("No automatic patches were applied. Generating manual patch instructions...")
                
                # Generate fallback manual patch instructions
                manual_patches = generate_manual_patches(divergences, self.kernel_path, self.output_path)
                
                # Output the manual patch instructions
                print("\n==== Manual Patch Instructions ====\n")
                for i, patch in enumerate(manual_patches, 1):
                    print(f"Patch {i}: {patch['function']}")
                    print(f"  Issue: {patch['issue']}")
                    print(f"  Location: 0x{patch['address']:08x}")
                    print(f"  Solution: {patch['solution']}")
                    print(f"  Instructions: {patch['instructions']}\n")
                
                logger.warning("No automatic patches were applied. Manual patching instructions have been generated.")
                
                # Make a copy of the kernel for manual patching
                binary_patcher.save()
                return True
            
            # Save the patched kernel
            if not binary_patcher.save():
                logger.error("Failed to save patched kernel")
                return False
            
            logger.info(f"Kernel analysis and patching process completed. Patched kernel saved to {self.output_path}")
            return True
        except Exception as e:
            logger.error(f"Error during kernel patching process: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return False
            
    def create_patch_for_divergence(self, divergence, binary_patcher):
        """Create a patch for a specific divergence based on function signatures."""
        try:
            function_name = divergence.get('function', '')
            
            # Log detailed information about the divergence
            logger.info(f"Creating patch for function: {function_name}")
            logger.info(f"Expected instructions: {len(divergence.get('expected_path', {}).get('instructions', []))}")
            logger.info(f"Actual instructions: {len(divergence.get('actual_path', {}).get('instructions', []))}")
            
            # Select appropriate patching strategy based on function name
            if function_name and 'hex_to_bytes' in function_name.lower():
                logger.info("Using hex_to_bytes patching strategy")
                return self.patch_hex_to_bytes(divergence, binary_patcher)
            elif function_name and 'parse.constprop' in function_name.lower():
                logger.info("Using parse.constprop patching strategy")
                return self.patch_parse_constprop(divergence, binary_patcher)
            elif function_name and ('free' in function_name.lower() or 'dealloc' in function_name.lower()):
                logger.info("Using free/dealloc function patching strategy")
                return self.patch_free_function(divergence, binary_patcher)
            else:
                # If no specific strategy, try to use a generic approach
                logger.info(f"No specific patch strategy for function: {function_name}")
                logger.info("Attempting generic patching approach...")
                
                # Prioritize patching functions with more divergent instructions
                expected_instrs = divergence.get('expected_path', {}).get('instructions', [])
                if len(expected_instrs) > 1:
                    return self.patch_generic_function(divergence, binary_patcher)
                else:
                    logger.warning(f"Insufficient instructions to patch function: {function_name}")
                    return None
                
        except Exception as e:
            logger.error(f"Error creating patch for divergence: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return None
            
    def patch_generic_function(self, divergence, binary_patcher):
        """Generic patching strategy for unknown function types."""
        try:
            expected_instrs = divergence.get('expected_path', {}).get('instructions', [])
            
            if not expected_instrs:
                logger.warning("No expected instructions found for generic function patch")
                return None
                
            patch_addr = expected_instrs[0].get('address', 0)
            function_name = divergence.get('function', 'unknown_function')
            
            logger.info(f"Creating generic patch for {function_name} at 0x{patch_addr:x}")
            
            patch_info = {
                'function': function_name,
                'address': patch_addr,
                'instructions': expected_instrs,
                'patched': False
            }
            
            patched_count = 0
            
            # For generic functions, we prioritize patching branch instructions
            branch_instrs = [i for i in expected_instrs if i.get('mnemonic', '').startswith('b')]
            cmp_instrs = [i for i in expected_instrs if 'cmp' in i.get('mnemonic', '')]
            
            # First patch comparison and branch instructions
            priority_instrs = branch_instrs + cmp_instrs
            
            for instr in priority_instrs:
                addr = instr.get('address', 0)
                hex_data = instr.get('hex', '')
                
                if hex_data and addr:
                    try:
                        instr_bytes = bytes.fromhex(hex_data.strip())
                        binary_patcher.patch_bytes(addr, instr_bytes)
                        patched_count += 1
                        patch_info['patched'] = True
                        logger.info(f"Patched priority instruction at 0x{addr:x}: {instr.get('mnemonic', '')} {instr.get('args', '')}")
                    except Exception as e:
                        logger.error(f"Failed to patch instruction at 0x{addr:x}: {e}")
            
            # Then patch remaining instructions if needed
            remaining_instrs = [i for i in expected_instrs if i not in priority_instrs]
            
            if not patch_info['patched'] and remaining_instrs:
                logger.info("No priority instructions patched, attempting to patch remaining instructions")
                
                for instr in remaining_instrs:
                    addr = instr.get('address', 0)
                    hex_data = instr.get('hex', '')
                    
                    if hex_data and addr:
                        try:
                            instr_bytes = bytes.fromhex(hex_data.strip())
                            binary_patcher.patch_bytes(addr, instr_bytes)
                            patched_count += 1
                            patch_info['patched'] = True
                        except Exception as e:
                            logger.error(f"Failed to patch instruction at 0x{addr:x}: {e}")
            
            logger.info(f"Patched {patched_count}/{len(expected_instrs)} instructions for {function_name}")
            return patch_info if patch_info['patched'] else None
            
        except Exception as e:
            logger.error(f"Error in generic function patching: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return None
            
    def patch_hex_to_bytes(self, divergence, binary_patcher):
        """Create a patch for the hex_to_bytes function."""
        # Get instructions and addresses
        expected_instrs = divergence.get('expected_path', {}).get('instructions', [])
        actual_instrs = divergence.get('actual_path', {}).get('instructions', [])
        
        if not expected_instrs:
            logger.warning("No expected instructions found for hex_to_bytes patch")
            return None
            
        # Find the comparison and branch instructions
        cmp_instrs = [i for i in expected_instrs if 'cmp' in i.get('mnemonic', '')]
        branch_instrs = [i for i in expected_instrs if i.get('mnemonic', '').startswith('b')]
        
        if not cmp_instrs or not branch_instrs:
            logger.warning("Could not find critical instructions for hex_to_bytes patch")
            return None
            
        # Get the address of the first instruction to patch
        patch_addr = expected_instrs[0].get('address', 0)
        
        # Create a volatility barrier patch
        patch_info = {
            'function': 'hex_to_bytes',
            'address': patch_addr,
            'instructions': expected_instrs,
            'patched': False
        }
        
        # Apply the patch to prevent constant propagation
        # This will depend on the specific compiler optimization being applied
        # Here we use a simple approach: restore the original instructions
        
        for instr in expected_instrs:
            addr = instr.get('address', 0)
            hex_data = instr.get('hex', '')
            
            if hex_data and addr:
                try:
                    instr_bytes = bytes.fromhex(hex_data)
                    binary_patcher.patch_bytes(addr, instr_bytes)
                    patch_info['patched'] = True
                except Exception as e:
                    logger.error(f"Failed to patch instruction at 0x{addr:x}: {e}")
        
        return patch_info if patch_info['patched'] else None('address', 0)
    
    def patch_parse_constprop(self, divergence, binary_patcher):
        """Create a patch for the parse.constprop.0 function."""
        # Get instructions and addresses
        expected_instrs = divergence.get('expected_path', {}).get('instructions', [])
        actual_instrs = divergence.get('actual_path', {}).get('instructions', [])
        
        if not expected_instrs:
            logger.warning("No expected instructions found for parse.constprop.0 patch")
            return None
            
        # Check for branch instructions in the expected path
        branch_instrs = [i for i in expected_instrs if i.get('mnemonic', '').startswith('b') and not i.get('mnemonic', '').startswith('bl')]
        
        # Find the first address to patch
        patch_addr = expected_instrs[0].get('address', 0)
        
        # Create patch info
        patch_info = {
            'function': 'parse.constprop.0',
            'address': patch_addr,
            'instructions': expected_instrs,
            'patched': False
        }
        
        # Apply patches to restore original branch instructions
        for instr in expected_instrs:
            addr = instr.get('address', 0)
            hex_data = instr.get('hex', '')
            
            if hex_data and addr:
                try:
                    instr_bytes = bytes.fromhex(hex_data)
                    binary_patcher.patch_bytes(addr, instr_bytes)
                    patch_info['patched'] = True
                except Exception as e:
                    logger.error(f"Failed to patch instruction at 0x{addr:x}: {e}")
        
        return patch_info if patch_info['patched'] else None
        
    def patch_free_function(self, divergence, binary_patcher):
        """Create a patch for the free function."""
        # This follows the same pattern as the other patch functions
        expected_instrs = divergence.get('expected_path', {}).get('instructions', [])
        
        if not expected_instrs:
            logger.warning("No expected instructions found for free function patch")
            return None
            
        patch_addr = expected_instrs[0].get('address', 0)
        
        patch_info = {
            'function': 'free function',
            'address': patch_addr,
            'instructions': expected_instrs,
            'patched': False
        }
        
        for instr in expected_instrs:
            addr = instr.get('address', 0)
            hex_data = instr.get('hex', '')
            
            if hex_data and addr:
                try:
                    instr_bytes = bytes.fromhex(hex_data)
                    binary_patcher.patch_bytes(addr, instr_bytes)
                    patch_info['patched'] = True
                except Exception as e:
                    logger.error(f"Failed to patch instruction at 0x{addr:x}: {e}")
        
        return patch_info if patch_info['patched'] else None
    


class ARMBinaryPatcher:
    """Class to handle patching ARM binary files."""
    
    def __init__(self, input_path: str, output_path: str):
        self.input_path = input_path
        self.output_path = output_path
        self.patches = []
        
        # Copy the input file to output path first
        shutil.copy(input_path, output_path)
        
    def patch_bytes(self, address: int, new_bytes: bytes):
        """Register a patch to be applied at the specified address."""
        self.patches.append((address, new_bytes))
        
    def save(self):
        """Apply all registered patches to the output file."""
        try:
            # Open the output file in binary mode
            with open(self.output_path, 'r+b') as f:
                # Apply each patch
                for address, new_bytes in self.patches:
                    # First, find the offset in the file corresponding to the address
                    # This would depend on the ELF header and program headers
                    # For now, we use a simplistic approach assuming a direct mapping
                    
                    # Get the file offset for the address
                    with open(self.output_path, 'rb') as elf_file:
                        elffile = ELFFile(elf_file)
                        offset = None
                        
                        # Find the segment containing this address
                        for segment in elffile.iter_segments():
                            if segment['p_type'] == 'PT_LOAD':
                                if segment['p_vaddr'] <= address < segment['p_vaddr'] + segment['p_memsz']:
                                    offset = segment['p_offset'] + (address - segment['p_vaddr'])
                                    break
                                    
                        if offset is None:
                            logger.error(f"Could not find file offset for address 0x{address:x}")
                            continue
                    
                    # Seek to the offset and write the bytes
                    f.seek(offset)
                    f.write(new_bytes)
                    logger.info(f"Patched 0x{len(new_bytes):x} bytes at address 0x{address:x} (file offset 0x{offset:x})")
                    
            logger.info(f"Applied {len(self.patches)} patches to {self.output_path}")
            return True
        except Exception as e:
            logger.error(f"Error applying patches: {e}")
            return False

def generate_manual_patches(divergences, kernel_path, output_path):
    """Generate manual patch instructions based on divergence analysis."""
    manual_patches = []
    
    for divergence in divergences:
        function_name = divergence.get("function", "unknown_function")
        address = divergence.get("address", 0)
        
        removed_instrs = [i["raw"] for i in divergence.get("expected_path", {}).get("instructions", [])]
        added_instrs = [i["raw"] for i in divergence.get("actual_path", {}).get("instructions", [])]
        
        # Analyze the divergence pattern to determine the issue and solution
        issue, solution, instructions = analyze_divergence_pattern(function_name, removed_instrs, added_instrs)
        
        manual_patches.append({
            "function": function_name,
            "address": address,
            "issue": issue,
            "solution": solution,
            "instructions": instructions
        })
    
    return manual_patches

def analyze_divergence_pattern(function_name, removed_instrs, added_instrs):
    """Analyze the pattern of removed and added instructions to determine the issue and solution."""
    
    # Initialize with default values
    issue = "Unknown constprop optimization"
    solution = "Add volatility barrier"
    instructions = "Modify the binary to prevent constant propagation"
    
    # Check for common patterns in the divergence
    
    # Check for parse.constprop.0 optimizations
    if function_name == "parse.constprop.0":
        if any("cmp" in instr and "bne" in instr for instr in removed_instrs):
            issue = "Constant propagation removed conditional branch check"
            solution = "Add volatile variable to force runtime evaluation of condition"
            instructions = """
1. Identify the condition that was optimized out:
   - Look for 'cmp' instructions followed by conditional branches
   - These indicate compiler optimized away a runtime check

2. Add a volatility barrier:
   - Replace optimized code with:
     ```
     volatile int prevent_optimization = condition_value;
     if (prevent_optimization) {
         // original branch code
     }
     ```

3. Patch the binary by inserting instructions that:
   - Load a value from memory (force memory access)
   - Compare that value
   - Branch based on the comparison
            """
    
    # Check for hex_to_bytes optimizations
    elif function_name == "hex_to_bytes":
        if any("sub" in instr and "cmp" in instr for instr in removed_instrs):
            issue = "Constant propagation optimized character comparisons"
            solution = "Add volatile variables for character values to force runtime comparison"
            instructions = """
1. Identify the character comparison that was optimized:
   - Look for 'sub' instructions that subtract ASCII values
   - Check for 'cmp' instructions that compare the result

2. Add a volatility barrier:
   - Replace optimized code with:
     ```
     volatile char c = input_char;
     if (c >= 'A' && c <= 'F') {
         // handle uppercase hex
     } else if (c >= 'a' && c <= 'f') {
         // handle lowercase hex
     }
     ```

3. Patch the binary by inserting instructions that:
   - Load character from memory with volatile semantics
   - Perform the comparison with register values rather than immediates
            """
    
    # Check for free function optimizations
    elif function_name == "free" or "free" in function_name:
        issue = "Memory management function optimization altered control flow"
        solution = "Force pointer dereferencing through volatile pointers"
        instructions = """
1. Identify the memory access pattern that was optimized:
   - Look for 'ldr' instructions that load from memory
   - Check for 'cmp' instructions that compare the loaded values

2. Add a volatility barrier:
   - Replace optimized code with:
     ```
     volatile void *ptr = memory_pointer;
     if (*(volatile uint32_t *)ptr == expected_value) {
         // original branch code
     }
     ```

3. Patch the binary by inserting instructions that:
   - Load pointers through memory with volatile semantics
   - Compare loaded values using registers not immediates
            """
    
    return issue, solution, instructions

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Analyze and patch kernel for constant propagation optimizations')
    parser.add_argument('--diff', required=True, help='Path to QEMU assembly log diff file')
    parser.add_argument('--kernel', required=True, help='Path to kernel binary')
    parser.add_argument('--output', required=True, help='Path to save patched kernel')
    parser.add_argument('--manual', action='store_true', help='Generate manual patch instructions instead of using Ghidra')
    args = parser.parse_args()
    
    # Check if files exist
    if not os.path.exists(args.diff):
        logger.error(f"Diff file not found: {args.diff}")
        return
    if not os.path.exists(args.kernel):
        logger.error(f"Kernel file not found: {args.kernel}")
        return
    
    # Run the parser without Ghidra first to identify issues
    qemu_analyzer = QemuLogAnalyzer(args.diff)
    divergences = qemu_analyzer.parse_diff()
    
    if not divergences:
        logger.error("No execution path divergences found in the QEMU log")
        return False
    
    logger.info(f"Found {len(divergences)} divergent execution paths")
    
    if args.manual:
        # Generate manual patch instructions
        manual_patches = generate_manual_patches(divergences, args.kernel, args.output)
        
        # Output the manual patch instructions
        print("\n==== Manual Patch Instructions ====\n")
        for i, patch in enumerate(manual_patches, 1):
            print(f"Patch {i}: {patch['function']}")
            print(f"  Issue: {patch['issue']}")
            print(f"  Location: 0x{patch['address']:08x}")
            print(f"  Solution: {patch['solution']}")
            print(f"  Instructions: {patch['instructions']}\n")
        
        # Make a copy of the kernel for manual patching
        shutil.copy(args.kernel, args.output)
        logger.info(f"Created copy of kernel at {args.output} for manual patching")
        return True
    else:
        # Run the patcher
        patcher = KernelPatcher(args.diff, args.kernel, args.output)
        success = patcher.run()
        
        if success:
            logger.info("Kernel patching completed successfully")
        else:
            logger.error("Kernel patching failed")
        return success

if __name__ == "__main__":
    main()