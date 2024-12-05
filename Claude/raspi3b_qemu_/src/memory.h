#ifndef MEMORY_H
#define MEMORY_H
#include <stddef.h>
#include <stdint.h>

// Standard memory functions
void* malloc(size_t size);
void free(void* ptr);
void strcpy(char *dest, const char *src);

// x* memory functions
void* xmalloc(size_t n);
void* xmalloc_clear(size_t n);
void* xcalloc(size_t n, size_t m);
void xfree(void* p);
void* xrealloc(void* p, size_t n);
void* memset(void* dest, int c, size_t n);
void* memcpy(void* dest, const void* src, size_t n);
void* memmove(void* dest, const void* src, size_t n);

void *xtrycalloc(size_t nmemb, size_t size);
/* Secure memory wiping */
void wipememory(void *ptr, size_t len);

#endif // MEMORY_H