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