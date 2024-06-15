#ifndef MMU_H
#define MMU_H

#define PAGE_SIZE 0x1000
#define STACK_SIZE 0x1000
#define GUARD_PAGE 1

extern unsigned long page_table[];
extern char _stack_bottom, _stack_top;

void init_page_table();
void setup_stack_guard();
void enable_mmu();

#endif // MMU_H
