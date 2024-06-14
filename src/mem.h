#ifndef MEM_H
#define MEM_H

#include <stddef.h>

void *memcpy(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);
void *malloc(size_t size);
void free(void *ptr);
void init_page_table();
void enable_mmu();
void setup_stack_guard();

#endif // MEM_H