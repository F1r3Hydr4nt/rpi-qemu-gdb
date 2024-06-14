CROSS_COMPILE = aarch64-linux-gnu-
CFLAGS = -O2 -Wall -nostdlib -nostartfiles -ffreestanding -g

# Directories
SRC_DIR = src
BUILD_DIR = build

# Files
BOOT_SRC = $(SRC_DIR)/boot.S
KERNEL_SRC = $(SRC_DIR)/kernel.c
LD_SCRIPT = $(SRC_DIR)/linker.ld

BOOT_OBJ = $(BUILD_DIR)/boot.o
KERNEL_OBJ = $(BUILD_DIR)/kernel.o
KERNEL_ELF = $(BUILD_DIR)/kernel8.elf
KERNEL_IMG = $(BUILD_DIR)/kernel8.img

all: $(KERNEL_IMG)

clean:
	rm -f $(BUILD_DIR)/*.o $(KERNEL_ELF) $(KERNEL_IMG)

$(BUILD_DIR)/boot.o: $(BOOT_SRC)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.o: $(KERNEL_SRC)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(BOOT_OBJ) $(KERNEL_OBJ)
	$(CROSS_COMPILE)ld -T $(LD_SCRIPT) $^ -o $@

$(KERNEL_IMG): $(KERNEL_ELF)
	$(CROSS_COMPILE)objcopy $< -O binary $@