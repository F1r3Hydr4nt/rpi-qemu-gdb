	.cpu cortex-a7
	.eabi_attribute 20, 1	@ Tag_ABI_FP_denormal
	.eabi_attribute 21, 1	@ Tag_ABI_FP_exceptions
	.eabi_attribute 23, 3	@ Tag_ABI_FP_number_model
	.eabi_attribute 24, 1	@ Tag_ABI_align8_needed
	.eabi_attribute 25, 1	@ Tag_ABI_align8_preserved
	.eabi_attribute 26, 1	@ Tag_ABI_enum_size
	.eabi_attribute 30, 2	@ Tag_ABI_optimization_goals
	.eabi_attribute 34, 1	@ Tag_CPU_unaligned_access
	.eabi_attribute 18, 4	@ Tag_ABI_PCS_wchar_t
	.file	"memory.c"
@ GNU C17 (15:10.3-2021.07-4) version 10.3.1 20210621 (release) (arm-none-eabi)
@	compiled by GNU C version 11.2.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

@ GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
@ options passed:  -I src -I src/common -imultilib thumb/v7-a/nofp
@ -D__USES_INITFINI__ src/memory.c -mcpu=cortex-a7 -mfloat-abi=soft -marm
@ -mlibarch=armv7ve -march=armv7ve -auxbase-strip build/asm_output/memory.s
@ -g -O2 -Wall -Wextra -fpic -ffreestanding -ffunction-sections
@ -fdata-sections -fno-common -fverbose-asm
@ options enabled:  -faggressive-loop-optimizations -falign-functions
@ -falign-jumps -falign-labels -falign-loops -fallocation-dce
@ -fauto-inc-dec -fbranch-count-reg -fcaller-saves
@ -fcombine-stack-adjustments -fcompare-elim -fcprop-registers
@ -fcrossjumping -fcse-follow-jumps -fdata-sections -fdefer-pop
@ -fdelete-null-pointer-checks -fdevirtualize -fdevirtualize-speculatively
@ -fdwarf2-cfi-asm -fearly-inlining -feliminate-unused-debug-symbols
@ -feliminate-unused-debug-types -fexpensive-optimizations
@ -fforward-propagate -ffp-int-builtin-inexact -ffunction-cse
@ -ffunction-sections -fgcse -fgcse-lm -fgnu-unique
@ -fguess-branch-probability -fhoist-adjacent-loads -fident -fif-conversion
@ -fif-conversion2 -findirect-inlining -finline -finline-atomics
@ -finline-functions -finline-functions-called-once
@ -finline-small-functions -fipa-bit-cp -fipa-cp -fipa-icf
@ -fipa-icf-functions -fipa-icf-variables -fipa-profile -fipa-pure-const
@ -fipa-ra -fipa-reference -fipa-reference-addressable -fipa-sra
@ -fipa-stack-alignment -fipa-vrp -fira-hoist-pressure
@ -fira-share-save-slots -fira-share-spill-slots
@ -fisolate-erroneous-paths-dereference -fivopts -fkeep-static-consts
@ -fleading-underscore -flifetime-dse -flra-remat -fmath-errno
@ -fmerge-constants -fmerge-debug-strings -fmove-loop-invariants
@ -fomit-frame-pointer -foptimize-sibling-calls -foptimize-strlen
@ -fpartial-inlining -fpeephole -fpeephole2 -fpic -fplt
@ -fprefetch-loop-arrays -freg-struct-return -freorder-blocks
@ -freorder-functions -frerun-cse-after-loop
@ -fsched-critical-path-heuristic -fsched-dep-count-heuristic
@ -fsched-group-heuristic -fsched-interblock -fsched-last-insn-heuristic
@ -fsched-pressure -fsched-rank-heuristic -fsched-spec
@ -fsched-spec-insn-heuristic -fsched-stalled-insns-dep -fschedule-insns
@ -fschedule-insns2 -fsection-anchors -fsemantic-interposition
@ -fshow-column -fshrink-wrap -fshrink-wrap-separate -fsigned-zeros
@ -fsplit-ivs-in-unroller -fsplit-wide-types -fssa-backprop -fssa-phiopt
@ -fstdarg-opt -fstore-merging -fstrict-aliasing
@ -fstrict-volatile-bitfields -fsync-libcalls -fthread-jumps
@ -ftoplevel-reorder -ftrapping-math -ftree-bit-ccp -ftree-builtin-call-dce
@ -ftree-ccp -ftree-ch -ftree-coalesce-vars -ftree-copy-prop -ftree-cselim
@ -ftree-dce -ftree-dominator-opts -ftree-dse -ftree-forwprop -ftree-fre
@ -ftree-loop-if-convert -ftree-loop-im -ftree-loop-ivcanon
@ -ftree-loop-optimize -ftree-parallelize-loops= -ftree-phiprop -ftree-pre
@ -ftree-pta -ftree-reassoc -ftree-scev-cprop -ftree-sink -ftree-slsr
@ -ftree-sra -ftree-switch-conversion -ftree-tail-merge -ftree-ter
@ -ftree-vrp -funit-at-a-time -fvar-tracking -fvar-tracking-assignments
@ -fverbose-asm -fzero-initialized-in-bss -marm -mbe32 -mlittle-endian
@ -mpic-data-is-text-relative -msched-prolog -munaligned-access
@ -mvectorize-with-neon-quad -mword-relocations

	.text
.Ltext0:
	.cfi_sections	.debug_frame
	.section	.text.malloc,"ax",%progbits
	.align	2
	.global	malloc
	.arch armv7ve
	.syntax unified
	.arm
	.fpu softvfp
	.type	malloc, %function
malloc:
.LVL0:
.LFB2:
	.file 1 "src/memory.c"
	.loc 1 35 27 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 36 5 view .LVU1
@ src/memory.c:36:     if (!heap_initialized) init_heap();
	.loc 1 36 9 is_stmt 0 view .LVU2
	ldr	r1, .L30	@ tmp128,
.LPIC1:
	add	r1, pc, r1	@ tmp128, tmp128
@ src/memory.c:36:     if (!heap_initialized) init_heap();
	.loc 1 36 8 view .LVU3
	ldrb	r2, [r1]	@ zero_extendqisi2	@ heap_initialized, heap_initialized
	cmp	r2, #0	@ heap_initialized,
	beq	.L28		@,
	.loc 1 37 5 is_stmt 1 view .LVU4
@ src/memory.c:37:     if (size == 0) return NULL;
	.loc 1 37 8 is_stmt 0 view .LVU5
	cmp	r0, #0	@ size,
	beq	.L3		@,
	.loc 1 40 5 is_stmt 1 view .LVU6
@ src/memory.c:42:     block_header_t *curr = free_list;
	.loc 1 42 21 is_stmt 0 view .LVU7
	ldr	r3, .L30+4	@ tmp146,
@ src/memory.c:40:     size = (size + sizeof(block_header_t) + (BLOCK_SIZE-1)) & ~(BLOCK_SIZE-1);
	.loc 1 40 43 view .LVU8
	add	r1, r0, #27	@ _2, size,
@ src/memory.c:40:     size = (size + sizeof(block_header_t) + (BLOCK_SIZE-1)) & ~(BLOCK_SIZE-1);
	.loc 1 40 10 view .LVU9
	bic	r1, r1, #15	@ size, _2,
.LVL1:
	.loc 1 42 5 is_stmt 1 view .LVU10
@ src/memory.c:42:     block_header_t *curr = free_list;
	.loc 1 42 21 is_stmt 0 view .LVU11
.LPIC8:
	add	r3, pc, r3	@ tmp146, tmp146
	ldr	r3, [r3]	@ curr, free_list
.LVL2:
	.loc 1 43 5 is_stmt 1 view .LVU12
	.loc 1 46 5 view .LVU13
	.loc 1 46 11 view .LVU14
	cmp	r3, #0	@ curr,
	beq	.L3		@,
.LVL3:
.L26:
@ src/memory.c:47:         if (curr->is_free && curr->size >= size) {
	.loc 1 47 17 is_stmt 0 view .LVU15
	ldrb	r2, [r3, #4]	@ zero_extendqisi2	@ prephitmp_5,
.LVL4:
.L8:
	.loc 1 47 9 is_stmt 1 view .LVU16
	.loc 1 61 9 view .LVU17
	.loc 1 62 9 view .LVU18
@ src/memory.c:47:         if (curr->is_free && curr->size >= size) {
	.loc 1 47 12 is_stmt 0 view .LVU19
	cmp	r2, #0	@ prephitmp_5,
	beq	.L5		@,
@ src/memory.c:47:         if (curr->is_free && curr->size >= size) {
	.loc 1 47 34 discriminator 1 view .LVU20
	ldr	r2, [r3]	@ _4, curr_29->size
@ src/memory.c:47:         if (curr->is_free && curr->size >= size) {
	.loc 1 47 27 discriminator 1 view .LVU21
	cmp	r2, r1	@ _4, size
	bcs	.L29		@,
.L5:
@ src/memory.c:62:         curr = curr->next;
	.loc 1 62 14 view .LVU22
	ldr	r3, [r3, #8]	@ curr, curr_29->next
.LVL5:
	.loc 1 46 11 is_stmt 1 view .LVU23
	cmp	r3, #0	@ curr,
	bne	.L26		@,
.LVL6:
.L3:
@ src/memory.c:37:     if (size == 0) return NULL;
	.loc 1 37 27 is_stmt 0 view .LVU24
	mov	r0, #0	@ <retval>,
@ src/memory.c:66: }
	.loc 1 66 1 view .LVU25
	bx	lr	@
.LVL7:
.L28:
	.loc 1 36 28 is_stmt 1 view .LVU26
.LBB5:
.LBI5:
	.loc 1 23 13 view .LVU27
.LBB6:
	.loc 1 24 5 view .LVU28
	.loc 1 26 5 view .LVU29
@ src/memory.c:26:     free_list = (block_header_t*)heap;
	.loc 1 26 15 is_stmt 0 view .LVU30
	ldr	r3, .L30+8	@ tmp133,
.LBE6:
.LBE5:
@ src/memory.c:37:     if (size == 0) return NULL;
	.loc 1 37 8 view .LVU31
	cmp	r0, #0	@ size,
.LBB10:
.LBB7:
@ src/memory.c:26:     free_list = (block_header_t*)heap;
	.loc 1 26 15 view .LVU32
	ldr	ip, .L30+12	@ tmp131,
.LPIC3:
	add	r3, pc, r3	@ tmp133, tmp133
.LPIC2:
	add	ip, pc, ip	@ tmp131, tmp131
@ src/memory.c:29:     free_list->next = NULL;
	.loc 1 29 21 view .LVU33
	str	r2, [r3, #8]	@ heap_initialized, MEM[(struct block_header_t *)&heap].next
@ src/memory.c:28:     free_list->is_free = 1;
	.loc 1 28 24 view .LVU34
	mov	r2, #1	@ tmp137,
@ src/memory.c:31:     heap_initialized = 1;
	.loc 1 31 22 view .LVU35
	strb	r2, [r1]	@ tmp137, heap_initialized
.LBE7:
.LBE10:
@ src/memory.c:40:     size = (size + sizeof(block_header_t) + (BLOCK_SIZE-1)) & ~(BLOCK_SIZE-1);
	.loc 1 40 43 view .LVU36
	addne	r1, r0, #27	@ _10, size,
.LBB11:
.LBB8:
@ src/memory.c:26:     free_list = (block_header_t*)heap;
	.loc 1 26 15 view .LVU37
	str	r3, [ip]	@ tmp133, free_list
	.loc 1 27 5 is_stmt 1 view .LVU38
@ src/memory.c:27:     free_list->size = HEAP_SIZE;
	.loc 1 27 21 is_stmt 0 view .LVU39
	mov	ip, #131072	@ tmp135,
.LBE8:
.LBE11:
@ src/memory.c:40:     size = (size + sizeof(block_header_t) + (BLOCK_SIZE-1)) & ~(BLOCK_SIZE-1);
	.loc 1 40 10 view .LVU40
	bicne	r1, r1, #15	@ size, _10,
.LBB12:
.LBB9:
@ src/memory.c:28:     free_list->is_free = 1;
	.loc 1 28 24 view .LVU41
	strb	r2, [r3, #4]	@ tmp137, MEM[(struct block_header_t *)&heap].is_free
@ src/memory.c:27:     free_list->size = HEAP_SIZE;
	.loc 1 27 21 view .LVU42
	str	ip, [r3]	@ tmp135, MEM[(struct block_header_t *)&heap].size
	.loc 1 28 5 is_stmt 1 view .LVU43
	.loc 1 29 5 view .LVU44
	.loc 1 31 5 view .LVU45
.LBE9:
.LBE12:
	.loc 1 37 5 view .LVU46
@ src/memory.c:37:     if (size == 0) return NULL;
	.loc 1 37 8 is_stmt 0 view .LVU47
	bne	.L8		@,
	b	.L3		@
.LVL8:
.L29:
	.loc 1 49 13 is_stmt 1 view .LVU48
@ src/memory.c:49:             if (curr->size >= size + BLOCK_SIZE + sizeof(block_header_t)) {
	.loc 1 49 49 is_stmt 0 view .LVU49
	add	r0, r1, #28	@ tmp147, size,
@ src/memory.c:49:             if (curr->size >= size + BLOCK_SIZE + sizeof(block_header_t)) {
	.loc 1 49 16 view .LVU50
	cmp	r2, r0	@ _4, tmp147
	bcc	.L6		@,
.LBB13:
	.loc 1 50 17 is_stmt 1 view .LVU51
@ src/memory.c:50:                 block_header_t* next = (block_header_t*)((uint8_t*)curr + size);
	.loc 1 50 33 is_stmt 0 view .LVU52
	add	r0, r3, r1	@ next, curr, size
.LVL9:
	.loc 1 51 17 is_stmt 1 view .LVU53
@ src/memory.c:51:                 next->size = curr->size - size;
	.loc 1 51 41 is_stmt 0 view .LVU54
	sub	r2, r2, r1	@ tmp148, _4, size
@ src/memory.c:51:                 next->size = curr->size - size;
	.loc 1 51 28 view .LVU55
	str	r2, [r3, r1]	@ tmp148, next_20->size
	.loc 1 52 17 is_stmt 1 view .LVU56
@ src/memory.c:52:                 next->is_free = 1;
	.loc 1 52 31 is_stmt 0 view .LVU57
	mov	r2, #1	@ tmp149,
	strb	r2, [r0, #4]	@ tmp149, next_20->is_free
	.loc 1 53 17 is_stmt 1 view .LVU58
@ src/memory.c:53:                 next->next = curr->next;
	.loc 1 53 34 is_stmt 0 view .LVU59
	ldr	r2, [r3, #8]	@ _9, curr_29->next
@ src/memory.c:53:                 next->next = curr->next;
	.loc 1 53 28 view .LVU60
	str	r2, [r0, #8]	@ _9, next_20->next
	.loc 1 54 17 is_stmt 1 view .LVU61
@ src/memory.c:54:                 curr->size = size;
	.loc 1 54 28 is_stmt 0 view .LVU62
	str	r1, [r3]	@ size, curr_29->size
	.loc 1 55 17 is_stmt 1 view .LVU63
@ src/memory.c:55:                 curr->next = next;
	.loc 1 55 28 is_stmt 0 view .LVU64
	str	r0, [r3, #8]	@ next, curr_29->next
.LVL10:
.L6:
	.loc 1 55 28 view .LVU65
.LBE13:
	.loc 1 58 13 is_stmt 1 view .LVU66
@ src/memory.c:58:             curr->is_free = 0;
	.loc 1 58 27 is_stmt 0 view .LVU67
	mov	r2, #0	@ tmp151,
@ src/memory.c:59:             return (void*)((uint8_t*)curr + sizeof(block_header_t));
	.loc 1 59 20 view .LVU68
	add	r0, r3, #12	@ <retval>, curr,
@ src/memory.c:58:             curr->is_free = 0;
	.loc 1 58 27 view .LVU69
	strb	r2, [r3, #4]	@ tmp151, curr_29->is_free
	.loc 1 59 13 is_stmt 1 view .LVU70
@ src/memory.c:59:             return (void*)((uint8_t*)curr + sizeof(block_header_t));
	.loc 1 59 20 is_stmt 0 view .LVU71
	bx	lr	@
.L31:
	.align	2
.L30:
	.word	.LANCHOR0-(.LPIC1+8)
	.word	.LANCHOR1-(.LPIC8+8)
	.word	heap-(.LPIC3+8)
	.word	.LANCHOR1-(.LPIC2+8)
	.cfi_endproc
.LFE2:
	.size	malloc, .-malloc
	.section	.text.free,"ax",%progbits
	.align	2
	.global	free
	.syntax unified
	.arm
	.fpu softvfp
	.type	free, %function
free:
.LVL11:
.LFB3:
	.loc 1 69 22 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 70 5 view .LVU73
@ src/memory.c:70:     if (!ptr) return;
	.loc 1 70 8 is_stmt 0 view .LVU74
	cmp	r0, #0	@ ptr
	.loc 1 70 8 view .LVU75
	bxeq	lr	@
	.loc 1 72 5 is_stmt 1 view .LVU76
@ src/memory.c:76:     if (header->next && header->next->is_free) {
	.loc 1 76 15 is_stmt 0 view .LVU77
	ldr	r3, [r0, #-4]	@ _1, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].next
@ src/memory.c:73:     header->is_free = 1;
	.loc 1 73 21 view .LVU78
	mov	r2, #1	@ tmp129,
@ src/memory.c:69: void free(void* ptr) {
	.loc 1 69 22 view .LVU79
	str	lr, [sp, #-4]!	@,
	.cfi_def_cfa_offset 4
	.cfi_offset 14, -4
@ src/memory.c:76:     if (header->next && header->next->is_free) {
	.loc 1 76 8 view .LVU80
	cmp	r3, #0	@ _1,
@ src/memory.c:73:     header->is_free = 1;
	.loc 1 73 21 view .LVU81
	strb	r2, [r0, #-8]	@ tmp129, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].is_free
@ src/memory.c:72:     block_header_t* header = (block_header_t*)((uint8_t*)ptr - sizeof(block_header_t));
	.loc 1 72 21 view .LVU82
	sub	lr, r0, #12	@ header, ptr,
.LVL12:
	.loc 1 73 5 is_stmt 1 view .LVU83
	.loc 1 76 5 view .LVU84
@ src/memory.c:76:     if (header->next && header->next->is_free) {
	.loc 1 76 8 is_stmt 0 view .LVU85
	beq	.L35		@,
@ src/memory.c:76:     if (header->next && header->next->is_free) {
	.loc 1 76 22 discriminator 1 view .LVU86
	ldrb	r2, [r3, #4]	@ zero_extendqisi2	@ _1->is_free, _1->is_free
	cmp	r2, #0	@ _1->is_free,
	bne	.L54		@,
.L35:
	.loc 1 82 5 is_stmt 1 view .LVU87
@ src/memory.c:82:     block_header_t* curr = free_list;
	.loc 1 82 21 is_stmt 0 view .LVU88
	ldr	r3, .L55	@ tmp136,
.LPIC9:
	add	r3, pc, r3	@ tmp136, tmp136
	ldr	r3, [r3]	@ _16, free_list
.LVL13:
	.loc 1 83 5 is_stmt 1 view .LVU89
	.loc 1 83 11 view .LVU90
	cmp	r3, #0	@ _16,
	ldreq	pc, [sp], #4	@
.LVL14:
.L44:
	.loc 1 84 9 discriminator 1 view .LVU91
	.loc 1 84 9 is_stmt 0 discriminator 1 view .LVU92
	mov	r2, r3	@ curr, _16
@ src/memory.c:83:     while (curr && curr->next) {
	.loc 1 83 24 discriminator 1 view .LVU93
	ldr	r3, [r3, #8]	@ _16, curr_31->next
.LVL15:
@ src/memory.c:83:     while (curr && curr->next) {
	.loc 1 83 17 discriminator 1 view .LVU94
	cmp	r3, #0	@ _16,
	ldreq	pc, [sp], #4	@
@ src/memory.c:84:         if (curr->is_free && (uint8_t*)curr + curr->size == (uint8_t*)header) {
	.loc 1 84 12 view .LVU95
	ldrb	r1, [r2, #4]	@ zero_extendqisi2	@ curr_8->is_free, curr_8->is_free
	cmp	r1, #0	@ curr_8->is_free,
	beq	.L44		@,
@ src/memory.c:84:         if (curr->is_free && (uint8_t*)curr + curr->size == (uint8_t*)header) {
	.loc 1 84 51 discriminator 1 view .LVU96
	ldr	r1, [r2]	@ _11, curr_8->size
@ src/memory.c:84:         if (curr->is_free && (uint8_t*)curr + curr->size == (uint8_t*)header) {
	.loc 1 84 45 discriminator 1 view .LVU97
	add	ip, r2, r1	@ tmp138, curr, _11
@ src/memory.c:84:         if (curr->is_free && (uint8_t*)curr + curr->size == (uint8_t*)header) {
	.loc 1 84 27 discriminator 1 view .LVU98
	cmp	lr, ip	@ header, tmp138
	bne	.L44		@,
	.loc 1 85 13 is_stmt 1 view .LVU99
@ src/memory.c:85:             curr->size += header->size;
	.loc 1 85 24 is_stmt 0 view .LVU100
	ldr	r3, [r0, #-12]	@ MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].size, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].size
@ src/memory.c:86:             curr->next = header->next;
	.loc 1 86 32 view .LVU101
	ldr	r0, [r0, #-4]	@ _15, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].next
.LVL16:
@ src/memory.c:85:             curr->size += header->size;
	.loc 1 85 24 view .LVU102
	add	r1, r3, r1	@ tmp139, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].size, _11
@ src/memory.c:86:             curr->next = header->next;
	.loc 1 86 24 view .LVU103
	str	r0, [r2, #8]	@ _15, curr_8->next
@ src/memory.c:85:             curr->size += header->size;
	.loc 1 85 24 view .LVU104
	str	r1, [r2]	@ tmp139, curr_8->size
	.loc 1 86 13 is_stmt 1 view .LVU105
	.loc 1 87 13 view .LVU106
	ldr	pc, [sp], #4	@
.LVL17:
.L54:
	.loc 1 77 9 view .LVU107
@ src/memory.c:77:         header->size += header->next->size;
	.loc 1 77 22 is_stmt 0 view .LVU108
	ldr	ip, [r3]	@ _1->size, _1->size
	ldr	r2, [r0, #-12]	@ MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].size, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].size
@ src/memory.c:78:         header->next = header->next->next;
	.loc 1 78 36 view .LVU109
	ldr	r1, [r3, #8]	@ _9, _1->next
@ src/memory.c:77:         header->size += header->next->size;
	.loc 1 77 22 view .LVU110
	add	r3, r2, ip	@ tmp132, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].size, _1->size
	str	r3, [r0, #-12]	@ tmp132, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].size
	.loc 1 78 9 is_stmt 1 view .LVU111
@ src/memory.c:78:         header->next = header->next->next;
	.loc 1 78 22 is_stmt 0 view .LVU112
	str	r1, [r0, #-4]	@ _9, MEM[(struct block_header_t *)ptr_20(D) + 4294967284B].next
	b	.L35		@
.L56:
	.align	2
.L55:
	.word	.LANCHOR1-(.LPIC9+8)
	.cfi_endproc
.LFE3:
	.size	free, .-free
	.section	.text.xfree,"ax",%progbits
	.align	2
	.global	xfree
	.syntax unified
	.arm
	.fpu softvfp
	.type	xfree, %function
xfree:
.LVL18:
.LFB7:
	.loc 1 144 21 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 145 5 view .LVU114
@ src/memory.c:145:     if (p) {
	.loc 1 145 8 is_stmt 0 view .LVU115
	cmp	r0, #0	@ tmp114,
	bxeq	lr	@
	.loc 1 146 9 is_stmt 1 view .LVU116
	b	free(PLT)	@
.LVL19:
	.loc 1 146 9 is_stmt 0 view .LVU117
	.cfi_endproc
.LFE7:
	.size	xfree, .-xfree
	.section	.text.memset,"ax",%progbits
	.align	2
	.global	memset
	.syntax unified
	.arm
	.fpu softvfp
	.type	memset, %function
memset:
.LVL20:
.LFB9:
	.loc 1 184 43 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
@ src/memory.c:186:     while (n--) {
	.loc 1 186 11 is_stmt 0 view .LVU119
	cmp	r2, #0	@ n
	.loc 1 185 5 is_stmt 1 view .LVU120
.LVL21:
	.loc 1 186 5 view .LVU121
	.loc 1 186 11 view .LVU122
	.loc 1 186 11 is_stmt 0 view .LVU123
	bxeq	lr	@
	add	r2, r0, r2	@ _18, dest, n
.LVL22:
@ src/memory.c:187:         *p++ = (unsigned char)c;
	.loc 1 187 16 view .LVU124
	uxtb	r1, r1	@ _4, c
.LVL23:
@ src/memory.c:185:     unsigned char* p = dest;
	.loc 1 185 20 view .LVU125
	mov	r3, r0	@ p, dest
.LVL24:
.L61:
	.loc 1 187 9 is_stmt 1 view .LVU126
@ src/memory.c:187:         *p++ = (unsigned char)c;
	.loc 1 187 14 is_stmt 0 view .LVU127
	strb	r1, [r3], #1	@ _4, MEM[base: p_9, offset: 4294967295B]
.LVL25:
	.loc 1 186 11 is_stmt 1 view .LVU128
	.loc 1 186 11 is_stmt 0 view .LVU129
	cmp	r3, r2	@ p, _18
	bne	.L61		@,
	bx	lr	@
	.cfi_endproc
.LFE9:
	.size	memset, .-memset
	.section	.rodata.xmalloc.str1.4,"aMS",%progbits,1
	.align	2
.LC0:
	.ascii	"xmalloc failed to allocate %zu bytes\012\000"
	.section	.text.xmalloc,"ax",%progbits
	.align	2
	.global	xmalloc
	.syntax unified
	.arm
	.fpu softvfp
	.type	xmalloc, %function
xmalloc:
.LVL26:
.LFB4:
	.loc 1 94 25 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 95 5 view .LVU131
	.loc 1 98 5 view .LVU132
	cmp	r0, #1	@ tmp119,
@ src/memory.c:94: void* xmalloc(size_t n) {
	.loc 1 94 25 is_stmt 0 view .LVU133
	push	{r4, r5, r6, lr}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 4, -16
	.cfi_offset 5, -12
	.cfi_offset 6, -8
	.cfi_offset 14, -4
	movcs	r4, r0	@ n, tmp119
	movcc	r4, #1	@ n,
.LVL27:
	.loc 1 101 5 is_stmt 1 view .LVU134
@ src/memory.c:101:     ptr = malloc(n);
	.loc 1 101 11 is_stmt 0 view .LVU135
	mov	r0, r4	@, n
	bl	malloc(PLT)	@
.LVL28:
	.loc 1 104 5 is_stmt 1 view .LVU136
@ src/memory.c:104:     if (!ptr) {
	.loc 1 104 8 is_stmt 0 view .LVU137
	subs	r5, r0, #0	@ <retval>, tmp120
	beq	.L69		@,
	.loc 1 110 5 is_stmt 1 view .LVU138
	mov	r2, r4	@, n
	mov	r1, #0	@,
	bl	memset(PLT)	@
.LVL29:
	.loc 1 112 5 view .LVU139
.L65:
@ src/memory.c:113: }
	.loc 1 113 1 is_stmt 0 view .LVU140
	mov	r0, r5	@, <retval>
	pop	{r4, r5, r6, pc}	@
.LVL30:
.L69:
	.loc 1 105 9 is_stmt 1 view .LVU141
	ldr	r0, .L70	@,
.LVL31:
	.loc 1 105 9 is_stmt 0 view .LVU142
	mov	r1, r4	@, n
.LPIC10:
	add	r0, pc, r0	@,
	bl	tfp_printf(PLT)	@
.LVL32:
	.loc 1 106 9 is_stmt 1 view .LVU143
@ src/memory.c:106:         return NULL;// abort(); /* In GnuPG we abort on allocation failure */
	.loc 1 106 16 is_stmt 0 view .LVU144
	b	.L65		@
.L71:
	.align	2
.L70:
	.word	.LC0-(.LPIC10+8)
	.cfi_endproc
.LFE4:
	.size	xmalloc, .-xmalloc
	.section	.text.xmalloc_clear,"ax",%progbits
	.align	2
	.global	xmalloc_clear
	.syntax unified
	.arm
	.fpu softvfp
	.type	xmalloc_clear, %function
xmalloc_clear:
.LVL33:
.LFB5:
	.loc 1 115 31 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 116 5 view .LVU146
@ src/memory.c:115: void* xmalloc_clear(size_t n) {
	.loc 1 115 31 is_stmt 0 view .LVU147
	push	{r4, r5, r6, lr}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 4, -16
	.cfi_offset 5, -12
	.cfi_offset 6, -8
	.cfi_offset 14, -4
@ src/memory.c:115: void* xmalloc_clear(size_t n) {
	.loc 1 115 31 view .LVU148
	mov	r5, r0	@ n, tmp116
@ src/memory.c:116:     void* ptr = malloc(n);
	.loc 1 116 17 view .LVU149
	bl	malloc(PLT)	@
.LVL34:
	.loc 1 117 5 is_stmt 1 view .LVU150
@ src/memory.c:117:     if (ptr) {
	.loc 1 117 8 is_stmt 0 view .LVU151
	subs	r4, r0, #0	@ <retval>, tmp117
	beq	.L72		@,
	.loc 1 118 9 is_stmt 1 view .LVU152
	mov	r2, r5	@, n
	mov	r1, #0	@,
	bl	memset(PLT)	@
.LVL35:
	.loc 1 121 5 view .LVU153
	.loc 1 122 5 view .LVU154
.L72:
@ src/memory.c:123: }
	.loc 1 123 1 is_stmt 0 view .LVU155
	mov	r0, r4	@, <retval>
	pop	{r4, r5, r6, pc}	@
	.cfi_endproc
.LFE5:
	.size	xmalloc_clear, .-xmalloc_clear
	.section	.text.xcalloc,"ax",%progbits
	.align	2
	.global	xcalloc
	.syntax unified
	.arm
	.fpu softvfp
	.type	xcalloc, %function
xcalloc:
.LVL36:
.LFB6:
	.loc 1 125 35 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 126 5 view .LVU157
	.loc 1 127 5 view .LVU158
	.loc 1 130 5 view .LVU159
@ src/memory.c:130:     if (n && m > SIZE_MAX / n) {
	.loc 1 130 8 is_stmt 0 view .LVU160
	cmp	r0, #0	@ n
@ src/memory.c:125: void* xcalloc(size_t n, size_t m) {
	.loc 1 125 35 view .LVU161
	push	{r4, r5, r6, lr}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 4, -16
	.cfi_offset 5, -12
	.cfi_offset 6, -8
	.cfi_offset 14, -4
@ src/memory.c:130:     if (n && m > SIZE_MAX / n) {
	.loc 1 130 8 view .LVU162
	beq	.L79		@,
	umull	r2, r3, r0, r1	@ tmp127, tmp120, n, m
	cmp	r3, #0	@ tmp120,
@ src/memory.c:131:         return NULL;
	.loc 1 131 16 discriminator 1 view .LVU163
	movne	r5, #0	@ <retval>,
	bne	.L78		@,
.L79:
	.loc 1 134 5 is_stmt 1 view .LVU164
@ src/memory.c:134:     total = n * m;
	.loc 1 134 11 is_stmt 0 view .LVU165
	mul	r4, r1, r0	@ total, m, n
.LVL37:
	.loc 1 135 5 is_stmt 1 view .LVU166
@ src/memory.c:135:     ptr = malloc(total);
	.loc 1 135 11 is_stmt 0 view .LVU167
	mov	r0, r4	@, total
.LVL38:
	.loc 1 135 11 view .LVU168
	bl	malloc(PLT)	@
.LVL39:
	.loc 1 137 5 is_stmt 1 view .LVU169
@ src/memory.c:137:     if (ptr) {
	.loc 1 137 8 is_stmt 0 view .LVU170
	subs	r5, r0, #0	@ <retval>, tmp125
	beq	.L78		@,
	.loc 1 138 9 is_stmt 1 view .LVU171
	mov	r2, r4	@, total
	mov	r1, #0	@,
	bl	memset(PLT)	@
.LVL40:
.L78:
@ src/memory.c:142: }
	.loc 1 142 1 is_stmt 0 view .LVU172
	mov	r0, r5	@, <retval>
	pop	{r4, r5, r6, pc}	@
	.cfi_endproc
.LFE6:
	.size	xcalloc, .-xcalloc
	.section	.text.memcpy,"ax",%progbits
	.align	2
	.global	memcpy
	.syntax unified
	.arm
	.fpu softvfp
	.type	memcpy, %function
memcpy:
.LVL41:
.LFB10:
	.loc 1 192 53 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
@ src/memory.c:195:     while (n--) {
	.loc 1 195 11 is_stmt 0 view .LVU174
	cmp	r2, #0	@ n
	.loc 1 193 5 is_stmt 1 view .LVU175
.LVL42:
	.loc 1 194 5 view .LVU176
	.loc 1 195 5 view .LVU177
	.loc 1 195 11 view .LVU178
	.loc 1 195 11 is_stmt 0 view .LVU179
	bxeq	lr	@
	add	ip, r1, r2	@ _14, src, n
	sub	r3, r0, #1	@ ivtmp.85, dest,
.LVL43:
.L95:
	.loc 1 196 9 is_stmt 1 view .LVU180
@ src/memory.c:196:         *d++ = *s++;
	.loc 1 196 16 is_stmt 0 view .LVU181
	ldrb	r2, [r1], #1	@ zero_extendqisi2	@ _1, MEM[base: s_11, offset: 4294967295B]
.LVL44:
@ src/memory.c:195:     while (n--) {
	.loc 1 195 11 view .LVU182
	cmp	r1, ip	@ src, _14
@ src/memory.c:196:         *d++ = *s++;
	.loc 1 196 14 view .LVU183
	strb	r2, [r3, #1]!	@ _1, MEM[base: _17, offset: 0B]
	.loc 1 195 11 is_stmt 1 view .LVU184
	.loc 1 195 11 is_stmt 0 view .LVU185
	bne	.L95		@,
	bx	lr	@
	.cfi_endproc
.LFE10:
	.size	memcpy, .-memcpy
	.section	.text.xrealloc,"ax",%progbits
	.align	2
	.global	xrealloc
	.syntax unified
	.arm
	.fpu softvfp
	.type	xrealloc, %function
xrealloc:
.LVL45:
.LFB8:
	.loc 1 150 35 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 151 5 view .LVU187
	.loc 1 153 5 view .LVU188
@ src/memory.c:150: void* xrealloc(void* p, size_t n) {
	.loc 1 150 35 is_stmt 0 view .LVU189
	push	{r4, r5, r6, lr}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 4, -16
	.cfi_offset 5, -12
	.cfi_offset 6, -8
	.cfi_offset 14, -4
@ src/memory.c:153:     if (!p) {
	.loc 1 153 8 view .LVU190
	subs	r5, r0, #0	@ p, tmp120
	beq	.L109		@,
	.loc 1 157 5 is_stmt 1 view .LVU191
@ src/memory.c:157:     if (n == 0) {
	.loc 1 157 8 is_stmt 0 view .LVU192
	cmp	r1, #0	@ n,
	beq	.L110		@,
	.loc 1 163 5 is_stmt 1 view .LVU193
.LVL46:
	.loc 1 164 5 view .LVU194
@ src/memory.c:164:     size_t old_size = header->size - sizeof(block_header_t);
	.loc 1 164 12 is_stmt 0 view .LVU195
	ldr	r6, [r5, #-12]	@ MEM[(struct block_header_t *)p_4(D) + 4294967284B].size, MEM[(struct block_header_t *)p_4(D) + 4294967284B].size
	sub	r6, r6, #12	@ old_size, MEM[(struct block_header_t *)p_4(D) + 4294967284B].size,
.LVL47:
	.loc 1 167 5 is_stmt 1 view .LVU196
@ src/memory.c:167:     if (n <= old_size) {
	.loc 1 167 8 is_stmt 0 view .LVU197
	cmp	r1, r6	@ n, old_size
	movls	r4, r5	@ <retval>, p
	bhi	.L111		@,
.LVL48:
.L100:
@ src/memory.c:182: }
	.loc 1 182 1 view .LVU198
	mov	r0, r4	@, <retval>
	pop	{r4, r5, r6, pc}	@
.LVL49:
.L111:
	.loc 1 172 5 is_stmt 1 view .LVU199
@ src/memory.c:172:     new_ptr = malloc(n);
	.loc 1 172 15 is_stmt 0 view .LVU200
	mov	r0, r1	@, n
.LVL50:
	.loc 1 172 15 view .LVU201
	bl	malloc(PLT)	@
.LVL51:
	.loc 1 173 5 is_stmt 1 view .LVU202
@ src/memory.c:173:     if (!new_ptr) {
	.loc 1 173 8 is_stmt 0 view .LVU203
	subs	r4, r0, #0	@ <retval>, tmp122
	beq	.L100		@,
	.loc 1 178 5 is_stmt 1 view .LVU204
	mov	r2, r6	@, old_size
	mov	r1, r5	@, p
	bl	memcpy(PLT)	@
.LVL52:
	.loc 1 179 5 view .LVU205
	mov	r0, r5	@, p
	bl	free(PLT)	@
.LVL53:
	.loc 1 181 5 view .LVU206
@ src/memory.c:182: }
	.loc 1 182 1 is_stmt 0 view .LVU207
	mov	r0, r4	@, <retval>
	pop	{r4, r5, r6, pc}	@
.LVL54:
.L109:
	.loc 1 154 9 is_stmt 1 view .LVU208
@ src/memory.c:182: }
	.loc 1 182 1 is_stmt 0 view .LVU209
	pop	{r4, r5, r6, lr}	@
	.cfi_remember_state
	.cfi_restore 14
	.cfi_restore 6
	.cfi_restore 5
	.cfi_restore 4
	.cfi_def_cfa_offset 0
@ src/memory.c:154:         return malloc(n);
	.loc 1 154 16 view .LVU210
	mov	r0, r1	@, n
.LVL55:
	.loc 1 154 16 view .LVU211
	b	malloc(PLT)	@
.LVL56:
.L110:
	.cfi_restore_state
	.loc 1 158 9 is_stmt 1 view .LVU212
@ src/memory.c:159:         return NULL;
	.loc 1 159 16 is_stmt 0 view .LVU213
	mov	r4, r1	@ <retval>, n
@ src/memory.c:158:         free(p);
	.loc 1 158 9 view .LVU214
	bl	free(PLT)	@
.LVL57:
	.loc 1 159 9 is_stmt 1 view .LVU215
@ src/memory.c:159:         return NULL;
	.loc 1 159 16 is_stmt 0 view .LVU216
	b	.L100		@
	.cfi_endproc
.LFE8:
	.size	xrealloc, .-xrealloc
	.section	.text.memmove,"ax",%progbits
	.align	2
	.global	memmove
	.syntax unified
	.arm
	.fpu softvfp
	.type	memmove, %function
memmove:
.LVL58:
.LFB11:
	.loc 1 201 54 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 202 5 view .LVU218
	.loc 1 203 5 view .LVU219
	.loc 1 205 5 view .LVU220
@ src/memory.c:205:     if (d > s && d < s + n) {
	.loc 1 205 8 is_stmt 0 view .LVU221
	cmp	r0, r1	@ dest, src
	bls	.L113		@,
@ src/memory.c:205:     if (d > s && d < s + n) {
	.loc 1 205 24 discriminator 1 view .LVU222
	add	r3, r1, r2	@ s, src, n
@ src/memory.c:205:     if (d > s && d < s + n) {
	.loc 1 205 15 discriminator 1 view .LVU223
	cmp	r3, r0	@ s, dest
	bls	.L113		@,
	.loc 1 206 9 is_stmt 1 view .LVU224
@ src/memory.c:206:         d += n;
	.loc 1 206 11 is_stmt 0 view .LVU225
	add	ip, r0, r2	@ d, dest, n
.LVL59:
	.loc 1 207 9 is_stmt 1 view .LVU226
	.loc 1 208 9 view .LVU227
	.loc 1 208 15 view .LVU228
	.loc 1 208 15 is_stmt 0 view .LVU229
	cmp	r2, #0	@ n,
	bxeq	lr	@
	mov	r2, ip	@ ivtmp.106, d
.LVL60:
.L117:
	.loc 1 209 13 is_stmt 1 view .LVU230
@ src/memory.c:209:             *--d = *--s;
	.loc 1 209 20 is_stmt 0 view .LVU231
	ldrb	ip, [r3, #-1]!	@ zero_extendqisi2	@ _2, MEM[base: s_20, offset: 0B]
.LVL61:
@ src/memory.c:208:         while (n--) {
	.loc 1 208 15 view .LVU232
	cmp	r1, r3	@ src, s
@ src/memory.c:209:             *--d = *--s;
	.loc 1 209 18 view .LVU233
	strb	ip, [r2, #-1]!	@ _2, MEM[base: _27, offset: 0B]
	.loc 1 208 15 is_stmt 1 view .LVU234
	.loc 1 208 15 is_stmt 0 view .LVU235
	bne	.L117		@,
	bx	lr	@
.LVL62:
.L113:
	.loc 1 213 15 is_stmt 1 view .LVU236
	.loc 1 213 15 is_stmt 0 view .LVU237
	cmp	r2, #0	@ n,
	bxeq	lr	@
	add	ip, r1, r2	@ _5, src, n
	sub	r3, r0, #1	@ ivtmp.120, dest,
.LVL63:
.L118:
	.loc 1 214 13 is_stmt 1 view .LVU238
@ src/memory.c:214:             *d++ = *s++;
	.loc 1 214 20 is_stmt 0 view .LVU239
	ldrb	r2, [r1], #1	@ zero_extendqisi2	@ _3, MEM[base: s_24, offset: 4294967295B]
.LVL64:
@ src/memory.c:213:         while (n--) {
	.loc 1 213 15 view .LVU240
	cmp	ip, r1	@ _5, src
@ src/memory.c:214:             *d++ = *s++;
	.loc 1 214 18 view .LVU241
	strb	r2, [r3, #1]!	@ _3, MEM[base: _7, offset: 0B]
	.loc 1 213 15 is_stmt 1 view .LVU242
	.loc 1 213 15 is_stmt 0 view .LVU243
	bne	.L118		@,
	bx	lr	@
	.cfi_endproc
.LFE11:
	.size	memmove, .-memmove
	.section	.text.wipememory,"ax",%progbits
	.align	2
	.global	wipememory
	.syntax unified
	.arm
	.fpu softvfp
	.type	wipememory, %function
wipememory:
.LVL65:
.LFB12:
	.loc 1 220 40 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
@ src/memory.c:222:     while (len--)
	.loc 1 222 11 is_stmt 0 view .LVU245
	cmp	r1, #0	@ len
	.loc 1 221 5 is_stmt 1 view .LVU246
.LVL66:
	.loc 1 222 5 view .LVU247
	.loc 1 222 11 view .LVU248
	.loc 1 222 11 is_stmt 0 view .LVU249
	bxeq	lr	@
	add	r1, r0, r1	@ _16, ptr, len
.LVL67:
@ src/memory.c:223:         *p++ = 0;
	.loc 1 223 14 view .LVU250
	mov	r2, #0	@ tmp117,
.LVL68:
.L128:
	.loc 1 223 9 is_stmt 1 view .LVU251
	mov	r3, r0	@ p, ptr
@ src/memory.c:223:         *p++ = 0;
	.loc 1 223 11 is_stmt 0 view .LVU252
	add	r0, r0, #1	@ ptr, ptr,
.LVL69:
@ src/memory.c:222:     while (len--)
	.loc 1 222 11 view .LVU253
	cmp	r0, r1	@ ptr, _16
@ src/memory.c:223:         *p++ = 0;
	.loc 1 223 14 view .LVU254
	strb	r2, [r3]	@ tmp117, *p_13
	.loc 1 222 11 is_stmt 1 view .LVU255
	.loc 1 222 11 is_stmt 0 view .LVU256
	bne	.L128		@,
	bx	lr	@
	.cfi_endproc
.LFE12:
	.size	wipememory, .-wipememory
	.section	.text.strcpy,"ax",%progbits
	.align	2
	.global	strcpy
	.syntax unified
	.arm
	.fpu softvfp
	.type	strcpy, %function
strcpy:
.LVL70:
.LFB13:
	.loc 1 226 42 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 227 5 view .LVU258
	sub	r0, r0, #1	@ ivtmp.144, tmp120,
.LVL71:
.L134:
	.loc 1 227 39 discriminator 1 view .LVU259
	.loc 1 227 11 discriminator 1 view .LVU260
@ src/memory.c:227:     while ((*dest++ = *src++) != '\0');
	.loc 1 227 23 is_stmt 0 discriminator 1 view .LVU261
	ldrb	r3, [r1], #1	@ zero_extendqisi2	@ _1, MEM[base: src_8, offset: 4294967295B]
.LVL72:
@ src/memory.c:227:     while ((*dest++ = *src++) != '\0');
	.loc 1 227 21 discriminator 1 view .LVU262
	strb	r3, [r0, #1]!	@ _1, MEM[base: _15, offset: 0B]
@ src/memory.c:227:     while ((*dest++ = *src++) != '\0');
	.loc 1 227 11 discriminator 1 view .LVU263
	cmp	r3, #0	@ _1,
	bne	.L134		@,
	bx	lr	@
	.cfi_endproc
.LFE13:
	.size	strcpy, .-strcpy
	.section	.text.xtrycalloc,"ax",%progbits
	.align	2
	.global	xtrycalloc
	.syntax unified
	.arm
	.fpu softvfp
	.type	xtrycalloc, %function
xtrycalloc:
.LVL73:
.LFB14:
	.loc 1 230 45 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 232 5 view .LVU265
@ src/memory.c:232:     if (nmemb && size && (nmemb * size) / nmemb != size) {
	.loc 1 232 8 is_stmt 0 view .LVU266
	cmp	r0, #0	@ nmemb,
	cmpne	r1, #0	@, size,
@ src/memory.c:230: void *xtrycalloc(size_t nmemb, size_t size) {
	.loc 1 230 45 view .LVU267
	push	{r4, r5, r6, lr}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 4, -16
	.cfi_offset 5, -12
	.cfi_offset 6, -8
	.cfi_offset 14, -4
@ src/memory.c:232:     if (nmemb && size && (nmemb * size) / nmemb != size) {
	.loc 1 232 33 view .LVU268
	mul	r5, r1, r0	@ _18, size, nmemb
@ src/memory.c:232:     if (nmemb && size && (nmemb * size) / nmemb != size) {
	.loc 1 232 8 view .LVU269
	beq	.L141		@,
@ src/memory.c:232:     if (nmemb && size && (nmemb * size) / nmemb != size) {
	.loc 1 232 41 discriminator 1 view .LVU270
	udiv	r0, r5, r0	@ tmp131, _18, nmemb
.LVL74:
@ src/memory.c:232:     if (nmemb && size && (nmemb * size) / nmemb != size) {
	.loc 1 232 23 discriminator 1 view .LVU271
	cmp	r0, r1	@ tmp131, size
	bne	.L144		@,
.L141:
	.loc 1 236 5 is_stmt 1 view .LVU272
.LVL75:
	.loc 1 237 5 view .LVU273
@ src/memory.c:237:     void *ptr = malloc(total);
	.loc 1 237 17 is_stmt 0 view .LVU274
	mov	r0, r5	@, _18
	bl	malloc(PLT)	@
.LVL76:
	.loc 1 239 5 is_stmt 1 view .LVU275
@ src/memory.c:239:     if (ptr) {
	.loc 1 239 8 is_stmt 0 view .LVU276
	subs	r4, r0, #0	@ <retval>, tmp136
	beq	.L137		@,
	.loc 1 240 9 is_stmt 1 view .LVU277
	mov	r2, r5	@, _18
	mov	r1, #0	@,
	bl	memset(PLT)	@
.LVL77:
.L137:
@ src/memory.c:244: }
	.loc 1 244 1 is_stmt 0 view .LVU278
	mov	r0, r4	@, <retval>
	pop	{r4, r5, r6, pc}	@
.LVL78:
.L144:
@ src/memory.c:233:         return NULL;
	.loc 1 233 16 view .LVU279
	mov	r4, #0	@ <retval>,
@ src/memory.c:244: }
	.loc 1 244 1 view .LVU280
	mov	r0, r4	@, <retval>
	pop	{r4, r5, r6, pc}	@
	.cfi_endproc
.LFE14:
	.size	xtrycalloc, .-xtrycalloc
	.section	.text.strchr,"ax",%progbits
	.align	2
	.global	strchr
	.syntax unified
	.arm
	.fpu softvfp
	.type	strchr, %function
strchr:
.LVL79:
.LFB16:
	.loc 1 256 36 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 257 5 view .LVU282
@ src/memory.c:257:     while (*s != (char)c) {
	.loc 1 257 15 is_stmt 0 view .LVU283
	uxtb	r1, r1	@ _10, tmp121
.LVL80:
	.loc 1 257 15 view .LVU284
	mov	r3, r0	@ ivtmp.156, tmp120
.LVL81:
.L146:
	.loc 1 258 9 is_stmt 1 view .LVU285
@ src/memory.c:257:     while (*s != (char)c) {
	.loc 1 257 12 is_stmt 0 view .LVU286
	ldrb	r2, [r3]	@ zero_extendqisi2	@ _1, MEM[base: s_3, offset: 0B]
	mov	r0, r3	@ <retval>, ivtmp.156
.LVL82:
	.loc 1 257 11 is_stmt 1 view .LVU287
	add	r3, r3, #1	@ ivtmp.156, <retval>,
.LVL83:
	.loc 1 257 11 is_stmt 0 view .LVU288
	cmp	r2, r1	@ _1, _10
	bxeq	lr	@
@ src/memory.c:258:         if (!*s++)
	.loc 1 258 12 view .LVU289
	cmp	r2, #0	@ _1,
	bne	.L146		@,
@ src/memory.c:259:             return NULL;
	.loc 1 259 20 view .LVU290
	mov	r0, r2	@ <retval>, _1
@ src/memory.c:262: }
	.loc 1 262 1 view .LVU291
	bx	lr	@
	.cfi_endproc
.LFE16:
	.size	strchr, .-strchr
	.section	.text.strcmp,"ax",%progbits
	.align	2
	.global	strcmp
	.syntax unified
	.arm
	.fpu softvfp
	.type	strcmp, %function
strcmp:
.LVL84:
.LFB17:
	.loc 1 265 44 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 266 5 view .LVU293
	.loc 1 266 11 view .LVU294
@ src/memory.c:266:     while (*s1 && (*s1 == *s2)) {
	.loc 1 266 12 is_stmt 0 view .LVU295
	ldrb	r3, [r0]	@ zero_extendqisi2	@ _1, *s1_10(D)
@ src/memory.c:266:     while (*s1 && (*s1 == *s2)) {
	.loc 1 266 11 view .LVU296
	cmp	r3, #0	@ _1,
@ src/memory.c:270:     return *(const unsigned char*)s1 - *(const unsigned char*)s2;
	.loc 1 270 40 view .LVU297
	ldrbeq	r2, [r1]	@ zero_extendqisi2	@ _3, *s2_11(D)
@ src/memory.c:266:     while (*s1 && (*s1 == *s2)) {
	.loc 1 266 11 view .LVU298
	bne	.L154		@,
	b	.L153		@
.LVL85:
.L155:
@ src/memory.c:266:     while (*s1 && (*s1 == *s2)) {
	.loc 1 266 12 view .LVU299
	ldrb	r3, [r0, #1]!	@ zero_extendqisi2	@ _1, MEM[base: s1_13, offset: 0B]
.LVL86:
@ src/memory.c:266:     while (*s1 && (*s1 == *s2)) {
	.loc 1 266 11 view .LVU300
	cmp	r3, #0	@ _1,
	beq	.L157		@,
.LVL87:
.L154:
	.loc 1 267 9 is_stmt 1 discriminator 1 view .LVU301
	.loc 1 268 9 discriminator 1 view .LVU302
	mov	ip, r1	@ s2, ivtmp.167
.LVL88:
@ src/memory.c:266:     while (*s1 && (*s1 == *s2)) {
	.loc 1 266 27 is_stmt 0 discriminator 1 view .LVU303
	ldrb	r2, [r1], #1	@ zero_extendqisi2	@ _3, MEM[base: s2_19, offset: 0B]
.LVL89:
	.loc 1 266 11 is_stmt 1 discriminator 1 view .LVU304
@ src/memory.c:266:     while (*s1 && (*s1 == *s2)) {
	.loc 1 266 16 is_stmt 0 discriminator 1 view .LVU305
	cmp	r2, r3	@ _3, _1
	beq	.L155		@,
.LVL90:
.L153:
	.loc 1 270 5 is_stmt 1 view .LVU306
@ src/memory.c:271: }
	.loc 1 271 1 is_stmt 0 view .LVU307
	sub	r0, r3, r2	@, _1, _3
	bx	lr	@
.LVL91:
.L157:
@ src/memory.c:270:     return *(const unsigned char*)s1 - *(const unsigned char*)s2;
	.loc 1 270 40 view .LVU308
	ldrb	r2, [ip, #1]	@ zero_extendqisi2	@ _3, MEM[(const unsigned char *)s2_19 + 1B]
	.loc 1 270 5 is_stmt 1 view .LVU309
@ src/memory.c:271: }
	.loc 1 271 1 is_stmt 0 view .LVU310
	sub	r0, r3, r2	@, _1, _3
.LVL92:
	.loc 1 271 1 view .LVU311
	bx	lr	@
	.cfi_endproc
.LFE17:
	.size	strcmp, .-strcmp
	.section	.rodata.open.str1.4,"aMS",%progbits,1
	.align	2
.LC1:
	.ascii	"stdout\000"
	.align	2
.LC2:
	.ascii	"stdin\000"
	.section	.text.open,"ax",%progbits
	.align	2
	.global	open
	.syntax unified
	.arm
	.fpu softvfp
	.type	open, %function
open:
.LVL93:
.LFB15:
	.loc 1 247 48 is_stmt 1 view -0
	.cfi_startproc
	@ args = 4, pretend = 12, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 1
	.loc 1 250 5 view .LVU313
@ src/memory.c:247: int open(const char *pathname, int flags, ...) {
	.loc 1 247 48 is_stmt 0 view .LVU314
	push	{r1, r2, r3}	@
	.cfi_def_cfa_offset 12
	.cfi_offset 1, -12
	.cfi_offset 2, -8
	.cfi_offset 3, -4
@ src/memory.c:250:     if (strcmp(pathname, "stdout") == 0) return 1;
	.loc 1 250 9 view .LVU315
	ldr	r1, .L162	@,
@ src/memory.c:247: int open(const char *pathname, int flags, ...) {
	.loc 1 247 48 view .LVU316
	push	{r4, r5, lr}	@
	.cfi_def_cfa_offset 24
	.cfi_offset 4, -24
	.cfi_offset 5, -20
	.cfi_offset 14, -16
@ src/memory.c:247: int open(const char *pathname, int flags, ...) {
	.loc 1 247 48 view .LVU317
	mov	r4, r0	@ pathname, tmp127
@ src/memory.c:250:     if (strcmp(pathname, "stdout") == 0) return 1;
	.loc 1 250 9 view .LVU318
.LPIC11:
	add	r1, pc, r1	@,
	bl	strcmp(PLT)	@
.LVL94:
@ src/memory.c:250:     if (strcmp(pathname, "stdout") == 0) return 1;
	.loc 1 250 8 view .LVU319
	cmp	r0, #0	@ tmp128,
@ src/memory.c:250:     if (strcmp(pathname, "stdout") == 0) return 1;
	.loc 1 250 49 view .LVU320
	moveq	r0, #1	@ <retval>,
@ src/memory.c:250:     if (strcmp(pathname, "stdout") == 0) return 1;
	.loc 1 250 8 view .LVU321
	beq	.L158		@,
	.loc 1 251 5 is_stmt 1 view .LVU322
@ src/memory.c:251:     if (strcmp(pathname, "stdin") == 0) return 0;
	.loc 1 251 9 is_stmt 0 view .LVU323
	ldr	r1, .L162+4	@,
	mov	r0, r4	@, pathname
.LPIC12:
	add	r1, pc, r1	@,
	bl	strcmp(PLT)	@
.LVL95:
@ src/memory.c:251:     if (strcmp(pathname, "stdin") == 0) return 0;
	.loc 1 251 8 view .LVU324
	subs	r0, r0, #0	@ tmp125, tmp129,
	movne	r0, #1	@ tmp125,
	rsb	r0, r0, #0	@ <retval>, tmp125
.L158:
@ src/memory.c:253: }
	.loc 1 253 1 view .LVU325
	pop	{r4, r5, lr}	@
	.cfi_restore 14
	.cfi_restore 5
	.cfi_restore 4
	.cfi_def_cfa_offset 12
.LVL96:
	.loc 1 253 1 view .LVU326
	add	sp, sp, #12	@,,
	.cfi_restore 3
	.cfi_restore 2
	.cfi_restore 1
	.cfi_def_cfa_offset 0
	bx	lr	@
.L163:
	.align	2
.L162:
	.word	.LC1-(.LPIC11+8)
	.word	.LC2-(.LPIC12+8)
	.cfi_endproc
.LFE15:
	.size	open, .-open
	.section	.text.strdup,"ax",%progbits
	.align	2
	.global	strdup
	.syntax unified
	.arm
	.fpu softvfp
	.type	strdup, %function
strdup:
.LVL97:
.LFB18:
	.loc 1 274 29 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 275 5 view .LVU328
@ src/memory.c:274: char *strdup(const char *s) {
	.loc 1 274 29 is_stmt 0 view .LVU329
	push	{r4, r5, r6, lr}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 4, -16
	.cfi_offset 5, -12
	.cfi_offset 6, -8
	.cfi_offset 14, -4
@ src/memory.c:274: char *strdup(const char *s) {
	.loc 1 274 29 view .LVU330
	mov	r6, r0	@ s, tmp119
@ src/memory.c:275:     size_t len = strlen(s) + 1;
	.loc 1 275 18 view .LVU331
	bl	strlen(PLT)	@
.LVL98:
@ src/memory.c:275:     size_t len = strlen(s) + 1;
	.loc 1 275 28 view .LVU332
	add	r5, r0, #1	@ len, tmp120,
.LVL99:
	.loc 1 276 5 is_stmt 1 view .LVU333
@ src/memory.c:276:     char *new = malloc(len);
	.loc 1 276 17 is_stmt 0 view .LVU334
	mov	r0, r5	@, len
	bl	malloc(PLT)	@
.LVL100:
	.loc 1 277 5 is_stmt 1 view .LVU335
@ src/memory.c:277:     if (new) {
	.loc 1 277 8 is_stmt 0 view .LVU336
	subs	r4, r0, #0	@ <retval>, tmp121
	beq	.L164		@,
	.loc 1 278 9 is_stmt 1 view .LVU337
	mov	r2, r5	@, len
	mov	r1, r6	@, s
	bl	memcpy(PLT)	@
.LVL101:
	.loc 1 280 5 view .LVU338
.L164:
@ src/memory.c:281: }
	.loc 1 281 1 is_stmt 0 view .LVU339
	mov	r0, r4	@, <retval>
	pop	{r4, r5, r6, pc}	@
	.cfi_endproc
.LFE18:
	.size	strdup, .-strdup
	.section	.text.xstrdup,"ax",%progbits
	.align	2
	.global	xstrdup
	.syntax unified
	.arm
	.fpu softvfp
	.type	xstrdup, %function
xstrdup:
.LVL102:
.LFB19:
	.loc 1 284 35 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 285 5 view .LVU341
@ src/memory.c:284: char *xstrdup(const char *string) {
	.loc 1 284 35 is_stmt 0 view .LVU342
	push	{r4, lr}	@
	.cfi_def_cfa_offset 8
	.cfi_offset 4, -8
	.cfi_offset 14, -4
@ src/memory.c:285:     char *p = strdup(string);
	.loc 1 285 15 view .LVU343
	bl	strdup(PLT)	@
.LVL103:
	.loc 1 286 5 is_stmt 1 view .LVU344
@ src/memory.c:286:     if (!p) {
	.loc 1 286 8 is_stmt 0 view .LVU345
	cmp	r0, #0	@ tmp116,
	popne	{r4, pc}	@
.L172:
	.loc 1 288 9 is_stmt 1 discriminator 1 view .LVU346
	.loc 1 288 17 discriminator 1 view .LVU347
	.loc 1 288 14 discriminator 1 view .LVU348
	.loc 1 288 9 discriminator 1 view .LVU349
	.loc 1 288 17 discriminator 1 view .LVU350
	.loc 1 288 14 discriminator 1 view .LVU351
	b	.L172		@
	.cfi_endproc
.LFE19:
	.size	xstrdup, .-xstrdup
	.section	.bss.free_list,"aw",%nobits
	.align	2
	.set	.LANCHOR1,. + 0
	.type	free_list, %object
	.size	free_list, 4
free_list:
	.space	4
	.section	.bss.heap,"aw",%nobits
	.align	3
	.type	heap, %object
	.size	heap, 131072
heap:
	.space	131072
	.section	.bss.heap_initialized,"aw",%nobits
	.set	.LANCHOR0,. + 0
	.type	heap_initialized, %object
	.size	heap_initialized, 1
heap_initialized:
	.space	1
	.text
.Letext0:
	.file 2 "/usr/lib/gcc/arm-none-eabi/10.3.1/include/stddef.h"
	.file 3 "/usr/lib/gcc/arm-none-eabi/10.3.1/include/stdint.h"
	.file 4 "src/printf.h"
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.4byte	0x95d
	.2byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF51
	.byte	0xc
	.4byte	.LASF52
	.4byte	.LASF53
	.4byte	.Ldebug_ranges0+0x28
	.4byte	0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x3
	.4byte	.LASF6
	.byte	0x2
	.byte	0xd1
	.byte	0x17
	.4byte	0x38
	.uleb128 0x4
	.byte	0x4
	.byte	0x7
	.4byte	.LASF0
	.uleb128 0x4
	.byte	0x8
	.byte	0x5
	.4byte	.LASF1
	.uleb128 0x4
	.byte	0x8
	.byte	0x4
	.4byte	.LASF2
	.uleb128 0x4
	.byte	0x1
	.byte	0x6
	.4byte	.LASF3
	.uleb128 0x4
	.byte	0x2
	.byte	0x5
	.4byte	.LASF4
	.uleb128 0x4
	.byte	0x4
	.byte	0x5
	.4byte	.LASF5
	.uleb128 0x3
	.4byte	.LASF7
	.byte	0x3
	.byte	0x2e
	.byte	0x18
	.4byte	0x6e
	.uleb128 0x4
	.byte	0x1
	.byte	0x8
	.4byte	.LASF8
	.uleb128 0x5
	.4byte	0x6e
	.uleb128 0x4
	.byte	0x2
	.byte	0x7
	.4byte	.LASF9
	.uleb128 0x4
	.byte	0x4
	.byte	0x7
	.4byte	.LASF10
	.uleb128 0x4
	.byte	0x8
	.byte	0x7
	.4byte	.LASF11
	.uleb128 0x6
	.byte	0x4
	.uleb128 0x7
	.4byte	.LASF54
	.byte	0xc
	.byte	0x1
	.byte	0xb
	.byte	0x10
	.4byte	0xc6
	.uleb128 0x8
	.4byte	.LASF12
	.byte	0x1
	.byte	0xc
	.byte	0xc
	.4byte	0x2c
	.byte	0
	.uleb128 0x8
	.4byte	.LASF13
	.byte	0x1
	.byte	0xd
	.byte	0xd
	.4byte	0x62
	.byte	0x4
	.uleb128 0x8
	.4byte	.LASF14
	.byte	0x1
	.byte	0xe
	.byte	0x1a
	.4byte	0xc6
	.byte	0x8
	.byte	0
	.uleb128 0x9
	.byte	0x4
	.4byte	0x91
	.uleb128 0x3
	.4byte	.LASF15
	.byte	0x1
	.byte	0xf
	.byte	0x3
	.4byte	0x91
	.uleb128 0xa
	.4byte	0x62
	.4byte	0xeb
	.uleb128 0xb
	.4byte	0x38
	.4byte	0x1ffff
	.byte	0
	.uleb128 0xc
	.4byte	.LASF18
	.byte	0x1
	.byte	0x12
	.byte	0x10
	.4byte	0xd8
	.byte	0x8
	.uleb128 0x5
	.byte	0x3
	.4byte	heap
	.uleb128 0xd
	.4byte	.LASF16
	.byte	0x1
	.byte	0x13
	.byte	0x18
	.4byte	0x110
	.uleb128 0x5
	.byte	0x3
	.4byte	free_list
	.uleb128 0x9
	.byte	0x4
	.4byte	0xcc
	.uleb128 0xd
	.4byte	.LASF17
	.byte	0x1
	.byte	0x14
	.byte	0x10
	.4byte	0x62
	.uleb128 0x5
	.byte	0x3
	.4byte	heap_initialized
	.uleb128 0xe
	.4byte	.LASF20
	.byte	0x1
	.2byte	0x11c
	.byte	0x7
	.4byte	0x17d
	.4byte	.LFB19
	.4byte	.LFE19-.LFB19
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x17d
	.uleb128 0xf
	.4byte	.LASF22
	.byte	0x1
	.2byte	0x11c
	.byte	0x1b
	.4byte	0x194
	.4byte	.LLST49
	.4byte	.LVUS49
	.uleb128 0x10
	.ascii	"p\000"
	.byte	0x1
	.2byte	0x11d
	.byte	0xb
	.4byte	0x17d
	.4byte	.LLST50
	.4byte	.LVUS50
	.uleb128 0x11
	.4byte	.LVL103
	.4byte	0x19a
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x3
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0
	.byte	0
	.uleb128 0x9
	.byte	0x4
	.4byte	0x183
	.uleb128 0x4
	.byte	0x1
	.byte	0x8
	.4byte	.LASF19
	.uleb128 0x5
	.4byte	0x183
	.uleb128 0x13
	.4byte	0x183
	.uleb128 0x9
	.byte	0x4
	.4byte	0x18a
	.uleb128 0xe
	.4byte	.LASF21
	.byte	0x1
	.2byte	0x112
	.byte	0x7
	.4byte	0x17d
	.4byte	.LFB18
	.4byte	.LFE18-.LFB18
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x24a
	.uleb128 0x14
	.ascii	"s\000"
	.byte	0x1
	.2byte	0x112
	.byte	0x1a
	.4byte	0x194
	.4byte	.LLST46
	.4byte	.LVUS46
	.uleb128 0x10
	.ascii	"len\000"
	.byte	0x1
	.2byte	0x113
	.byte	0xc
	.4byte	0x2c
	.4byte	.LLST47
	.4byte	.LVUS47
	.uleb128 0x15
	.4byte	.LASF49
	.byte	0x1
	.2byte	0x113
	.byte	0x12
	.4byte	0x25
	.4byte	0x1f0
	.uleb128 0x16
	.byte	0
	.uleb128 0x10
	.ascii	"new\000"
	.byte	0x1
	.2byte	0x114
	.byte	0xb
	.4byte	0x17d
	.4byte	.LLST48
	.4byte	.LVUS48
	.uleb128 0x17
	.4byte	.LVL98
	.4byte	0x947
	.4byte	0x219
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.byte	0
	.uleb128 0x17
	.4byte	.LVL100
	.4byte	0x8b4
	.4byte	0x22d
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.byte	0
	.uleb128 0x11
	.4byte	.LVL101
	.4byte	0x4e9
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0xe
	.4byte	.LASF23
	.byte	0x1
	.2byte	0x109
	.byte	0x5
	.4byte	0x25
	.4byte	.LFB17
	.4byte	.LFE17-.LFB17
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x28e
	.uleb128 0x14
	.ascii	"s1\000"
	.byte	0x1
	.2byte	0x109
	.byte	0x18
	.4byte	0x194
	.4byte	.LLST43
	.4byte	.LVUS43
	.uleb128 0x14
	.ascii	"s2\000"
	.byte	0x1
	.2byte	0x109
	.byte	0x28
	.4byte	0x194
	.4byte	.LLST44
	.4byte	.LVUS44
	.byte	0
	.uleb128 0xe
	.4byte	.LASF24
	.byte	0x1
	.2byte	0x100
	.byte	0x7
	.4byte	0x17d
	.4byte	.LFB16
	.4byte	.LFE16-.LFB16
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x2d0
	.uleb128 0x14
	.ascii	"s\000"
	.byte	0x1
	.2byte	0x100
	.byte	0x1a
	.4byte	0x194
	.4byte	.LLST41
	.4byte	.LVUS41
	.uleb128 0x14
	.ascii	"c\000"
	.byte	0x1
	.2byte	0x100
	.byte	0x21
	.4byte	0x25
	.4byte	.LLST42
	.4byte	.LVUS42
	.byte	0
	.uleb128 0x18
	.4byte	.LASF25
	.byte	0x1
	.byte	0xf7
	.byte	0x5
	.4byte	0x25
	.4byte	.LFB15
	.4byte	.LFE15-.LFB15
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x333
	.uleb128 0x19
	.4byte	.LASF26
	.byte	0x1
	.byte	0xf7
	.byte	0x16
	.4byte	0x194
	.4byte	.LLST45
	.4byte	.LVUS45
	.uleb128 0x1a
	.4byte	.LASF34
	.byte	0x1
	.byte	0xf7
	.byte	0x24
	.4byte	0x25
	.uleb128 0x2
	.byte	0x91
	.sleb128 -12
	.uleb128 0x16
	.uleb128 0x17
	.4byte	.LVL94
	.4byte	0x24a
	.4byte	0x322
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.byte	0
	.uleb128 0x11
	.4byte	.LVL95
	.4byte	0x24a
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x18
	.4byte	.LASF27
	.byte	0x1
	.byte	0xe6
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB14
	.4byte	.LFE14-.LFB14
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x3cd
	.uleb128 0x19
	.4byte	.LASF28
	.byte	0x1
	.byte	0xe6
	.byte	0x19
	.4byte	0x2c
	.4byte	.LLST37
	.4byte	.LVUS37
	.uleb128 0x19
	.4byte	.LASF12
	.byte	0x1
	.byte	0xe6
	.byte	0x27
	.4byte	0x2c
	.4byte	.LLST38
	.4byte	.LVUS38
	.uleb128 0x1b
	.4byte	.LASF29
	.byte	0x1
	.byte	0xec
	.byte	0xc
	.4byte	0x2c
	.4byte	.LLST39
	.4byte	.LVUS39
	.uleb128 0x1c
	.ascii	"ptr\000"
	.byte	0x1
	.byte	0xed
	.byte	0xb
	.4byte	0x8f
	.4byte	.LLST40
	.4byte	.LVUS40
	.uleb128 0x17
	.4byte	.LVL76
	.4byte	0x8b4
	.4byte	0x3b1
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.byte	0
	.uleb128 0x11
	.4byte	.LVL77
	.4byte	0x55c
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x1
	.byte	0x30
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x1d
	.4byte	.LASF31
	.byte	0x1
	.byte	0xe2
	.byte	0x6
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x40c
	.uleb128 0x19
	.4byte	.LASF30
	.byte	0x1
	.byte	0xe2
	.byte	0x13
	.4byte	0x17d
	.4byte	.LLST35
	.4byte	.LVUS35
	.uleb128 0x1e
	.ascii	"src\000"
	.byte	0x1
	.byte	0xe2
	.byte	0x25
	.4byte	0x194
	.4byte	.LLST36
	.4byte	.LVUS36
	.byte	0
	.uleb128 0x1d
	.4byte	.LASF32
	.byte	0x1
	.byte	0xdc
	.byte	0x6
	.4byte	.LFB12
	.4byte	.LFE12-.LFB12
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x45d
	.uleb128 0x1e
	.ascii	"ptr\000"
	.byte	0x1
	.byte	0xdc
	.byte	0x17
	.4byte	0x8f
	.4byte	.LLST32
	.4byte	.LVUS32
	.uleb128 0x1e
	.ascii	"len\000"
	.byte	0x1
	.byte	0xdc
	.byte	0x23
	.4byte	0x2c
	.4byte	.LLST33
	.4byte	.LVUS33
	.uleb128 0x1c
	.ascii	"p\000"
	.byte	0x1
	.byte	0xdd
	.byte	0x14
	.4byte	0x45d
	.4byte	.LLST34
	.4byte	.LVUS34
	.byte	0
	.uleb128 0x9
	.byte	0x4
	.4byte	0x18f
	.uleb128 0x18
	.4byte	.LASF33
	.byte	0x1
	.byte	0xc9
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB11
	.4byte	.LFE11-.LFB11
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x4d6
	.uleb128 0x1a
	.4byte	.LASF30
	.byte	0x1
	.byte	0xc9
	.byte	0x15
	.4byte	0x8f
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x1e
	.ascii	"src\000"
	.byte	0x1
	.byte	0xc9
	.byte	0x27
	.4byte	0x4d6
	.4byte	.LLST28
	.4byte	.LVUS28
	.uleb128 0x1e
	.ascii	"n\000"
	.byte	0x1
	.byte	0xc9
	.byte	0x33
	.4byte	0x2c
	.4byte	.LLST29
	.4byte	.LVUS29
	.uleb128 0x1c
	.ascii	"d\000"
	.byte	0x1
	.byte	0xca
	.byte	0x14
	.4byte	0x4dd
	.4byte	.LLST30
	.4byte	.LVUS30
	.uleb128 0x1c
	.ascii	"s\000"
	.byte	0x1
	.byte	0xcb
	.byte	0x1a
	.4byte	0x4e3
	.4byte	.LLST31
	.4byte	.LVUS31
	.byte	0
	.uleb128 0x9
	.byte	0x4
	.4byte	0x4dc
	.uleb128 0x1f
	.uleb128 0x9
	.byte	0x4
	.4byte	0x6e
	.uleb128 0x9
	.byte	0x4
	.4byte	0x75
	.uleb128 0x18
	.4byte	.LASF35
	.byte	0x1
	.byte	0xc0
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB10
	.4byte	.LFE10-.LFB10
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x55c
	.uleb128 0x1a
	.4byte	.LASF30
	.byte	0x1
	.byte	0xc0
	.byte	0x14
	.4byte	0x8f
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x1e
	.ascii	"src\000"
	.byte	0x1
	.byte	0xc0
	.byte	0x26
	.4byte	0x4d6
	.4byte	.LLST19
	.4byte	.LVUS19
	.uleb128 0x1e
	.ascii	"n\000"
	.byte	0x1
	.byte	0xc0
	.byte	0x32
	.4byte	0x2c
	.4byte	.LLST20
	.4byte	.LVUS20
	.uleb128 0x1c
	.ascii	"d\000"
	.byte	0x1
	.byte	0xc1
	.byte	0x14
	.4byte	0x4dd
	.4byte	.LLST21
	.4byte	.LVUS21
	.uleb128 0x1c
	.ascii	"s\000"
	.byte	0x1
	.byte	0xc2
	.byte	0x1a
	.4byte	0x4e3
	.4byte	.LLST22
	.4byte	.LVUS22
	.byte	0
	.uleb128 0x18
	.4byte	.LASF36
	.byte	0x1
	.byte	0xb8
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB9
	.4byte	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x5bb
	.uleb128 0x1a
	.4byte	.LASF30
	.byte	0x1
	.byte	0xb8
	.byte	0x14
	.4byte	0x8f
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x1e
	.ascii	"c\000"
	.byte	0x1
	.byte	0xb8
	.byte	0x1e
	.4byte	0x25
	.4byte	.LLST8
	.4byte	.LVUS8
	.uleb128 0x1e
	.ascii	"n\000"
	.byte	0x1
	.byte	0xb8
	.byte	0x28
	.4byte	0x2c
	.4byte	.LLST9
	.4byte	.LVUS9
	.uleb128 0x1c
	.ascii	"p\000"
	.byte	0x1
	.byte	0xb9
	.byte	0x14
	.4byte	0x4dd
	.4byte	.LLST10
	.4byte	.LVUS10
	.byte	0
	.uleb128 0x18
	.4byte	.LASF37
	.byte	0x1
	.byte	0x96
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB8
	.4byte	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x69d
	.uleb128 0x1e
	.ascii	"p\000"
	.byte	0x1
	.byte	0x96
	.byte	0x16
	.4byte	0x8f
	.4byte	.LLST23
	.4byte	.LVUS23
	.uleb128 0x1e
	.ascii	"n\000"
	.byte	0x1
	.byte	0x96
	.byte	0x20
	.4byte	0x2c
	.4byte	.LLST24
	.4byte	.LVUS24
	.uleb128 0x1b
	.4byte	.LASF38
	.byte	0x1
	.byte	0x97
	.byte	0xb
	.4byte	0x8f
	.4byte	.LLST25
	.4byte	.LVUS25
	.uleb128 0x1b
	.4byte	.LASF39
	.byte	0x1
	.byte	0xa3
	.byte	0x15
	.4byte	0x110
	.4byte	.LLST26
	.4byte	.LVUS26
	.uleb128 0x1b
	.4byte	.LASF40
	.byte	0x1
	.byte	0xa4
	.byte	0xc
	.4byte	0x2c
	.4byte	.LLST27
	.4byte	.LVUS27
	.uleb128 0x17
	.4byte	.LVL51
	.4byte	0x8b4
	.4byte	0x64a
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x3
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0
	.uleb128 0x17
	.4byte	.LVL52
	.4byte	0x4e9
	.4byte	0x66a
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.byte	0
	.uleb128 0x17
	.4byte	.LVL53
	.4byte	0x861
	.4byte	0x67e
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.byte	0
	.uleb128 0x20
	.4byte	.LVL56
	.4byte	0x8b4
	.4byte	0x693
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x3
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0
	.uleb128 0x21
	.4byte	.LVL57
	.4byte	0x861
	.byte	0
	.uleb128 0x1d
	.4byte	.LASF41
	.byte	0x1
	.byte	0x90
	.byte	0x6
	.4byte	.LFB7
	.4byte	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x6d7
	.uleb128 0x1e
	.ascii	"p\000"
	.byte	0x1
	.byte	0x90
	.byte	0x12
	.4byte	0x8f
	.4byte	.LLST7
	.4byte	.LVUS7
	.uleb128 0x22
	.4byte	.LVL19
	.4byte	0x861
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x3
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0
	.byte	0
	.uleb128 0x18
	.4byte	.LASF42
	.byte	0x1
	.byte	0x7d
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB6
	.4byte	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x76d
	.uleb128 0x1e
	.ascii	"n\000"
	.byte	0x1
	.byte	0x7d
	.byte	0x16
	.4byte	0x2c
	.4byte	.LLST15
	.4byte	.LVUS15
	.uleb128 0x1e
	.ascii	"m\000"
	.byte	0x1
	.byte	0x7d
	.byte	0x20
	.4byte	0x2c
	.4byte	.LLST16
	.4byte	.LVUS16
	.uleb128 0x1b
	.4byte	.LASF29
	.byte	0x1
	.byte	0x7e
	.byte	0xc
	.4byte	0x2c
	.4byte	.LLST17
	.4byte	.LVUS17
	.uleb128 0x1c
	.ascii	"ptr\000"
	.byte	0x1
	.byte	0x7f
	.byte	0xb
	.4byte	0x8f
	.4byte	.LLST18
	.4byte	.LVUS18
	.uleb128 0x17
	.4byte	.LVL39
	.4byte	0x8b4
	.4byte	0x751
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.byte	0
	.uleb128 0x11
	.4byte	.LVL40
	.4byte	0x55c
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x1
	.byte	0x30
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x18
	.4byte	.LASF43
	.byte	0x1
	.byte	0x73
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB5
	.4byte	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x7dd
	.uleb128 0x1e
	.ascii	"n\000"
	.byte	0x1
	.byte	0x73
	.byte	0x1c
	.4byte	0x2c
	.4byte	.LLST13
	.4byte	.LVUS13
	.uleb128 0x1c
	.ascii	"ptr\000"
	.byte	0x1
	.byte	0x74
	.byte	0xb
	.4byte	0x8f
	.4byte	.LLST14
	.4byte	.LVUS14
	.uleb128 0x17
	.4byte	.LVL34
	.4byte	0x8b4
	.4byte	0x7c1
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.byte	0
	.uleb128 0x11
	.4byte	.LVL35
	.4byte	0x55c
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x1
	.byte	0x30
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x18
	.4byte	.LASF44
	.byte	0x1
	.byte	0x5e
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB4
	.4byte	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x861
	.uleb128 0x1e
	.ascii	"n\000"
	.byte	0x1
	.byte	0x5e
	.byte	0x16
	.4byte	0x2c
	.4byte	.LLST11
	.4byte	.LVUS11
	.uleb128 0x1c
	.ascii	"ptr\000"
	.byte	0x1
	.byte	0x5f
	.byte	0xb
	.4byte	0x8f
	.4byte	.LLST12
	.4byte	.LVUS12
	.uleb128 0x17
	.4byte	.LVL28
	.4byte	0x8b4
	.4byte	0x831
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.byte	0
	.uleb128 0x17
	.4byte	.LVL29
	.4byte	0x55c
	.4byte	0x850
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x1
	.byte	0x30
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.byte	0
	.uleb128 0x11
	.4byte	.LVL32
	.4byte	0x954
	.uleb128 0x12
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x74
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x1d
	.4byte	.LASF45
	.byte	0x1
	.byte	0x45
	.byte	0x6
	.4byte	.LFB3
	.4byte	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x8b4
	.uleb128 0x1e
	.ascii	"ptr\000"
	.byte	0x1
	.byte	0x45
	.byte	0x11
	.4byte	0x8f
	.4byte	.LLST4
	.4byte	.LVUS4
	.uleb128 0x1b
	.4byte	.LASF39
	.byte	0x1
	.byte	0x48
	.byte	0x15
	.4byte	0x110
	.4byte	.LLST5
	.4byte	.LVUS5
	.uleb128 0x1b
	.4byte	.LASF46
	.byte	0x1
	.byte	0x52
	.byte	0x15
	.4byte	0x110
	.4byte	.LLST6
	.4byte	.LVUS6
	.byte	0
	.uleb128 0x18
	.4byte	.LASF47
	.byte	0x1
	.byte	0x23
	.byte	0x7
	.4byte	0x8f
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x93e
	.uleb128 0x19
	.4byte	.LASF12
	.byte	0x1
	.byte	0x23
	.byte	0x15
	.4byte	0x2c
	.4byte	.LLST0
	.4byte	.LVUS0
	.uleb128 0x1b
	.4byte	.LASF46
	.byte	0x1
	.byte	0x2a
	.byte	0x15
	.4byte	0x110
	.4byte	.LLST1
	.4byte	.LVUS1
	.uleb128 0x1b
	.4byte	.LASF48
	.byte	0x1
	.byte	0x2b
	.byte	0x15
	.4byte	0x110
	.4byte	.LLST2
	.4byte	.LVUS2
	.uleb128 0x23
	.4byte	.LBB13
	.4byte	.LBE13-.LBB13
	.4byte	0x92c
	.uleb128 0x1b
	.4byte	.LASF14
	.byte	0x1
	.byte	0x32
	.byte	0x21
	.4byte	0x110
	.4byte	.LLST3
	.4byte	.LVUS3
	.byte	0
	.uleb128 0x24
	.4byte	0x93e
	.4byte	.LBI5
	.byte	.LVU27
	.4byte	.Ldebug_ranges0+0
	.byte	0x1
	.byte	0x24
	.byte	0x1c
	.byte	0
	.uleb128 0x25
	.4byte	.LASF55
	.byte	0x1
	.byte	0x17
	.byte	0xd
	.byte	0x1
	.uleb128 0x26
	.4byte	.LASF49
	.4byte	.LASF49
	.byte	0x1
	.2byte	0x113
	.byte	0x12
	.uleb128 0x27
	.4byte	.LASF50
	.4byte	.LASF50
	.byte	0x4
	.byte	0x4c
	.byte	0x6
	.byte	0
	.section	.debug_abbrev,"",%progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x55
	.uleb128 0x17
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x88
	.uleb128 0xb
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x410a
	.byte	0
	.uleb128 0x2
	.uleb128 0x18
	.uleb128 0x2111
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x35
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x17
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x18
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x1b
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x1d
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1e
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x1f
	.uleb128 0x26
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x20
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x2115
	.uleb128 0x19
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x21
	.uleb128 0x4109
	.byte	0
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x22
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x2115
	.uleb128 0x19
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x23
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x24
	.uleb128 0x1d
	.byte	0
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x52
	.uleb128 0x1
	.uleb128 0x2138
	.uleb128 0xb
	.uleb128 0x55
	.uleb128 0x17
	.uleb128 0x58
	.uleb128 0xb
	.uleb128 0x59
	.uleb128 0xb
	.uleb128 0x57
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x25
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x20
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x26
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x6e
	.uleb128 0xe
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x27
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x6e
	.uleb128 0xe
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_loc,"",%progbits
.Ldebug_loc0:
.LVUS49:
	.uleb128 0
	.uleb128 .LVU344
	.uleb128 .LVU344
	.uleb128 0
.LLST49:
	.4byte	.LVL102
	.4byte	.LVL103-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL103-1
	.4byte	.LFE19
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS50:
	.uleb128 .LVU344
	.uleb128 0
.LLST50:
	.4byte	.LVL103
	.4byte	.LFE19
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS46:
	.uleb128 0
	.uleb128 .LVU332
	.uleb128 .LVU332
	.uleb128 0
.LLST46:
	.4byte	.LVL97
	.4byte	.LVL98-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL98-1
	.4byte	.LFE18
	.2byte	0x1
	.byte	0x56
	.4byte	0
	.4byte	0
.LVUS47:
	.uleb128 .LVU333
	.uleb128 0
.LLST47:
	.4byte	.LVL99
	.4byte	.LFE18
	.2byte	0x1
	.byte	0x55
	.4byte	0
	.4byte	0
.LVUS48:
	.uleb128 .LVU335
	.uleb128 .LVU338
	.uleb128 .LVU338
	.uleb128 0
.LLST48:
	.4byte	.LVL100
	.4byte	.LVL101-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL101-1
	.4byte	.LFE18
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS43:
	.uleb128 0
	.uleb128 .LVU299
	.uleb128 .LVU299
	.uleb128 .LVU300
	.uleb128 .LVU300
	.uleb128 .LVU301
	.uleb128 .LVU302
	.uleb128 .LVU303
	.uleb128 .LVU303
	.uleb128 .LVU304
	.uleb128 .LVU304
	.uleb128 .LVU306
	.uleb128 .LVU308
	.uleb128 .LVU311
.LLST43:
	.4byte	.LVL84
	.4byte	.LVL85
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL85
	.4byte	.LVL86
	.2byte	0x3
	.byte	0x70
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL86
	.4byte	.LVL87
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL87
	.4byte	.LVL88
	.2byte	0x3
	.byte	0x70
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL88
	.4byte	.LVL89
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL89
	.4byte	.LVL90
	.2byte	0x3
	.byte	0x70
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL91
	.4byte	.LVL92
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS44:
	.uleb128 0
	.uleb128 .LVU303
	.uleb128 .LVU303
	.uleb128 .LVU304
	.uleb128 .LVU304
	.uleb128 0
.LLST44:
	.4byte	.LVL84
	.4byte	.LVL88
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL88
	.4byte	.LVL89
	.2byte	0x1
	.byte	0x5c
	.4byte	.LVL89
	.4byte	.LFE17
	.2byte	0x1
	.byte	0x51
	.4byte	0
	.4byte	0
.LVUS41:
	.uleb128 0
	.uleb128 .LVU285
	.uleb128 .LVU285
	.uleb128 .LVU287
	.uleb128 .LVU287
	.uleb128 .LVU288
	.uleb128 .LVU288
	.uleb128 0
.LLST41:
	.4byte	.LVL79
	.4byte	.LVL81
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL81
	.4byte	.LVL82
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL82
	.4byte	.LVL83
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL83
	.4byte	.LFE16
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS42:
	.uleb128 0
	.uleb128 .LVU284
	.uleb128 .LVU284
	.uleb128 0
.LLST42:
	.4byte	.LVL79
	.4byte	.LVL80
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL80
	.4byte	.LFE16
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS45:
	.uleb128 0
	.uleb128 .LVU319
	.uleb128 .LVU319
	.uleb128 .LVU326
	.uleb128 .LVU326
	.uleb128 0
.LLST45:
	.4byte	.LVL93
	.4byte	.LVL94-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL94-1
	.4byte	.LVL96
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL96
	.4byte	.LFE15
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS37:
	.uleb128 0
	.uleb128 .LVU271
	.uleb128 .LVU271
	.uleb128 0
.LLST37:
	.4byte	.LVL73
	.4byte	.LVL74
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL74
	.4byte	.LFE14
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS38:
	.uleb128 0
	.uleb128 .LVU275
	.uleb128 .LVU275
	.uleb128 .LVU279
	.uleb128 .LVU279
	.uleb128 0
.LLST38:
	.4byte	.LVL73
	.4byte	.LVL76-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL76-1
	.4byte	.LVL78
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	.LVL78
	.4byte	.LFE14
	.2byte	0x1
	.byte	0x51
	.4byte	0
	.4byte	0
.LVUS39:
	.uleb128 .LVU273
	.uleb128 .LVU275
	.uleb128 .LVU275
	.uleb128 .LVU279
.LLST39:
	.4byte	.LVL75
	.4byte	.LVL76-1
	.2byte	0x7
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x71
	.sleb128 0
	.byte	0x1e
	.byte	0x9f
	.4byte	.LVL76-1
	.4byte	.LVL78
	.2byte	0x8
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x1e
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS40:
	.uleb128 .LVU275
	.uleb128 .LVU278
	.uleb128 .LVU278
	.uleb128 .LVU279
.LLST40:
	.4byte	.LVL76
	.4byte	.LVL77-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL77-1
	.4byte	.LVL78
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS35:
	.uleb128 0
	.uleb128 .LVU259
	.uleb128 .LVU259
	.uleb128 0
.LLST35:
	.4byte	.LVL70
	.4byte	.LVL71
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL71
	.4byte	.LFE13
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS36:
	.uleb128 0
	.uleb128 .LVU261
	.uleb128 .LVU261
	.uleb128 .LVU262
	.uleb128 .LVU262
	.uleb128 0
.LLST36:
	.4byte	.LVL70
	.4byte	.LVL71
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL71
	.4byte	.LVL72
	.2byte	0x3
	.byte	0x71
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL72
	.4byte	.LFE13
	.2byte	0x1
	.byte	0x51
	.4byte	0
	.4byte	0
.LVUS32:
	.uleb128 0
	.uleb128 .LVU251
	.uleb128 .LVU251
	.uleb128 0
.LLST32:
	.4byte	.LVL65
	.4byte	.LVL68
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL68
	.4byte	.LFE12
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS33:
	.uleb128 0
	.uleb128 .LVU249
	.uleb128 .LVU249
	.uleb128 .LVU250
	.uleb128 .LVU250
	.uleb128 0
.LLST33:
	.4byte	.LVL65
	.4byte	.LVL66
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL66
	.4byte	.LVL67
	.2byte	0x3
	.byte	0x71
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL67
	.4byte	.LFE12
	.2byte	0x6
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x31
	.byte	0x1c
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS34:
	.uleb128 .LVU247
	.uleb128 0
.LLST34:
	.4byte	.LVL66
	.4byte	.LFE12
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS28:
	.uleb128 0
	.uleb128 .LVU238
	.uleb128 .LVU238
	.uleb128 0
.LLST28:
	.4byte	.LVL58
	.4byte	.LVL63
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL63
	.4byte	.LFE11
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS29:
	.uleb128 0
	.uleb128 .LVU229
	.uleb128 .LVU229
	.uleb128 .LVU230
	.uleb128 .LVU230
	.uleb128 .LVU236
	.uleb128 .LVU236
	.uleb128 .LVU237
	.uleb128 .LVU237
	.uleb128 .LVU238
	.uleb128 .LVU238
	.uleb128 0
.LLST29:
	.4byte	.LVL58
	.4byte	.LVL59
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL59
	.4byte	.LVL60
	.2byte	0x3
	.byte	0x72
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL60
	.4byte	.LVL62
	.2byte	0x6
	.byte	0xf3
	.uleb128 0x1
	.byte	0x52
	.byte	0x31
	.byte	0x1c
	.byte	0x9f
	.4byte	.LVL62
	.4byte	.LVL62
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL62
	.4byte	.LVL63
	.2byte	0x3
	.byte	0x72
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL63
	.4byte	.LFE11
	.2byte	0x6
	.byte	0xf3
	.uleb128 0x1
	.byte	0x52
	.byte	0x31
	.byte	0x1c
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS30:
	.uleb128 .LVU219
	.uleb128 .LVU226
	.uleb128 .LVU226
	.uleb128 .LVU230
	.uleb128 .LVU230
	.uleb128 .LVU236
	.uleb128 .LVU236
	.uleb128 .LVU238
.LLST30:
	.4byte	.LVL58
	.4byte	.LVL59
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL59
	.4byte	.LVL60
	.2byte	0x1
	.byte	0x5c
	.4byte	.LVL60
	.4byte	.LVL62
	.2byte	0x7
	.byte	0x70
	.sleb128 0
	.byte	0xf3
	.uleb128 0x1
	.byte	0x52
	.byte	0x22
	.byte	0x9f
	.4byte	.LVL62
	.4byte	.LVL63
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS31:
	.uleb128 .LVU220
	.uleb128 .LVU227
	.uleb128 .LVU227
	.uleb128 .LVU231
	.uleb128 .LVU231
	.uleb128 .LVU232
	.uleb128 .LVU232
	.uleb128 .LVU236
	.uleb128 .LVU236
	.uleb128 .LVU239
	.uleb128 .LVU239
	.uleb128 .LVU240
	.uleb128 .LVU240
	.uleb128 0
.LLST31:
	.4byte	.LVL58
	.4byte	.LVL59
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL59
	.4byte	.LVL60
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL60
	.4byte	.LVL61
	.2byte	0x3
	.byte	0x73
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL61
	.4byte	.LVL62
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL62
	.4byte	.LVL63
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL63
	.4byte	.LVL64
	.2byte	0x3
	.byte	0x71
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL64
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x51
	.4byte	0
	.4byte	0
.LVUS19:
	.uleb128 0
	.uleb128 .LVU180
	.uleb128 .LVU180
	.uleb128 0
.LLST19:
	.4byte	.LVL41
	.4byte	.LVL43
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL43
	.4byte	.LFE10
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS20:
	.uleb128 0
	.uleb128 .LVU179
	.uleb128 .LVU179
	.uleb128 .LVU180
	.uleb128 .LVU180
	.uleb128 0
.LLST20:
	.4byte	.LVL41
	.4byte	.LVL42
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL42
	.4byte	.LVL43
	.2byte	0x3
	.byte	0x72
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL43
	.4byte	.LFE10
	.2byte	0x6
	.byte	0xf3
	.uleb128 0x1
	.byte	0x52
	.byte	0x31
	.byte	0x1c
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS21:
	.uleb128 .LVU176
	.uleb128 .LVU180
.LLST21:
	.4byte	.LVL42
	.4byte	.LVL43
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS22:
	.uleb128 .LVU177
	.uleb128 .LVU181
	.uleb128 .LVU181
	.uleb128 .LVU182
	.uleb128 .LVU182
	.uleb128 0
.LLST22:
	.4byte	.LVL42
	.4byte	.LVL43
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL43
	.4byte	.LVL44
	.2byte	0x3
	.byte	0x71
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL44
	.4byte	.LFE10
	.2byte	0x1
	.byte	0x51
	.4byte	0
	.4byte	0
.LVUS8:
	.uleb128 0
	.uleb128 .LVU125
	.uleb128 .LVU125
	.uleb128 0
.LLST8:
	.4byte	.LVL20
	.4byte	.LVL23
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL23
	.4byte	.LFE9
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS9:
	.uleb128 0
	.uleb128 .LVU123
	.uleb128 .LVU123
	.uleb128 .LVU124
	.uleb128 .LVU124
	.uleb128 .LVU126
.LLST9:
	.4byte	.LVL20
	.4byte	.LVL21
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL21
	.4byte	.LVL22
	.2byte	0x3
	.byte	0x72
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL22
	.4byte	.LVL24
	.2byte	0x6
	.byte	0xf3
	.uleb128 0x1
	.byte	0x52
	.byte	0x31
	.byte	0x1c
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS10:
	.uleb128 .LVU121
	.uleb128 .LVU126
	.uleb128 .LVU126
	.uleb128 .LVU127
	.uleb128 .LVU127
	.uleb128 .LVU128
	.uleb128 .LVU128
	.uleb128 0
.LLST10:
	.4byte	.LVL21
	.4byte	.LVL24
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL24
	.4byte	.LVL24
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL24
	.4byte	.LVL25
	.2byte	0x3
	.byte	0x73
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL25
	.4byte	.LFE9
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS23:
	.uleb128 0
	.uleb128 .LVU198
	.uleb128 .LVU198
	.uleb128 .LVU199
	.uleb128 .LVU199
	.uleb128 .LVU201
	.uleb128 .LVU201
	.uleb128 .LVU208
	.uleb128 .LVU208
	.uleb128 .LVU211
	.uleb128 .LVU211
	.uleb128 .LVU212
	.uleb128 .LVU212
	.uleb128 .LVU215
	.uleb128 .LVU215
	.uleb128 0
.LLST23:
	.4byte	.LVL45
	.4byte	.LVL48
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL48
	.4byte	.LVL49
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL49
	.4byte	.LVL50
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL50
	.4byte	.LVL54
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL54
	.4byte	.LVL55
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL55
	.4byte	.LVL56
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	.LVL56
	.4byte	.LVL57-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL57-1
	.4byte	.LFE8
	.2byte	0x1
	.byte	0x55
	.4byte	0
	.4byte	0
.LVUS24:
	.uleb128 0
	.uleb128 .LVU198
	.uleb128 .LVU198
	.uleb128 .LVU199
	.uleb128 .LVU199
	.uleb128 .LVU202
	.uleb128 .LVU202
	.uleb128 .LVU208
	.uleb128 .LVU208
	.uleb128 .LVU212
	.uleb128 .LVU212
	.uleb128 .LVU212
	.uleb128 .LVU212
	.uleb128 .LVU215
	.uleb128 .LVU215
	.uleb128 0
.LLST24:
	.4byte	.LVL45
	.4byte	.LVL48
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL48
	.4byte	.LVL49
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	.LVL49
	.4byte	.LVL51-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL51-1
	.4byte	.LVL54
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	.LVL54
	.4byte	.LVL56-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL56-1
	.4byte	.LVL56
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	.LVL56
	.4byte	.LVL57-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL57-1
	.4byte	.LFE8
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS25:
	.uleb128 .LVU202
	.uleb128 .LVU205
	.uleb128 .LVU205
	.uleb128 .LVU208
.LLST25:
	.4byte	.LVL51
	.4byte	.LVL52-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL52-1
	.4byte	.LVL54
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS26:
	.uleb128 .LVU194
	.uleb128 .LVU198
	.uleb128 .LVU199
	.uleb128 .LVU201
	.uleb128 .LVU201
	.uleb128 .LVU208
.LLST26:
	.4byte	.LVL46
	.4byte	.LVL48
	.2byte	0x3
	.byte	0x70
	.sleb128 -12
	.byte	0x9f
	.4byte	.LVL49
	.4byte	.LVL50
	.2byte	0x3
	.byte	0x70
	.sleb128 -12
	.byte	0x9f
	.4byte	.LVL50
	.4byte	.LVL54
	.2byte	0x3
	.byte	0x75
	.sleb128 -12
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS27:
	.uleb128 .LVU196
	.uleb128 .LVU198
	.uleb128 .LVU199
	.uleb128 .LVU208
.LLST27:
	.4byte	.LVL47
	.4byte	.LVL48
	.2byte	0x1
	.byte	0x56
	.4byte	.LVL49
	.4byte	.LVL54
	.2byte	0x1
	.byte	0x56
	.4byte	0
	.4byte	0
.LVUS7:
	.uleb128 0
	.uleb128 .LVU117
	.uleb128 .LVU117
	.uleb128 0
.LLST7:
	.4byte	.LVL18
	.4byte	.LVL19-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL19-1
	.4byte	.LFE7
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS15:
	.uleb128 0
	.uleb128 .LVU168
	.uleb128 .LVU168
	.uleb128 0
.LLST15:
	.4byte	.LVL36
	.4byte	.LVL38
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL38
	.4byte	.LFE6
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS16:
	.uleb128 0
	.uleb128 .LVU169
	.uleb128 .LVU169
	.uleb128 0
.LLST16:
	.4byte	.LVL36
	.4byte	.LVL39-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL39-1
	.4byte	.LFE6
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS17:
	.uleb128 .LVU166
	.uleb128 .LVU172
.LLST17:
	.4byte	.LVL37
	.4byte	.LVL40
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS18:
	.uleb128 .LVU169
	.uleb128 .LVU172
	.uleb128 .LVU172
	.uleb128 .LVU172
.LLST18:
	.4byte	.LVL39
	.4byte	.LVL40-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL40-1
	.4byte	.LVL40
	.2byte	0x1
	.byte	0x55
	.4byte	0
	.4byte	0
.LVUS13:
	.uleb128 0
	.uleb128 .LVU150
	.uleb128 .LVU150
	.uleb128 0
.LLST13:
	.4byte	.LVL33
	.4byte	.LVL34-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL34-1
	.4byte	.LFE5
	.2byte	0x1
	.byte	0x55
	.4byte	0
	.4byte	0
.LVUS14:
	.uleb128 .LVU150
	.uleb128 .LVU153
	.uleb128 .LVU153
	.uleb128 0
.LLST14:
	.4byte	.LVL34
	.4byte	.LVL35-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL35-1
	.4byte	.LFE5
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS11:
	.uleb128 0
	.uleb128 .LVU134
	.uleb128 .LVU134
	.uleb128 0
.LLST11:
	.4byte	.LVL26
	.4byte	.LVL27
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL27
	.4byte	.LFE4
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS12:
	.uleb128 .LVU136
	.uleb128 .LVU139
	.uleb128 .LVU139
	.uleb128 .LVU141
	.uleb128 .LVU141
	.uleb128 .LVU142
	.uleb128 .LVU142
	.uleb128 0
.LLST12:
	.4byte	.LVL28
	.4byte	.LVL29-1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL29-1
	.4byte	.LVL30
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL30
	.4byte	.LVL31
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL31
	.4byte	.LFE4
	.2byte	0x1
	.byte	0x55
	.4byte	0
	.4byte	0
.LVUS4:
	.uleb128 0
	.uleb128 .LVU102
	.uleb128 .LVU102
	.uleb128 .LVU107
	.uleb128 .LVU107
	.uleb128 0
.LLST4:
	.4byte	.LVL11
	.4byte	.LVL16
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL16
	.4byte	.LVL17
	.2byte	0x3
	.byte	0x7e
	.sleb128 12
	.byte	0x9f
	.4byte	.LVL17
	.4byte	.LFE3
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS5:
	.uleb128 .LVU83
	.uleb128 0
.LLST5:
	.4byte	.LVL12
	.4byte	.LFE3
	.2byte	0x1
	.byte	0x5e
	.4byte	0
	.4byte	0
.LVUS6:
	.uleb128 .LVU89
	.uleb128 .LVU91
	.uleb128 .LVU92
	.uleb128 .LVU94
	.uleb128 .LVU94
	.uleb128 .LVU107
.LLST6:
	.4byte	.LVL13
	.4byte	.LVL14
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL14
	.4byte	.LVL15
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL15
	.4byte	.LVL17
	.2byte	0x1
	.byte	0x52
	.4byte	0
	.4byte	0
.LVUS0:
	.uleb128 0
	.uleb128 .LVU10
	.uleb128 .LVU10
	.uleb128 .LVU15
	.uleb128 .LVU26
	.uleb128 .LVU48
.LLST0:
	.4byte	.LVL0
	.4byte	.LVL1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL1
	.4byte	.LVL3
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL7
	.4byte	.LVL8
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS1:
	.uleb128 .LVU12
	.uleb128 .LVU24
	.uleb128 .LVU48
	.uleb128 0
.LLST1:
	.4byte	.LVL2
	.4byte	.LVL6
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL8
	.4byte	.LFE2
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS2:
	.uleb128 .LVU13
	.uleb128 .LVU15
	.uleb128 .LVU18
	.uleb128 .LVU23
	.uleb128 .LVU48
	.uleb128 0
.LLST2:
	.4byte	.LVL2
	.4byte	.LVL3
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL4
	.4byte	.LVL5
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL8
	.4byte	.LFE2
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS3:
	.uleb128 .LVU53
	.uleb128 .LVU65
.LLST3:
	.4byte	.LVL9
	.4byte	.LVL10
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
	.section	.debug_aranges,"",%progbits
	.4byte	0xa4
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.4byte	.LFB3
	.4byte	.LFE3-.LFB3
	.4byte	.LFB7
	.4byte	.LFE7-.LFB7
	.4byte	.LFB9
	.4byte	.LFE9-.LFB9
	.4byte	.LFB4
	.4byte	.LFE4-.LFB4
	.4byte	.LFB5
	.4byte	.LFE5-.LFB5
	.4byte	.LFB6
	.4byte	.LFE6-.LFB6
	.4byte	.LFB10
	.4byte	.LFE10-.LFB10
	.4byte	.LFB8
	.4byte	.LFE8-.LFB8
	.4byte	.LFB11
	.4byte	.LFE11-.LFB11
	.4byte	.LFB12
	.4byte	.LFE12-.LFB12
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.4byte	.LFB14
	.4byte	.LFE14-.LFB14
	.4byte	.LFB16
	.4byte	.LFE16-.LFB16
	.4byte	.LFB17
	.4byte	.LFE17-.LFB17
	.4byte	.LFB15
	.4byte	.LFE15-.LFB15
	.4byte	.LFB18
	.4byte	.LFE18-.LFB18
	.4byte	.LFB19
	.4byte	.LFE19-.LFB19
	.4byte	0
	.4byte	0
	.section	.debug_ranges,"",%progbits
.Ldebug_ranges0:
	.4byte	.LBB5
	.4byte	.LBE5
	.4byte	.LBB10
	.4byte	.LBE10
	.4byte	.LBB11
	.4byte	.LBE11
	.4byte	.LBB12
	.4byte	.LBE12
	.4byte	0
	.4byte	0
	.4byte	.LFB2
	.4byte	.LFE2
	.4byte	.LFB3
	.4byte	.LFE3
	.4byte	.LFB7
	.4byte	.LFE7
	.4byte	.LFB9
	.4byte	.LFE9
	.4byte	.LFB4
	.4byte	.LFE4
	.4byte	.LFB5
	.4byte	.LFE5
	.4byte	.LFB6
	.4byte	.LFE6
	.4byte	.LFB10
	.4byte	.LFE10
	.4byte	.LFB8
	.4byte	.LFE8
	.4byte	.LFB11
	.4byte	.LFE11
	.4byte	.LFB12
	.4byte	.LFE12
	.4byte	.LFB13
	.4byte	.LFE13
	.4byte	.LFB14
	.4byte	.LFE14
	.4byte	.LFB16
	.4byte	.LFE16
	.4byte	.LFB17
	.4byte	.LFE17
	.4byte	.LFB15
	.4byte	.LFE15
	.4byte	.LFB18
	.4byte	.LFE18
	.4byte	.LFB19
	.4byte	.LFE19
	.4byte	0
	.4byte	0
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.section	.debug_str,"MS",%progbits,1
.LASF15:
	.ascii	"block_header_t\000"
.LASF39:
	.ascii	"header\000"
.LASF17:
	.ascii	"heap_initialized\000"
.LASF30:
	.ascii	"dest\000"
.LASF16:
	.ascii	"free_list\000"
.LASF4:
	.ascii	"short int\000"
.LASF6:
	.ascii	"size_t\000"
.LASF47:
	.ascii	"malloc\000"
.LASF13:
	.ascii	"is_free\000"
.LASF20:
	.ascii	"xstrdup\000"
.LASF40:
	.ascii	"old_size\000"
.LASF35:
	.ascii	"memcpy\000"
.LASF7:
	.ascii	"uint8_t\000"
.LASF41:
	.ascii	"xfree\000"
.LASF18:
	.ascii	"heap\000"
.LASF27:
	.ascii	"xtrycalloc\000"
.LASF55:
	.ascii	"init_heap\000"
.LASF1:
	.ascii	"long long int\000"
.LASF43:
	.ascii	"xmalloc_clear\000"
.LASF54:
	.ascii	"block_header\000"
.LASF36:
	.ascii	"memset\000"
.LASF5:
	.ascii	"long int\000"
.LASF22:
	.ascii	"string\000"
.LASF44:
	.ascii	"xmalloc\000"
.LASF53:
	.ascii	"/home/fred/code/rpi-qemu-gdb/Claude/raspi3b_qemu_\000"
.LASF2:
	.ascii	"long double\000"
.LASF33:
	.ascii	"memmove\000"
.LASF8:
	.ascii	"unsigned char\000"
.LASF24:
	.ascii	"strchr\000"
.LASF32:
	.ascii	"wipememory\000"
.LASF3:
	.ascii	"signed char\000"
.LASF34:
	.ascii	"flags\000"
.LASF11:
	.ascii	"long long unsigned int\000"
.LASF0:
	.ascii	"unsigned int\000"
.LASF50:
	.ascii	"tfp_printf\000"
.LASF9:
	.ascii	"short unsigned int\000"
.LASF37:
	.ascii	"xrealloc\000"
.LASF19:
	.ascii	"char\000"
.LASF49:
	.ascii	"strlen\000"
.LASF28:
	.ascii	"nmemb\000"
.LASF31:
	.ascii	"strcpy\000"
.LASF26:
	.ascii	"pathname\000"
.LASF10:
	.ascii	"long unsigned int\000"
.LASF12:
	.ascii	"size\000"
.LASF52:
	.ascii	"src/memory.c\000"
.LASF38:
	.ascii	"new_ptr\000"
.LASF23:
	.ascii	"strcmp\000"
.LASF21:
	.ascii	"strdup\000"
.LASF25:
	.ascii	"open\000"
.LASF51:
	.ascii	"GNU C17 10.3.1 20210621 (release) -mcpu=cortex-a7 -"
	.ascii	"mfloat-abi=soft -marm -march=armv7ve -g -O2 -fpic -"
	.ascii	"ffreestanding -ffunction-sections -fdata-sections -"
	.ascii	"fno-common\000"
.LASF29:
	.ascii	"total\000"
.LASF48:
	.ascii	"prev\000"
.LASF45:
	.ascii	"free\000"
.LASF42:
	.ascii	"xcalloc\000"
.LASF14:
	.ascii	"next\000"
.LASF46:
	.ascii	"curr\000"
	.ident	"GCC: (15:10.3-2021.07-4) 10.3.1 20210621 (release)"
