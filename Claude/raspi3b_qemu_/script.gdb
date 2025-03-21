# script1.gdb - initial setup
target remote localhost:1234
break *_start
break main

# Set the breakpoint at the specified address
break *0x0000d1f0

set history save on
set history filename ~/.gdb_history
set history size 10000
continue
#!/usr/bin/gdb -x
# GDB script to debug kernel execution path divergence
# Save this as 'debug-kernel-diff.gdb' and run with:
# gdb -x debug-kernel-diff.gdb

# Configure GDB settings
set pagination off
set confirm off
set print pretty on
set print array on
set print elements 128

# Create log file for debugging session
set logging enabled on

# Set break at the common comparison point (adjust addresses as needed)
define setup_original_kernel
  # For original kernel
  break *0xd2c0  # cmp r8, #63
  commands
    silent
    printf "ORIGINAL KERNEL: Hit comparison at 0x%x\n", $pc
    printf "  r5 = 0x%08x, r8 = 0x%08x\n", $r5, $r8
    if ($r8 == 63 && $r5 == -1)
      printf "  Condition will be true (will branch to 0xd3c8)\n"
    else
      printf "  Condition will be false\n"
    end
    continue
  end
  
  # Set break at original kernel's branch
  break *0xd380  # b 0xd580
  commands
    silent
    printf "ORIGINAL KERNEL: Hit branch at 0x%x to 0xd580\n", $pc
    backtrace 3
    continue
  end
  
  # Set break at function calls
  break *0xd588  # bl 0xa828
  commands
    silent
    printf "ORIGINAL KERNEL: Calling function at 0xa828 with r0=0x%08x, r1=0x%08x\n", $r0, $r1
    continue
  end
  
  break *0xd598  # bl 0xec94
  commands
    silent
    printf "ORIGINAL KERNEL: Calling function at 0xec94 with r0=0x%08x, r1=0x%08x\n", $r0, $r1
    x/10s $r0  # Examine as string in case it's a message
    continue
  end
  
  break *0xd5a4  # bl 0xa040
  commands
    silent
    printf "ORIGINAL KERNEL: Calling function at 0xa040 with r0=0x%08x, r1=0x%08x\n", $r0, $r1
    continue
  end
  
  break *0xd3e4  # Function return (pop {..., pc})
  commands
    silent
    printf "ORIGINAL KERNEL: Function returning with r0=0x%08x\n", $r0
    continue
  end
end

define setup_patched_kernel
  # For patched kernel
  break *0xd258  # First instruction of patched section
  commands
    silent
    printf "PATCHED KERNEL: Starting patched code at 0x%x\n", $pc
    printf "  r5 = 0x%08x, r8 = 0x%08x\n", $r5, $r8
    continue
  end
  
  break *0xd268  # bl 0xec94 in patched kernel
  commands
    silent
    printf "PATCHED KERNEL: About to call function at 0xec94\n"
    printf "  r0 = 0x%08x, r1 = 0x%08x\n", $r0, $r1
    x/10s $r0  # Examine as string in case it's a message
    continue
  end
  
  break *0xd26c  # mov r0, #14 in patched kernel
  commands
    silent
    printf "PATCHED KERNEL: Setting return value r0=14\n"
    continue
  end
  
  break *0xd274  # Function return in patched kernel
  commands
    silent
    printf "PATCHED KERNEL: Function returning with r0=0x%08x\n", $r0
    continue
  end
end

break *0xec94
commands
  silent
  printf "COMMON FUNCTION: Called at 0xec94 with r0=0x%08x, r1=0x%08x\n", $r0, $r1
  # Try to see if r0 points to a string (common for debugging messages)
  x/s $r0
  backtrace 2
  continue
end

define set_watchpoints
  printf "Setting up watchpoints for key registers...\n"
  # Note: These require hardware watchpoints and may slow execution
  # rwatch $r5
  # rwatch $r8
end

define debug_execution
  printf "=== Starting Kernel Execution Path Analysis ===\n"
  
  # Detect which kernel we're debugging (using presence of instructions)
  printf "Detecting kernel version...\n"
  
  # Try to find signature instructions
  set $_found_original = 0
  set $_found_patched = 0
  
  # Check for original kernel signature instruction
  shell echo "Checking for original kernel..."
  x/i 0xd2c0
  if ($_ != 0)
    if (*(unsigned int*)0xd2c0 == 0xe358003f)
      set $_found_original = 1
      printf "Found original kernel signature at 0xd2c0\n"
    end
  end
  
  # Check for patched kernel signature instruction  
  shell echo "Checking for patched kernel..."
  x/i 0xd258
  if ($_ != 0)
    if (*(unsigned int*)0xd258 == 0xe3031c34)
      set $_found_patched = 1
      printf "Found patched kernel signature at 0xd258\n"
    end
  end
  
  if ($_found_original)
    printf "Detected ORIGINAL kernel. Setting up appropriate breakpoints...\n"
    setup_original_kernel
  end
  
  if ($_found_patched)
    printf "Detected PATCHED kernel. Setting up appropriate breakpoints...\n"
    setup_patched_kernel
  end
  
  if (!$_found_original && !$_found_patched)
    printf "ERROR: Could not detect kernel version! Addresses may be incorrect.\n"
    printf "Try adjusting addresses in the script based on your actual binary.\n"
  end
  
  # Set up watches and continue execution
  set_watchpoints
  printf "Setup complete. Continuing execution...\n"
  continue
end

debug_execution

