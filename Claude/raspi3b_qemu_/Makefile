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
TARGET = $(BUILD_DIR)/kernel.img

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

log: $(TARGET)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel kernel.good.img -d int,guest_errors,mmu,in_asm -D qemu.in_asm.good.log -nographic -serial mon:stdio

log2: $(TARGET)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel kernel.bad.img -d int,guest_errors,mmu,in_asm -D qemu.in_asm.bad.log -nographic -serial mon:stdio

debug: $(TARGET)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET) -nographic -serial mon:stdio -s -S

gdb:
	gdb-multiarch $(TARGET) -x script.gdb

# Useful commands
# pkill qemu-system-arm
# (gdb) break main.c:10 # Break at line 10