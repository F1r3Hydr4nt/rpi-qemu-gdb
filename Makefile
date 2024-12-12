CROSS_COMPILE = aarch64-linux-gnu-
CFLAGS = -O0 -Wall -nostdlib -nostartfiles -ffreestanding -g -gdwarf-4

# Directories
SRC_DIR = src
COMMON_DIR = common
BUILD_DIR = build
BUILD_COMMON_DIR = $(BUILD_DIR)/common

# Create build directories if they don't exist
$(shell mkdir -p $(BUILD_DIR) $(BUILD_COMMON_DIR))

# Include paths
INCLUDES = -I$(SRC_DIR) -I$(COMMON_DIR)

# Source files from both directories
COMMON_SRCS = $(wildcard $(COMMON_DIR)/*.c)
SRC_SRCS = $(wildcard $(SRC_DIR)/*.c)

# Object files with proper paths
COMMON_OBJS = $(COMMON_SRCS:$(COMMON_DIR)/%.c=$(BUILD_COMMON_DIR)/%.o)
SRC_OBJS = $(SRC_SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
OBJS = $(COMMON_OBJS) $(SRC_OBJS)

# Header files from both directories
COMMON_HDRS = $(wildcard $(COMMON_DIR)/*.h)
SRC_HDRS = $(wildcard $(SRC_DIR)/*.h)

# Other files
BOOT_SRC = $(SRC_DIR)/boot.S
LD_SCRIPT = $(SRC_DIR)/linker.ld
BOOT_OBJ = $(BUILD_DIR)/boot.o
KERNEL_ELF = $(BUILD_DIR)/kernel8.elf
KERNEL_IMG = $(BUILD_DIR)/kernel8.img

# Generate dependency files
DEPS = $(OBJS:.o=.d)

all: $(KERNEL_IMG)

clean:
	rm -rf $(BUILD_DIR)

debug:
	qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -serial mon:stdio -nographic -s -S -d in_asm,cpu_reset -m 1024M

debug2:
	qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -serial mon:stdio -nographic -s -S -m 1024M

run:
	@echo "Type 'CTRL-A, x' to quit\n"
	qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -serial mon:stdio -nographic -m 1024M

gdb:
	gdb-multiarch build/kernel8.elf -ex "target remote localhost:1234" -ex "break *_start" -ex "continue"

# Include dependency files
-include $(DEPS)

# Compile boot.S
$(BUILD_DIR)/boot.o: $(BOOT_SRC)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@

# Compile common directory sources
$(BUILD_COMMON_DIR)/%.o: $(COMMON_DIR)/%.c
	$(CROSS_COMPILE)gcc $(CFLAGS) $(INCLUDES) -MMD -MP -c $< -o $@

# Compile src directory sources
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CROSS_COMPILE)gcc $(CFLAGS) $(INCLUDES) -MMD -MP -c $< -o $@

$(KERNEL_ELF): $(BOOT_OBJ) $(COMMON_OBJS) $(SRC_OBJS)
	$(CROSS_COMPILE)ld -T $(LD_SCRIPT) $^ -o $@

$(KERNEL_IMG): $(KERNEL_ELF)
	$(CROSS_COMPILE)objcopy $< -O binary $@

.PHONY: all clean debug debug2 run gdb
