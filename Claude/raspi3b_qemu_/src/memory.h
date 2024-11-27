#ifndef MEMORY_H
#define MEMORY_H
#include <stddef.h>
#include <stdint.h>

// Standard memory functions
void* malloc(size_t size);
void free(void* ptr);

// x* memory functions
void* xmalloc(size_t n);
void* xcalloc(size_t n, size_t m);
void xfree(void* p);
void* xrealloc(void* p, size_t n);

inline void* memset(void* dest, int c, size_t n) {
    unsigned char* p = dest;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return dest;
}

inline void* memcpy(void* dest, const void* src, size_t n) {
    unsigned char* d = dest;
    const unsigned char* s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

inline void* memmove(void* dest, const void* src, size_t n) {
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

#endif // MEMORY_H