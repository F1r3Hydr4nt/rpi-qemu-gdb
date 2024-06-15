#ifndef MEM_H
#define MEM_H

#include <stddef.h>

// Memory functions
void *memcpy(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);

// Memory allocation functions
void *malloc(size_t size);
void free(void *ptr);

#endif // MEM_H
