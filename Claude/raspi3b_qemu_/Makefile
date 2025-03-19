# Compiler and emulator
CROSS_COMPILE ?= arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
QEMU = qemu-system-arm
GDB = gdb-multiarch

# Directories
SRC_DIR = src
COMMON_DIR = $(SRC_DIR)/common
BUILD_DIR = build
RESULTS_DIR = results
BUILD_COMMON_DIR = $(BUILD_DIR)/common
ASM_OUTPUT_DIR = $(BUILD_DIR)/asm_output

# Source files (common first)
COMMON_SRCS = $(wildcard $(COMMON_DIR)/*.c)
ASM_SRCS = $(SRC_DIR)/start.s

# Debug the source files (uncomment to see what files are included)
# $(info All source files in SRC_DIR: $(wildcard $(SRC_DIR)/*.c))

# We'll explicitly include mainproc.c to avoid filtering issues
MAINPROC_SRC = $(SRC_DIR)/mainproc.c
MAINPROC_OBJ = $(BUILD_DIR)/mainproc.o

# We'll exclude main files from general sources and handle them separately
SRCS = $(filter-out $(SRC_DIR)/main%.c,$(wildcard $(SRC_DIR)/*.c))
# Filter out mainproc.c since we're handling it separately
SRCS := $(filter-out $(MAINPROC_SRC),$(SRCS))

# Debug the filtered source files (uncomment to verify)
# $(info Filtered source files: $(SRCS))

# Main source files for different versions
MAIN1_SRC = $(SRC_DIR)/main.1.c
MAIN2_SRC = $(SRC_DIR)/main.2.c

# Object files (common first)
COMMON_OBJS = $(COMMON_SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
ASM_OBJS = $(ASM_SRCS:$(SRC_DIR)/%.s=$(BUILD_DIR)/%.o)

# Main object files for different versions
MAIN1_OBJ = $(BUILD_DIR)/main1.o
MAIN2_OBJ = $(BUILD_DIR)/main2.o

# Include paths
INCLUDES = -I$(SRC_DIR) -I$(COMMON_DIR)

# Flags
CFLAGS = -mcpu=cortex-a7 -fpic -ffreestanding -O2 -Wall -Wextra -g $(INCLUDES) -ffunction-sections -fdata-sections -fno-common
ASFLAGS = -mcpu=cortex-a7
LDFLAGS = -T $(SRC_DIR)/linker.ld -ffreestanding -O2 -nostdlib \
          -Wl,--gc-sections \
          -Wl,--sort-section=alignment \
          -Wl,--sort-common=descending \
          -Wl,--no-merge-exidx-entries

# Define targets for each version
TARGET1 = $(BUILD_DIR)/kernel1.img
TARGET2 = $(BUILD_DIR)/kernel2.img

# Define targets for each version
TARGET1_ELF = $(BUILD_DIR)/kernel1.elf
TARGET2_ELF = $(BUILD_DIR)/kernel2.elf

.PHONY: all clean run1 run2 debug1 debug2 gdb1 gdb2 compare comparePatched compareLog log1 log2 logPatched

all: $(TARGET1) $(TARGET2)

# Build common objects first
common: $(COMMON_OBJS)

# Build rules for common objects
$(BUILD_DIR)/common/%.o: $(SRC_DIR)/common/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

# Build rules for main source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@

# Special rule for mainproc.c
$(MAINPROC_OBJ): $(MAINPROC_SRC)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

# Special rules for main1 and main2
$(MAIN1_OBJ): $(MAIN1_SRC)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(MAIN2_OBJ): $(MAIN2_SRC)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

# Build both kernel images - explicitly include mainproc.o
$(TARGET1): $(COMMON_OBJS) $(OBJS) $(ASM_OBJS) $(MAIN1_OBJ) $(MAINPROC_OBJ)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ -o $@

$(TARGET2): $(COMMON_OBJS) $(OBJS) $(ASM_OBJS) $(MAIN2_OBJ) $(MAINPROC_OBJ)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ -o $@

# Build both kernel ELF files - explicitly include mainproc.o
$(TARGET1_ELF): $(COMMON_OBJS) $(OBJS) $(ASM_OBJS) $(MAIN1_OBJ) $(MAINPROC_OBJ)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ -o $@

$(TARGET2_ELF): $(COMMON_OBJS) $(OBJS) $(ASM_OBJS) $(MAIN2_OBJ) $(MAINPROC_OBJ)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ -o $@

# # Create binary images from ELF files
# $(TARGET1): $(TARGET1_ELF)
# 	$(OBJCOPY) -O binary $< $@

# $(TARGET2): $(TARGET2_ELF)
# 	$(OBJCOPY) -O binary $< $@
clean:
	rm -rf $(BUILD_DIR)

# Run targets for each version
run1: $(TARGET1)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET1) -nographic -serial mon:stdio

run2: $(TARGET2)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET2) -nographic -serial mon:stdio
	
runPatched: $(TARGET2)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel build/patchedKernel.img -nographic -serial mon:stdio
runPatched2: $(TARGET2)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel build/patched_kernel.img -nographic -serial mon:stdio

# Log targets for each version
log1: $(TARGET1)
	@mkdir -p $(RESULTS_DIR)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET1) -d int,guest_errors,mmu,in_asm -D $(RESULTS_DIR)/kernel1.in_asm.log -nographic -serial mon:stdio

log2: $(TARGET2)
	@mkdir -p $(RESULTS_DIR)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET2) -d int,guest_errors,mmu,in_asm -D $(RESULTS_DIR)/kernel2.in_asm.log -nographic -serial mon:stdio

logPatched: $(TARGET2)
	@mkdir -p $(RESULTS_DIR)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel build/patchedKernel.img -d int,guest_errors,mmu,in_asm -D $(RESULTS_DIR)/patchedKernel.in_asm.log -nographic -serial mon:stdio

# Debug targets for each version
debug1: $(TARGET1)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET1) -nographic -serial mon:stdio -s -S

debug2: $(TARGET2)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET2) -nographic -serial mon:stdio -s -S

gdb1:
	gdb-multiarch $(TARGET1) -x script.gdb

gdb2:
	gdb-multiarch $(TARGET2) -x script.gdb

# Compare the two builds
compare: $(TARGET1) $(TARGET2)
	@mkdir -p $(RESULTS_DIR)
	@echo "Comparing sizes of kernel1.img and kernel2.img:"
	@ls -la $(TARGET1) $(TARGET2)
	@echo "\nComparing objdump of kernel1.img and kernel2.img:"
	@$(CROSS_COMPILE)objdump -d $(TARGET1) > $(RESULTS_DIR)/kernel1.dump
	@$(CROSS_COMPILE)objdump -d $(TARGET2) > $(RESULTS_DIR)/kernel2.dump
	@echo "Full diff saved to $(RESULTS_DIR)/disasm_diff.txt"
	@diff $(RESULTS_DIR)/kernel1.dump $(RESULTS_DIR)/kernel2.dump > $(RESULTS_DIR)/disasm_diff.txt || true

# Combined comparePatched target with binary verification, GPG verification, and log comparison
comparePatched: $(TARGET1)
	@mkdir -p $(RESULTS_DIR)
	@echo "Comparing sizes of kernel1.img and patchedKernel.img:"
	@ls -la $(TARGET1) build/patchedKernel.img
	
	
	# Continue with the original comparePatched content
	@echo "\nComparing objdump of kernel1.img and patchedKernel.img:"
	@$(CROSS_COMPILE)objdump -d $(TARGET1) > $(RESULTS_DIR)/kernel1.dump
	@$(CROSS_COMPILE)objdump -d build/patchedKernel.img > $(RESULTS_DIR)/patchedKernel.dump
	@echo "Full diff saved to $(RESULTS_DIR)/patched_disasm_diff.txt"
	@diff $(RESULTS_DIR)/kernel1.dump $(RESULTS_DIR)/patchedKernel.dump > $(RESULTS_DIR)/patched_disasm_diff.txt || true
	
	@echo "\nComparing symbols in kernel1 and patchedKernel:"
	@$(CROSS_COMPILE)nm -n $(TARGET1) > $(RESULTS_DIR)/kernel1.sym
	@$(CROSS_COMPILE)nm -n build/patchedKernel.img > $(RESULTS_DIR)/patchedKernel.sym || echo "Note: patched kernel may not have valid symbols"
	@diff $(RESULTS_DIR)/kernel1.sym $(RESULTS_DIR)/patchedKernel.sym > $(RESULTS_DIR)/patched_sym_diff.txt || true
	@echo "Symbol diff saved to $(RESULTS_DIR)/patched_sym_diff.txt"
	
	@echo "\nComparing binary content (hexdump):"
	@hexdump -C $(TARGET1) | head -50 > $(RESULTS_DIR)/kernel1.hex
	@hexdump -C build/patchedKernel.img | head -50 > $(RESULTS_DIR)/patchedKernel.hex
	@diff $(RESULTS_DIR)/kernel1.hex $(RESULTS_DIR)/patchedKernel.hex > $(RESULTS_DIR)/patched_hex_diff.txt || true
	@echo "Hexdump diff saved to $(RESULTS_DIR)/patched_hex_diff.txt"
	
	@echo "\nLooking for key and data differences in binary:"
	@echo "Key location (expecting differences around 0x14668):"
	@hexdump -C $(TARGET1) -s 0x14660 -n 64 > $(RESULTS_DIR)/kernel1_key.hex
	@hexdump -C build/patchedKernel.img -s 0x14660 -n 64 > $(RESULTS_DIR)/patchedKernel_key.hex
	@diff $(RESULTS_DIR)/kernel1_key.hex $(RESULTS_DIR)/patchedKernel_key.hex || true
	
	@echo "\nData location (expecting differences around 0x14C84):"
	@hexdump -C $(TARGET1) -s 0x14C80 -n 128 > $(RESULTS_DIR)/kernel1_data.hex
	@hexdump -C build/patchedKernel.img -s 0x14C80 -n 128 > $(RESULTS_DIR)/patchedKernel_data.hex
	@diff $(RESULTS_DIR)/kernel1_data.hex $(RESULTS_DIR)/patchedKernel_data.hex || true
	
	# Log file comparison section
	@echo "\n====== RUNTIME LOG COMPARISON ======\n"
	@echo "Checking for log files to compare..."
	
	@if [ ! -f "$(RESULTS_DIR)/kernel1.in_asm.log" ] || [ ! -f "$(RESULTS_DIR)/patchedKernel.in_asm.log" ]; then \
		echo "Note: Log files not found. Run these commands first to generate logs:"; \
		echo "  make log1"; \
		echo "  make logPatched"; \
		echo "Then run comparePatched again for full analysis."; \
	else \
		echo "✓ Log files found. Analyzing runtime behavior differences..."; \
		echo "\nExtracting critical sections from logs..."; \
		\
		grep -A 50 -B 50 "decrypt_memory" $(RESULTS_DIR)/kernel1.in_asm.log > $(RESULTS_DIR)/kernel1.decrypt.log || true; \
		grep -A 50 -B 50 "decrypt_memory" $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/patchedKernel.decrypt.log || true; \
		\
		grep "memory access" $(RESULTS_DIR)/kernel1.in_asm.log > $(RESULTS_DIR)/kernel1.mem_access.log || true; \
		grep "memory access" $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/patchedKernel.mem_access.log || true; \
		\
		grep -E "error|warning|fail" $(RESULTS_DIR)/kernel1.in_asm.log > $(RESULTS_DIR)/kernel1.errors.log || true; \
		grep -E "error|warning|fail" $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/patchedKernel.errors.log || true; \
		\
		echo "\nComparing decrypt function execution:"; \
		diff $(RESULTS_DIR)/kernel1.decrypt.log $(RESULTS_DIR)/patchedKernel.decrypt.log > $(RESULTS_DIR)/decrypt_diff.log || true; \
		if [ -s "$(RESULTS_DIR)/decrypt_diff.log" ]; then \
			echo "  Found differences in decrypt execution (see $(RESULTS_DIR)/decrypt_diff.log)"; \
			echo "  First 10 differences:"; \
			head -n 10 $(RESULTS_DIR)/decrypt_diff.log; \
		else \
			echo "  No differences found in decrypt execution."; \
		fi; \
		\
		echo "\nComparing memory access patterns:"; \
		diff $(RESULTS_DIR)/kernel1.mem_access.log $(RESULTS_DIR)/patchedKernel.mem_access.log > $(RESULTS_DIR)/mem_access_diff.log || true; \
		if [ -s "$(RESULTS_DIR)/mem_access_diff.log" ]; then \
			echo "  Found differences in memory access patterns (see $(RESULTS_DIR)/mem_access_diff.log)"; \
			echo "  Number of differences: `wc -l < $(RESULTS_DIR)/mem_access_diff.log`"; \
		else \
			echo "  No differences found in memory access patterns."; \
		fi; \
		\
		echo "\nComparing error/warning messages:"; \
		diff $(RESULTS_DIR)/kernel1.errors.log $(RESULTS_DIR)/patchedKernel.errors.log > $(RESULTS_DIR)/errors_diff.log || true; \
		if [ -s "$(RESULTS_DIR)/errors_diff.log" ]; then \
			echo "  Found differences in error/warning messages (see $(RESULTS_DIR)/errors_diff.log)"; \
			cat $(RESULTS_DIR)/errors_diff.log; \
		else \
			echo "  No differences found in error/warning messages."; \
		fi; \
		\
		echo "\nCreating full log diff summary:"; \
		diff --brief $(RESULTS_DIR)/kernel1.in_asm.log $(RESULTS_DIR)/patchedKernel.in_asm.log > /dev/null; \
		if [ $$? -eq 0 ]; then \
			echo "  ✓ Log files are identical - execution behavior unchanged"; \
		else \
			echo "  ✗ Log files differ - execution behavior changed"; \
			diff $(RESULTS_DIR)/kernel1.in_asm.log $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/full_log_diff.log || true; \
			echo "  Full log diff saved to $(RESULTS_DIR)/full_log_diff.log"; \
			echo "  Number of differences in full log: `wc -l < $(RESULTS_DIR)/full_log_diff.log`"; \
		fi; \
	fi
	
	@echo "\n====== COMPARISON COMPLETE ======\n"
	@echo "All results saved in $(RESULTS_DIR)/"
# Add this new target
# Compare log files between kernel1 and patchedKernel
compareLog: 
	@mkdir -p $(RESULTS_DIR)
	@echo "Comparing log files between kernel1 and patchedKernel..."
	
	@if [ ! -f "$(RESULTS_DIR)/kernel1.in_asm.log" ]; then \
		echo "Warning: kernel1.in_asm.log not found. Run 'make log1' first."; \
		exit 1; \
	fi
	
	@if [ ! -f "$(RESULTS_DIR)/patchedKernel.in_asm.log" ]; then \
		echo "Warning: patchedKernel.in_asm.log not found. Run 'make logPatched' first."; \
		exit 1; \
	fi
	
	@echo "Extracting critical sections from logs..."
	
	# Extract instruction execution around the decryption code
	@grep -A 50 -B 50 "decrypt_memory" $(RESULTS_DIR)/kernel1.in_asm.log > $(RESULTS_DIR)/kernel1.decrypt.log || true
	@grep -A 50 -B 50 "decrypt_memory" $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/patchedKernel.decrypt.log || true
	
	# Extract memory access patterns
	@grep "memory access" $(RESULTS_DIR)/kernel1.in_asm.log > $(RESULTS_DIR)/kernel1.mem_access.log || true
	@grep "memory access" $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/patchedKernel.mem_access.log || true
	
	# Extract any errors or warnings
	@grep -E "error|warning|fail" $(RESULTS_DIR)/kernel1.in_asm.log > $(RESULTS_DIR)/kernel1.errors.log || true
	@grep -E "error|warning|fail" $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/patchedKernel.errors.log || true
	
	# Look for differences in execution flow
	@echo "\nComparing decrypt function execution..."
	@diff $(RESULTS_DIR)/kernel1.decrypt.log $(RESULTS_DIR)/patchedKernel.decrypt.log > $(RESULTS_DIR)/decrypt_diff.log || true
	@if [ -s "$(RESULTS_DIR)/decrypt_diff.log" ]; then \
		echo "  Found differences in decrypt execution (see $(RESULTS_DIR)/decrypt_diff.log)"; \
		echo "  First 10 differences:"; \
		head -n 10 $(RESULTS_DIR)/decrypt_diff.log; \
	else \
		echo "  No differences found in decrypt execution."; \
	fi
	
	@echo "\nComparing memory access patterns..."
	@diff $(RESULTS_DIR)/kernel1.mem_access.log $(RESULTS_DIR)/patchedKernel.mem_access.log > $(RESULTS_DIR)/mem_access_diff.log || true
	@if [ -s "$(RESULTS_DIR)/mem_access_diff.log" ]; then \
		echo "  Found differences in memory access patterns (see $(RESULTS_DIR)/mem_access_diff.log)"; \
		echo "  Number of differences: `wc -l < $(RESULTS_DIR)/mem_access_diff.log`"; \
	else \
		echo "  No differences found in memory access patterns."; \
	fi
	
	@echo "\nComparing error/warning messages..."
	@diff $(RESULTS_DIR)/kernel1.errors.log $(RESULTS_DIR)/patchedKernel.errors.log > $(RESULTS_DIR)/errors_diff.log || true
	@if [ -s "$(RESULTS_DIR)/errors_diff.log" ]; then \
		echo "  Found differences in error/warning messages (see $(RESULTS_DIR)/errors_diff.log)"; \
		cat $(RESULTS_DIR)/errors_diff.log; \
	else \
		echo "  No differences found in error/warning messages."; \
	fi
	
	# Create a full diff of the logs for reference
	@echo "\nCreating full log diff (this may be very large)..."
	@diff $(RESULTS_DIR)/kernel1.in_asm.log $(RESULTS_DIR)/patchedKernel.in_asm.log > $(RESULTS_DIR)/full_log_diff.log || true
	@echo "Full log diff saved to $(RESULTS_DIR)/full_log_diff.log"
	@echo "Number of differences in full log: `wc -l < $(RESULTS_DIR)/full_log_diff.log`"
	
	@echo "\nLog comparison complete. Results saved in $(RESULTS_DIR)/"
# # Also add this to the mapmem target to include the patched kernel
# mapmem: $(TARGET1_ELF) $(TARGET2_ELF)
# 	@mkdir -p $(RESULTS_DIR)
# 	$(CROSS_COMPILE)nm -n $(TARGET1_ELF) > $(RESULTS_DIR)/kernel1.map
# 	$(CROSS_COMPILE)nm -n $(TARGET2_ELF) > $(RESULTS_DIR)/kernel2.map
# 	$(CROSS_COMPILE)readelf -S $(TARGET1_ELF) > $(RESULTS_DIR)/kernel1.sections
# 	$(CROSS_COMPILE)readelf -S $(TARGET2_ELF) > $(RESULTS_DIR)/kernel2.sections
# 	@if [ -f "build/patchedKernel.img" ]; then \
# 		echo "Generating memory map for patchedKernel.img"; \
# 		$(CROSS_COMPILE)readelf -a build/patchedKernel.img > $(RESULTS_DIR)/patchedKernel.sections 2>/dev/null || \
# 		echo "Note: readelf may fail on binary-only patched kernel"; \
# 		hexdump -C build/patchedKernel.img | head -100 > $(RESULTS_DIR)/patchedKernel.hexdump; \
# 	fi
# 	@echo "Memory maps generated in $(RESULTS_DIR)"

# Generate memory map for analysis
mapmem: $(TARGET1_ELF) $(TARGET2_ELF)
	@mkdir -p $(RESULTS_DIR)
	$(CROSS_COMPILE)nm -n $(TARGET1_ELF) > $(RESULTS_DIR)/kernel1.map
	$(CROSS_COMPILE)nm -n $(TARGET2_ELF) > $(RESULTS_DIR)/kernel2.map
	$(CROSS_COMPILE)readelf -S $(TARGET1_ELF) > $(RESULTS_DIR)/kernel1.sections
	$(CROSS_COMPILE)readelf -S $(TARGET2_ELF) > $(RESULTS_DIR)/kernel2.sections
	@echo "Memory maps generated in $(RESULTS_DIR)"

# # Useful commands
# # pkill qemu-system-arm
# # (gdb) break main.c:10 # Break at line 10
# Add these variables to your flags section
ASM_CFLAGS = $(CFLAGS) -S -fverbose-asm

# Add these targets to your Makefile

# Create assembly output for all source files
asm: $(SRCS) $(COMMON_SRCS) $(MAINPROC_SRC) $(MAIN1_SRC) $(MAIN2_SRC)
	@mkdir -p $(ASM_OUTPUT_DIR)
	@mkdir -p $(ASM_OUTPUT_DIR)/common
	@for src in $(SRCS); do \
		base=$$(basename $$src .c); \
		out=$(ASM_OUTPUT_DIR)/$$base.s; \
		echo "Generating $$out"; \
		$(CC) $(ASM_CFLAGS) -o $$out $$src; \
	done
	@for src in $(COMMON_SRCS); do \
		base=$$(basename $$src .c); \
		out=$(ASM_OUTPUT_DIR)/common/$$base.s; \
		echo "Generating $$out"; \
		$(CC) $(ASM_CFLAGS) -o $$out $$src; \
	done
	@echo "Generating assembly for mainproc.c"
	@$(CC) $(ASM_CFLAGS) -o $(ASM_OUTPUT_DIR)/mainproc.s $(MAINPROC_SRC)
	@echo "Generating assembly for main.1.c"
	@$(CC) $(ASM_CFLAGS) -o $(ASM_OUTPUT_DIR)/main.1.s $(MAIN1_SRC)
	@echo "Generating assembly for main.2.c"
	@$(CC) $(ASM_CFLAGS) -o $(ASM_OUTPUT_DIR)/main.2.s $(MAIN2_SRC)
	@echo "Assembly output generated in $(ASM_OUTPUT_DIR)"
	@echo "Comparing assembly between $(FILE1) and $(FILE2)..."
	@diff -u $(ASM_OUTPUT_DIR)/main.1.s $(ASM_OUTPUT_DIR)/main.2.s > $(RESULTS_DIR)/$(FILE1)_vs_$(FILE2).diff || true
	@echo "Diff saved to $(RESULTS_DIR)/$(FILE1)_vs_$(FILE2).diff"
# Build both kernels from assembly output
build-asm:
	@mkdir -p $(BUILD_DIR) $(BUILD_COMMON_DIR)
	
	@# Assemble common .s files
	@for src in $(ASM_OUTPUT_DIR)/common/*.s; do \
		base=$$(basename $$src .s); \
		out=$(BUILD_COMMON_DIR)/$$base.o; \
		echo "Assembling $$src to $$out"; \
		$(AS) $(ASFLAGS) $$src -o $$out; \
	done
	
	@# Assemble start.s if it exists
	@if [ -f "$(SRC_DIR)/start.s" ]; then \
		echo "Assembling $(SRC_DIR)/start.s to $(BUILD_DIR)/start.o"; \
		$(AS) $(ASFLAGS) $(SRC_DIR)/start.s -o $(BUILD_DIR)/start.o; \
	fi
	
	@# Assemble all other .s files, excluding main.1.s and main.2.s
	@for src in $(ASM_OUTPUT_DIR)/*.s; do \
		if [ -f "$$src" ]; then \
			base=$$(basename $$src .s); \
			if [ "$$base" != "main.1" ] && [ "$$base" != "main.2" ]; then \
				out=$(BUILD_DIR)/$$base.o; \
				echo "Assembling $$src to $$out"; \
				$(AS) $(ASFLAGS) $$src -o $$out; \
			fi \
		fi \
	done
	
	@# Build kernel1
	@if [ -f "$(ASM_OUTPUT_DIR)/main.1.s" ]; then \
		echo "Assembling $(ASM_OUTPUT_DIR)/main.1.s to $(BUILD_DIR)/main1.o"; \
		$(AS) $(ASFLAGS) $(ASM_OUTPUT_DIR)/main.1.s -o $(BUILD_DIR)/main1.o; \
		echo "Building kernel1"; \
		$(CC) $(LDFLAGS) $(BUILD_DIR)/*.o $(BUILD_COMMON_DIR)/*.o -o $(TARGET1_ELF); \
		$(OBJCOPY) -O binary $(TARGET1_ELF) $(TARGET1); \
	else \
		echo "Warning: main.1.s not found, skipping kernel1 build"; \
	fi
	
	@# Build kernel2
	@if [ -f "$(ASM_OUTPUT_DIR)/main.2.s" ]; then \
		echo "Assembling $(ASM_OUTPUT_DIR)/main.2.s to $(BUILD_DIR)/main2.o"; \
		$(AS) $(ASFLAGS) $(ASM_OUTPUT_DIR)/main.2.s -o $(BUILD_DIR)/main2.o; \
		echo "Building kernel2"; \
		mv $(BUILD_DIR)/main1.o $(BUILD_DIR)/main1.o.bak || true; \
		$(CC) $(LDFLAGS) $(BUILD_DIR)/*.o $(BUILD_COMMON_DIR)/*.o -o $(TARGET2_ELF); \
		mv $(BUILD_DIR)/main1.o.bak $(BUILD_DIR)/main1.o || true; \
		$(OBJCOPY) -O binary $(TARGET2_ELF) $(TARGET2); \
	else \
		echo "Warning: main.2.s not found, skipping kernel2 build"; \
	fi
	
	@echo "Build from assembly complete"