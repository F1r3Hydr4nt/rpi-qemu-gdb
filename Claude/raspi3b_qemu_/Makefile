# Compiler and emulator
CROSS_COMPILE ?= arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
QEMU = qemu-system-arm

# Directories
SRC_DIR = src
BUILD_DIR = build

# Source files
SRCS = $(SRC_DIR)/main.c
ASM_SRCS = $(SRC_DIR)/start.s

# Object files
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
ASM_OBJS = $(ASM_SRCS:$(SRC_DIR)/%.s=$(BUILD_DIR)/%.o)

# Flags
CFLAGS = -mcpu=cortex-a7 -fpic -ffreestanding -O2 -Wall -Wextra
ASFLAGS = -mcpu=cortex-a7
LDFLAGS = -T $(SRC_DIR)/linker.ld -ffreestanding -O2 -nostdlib

# Output
TARGET = $(BUILD_DIR)/kernel.img

.PHONY: all clean run

all: $(TARGET)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(@D)
	$(AS) $(ASFLAGS) $< -o $@

$(TARGET): $(OBJS) $(ASM_OBJS)
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) $^ -o $@

clean:
	rm -rf $(BUILD_DIR)

run: $(TARGET)
	$(QEMU) -M versatilepb -cpu cortex-a7 -kernel $(TARGET) -nographic -serial mon:stdio