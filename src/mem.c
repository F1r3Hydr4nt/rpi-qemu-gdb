#include "mem.h"

#define HEAP_SIZE 1024 * 1024  // 1 MB heap size
static unsigned char heap[HEAP_SIZE];
static size_t heap_index = 0;

typedef struct Block {
    size_t size;
    struct Block *next;
} Block;

static Block *free_list = NULL;

void *memcpy(void *dest, const void *src, size_t n) {
    char *d = dest;
    const char *s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

void *malloc(size_t size) {
    // Align size to multiple of sizeof(Block)
    size = (size + sizeof(Block) - 1) & ~(sizeof(Block) - 1);

    Block **curr = &free_list;
    while (*curr) {
        if ((*curr)->size >= size) {
            Block *block = *curr;
            if (block->size >= size + sizeof(Block)) {
                // Split block
                Block *new_block = (Block *)((unsigned char *)block + sizeof(Block) + size);
                new_block->size = block->size - size - sizeof(Block);
                new_block->next = block->next;
                *curr = new_block;
            } else {
                // Remove block from free list
                *curr = block->next;
            }
            return (unsigned char *)block + sizeof(Block);
        }
        curr = &(*curr)->next;
    }

    if (heap_index + size + sizeof(Block) > HEAP_SIZE) {
        return NULL;  // Not enough memory
    }

    Block *block = (Block *)(heap + heap_index);
    block->size = size;
    heap_index += size + sizeof(Block);
    return (unsigned char *)block + sizeof(Block);
}

void free(void *ptr) {
    if (!ptr) return;

    Block *block = (Block *)((unsigned char *)ptr - sizeof(Block));
    block->next = free_list;
    free_list = block;
}