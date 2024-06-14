CROSS_COMPILE = aarch64-linux-gnu-
CFLAGS = -O2 -Wall -nostdlib -nostartfiles -ffreestanding -g

# Directories
SRC_DIR = src
BUILD_DIR = build

# Wildcard source files
SRCS = $(wildcard $(SRC_DIR)/*.c)
HDRS = $(wildcard $(SRC_DIR)/*.h)

# Object files
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Other files
BOOT_SRC = $(SRC_DIR)/boot.S
LD_SCRIPT = $(SRC_DIR)/linker.ld
BOOT_OBJ = $(BUILD_DIR)/boot.o
KERNEL_ELF = $(BUILD_DIR)/kernel8.elf
KERNEL_IMG = $(BUILD_DIR)/kernel8.img

all: $(KERNEL_IMG)

clean:
	rm -f $(BUILD_DIR)/*.o $(KERNEL_ELF) $(KERNEL_IMG)

debug:
	qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -serial mon:stdio -nographic -s -S -d in_asm,cpu_reset

run:
	@echo "Type 'CTRL-A, x' to quit\n"
	qemu-system-aarch64 -M raspi3b -kernel build/kernel8.img -serial mon:stdio -nographic

$(BUILD_DIR)/boot.o: $(BOOT_SRC)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(HDRS)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(BOOT_OBJ) $(OBJS)
	$(CROSS_COMPILE)ld -T $(LD_SCRIPT) $^ -o $@

$(KERNEL_IMG): $(KERNEL_ELF)
	$(CROSS_COMPILE)objcopy $< -O binary $@

.PHONY: all clean debug run