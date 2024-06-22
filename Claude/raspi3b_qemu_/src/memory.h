#ifndef MEMORY_H
#define MEMORY_H

#include <stddef.h>
#include <stdint.h>

static inline void* memset(void* dest, int c, size_t n) {
    unsigned char* p = dest;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return dest;
}

static inline void* memcpy(void* dest, const void* src, size_t n) {
    unsigned char* d = dest;
    const unsigned char* s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

#endif // MEMORY_H