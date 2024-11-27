#include "memory.h"

// Memory allocator definitions
#define HEAP_SIZE (64 * 1024)  // 64KB heap
#define BLOCK_SIZE 16          // Minimum block size
#define MAX_BLOCKS (HEAP_SIZE / BLOCK_SIZE)

// Block header structure
typedef struct block_header {
    size_t size;  // Size including header
    uint8_t is_free;
    struct block_header* next;
} block_header_t;

// Static heap
static uint8_t heap[HEAP_SIZE] __attribute__((aligned(8)));
static block_header_t* free_list = NULL;
static uint8_t heap_initialized = 0;

// Initialize heap
static void init_heap(void) {
    if (heap_initialized) return;
    
    free_list = (block_header_t*)heap;
    free_list->size = HEAP_SIZE;
    free_list->is_free = 1;
    free_list->next = NULL;
    
    heap_initialized = 1;
}

// Memory allocation
void* malloc(size_t size) {
    if (!heap_initialized) init_heap();
    if (size == 0) return NULL;
    
    // Align size to BLOCK_SIZE
    size = (size + sizeof(block_header_t) + (BLOCK_SIZE-1)) & ~(BLOCK_SIZE-1);
    
    block_header_t *curr = free_list;
    block_header_t *prev = NULL;
    
    // Find first fit
    while (curr) {
        if (curr->is_free && curr->size >= size) {
            // Split block if too large
            if (curr->size >= size + BLOCK_SIZE + sizeof(block_header_t)) {
                block_header_t* next = (block_header_t*)((uint8_t*)curr + size);
                next->size = curr->size - size;
                next->is_free = 1;
                next->next = curr->next;
                curr->size = size;
                curr->next = next;
            }
            
            curr->is_free = 0;
            return (void*)((uint8_t*)curr + sizeof(block_header_t));
        }
        prev = curr;
        curr = curr->next;
    }
    
    return NULL;  // No space found
}

// Memory deallocation
void free(void* ptr) {
    if (!ptr) return;
    
    block_header_t* header = (block_header_t*)((uint8_t*)ptr - sizeof(block_header_t));
    header->is_free = 1;
    
    // Coalesce with next block if free
    if (header->next && header->next->is_free) {
        header->size += header->next->size;
        header->next = header->next->next;
    }
    
    // Coalesce with previous block if free
    block_header_t* curr = free_list;
    while (curr && curr->next) {
        if (curr->is_free && (uint8_t*)curr + curr->size == (uint8_t*)header) {
            curr->size += header->size;
            curr->next = header->next;
            break;
        }
        curr = curr->next;
    }
}