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
BUILD_COMMON_DIR = $(BUILD_DIR)/common

# Source files (common first)
COMMON_SRCS = $(wildcard $(COMMON_DIR)/*.c)
SRCS = $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS = $(SRC_DIR)/start.s

# Object files (common first)
COMMON_OBJS = $(COMMON_SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
ASM_OBJS = $(ASM_SRCS:$(SRC_DIR)/%.s=$(BUILD_DIR)/%.o)

# Include paths
INCLUDES = -I$(SRC_DIR) -I$(COMMON_DIR)

# Flags
CFLAGS = -mcpu=cortex-a7 -fpic -ffreestanding -O2 -Wall -Wextra -g $(INCLUDES)
ASFLAGS = -mcpu=cortex-a7
LDFLAGS = -T $(SRC_DIR)/linker.ld -ffreestanding -O2 -nostdlib

# Output
# Add these modifications to your existing Makefile

# Add TEST_NUM parameter (defaults to empty)
TEST_NUM ?= 

# Modify the TARGET line to include the test number if provided
ifeq ($(TEST_NUM),)
TARGET = $(BUILD_DIR)/kernel.img
else
TARGET = $(BUILD_DIR)/kernel$(TEST_NUM).img
endif

# You'll want to update the KERNEL line to match the new TARGET
KERNEL ?= $(TARGET)
.PHONY: all clean run debug gdb

all: $(TARGET)

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

$(TARGET): $(COMMON_OBJS) $(OBJS) $(ASM_OBJS)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET) -nographic -serial mon:stdio

# Modified log target that correctly handles paths
log: $(TARGET)
	@mkdir -p results
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET) -d int,guest_errors,mmu,in_asm -D results/kernel$(TEST_NUM).in_asm.log -nographic -serial mon:stdio

debug: $(TARGET)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET) -nographic -serial mon:stdio -s -S

gdb:
	gdb-multiarch $(TARGET) -x script.gdb
# Target to run patched kernel
runpatch: 
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -nographic -serial mon:stdio

# Target to run patched kernel with logging
logpatch:
	@mkdir -p results
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -d int,guest_errors,mmu,in_asm -D results/kernel2.patched.in_asm.log -nographic -serial mon:stdio

# Target to debug patched kernel
debugpatch:
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel results/kernel2.img.patched -nographic -serial mon:stdio -s -S

# Add this new command
# run-custom: 
# 	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(KERNEL) -nographic -serial mon:stdio
# make run-custom KERNEL=kernel.bad.img

# Useful commands
# pkill qemu-system-arm
# (gdb) break main.c:10 # Break at line 10