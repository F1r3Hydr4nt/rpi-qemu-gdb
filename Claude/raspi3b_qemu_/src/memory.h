#ifndef MEMORY_H
#define MEMORY_H
#include <stddef.h>
#include <stdint.h>

// Standard memory functions
void* malloc(size_t size);
void free(void* ptr);

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
int open(const char *pathname, int flags, ...);
char *strchr(const char *s, int c);
/* String comparison */
int strcmp(const char *s1, const char *s2);

/* String duplication for xstrdup */
char *strdup(const char *s);
#endif // MEMORY_H