#include "memory.h"
#include "printf.h"

// Memory allocator definitions
// #define HEAP_SIZE (64 * 1024)  // 64KB heap
#define HEAP_SIZE (128 * 1024)  // Increase to 128KB or larger
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

// x* memory functions implementation
void* xmalloc(size_t n) {
    void* ptr;

    /* Handle zero allocation */
    if (n == 0)
        n = 1;  /* Always allocate at least 1 byte */
        
    ptr = malloc(n);
    
    /* Check for allocation failure */
    if (!ptr) {
        printf("xmalloc failed to allocate %zu bytes\n", n);
        return NULL;// abort(); /* In GnuPG we abort on allocation failure */
    }
    
    /* Zero out allocated memory */
    memset(ptr, 0, n);
    
    return ptr;
}

void* xmalloc_clear(size_t n) {
    void* ptr = malloc(n);
    if (ptr) {
        memset(ptr, 0, n);
    } else if (n != 0) {
        // Handle allocation failure similar to xmalloc
    }
    return ptr;
}

void* xcalloc(size_t n, size_t m) {
    size_t total;
    void* ptr;
    
    // Check for multiplication overflow
    if (n && m > SIZE_MAX / n) {
        return NULL;
    }
    
    total = n * m;
    ptr = malloc(total);
    
    if (ptr) {
        memset(ptr, 0, total);
    }
    
    return ptr;
}

void xfree(void* p) {
    if (p) {
        free(p);
    }
}

void* xrealloc(void* p, size_t n) {
    void* new_ptr;
    
    if (!p) {
        return malloc(n);
    }
    
    if (n == 0) {
        free(p);
        return NULL;
    }
    
    // Get original block header
    block_header_t* header = (block_header_t*)((uint8_t*)p - sizeof(block_header_t));
    size_t old_size = header->size - sizeof(block_header_t);
    
    // If new size fits in existing block, just return original pointer
    if (n <= old_size) {
        return p;
    }
    
    // Allocate new block
    new_ptr = malloc(n);
    if (!new_ptr) {
        return NULL;
    }
    
    // Copy old data
    memcpy(new_ptr, p, old_size);
    free(p);
    
    return new_ptr;
}

void* memset(void* dest, int c, size_t n) {
    unsigned char* p = dest;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return dest;
}

void* memcpy(void* dest, const void* src, size_t n) {
    unsigned char* d = dest;
    const unsigned char* s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

void* memmove(void* dest, const void* src, size_t n) {
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;
    // If dest is after src, copy from end to start to avoid overwriting source
    if (d > s && d < s + n) {
        d += n;
        s += n;
        while (n--) {
            *--d = *--s;
        }
    } else {
        // Otherwise copy from start to end
        while (n--) {
            *d++ = *s++;
        }
    }
    return dest;
}

void wipememory(void *ptr, size_t len) {
    volatile char *p = (volatile char *)ptr;
    while (len--)
        *p++ = 0;
}

void strcpy(char *dest, const char *src) {
    while ((*dest++ = *src++) != '\0');
}

void *xtrycalloc(size_t nmemb, size_t size) {
    // Check for multiplication overflow
    if (nmemb && size && (nmemb * size) / nmemb != size) {
        return NULL;
    }
    
    size_t total = nmemb * size;
    void *ptr = malloc(total);
    
    if (ptr) {
        memset(ptr, 0, total);
    }
    
    return ptr;
}

/* Bare metal file operations - these are stub implementations */
int open(const char *pathname, int flags, ...) {
    // In bare metal, we might want to return a special file descriptor
    // for specific known files or devices
    if (strcmp(pathname, "stdout") == 0) return 1;
    if (strcmp(pathname, "stdin") == 0) return 0;
    return -1; // Fail for all other files
}

/* Find character in string */
char *strchr(const char *s, int c) {
    while (*s != (char)c) {
        if (!*s++)
            return NULL;
    }
    return (char *)s;
}

/* String comparison */
int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

/* String duplication for xstrdup */
char *strdup(const char *s) {
    size_t len = strlen(s) + 1;
    char *new = malloc(len);
    if (new) {
        memcpy(new, s, len);
    }
    return new;
}

/* Secure strdup implementation */
char *xstrdup(const char *string) {
    char *p = strdup(string);
    if (!p) {
        // In bare metal, we can't really recover from out of memory
        while(1); // Hang
    }
    return p;
}