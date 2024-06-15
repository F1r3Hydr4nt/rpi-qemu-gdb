#include "mem.h"

// Define the heap size
#define HEAP_SIZE 1024 * 1024 // 1 MB heap

// Allocate the heap
static unsigned char heap[HEAP_SIZE];
static size_t heap_index = 0;

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

// Align size to multiple of alignment
static size_t align(size_t size, size_t alignment) {
    return (size + alignment - 1) & ~(alignment - 1);
}

// Memory allocation function
void *malloc(size_t size) {
    size = align(size, sizeof(void*)); // Align size to sizeof(void*)

    if (heap_index + size > HEAP_SIZE) {
        return NULL;  // Not enough memory
    }

    void *ptr = &heap[heap_index];
    heap_index += size;
    return ptr;
}

void free(void *ptr) {
    // No-op in this simple allocator
    (void)ptr; // Suppress unused parameter warning
}
