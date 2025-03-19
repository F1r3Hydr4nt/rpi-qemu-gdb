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
CFLAGS = -mcpu=cortex-a7 -fpic -ffreestanding -O2 -Wall -Wextra -g $(INCLUDES)
ASFLAGS = -mcpu=cortex-a7
LDFLAGS = -T $(SRC_DIR)/linker.ld -ffreestanding -O2 -nostdlib

# Define targets for each version
TARGET1 = $(BUILD_DIR)/kernel1.img
TARGET2 = $(BUILD_DIR)/kernel2.img

.PHONY: all clean run1 run2 debug1 debug2 gdb1 gdb2 compare

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

clean:
	rm -rf $(BUILD_DIR)

# Run targets for each version
run1: $(TARGET1)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET1) -nographic -serial mon:stdio

run2: $(TARGET2)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET2) -nographic -serial mon:stdio

# Log targets for each version
log1: $(TARGET1)
	@mkdir -p $(RESULTS_DIR)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET1) -d int,guest_errors,mmu,in_asm -D $(RESULTS_DIR)/kernel1.in_asm.log -nographic -serial mon:stdio

log2: $(TARGET2)
	@mkdir -p $(RESULTS_DIR)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET2) -d int,guest_errors,mmu,in_asm -D $(RESULTS_DIR)/kernel2.in_asm.log -nographic -serial mon:stdio

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

# # Target to run patched kernel
# runpatch: 
# 	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -nographic -serial mon:stdio

# # Target to run patched kernel with logging
# logpatch:
# 	@mkdir -p results
# 	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -d int,guest_errors,mmu,in_asm -D results/kernel2.patched.in_asm.log -nographic -serial mon:stdio

# # Target to debug patched kernel
# debugpatch:
# 	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -nographic -serial mon:stdio -s -S

# # Add this new command
# # run-custom: 
# # 	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(KERNEL) -nographic -serial mon:stdio
# # make run-custom KERNEL=kernel.bad.img

# # Useful commands
# # pkill qemu-system-arm
# # (gdb) break main.c:10 # Break at line 10


# # Add targets to generate assembly output
# asm-output: $(SRCS) $(COMMON_SRCS)
# 	@mkdir -p $(ASM_OUTPUT_DIR)
# 	@mkdir -p $(ASM_OUTPUT_DIR)/common
# 	@for src in $(SRCS); do \
# 		out=$$(echo $$src | sed 's|$(SRC_DIR)/|$(ASM_OUTPUT_DIR)/|' | sed 's|\.c$$|\.s|'); \
# 		echo "Generating $$out"; \
# 		$(CC) $(ASM_CFLAGS) -o $$out $$src; \
# 	done
# 	@for src in $(COMMON_SRCS); do \
# 		out=$$(echo $$src | sed 's|$(SRC_DIR)/|$(ASM_OUTPUT_DIR)/|' | sed 's|\.c$$|\.s|'); \
# 		echo "Generating $$out"; \
# 		$(CC) $(ASM_CFLAGS) -o $$out $$src; \
# 	done

# # Add a target to compare assembly of two kernels
# diff-asm: 
# 	@mkdir -p results
# 	@if [ -z "$(TEST1)" ] || [ -z "$(TEST2)" ]; then \
# 		echo "Usage: make diff-asm TEST1=1 TEST2=2"; \
# 		exit 1; \
# 	fi
# 	@echo "Comparing assembly output between test $(TEST1) and test $(TEST2)..."
# 	@for file in $$(find $(ASM_OUTPUT_DIR) -name "*.s" | grep -v start.s); do \
# 		diff -u $$file $$file || true; \
# 	done > results/asm_diff.txt
# 	@echo "Diff saved to results/asm_diff.txt"

# # Add test build targets with debug flags
# test-debug-1:
# 	@mkdir -p $(BUILD_DIR)
# 	$(MAKE) clean
# 	$(MAKE) DEBUG=1 TEST_NUM=1

# test-debug-2:
# 	@mkdir -p $(BUILD_DIR)
# 	$(MAKE) clean
# 	$(MAKE) DEBUG=1 TEST_NUM=2

# # Build both tests with debugging for comparison
# build-both-debug: test-debug-1 test-debug-2
# 	@echo "Both test kernels built with debugging flags"

# # Generate assembly for both and compare
# compare-asm: build-both-debug asm-output diff-asm
# 	@echo "Assembly comparison complete"

# # Target to disassemble built binaries
# disassemble:
# 	@mkdir -p results
# 	$(CROSS_COMPILE)objdump -d $(BUILD_DIR)/kernel1.img > results/kernel1.disasm
# 	$(CROSS_COMPILE)objdump -d $(BUILD_DIR)/kernel2.img > results/kernel2.disasm
# 	diff -u results/kernel1.disasm results/kernel2.disasm > results/disasm_diff.txt
# 	@echo "Disassembly and diff saved to results directory"

# # Add QEMU trace analysis helper
# analyze-traces:
# 	@mkdir -p results
# 	@if [ -z "$(TEST1)" ] || [ -z "$(TEST2)" ]; then \
# 		echo "Usage: make analyze-traces TEST1=1 TEST2=2"; \
# 		exit 1; \
# 	fi
# 	@echo "Extracting key sections from QEMU traces..."
# 	@grep -A 20 -B 20 "decrypt" results/kernel$(TEST1).in_asm.log > results/kernel$(TEST1).decrypt.log
# 	@grep -A 20 -B 20 "decrypt" results/kernel$(TEST2).in_asm.log > results/kernel$(TEST2).decrypt.log
# 	@echo "Comparing decrypt sections..."
# 	@diff -u results/kernel$(TEST1).decrypt.log results/kernel$(TEST2).decrypt.log > results/decrypt_diff.txt
# 	@echo "Analysis complete. Check results/decrypt_diff.txt"
