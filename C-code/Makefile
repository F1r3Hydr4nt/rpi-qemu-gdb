# Define the compiler and compiler flags
CC = gcc
CFLAGS = -Wall -Wextra -g

# List of source files
SRCS = main.c \
       adler32.c crc32.c inffast.c inftrees.c trees.c deflate.c inflate.c zutil.c zpipe.c \
       sha1.c sha256.c

# List of header files
HDRS = sboxes.h sha1.h sha256.h zlib.h

# Object files
OBJS = $(SRCS:%.c=build/%.o)

# Output executable
TARGET = main

# Default target
all: build $(TARGET)

# Create the build directory
build:
	mkdir -p build

# Link the object files to create the final executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Compile each source file into an object file
build/%.o: %.c $(HDRS)
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up the build directory
clean:
	rm -rf build $(TARGET)

# PHONY targets to avoid conflicts with files of the same name
.PHONY: all clean build