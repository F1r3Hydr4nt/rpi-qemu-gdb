#include <stdio.h>
#include <stddef.h>
#include "printf.h"

// Define the heap size
#define HEAP_SIZE 1024 * 1024 // 1 MB heap

// Allocate the heap
static unsigned char heap[HEAP_SIZE];
static size_t heap_index = 0;

// Align size to multiple of alignment
static size_t align(size_t size, size_t alignment) {
    return (size + alignment - 1) & ~(alignment - 1);
}

// Memory copy function
void *memcpy(void *dest, const void *src, size_t n) {
    char *d = dest;
    const char *s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

// Memory set function
void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

// Memory allocation function
void *malloc(size_t size) {
    size = align(size, sizeof(void*)); // Align size to sizeof(void*)

    if (heap_index + size > HEAP_SIZE) {
        printf("Memory allocation failed: Not enough memory\n");
        return NULL;  // Not enough memory
    }

    void *ptr = &heap[heap_index];
    heap_index += size;
    return ptr;
}

// Memory reallocation function
void *realloc(void *ptr, size_t size) {
    if (ptr == NULL) {
        return malloc(size);
    }

    size = align(size, sizeof(void*)); // Align size to sizeof(void*)

    if (heap_index + size > HEAP_SIZE) {
        printf("Memory reallocation failed: Not enough memory\n");
        return NULL;  // Not enough memory
    }

    void *new_ptr = &heap[heap_index];
    memcpy(new_ptr, ptr, size);
    heap_index += size;
    return new_ptr;
}

// Free function
void free(void *ptr) {
    // No-op in this simple allocator
    (void)ptr; // Suppress unused parameter warning
}

// Reset the heap (useful for testing purposes)
void reset_heap() {
    heap_index = 0;
}