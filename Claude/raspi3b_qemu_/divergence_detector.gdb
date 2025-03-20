# divergence_detector.gdb - Automatically generated from diff log
# Generated script for detecting divergence points

# Initial setup
target remote localhost:1234
break *_start
break main
set history save on
set history filename ~/.gdb_history
set history size 10000

# Breakpoints at detected divergence points

# Breakpoints for unknown
break *0x10780  # sub	r3, r2, #65	; 0x41
break *0x10784  # cmp	r3, #5	; 0x5

# Breakpoints for hex_to_bytes
break hex_to_bytes
break *0x10700  # sub	r3, r2, #97	; 0x61
break *0x10704  # cmp	r3, #5	; 0x5
break *0x10708  # subls	r3, r2, #87	; 0x57
break *0x10754  # strb	r3, [r1, #1]!
break *0x1075c  # cmp	r0, ip
break *0x10760  # popeq	{pc}		; (ldreq pc, [sp], #4)
break *0x10780  # sub	r3, r2, #65	; 0x41
break *0x10784  # cmp	r3, #5	; 0x5
break *0x10700  # sub	r3, r2, #97	; 0x61
break *0x10704  # cmp	r3, #5	; 0x5
break *0x10708  # subls	r3, r2, #87	; 0x57
break *0x10754  # strb	r3, [r1, #1]!
break *0x1075c  # cmp	r0, ip
break *0x10760  # popeq	{pc}		; (ldreq pc, [sp], #4)

# Breakpoints for parse.constprop.0
break parse.constprop.0
break *0xd9b4  # eor	r2, sl, #1	; 0x1
break *0xd9b8  # cmp	r5, #5	; 0x5
break *0xd9c4  # cmp	r2, #0	; 0x0
break *0xd9cc  # ldr	r2, [r4, #16]
break *0xd9d0  # cmp	r2, #0	; 0x0
break *0xd9d8  # ldr	r0, [r4, #24]
break *0xd9dc  # ldr	r2, [r4, #28]
break *0xd9e0  # cmp	r0, r2
break *0xd4ec  # ldr	r0, [pc, #2964]	; 0xe088
break *0xdde4  # str	r3, [sp, #16]
break *0xddf0  # ldr	r2, [r4, #16]
break *0xddf4  # cmp	r5, #0	; 0x0
break *0xddf8  # ldr	r3, [sp, #16]
break *0xddfc  # subne	r5, r5, #1	; 0x1
break *0xde00  # cmp	r2, #0	; 0x0
break *0xe234  # ldr	r2, [r4, #28]
break *0xda10  # ldr	r1, [r4, #24]
break *0xda14  # cmp	r1, r2
break *0xda1c  # ldr	r2, [r4, #8]
break *0xda20  # ldr	r0, [r4, #32]
break *0xda28  # str	r2, [r4, #8]
break *0xda30  # str	r2, [r4, #24]
break *0xda34  # ldrb	r7, [r0, r1]
break *0xda38  # str	r3, [sp, #16]
break *0xda3c  # cmp	r5, #0	; 0x0
break *0xdeb8  # ldr	r3, [sp, #12]
break *0xdec0  # str	r0, [r3, #4]
break *0xdec4  # ldr	r3, [sp, #16]
break *0xdec8  # str	r8, [r0, #12]
break *0xdecc  # strb	r3, [r0, #8]
break *0xded0  # strb	sl, [r0, #9]
break *0xded4  # str	r7, [r0, #20]
break *0xded8  # ldr	r2, [r4, #16]
break *0xdedc  # cmp	r7, #0	; 0x0
break *0xdd10  # cmp	r2, #0	; 0x0
break *0xdd18  # ldr	r1, [r4, #24]
break *0xdd1c  # ldr	r3, [r4, #28]
break *0xdd20  # cmp	r1, r3
break *0xdd28  # ldr	r2, [r4, #8]
break *0xdd2c  # ldr	r0, [r4, #32]
break *0xdd34  # str	r2, [r4, #8]
break *0xdd3c  # str	r2, [r4, #24]
break *0xdd40  # ldrb	r1, [r0, r1]
break *0xdd48  # cmp	r3, r2
break *0xdd50  # ldr	r1, [r4, #8]
break *0xdd54  # ldr	r0, [r4, #32]
break *0xdd5c  # str	r1, [r4, #8]
break *0xdd64  # str	r1, [r4, #24]
break *0xdd68  # ldrb	r7, [r0, r2]
break *0xdd70  # cmp	r3, r1
break *0xdd78  # ldr	r2, [r4, #8]
break *0xdd7c  # ldr	r0, [r4, #32]
break *0xdd84  # str	r2, [r4, #8]
break *0xdd8c  # str	r2, [r4, #24]
break *0xdd90  # ldrb	r1, [r0, r1]
break *0xdd98  # cmp	r2, r3
break *0xdda0  # ldr	r3, [r4, #8]
break *0xdda4  # ldr	r1, [r4, #32]
break *0xddac  # str	r3, [r4, #8]
break *0xddb4  # str	r3, [r4, #24]
break *0xddb8  # ldrb	r3, [r1, r2]
break *0xddc0  # cmp	r5, #0	; 0x0
break *0xddc4  # str	r3, [fp, #16]
break *0xddc8  # subne	r5, r5, #4	; 0x4
break *0xddcc  # str	r5, [fp]
break *0xddd4  # str	r4, [fp, #4]
break *0xd1b4  # ldr	r1, [pc, #3752]	; 0xe064
break *0xd1bc  # ldr	r0, [pc, #3748]	; 0xe068
break *0xd220  # cmp	r8, #63	; 0x3f

# Breakpoints for free_packet.localalias
break free_packet.localalias
break *0xa84c  # ldrb	r1, [r0]
break *0xa850  # ldr	r0, [pc, #80]	; 0xa8a8
break *0xccac  # ldr	ip, [r3]
break *0xccb0  # ldr	r2, [r0, #-12]
break *0xccb4  # ldr	r1, [r3, #8]
break *0xccbc  # str	r3, [r0, #-12]
break *0xccc0  # str	r1, [r0, #-4]
break *0xa84c  # ldrb	r1, [r0]
break *0xa850  # ldr	r0, [pc, #80]	; 0xa8a8

# Breakpoints for free
break free
break *0xcc84  # ldr	r1, [r2]
break *0xcc8c  # cmp	lr, ip
break *0xcc84  # ldr	r1, [r2]
break *0xcc8c  # cmp	lr, ip

# Utility commands for divergence analysis
define examine_state
  printf "Examining execution state at 0x%x:\n", $pc
  info registers
  x/10i $pc
  printf "Memory around key registers:\n"
  x/64xb $r0
  printf "Memory around r1:\n"
  x/64xb $r1
  printf "Memory around r2:\n"
  x/64xb $r2
  printf "Memory around r3:\n"
  x/64xb $r3
  if $r4 != 0
    printf "Memory around r4:\n"
    x/64xb $r4
  end
  if $r5 != 0
    printf "Memory around r5:\n"
    x/64xb $r5
  end
end

# Command to track register changes between breakpoints
define track_regs
  set $old_r0 = $r0
  set $old_r1 = $r1
  set $old_r2 = $r2
  set $old_r3 = $r3
  set $old_r4 = $r4
  set $old_r5 = $r5
  set $old_r6 = $r6
  set $old_r7 = $r7
  cont
  printf "Register changes:\n"
  printf "R0: 0x%x -> 0x%x\n", $old_r0, $r0
  printf "R1: 0x%x -> 0x%x\n", $old_r1, $r1
  printf "R2: 0x%x -> 0x%x\n", $old_r2, $r2 
  printf "R3: 0x%x -> 0x%x\n", $old_r3, $r3
  printf "R4: 0x%x -> 0x%x\n", $old_r4, $r4
  printf "R5: 0x%x -> 0x%x\n", $old_r5, $r5
  printf "R6: 0x%x -> 0x%x\n", $old_r6, $r6
  printf "R7: 0x%x -> 0x%x\n", $old_r7, $r7
end

# Function to capture memory and register state
define capture_state
  set logging on
  set logging file divergence_state_${1}_0x${2}.txt
  
  printf "STATE CAPTURE at PC=0x%x\n", $pc
  printf "==================================\n\n"
  
  # All registers
  printf "REGISTER STATE:\n"
  info registers
  
  # Stack trace
  printf "\nCALL STACK:\n"
  backtrace
  
  # Memory dumps around key pointers
  printf "\nMEMORY DUMPS:\n"
  printf "R0 memory:\n"
  x/64xb $r0
  printf "R1 memory:\n"
  x/64xb $r1
  printf "R2 memory:\n"
  x/64xb $r2
  printf "R3 memory:\n"
  x/64xb $r3
  
  # Stack memory
  printf "\nStack region:\n"
  x/128xb $sp
  
  set logging off
  printf "State captured to divergence_state_${1}_0x${2}.txt\n"
end

# Memory difference detection between two runs
define compare_memory
  set $addr = $arg0
  set $size = $arg1
  set $filename = $arg2
  
  printf "Saving %d bytes from 0x%x to %s\n", $size, $addr, $filename
  dump binary memory $filename $addr ($addr + $size)
end

# Set watchpoints on a memory region
define watch_region
  set $base = $arg0
  set $size = $arg1
  
  printf "Setting watchpoints on %d bytes at 0x%x\n", $size, $base
  
  # Set watchpoints at key offsets
  watch *$base
  if $size > 4
    watch *($base+4)
  end
  if $size > 8
    watch *($base+8)
  end
  if $size > 12
    watch *($base+12)
  end
end

# Define a function to track the divergence point
define find_divergence
  set logging on
  set logging file divergence_log.txt
  set pagination off
  
  # Notify start of tracking
  printf "Starting divergence tracking...\n"
  
  # Run until one of our key breakpoints
  cont
  
  # When we hit a breakpoint, examine the state
  examine_state
  
  printf "Commands available at this breakpoint:\n"
  printf "  capture_state <run_id> <addr_label> - Capture full state\n"
  printf "  track_regs - Continue and track register changes\n"
  printf "  watch_region $rX <size> - Set watchpoints on memory region\n"
  printf "  compare_memory <addr> <size> <filename> - Save memory for comparison\n"
  
  set logging off
  set pagination on
end

# Shell command to find differences between memory dumps
shell echo '#!/bin/bash
if [ $# -ne 2 ]; then
  echo "Usage: $0 file1 file2"
  exit 1
fi
cmp -l "$1" "$2" | gawk '\''{ printf "Byte %d: %02x vs %02x\n", $1, strtonum("0"$2), strtonum("0"$3) }'\''' > find_difference.sh
shell chmod +x find_difference.sh

# Print help information
printf "Divergence detection script loaded.\n"
printf "Commands available:\n"
printf "  find_divergence - Start tracking at breakpoints\n"
printf "  examine_state - Display current execution state\n"
printf "  track_regs - Continue execution and track register changes\n"
printf "  capture_state <run_id> <addr_label> - Capture full state\n"
printf "  watch_region <addr> <size> - Set watchpoints on memory region\n"
printf "  compare_memory - Save memory region for later comparison\n"

continue
