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
	.file	"textfilter.c"
@ GNU C17 (15:10.3-2021.07-4) version 10.3.1 20210621 (release) (arm-none-eabi)
@	compiled by GNU C version 11.2.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

@ GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
@ options passed:  -I src -I src/common -imultilib thumb/v7-a/nofp
@ -D__USES_INITFINI__ src/textfilter.c -mcpu=cortex-a7 -mfloat-abi=soft
@ -marm -mlibarch=armv7ve -march=armv7ve
@ -auxbase-strip build/asm_output/textfilter.s -g -O2 -Wall -Wextra -fpic
@ -ffreestanding -ffunction-sections -fdata-sections -fno-common
@ -fverbose-asm
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
	.section	.text.text_filter,"ax",%progbits
	.align	2
	.global	text_filter
	.arch armv7ve
	.syntax unified
	.arm
	.fpu softvfp
	.type	text_filter, %function
text_filter:
.LVL0:
.LFB13:
	.file 1 "src/textfilter.c"
	.loc 1 137 1 view -0
	.cfi_startproc
	@ args = 4, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 138 5 view .LVU1
	.loc 1 139 5 view .LVU2
@ src/textfilter.c:145:     else if( control == IOBUFCTRL_FREE ) {
	.loc 1 145 12 is_stmt 0 view .LVU3
	cmp	r1, #2	@ tmp124,
.LVL1:
	.loc 1 140 5 is_stmt 1 view .LVU4
	.loc 1 142 5 view .LVU5
	.loc 1 145 10 view .LVU6
@ src/textfilter.c:145:     else if( control == IOBUFCTRL_FREE ) {
	.loc 1 145 12 is_stmt 0 view .LVU7
	beq	.L8		@,
	.loc 1 154 5 is_stmt 1 view .LVU8
@ src/textfilter.c:155: }
	.loc 1 155 1 is_stmt 0 view .LVU9
	mov	r0, #0	@,
.LVL2:
	.loc 1 155 1 view .LVU10
	bx	lr	@
.LVL3:
.L8:
.LBB2:
	.loc 1 149 2 is_stmt 1 view .LVU11
.LBE2:
@ src/textfilter.c:137: {
	.loc 1 137 1 is_stmt 0 view .LVU12
	push	{r4, lr}	@
	.cfi_def_cfa_offset 8
	.cfi_offset 4, -8
	.cfi_offset 14, -4
	mov	r4, r0	@ opaque, tmp123
.LBB3:
@ src/textfilter.c:149: 	xfree( tfx->buffer );
	.loc 1 149 2 view .LVU13
	ldr	r0, [r0]	@, MEM[(struct text_filter_context_t *)opaque_5(D)].buffer
.LVL4:
	.loc 1 149 2 view .LVU14
	bl	xfree(PLT)	@
.LVL5:
	.loc 1 150 2 is_stmt 1 view .LVU15
@ src/textfilter.c:150: 	tfx->buffer = NULL;
	.loc 1 150 14 is_stmt 0 view .LVU16
	mov	r3, #0	@ tmp121,
.LBE3:
@ src/textfilter.c:155: }
	.loc 1 155 1 view .LVU17
	mov	r0, #0	@,
.LBB4:
@ src/textfilter.c:150: 	tfx->buffer = NULL;
	.loc 1 150 14 view .LVU18
	str	r3, [r4]	@ tmp121, MEM[(struct text_filter_context_t *)opaque_5(D)].buffer
.LBE4:
	.loc 1 154 5 is_stmt 1 view .LVU19
@ src/textfilter.c:155: }
	.loc 1 155 1 is_stmt 0 view .LVU20
	pop	{r4, pc}	@
	.cfi_endproc
.LFE13:
	.size	text_filter, .-text_filter
	.text
.Letext0:
	.file 2 "/usr/lib/gcc/arm-none-eabi/10.3.1/include/stddef.h"
	.file 3 "/usr/include/newlib/sys/_types.h"
	.file 4 "/usr/include/newlib/sys/types.h"
	.file 5 "src/common/../common/types.h"
	.file 6 "src/common/iobuf.h"
	.file 7 "src/filter.h"
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.4byte	0x3ef
	.2byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF56
	.byte	0xc
	.4byte	.LASF57
	.4byte	.LASF58
	.4byte	.Ldebug_ranges0+0x20
	.4byte	0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.4byte	.LASF0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF1
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.4byte	.LASF2
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.4byte	.LASF3
	.uleb128 0x2
	.byte	0x4
	.byte	0x5
	.4byte	.LASF4
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF5
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.4byte	.LASF6
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.4byte	.LASF7
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF8
	.uleb128 0x4
	.4byte	.LASF10
	.byte	0x2
	.byte	0xd1
	.byte	0x17
	.4byte	0x64
	.uleb128 0x2
	.byte	0x8
	.byte	0x4
	.4byte	.LASF9
	.uleb128 0x5
	.byte	0x4
	.uleb128 0x4
	.4byte	.LASF11
	.byte	0x3
	.byte	0x2e
	.byte	0xe
	.4byte	0x41
	.uleb128 0x4
	.4byte	.LASF12
	.byte	0x3
	.byte	0x66
	.byte	0x10
	.4byte	0x80
	.uleb128 0x6
	.byte	0x4
	.4byte	0x9e
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF13
	.uleb128 0x4
	.4byte	.LASF14
	.byte	0x4
	.byte	0x9d
	.byte	0x12
	.4byte	0x8c
	.uleb128 0x4
	.4byte	.LASF15
	.byte	0x5
	.byte	0x4a
	.byte	0x1c
	.4byte	0x2c
	.uleb128 0x7
	.byte	0x7
	.byte	0x1
	.4byte	0x2c
	.byte	0x6
	.byte	0x76
	.byte	0x3
	.4byte	0xfc
	.uleb128 0x8
	.4byte	.LASF16
	.byte	0x1
	.uleb128 0x8
	.4byte	.LASF17
	.byte	0x2
	.uleb128 0x8
	.4byte	.LASF18
	.byte	0x3
	.uleb128 0x8
	.4byte	.LASF19
	.byte	0x4
	.uleb128 0x8
	.4byte	.LASF20
	.byte	0x5
	.uleb128 0x8
	.4byte	.LASF21
	.byte	0x6
	.uleb128 0x8
	.4byte	.LASF22
	.byte	0x7
	.uleb128 0x8
	.4byte	.LASF23
	.byte	0x10
	.byte	0
	.uleb128 0x9
	.4byte	.LASF59
	.byte	0x7
	.byte	0x1
	.4byte	0x2c
	.byte	0x6
	.byte	0x8c
	.byte	0x6
	.4byte	0x127
	.uleb128 0x8
	.4byte	.LASF24
	.byte	0
	.uleb128 0x8
	.4byte	.LASF25
	.byte	0x1
	.uleb128 0x8
	.4byte	.LASF26
	.byte	0x2
	.uleb128 0x8
	.4byte	.LASF27
	.byte	0x3
	.byte	0
	.uleb128 0x4
	.4byte	.LASF28
	.byte	0x6
	.byte	0xa0
	.byte	0x1e
	.4byte	0x133
	.uleb128 0x6
	.byte	0x4
	.4byte	0x139
	.uleb128 0xa
	.4byte	.LASF60
	.byte	0x48
	.byte	0x6
	.byte	0xa4
	.byte	0x8
	.4byte	0x209
	.uleb128 0xb
	.ascii	"use\000"
	.byte	0x6
	.byte	0xa8
	.byte	0x12
	.4byte	0xfc
	.byte	0
	.uleb128 0xc
	.4byte	.LASF29
	.byte	0x6
	.byte	0xad
	.byte	0x9
	.4byte	0xa5
	.byte	0x4
	.uleb128 0xc
	.4byte	.LASF30
	.byte	0x6
	.byte	0xb1
	.byte	0x9
	.4byte	0xa5
	.byte	0x8
	.uleb128 0xc
	.4byte	.LASF31
	.byte	0x6
	.byte	0xb6
	.byte	0x9
	.4byte	0xa5
	.byte	0xc
	.uleb128 0xc
	.4byte	.LASF32
	.byte	0x6
	.byte	0xbb
	.byte	0x7
	.4byte	0x5d
	.byte	0x10
	.uleb128 0xb
	.ascii	"d\000"
	.byte	0x6
	.byte	0xdd
	.byte	0x5
	.4byte	0x215
	.byte	0x14
	.uleb128 0xc
	.4byte	.LASF33
	.byte	0x6
	.byte	0xe3
	.byte	0x7
	.4byte	0x5d
	.byte	0x24
	.uleb128 0xc
	.4byte	.LASF34
	.byte	0x6
	.byte	0xe9
	.byte	0x7
	.4byte	0x5d
	.byte	0x28
	.uleb128 0xc
	.4byte	.LASF35
	.byte	0x6
	.byte	0xed
	.byte	0x9
	.4byte	0x282
	.byte	0x2c
	.uleb128 0xc
	.4byte	.LASF36
	.byte	0x6
	.byte	0xf1
	.byte	0x9
	.4byte	0x7e
	.byte	0x30
	.uleb128 0xc
	.4byte	.LASF37
	.byte	0x6
	.byte	0xf4
	.byte	0x7
	.4byte	0x5d
	.byte	0x34
	.uleb128 0xc
	.4byte	.LASF38
	.byte	0x6
	.byte	0xfa
	.byte	0x9
	.4byte	0x98
	.byte	0x38
	.uleb128 0xc
	.4byte	.LASF39
	.byte	0x6
	.byte	0xfd
	.byte	0xb
	.4byte	0x127
	.byte	0x3c
	.uleb128 0xd
	.ascii	"no\000"
	.byte	0x6
	.2byte	0x103
	.byte	0x7
	.4byte	0x5d
	.byte	0x40
	.uleb128 0xe
	.4byte	.LASF40
	.byte	0x6
	.2byte	0x10b
	.byte	0x7
	.4byte	0x5d
	.byte	0x44
	.byte	0
	.uleb128 0x4
	.4byte	.LASF41
	.byte	0x6
	.byte	0xa1
	.byte	0x1e
	.4byte	0x133
	.uleb128 0xf
	.byte	0x10
	.byte	0x6
	.byte	0xcf
	.byte	0x3
	.4byte	0x253
	.uleb128 0xc
	.4byte	.LASF42
	.byte	0x6
	.byte	0xd2
	.byte	0xc
	.4byte	0x6b
	.byte	0
	.uleb128 0xc
	.4byte	.LASF43
	.byte	0x6
	.byte	0xd7
	.byte	0xc
	.4byte	0x6b
	.byte	0x4
	.uleb128 0xb
	.ascii	"len\000"
	.byte	0x6
	.byte	0xda
	.byte	0xc
	.4byte	0x6b
	.byte	0x8
	.uleb128 0xb
	.ascii	"buf\000"
	.byte	0x6
	.byte	0xdc
	.byte	0xb
	.4byte	0x253
	.byte	0xc
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0xb1
	.uleb128 0x10
	.4byte	0x5d
	.4byte	0x27c
	.uleb128 0x11
	.4byte	0x7e
	.uleb128 0x11
	.4byte	0x5d
	.uleb128 0x11
	.4byte	0x127
	.uleb128 0x11
	.4byte	0x253
	.uleb128 0x11
	.4byte	0x27c
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0x6b
	.uleb128 0x6
	.byte	0x4
	.4byte	0x259
	.uleb128 0xf
	.byte	0x24
	.byte	0x7
	.byte	0x2e
	.byte	0x9
	.4byte	0x307
	.uleb128 0xc
	.4byte	.LASF44
	.byte	0x7
	.byte	0x2f
	.byte	0xb
	.4byte	0x253
	.byte	0
	.uleb128 0xc
	.4byte	.LASF45
	.byte	0x7
	.byte	0x30
	.byte	0xe
	.4byte	0x64
	.byte	0x4
	.uleb128 0xc
	.4byte	.LASF46
	.byte	0x7
	.byte	0x31
	.byte	0xe
	.4byte	0x64
	.byte	0x8
	.uleb128 0xc
	.4byte	.LASF47
	.byte	0x7
	.byte	0x32
	.byte	0xe
	.4byte	0x64
	.byte	0xc
	.uleb128 0xc
	.4byte	.LASF48
	.byte	0x7
	.byte	0x33
	.byte	0x9
	.4byte	0x5d
	.byte	0x10
	.uleb128 0xc
	.4byte	.LASF49
	.byte	0x7
	.byte	0x34
	.byte	0x9
	.4byte	0x5d
	.byte	0x14
	.uleb128 0xc
	.4byte	.LASF50
	.byte	0x7
	.byte	0x35
	.byte	0x9
	.4byte	0x5d
	.byte	0x18
	.uleb128 0xc
	.4byte	.LASF51
	.byte	0x7
	.byte	0x37
	.byte	0x9
	.4byte	0x5d
	.byte	0x1c
	.uleb128 0xc
	.4byte	.LASF52
	.byte	0x7
	.byte	0x38
	.byte	0x9
	.4byte	0x5d
	.byte	0x20
	.byte	0
	.uleb128 0x4
	.4byte	.LASF53
	.byte	0x7
	.byte	0x39
	.byte	0x3
	.4byte	0x288
	.uleb128 0x12
	.4byte	.LASF61
	.byte	0x1
	.byte	0x87
	.byte	0x1
	.4byte	0x5d
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x3e0
	.uleb128 0x13
	.4byte	.LASF54
	.byte	0x1
	.byte	0x87
	.byte	0x14
	.4byte	0x7e
	.4byte	.LLST0
	.4byte	.LVUS0
	.uleb128 0x13
	.4byte	.LASF55
	.byte	0x1
	.byte	0x87
	.byte	0x20
	.4byte	0x5d
	.4byte	.LLST1
	.4byte	.LVUS1
	.uleb128 0x14
	.ascii	"a\000"
	.byte	0x1
	.byte	0x88
	.byte	0xd
	.4byte	0x209
	.4byte	.LLST2
	.4byte	.LVUS2
	.uleb128 0x14
	.ascii	"buf\000"
	.byte	0x1
	.byte	0x88
	.byte	0x16
	.4byte	0x253
	.4byte	.LLST3
	.4byte	.LVUS3
	.uleb128 0x15
	.4byte	.LASF62
	.byte	0x1
	.byte	0x88
	.byte	0x23
	.4byte	0x27c
	.uleb128 0x2
	.byte	0x91
	.sleb128 0
	.uleb128 0x16
	.4byte	.LASF42
	.byte	0x1
	.byte	0x8a
	.byte	0xc
	.4byte	0x6b
	.4byte	.LLST4
	.4byte	.LVUS4
	.uleb128 0x17
	.ascii	"tfx\000"
	.byte	0x1
	.byte	0x8b
	.byte	0x1c
	.4byte	0x3e0
	.4byte	.LLST5
	.4byte	.LVUS5
	.uleb128 0x18
	.ascii	"rc\000"
	.byte	0x1
	.byte	0x8c
	.byte	0x9
	.4byte	0x5d
	.byte	0
	.uleb128 0x19
	.4byte	.Ldebug_ranges0+0
	.uleb128 0x1a
	.4byte	.LASF63
	.byte	0x1
	.byte	0x95
	.byte	0x2
	.4byte	0x5d
	.4byte	0x3d5
	.uleb128 0x1b
	.byte	0
	.uleb128 0x1c
	.4byte	.LVL5
	.4byte	0x3e6
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x4
	.4byte	0x307
	.uleb128 0x1d
	.4byte	.LASF63
	.4byte	.LASF63
	.byte	0x1
	.byte	0x95
	.byte	0x2
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
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x3
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
	.uleb128 0x4
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
	.uleb128 0x5
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
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
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
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
	.uleb128 0xa
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
	.uleb128 0xb
	.uleb128 0xd
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
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xc
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
	.uleb128 0xd
	.uleb128 0xd
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
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0xd
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
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x13
	.byte	0x1
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
	.uleb128 0x10
	.uleb128 0x15
	.byte	0x1
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x5
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
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
	.uleb128 0x13
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
	.uleb128 0x14
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
	.uleb128 0x15
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
	.uleb128 0x16
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
	.uleb128 0x17
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
	.uleb128 0x18
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
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x55
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x1a
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
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3c
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1b
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x4109
	.byte	0
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1d
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
.LVUS0:
	.uleb128 0
	.uleb128 .LVU10
	.uleb128 .LVU10
	.uleb128 .LVU11
	.uleb128 .LVU11
	.uleb128 .LVU14
	.uleb128 .LVU14
	.uleb128 0
.LLST0:
	.4byte	.LVL0
	.4byte	.LVL2
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL2
	.4byte	.LVL3
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	.LVL3
	.4byte	.LVL4
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL4
	.4byte	.LFE13
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS1:
	.uleb128 0
	.uleb128 .LVU15
	.uleb128 .LVU15
	.uleb128 0
.LLST1:
	.4byte	.LVL0
	.4byte	.LVL5-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL5-1
	.4byte	.LFE13
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x51
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS2:
	.uleb128 0
	.uleb128 .LVU15
	.uleb128 .LVU15
	.uleb128 0
.LLST2:
	.4byte	.LVL0
	.4byte	.LVL5-1
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL5-1
	.4byte	.LFE13
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x52
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS3:
	.uleb128 0
	.uleb128 .LVU15
	.uleb128 .LVU15
	.uleb128 0
.LLST3:
	.4byte	.LVL0
	.4byte	.LVL5-1
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL5-1
	.4byte	.LFE13
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x53
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS4:
	.uleb128 .LVU2
	.uleb128 .LVU15
.LLST4:
	.4byte	.LVL0
	.4byte	.LVL5-1
	.2byte	0x3
	.byte	0x91
	.sleb128 0
	.byte	0x6
	.4byte	0
	.4byte	0
.LVUS5:
	.uleb128 .LVU4
	.uleb128 .LVU10
	.uleb128 .LVU10
	.uleb128 .LVU11
	.uleb128 .LVU11
	.uleb128 .LVU14
	.uleb128 .LVU14
	.uleb128 0
.LLST5:
	.4byte	.LVL1
	.4byte	.LVL2
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL2
	.4byte	.LVL3
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	.LVL3
	.4byte	.LVL4
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL4
	.4byte	.LFE13
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
	.section	.debug_aranges,"",%progbits
	.4byte	0x1c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.4byte	0
	.4byte	0
	.section	.debug_ranges,"",%progbits
.Ldebug_ranges0:
	.4byte	.LBB2
	.4byte	.LBE2
	.4byte	.LBB3
	.4byte	.LBE3
	.4byte	.LBB4
	.4byte	.LBE4
	.4byte	0
	.4byte	0
	.4byte	.LFB13
	.4byte	.LFE13
	.4byte	0
	.4byte	0
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.section	.debug_str,"MS",%progbits,1
.LASF46:
	.ascii	"buffer_len\000"
.LASF54:
	.ascii	"opaque\000"
.LASF22:
	.ascii	"IOBUFCTRL_PEEK\000"
.LASF11:
	.ascii	"_off_t\000"
.LASF52:
	.ascii	"pending_esc\000"
.LASF2:
	.ascii	"short int\000"
.LASF10:
	.ascii	"size_t\000"
.LASF49:
	.ascii	"not_dash_escaped\000"
.LASF51:
	.ascii	"pending_lf\000"
.LASF47:
	.ascii	"buffer_pos\000"
.LASF63:
	.ascii	"xfree\000"
.LASF25:
	.ascii	"IOBUF_INPUT_TEMP\000"
.LASF58:
	.ascii	"/home/fred/code/rpi-qemu-gdb/Claude/raspi3b_qemu_\000"
.LASF6:
	.ascii	"long long int\000"
.LASF20:
	.ascii	"IOBUFCTRL_DESC\000"
.LASF57:
	.ascii	"src/textfilter.c\000"
.LASF4:
	.ascii	"long int\000"
.LASF62:
	.ascii	"ret_len\000"
.LASF14:
	.ascii	"off_t\000"
.LASF18:
	.ascii	"IOBUFCTRL_UNDERFLOW\000"
.LASF15:
	.ascii	"byte\000"
.LASF41:
	.ascii	"IOBUF\000"
.LASF23:
	.ascii	"IOBUFCTRL_USER\000"
.LASF59:
	.ascii	"iobuf_use\000"
.LASF9:
	.ascii	"long double\000"
.LASF55:
	.ascii	"control\000"
.LASF1:
	.ascii	"unsigned char\000"
.LASF0:
	.ascii	"signed char\000"
.LASF7:
	.ascii	"long long unsigned int\000"
.LASF29:
	.ascii	"nlimit\000"
.LASF8:
	.ascii	"unsigned int\000"
.LASF60:
	.ascii	"iobuf_struct\000"
.LASF43:
	.ascii	"start\000"
.LASF3:
	.ascii	"short unsigned int\000"
.LASF26:
	.ascii	"IOBUF_OUTPUT\000"
.LASF17:
	.ascii	"IOBUFCTRL_FREE\000"
.LASF13:
	.ascii	"char\000"
.LASF27:
	.ascii	"IOBUF_OUTPUT_TEMP\000"
.LASF40:
	.ascii	"subno\000"
.LASF50:
	.ascii	"escape_from\000"
.LASF21:
	.ascii	"IOBUFCTRL_CANCEL\000"
.LASF37:
	.ascii	"filter_ov_owner\000"
.LASF19:
	.ascii	"IOBUFCTRL_FLUSH\000"
.LASF44:
	.ascii	"buffer\000"
.LASF36:
	.ascii	"filter_ov\000"
.LASF5:
	.ascii	"long unsigned int\000"
.LASF33:
	.ascii	"filter_eof\000"
.LASF30:
	.ascii	"nbytes\000"
.LASF12:
	.ascii	"__off_t\000"
.LASF42:
	.ascii	"size\000"
.LASF24:
	.ascii	"IOBUF_INPUT\000"
.LASF61:
	.ascii	"text_filter\000"
.LASF45:
	.ascii	"buffer_size\000"
.LASF32:
	.ascii	"nofast\000"
.LASF56:
	.ascii	"GNU C17 10.3.1 20210621 (release) -mcpu=cortex-a7 -"
	.ascii	"mfloat-abi=soft -marm -march=armv7ve -g -O2 -fpic -"
	.ascii	"ffreestanding -ffunction-sections -fdata-sections -"
	.ascii	"fno-common\000"
.LASF34:
	.ascii	"error\000"
.LASF31:
	.ascii	"ntotal\000"
.LASF28:
	.ascii	"iobuf_t\000"
.LASF35:
	.ascii	"filter\000"
.LASF39:
	.ascii	"chain\000"
.LASF38:
	.ascii	"real_fname\000"
.LASF48:
	.ascii	"truncated\000"
.LASF53:
	.ascii	"text_filter_context_t\000"
.LASF16:
	.ascii	"IOBUFCTRL_INIT\000"
	.ident	"GCC: (15:10.3-2021.07-4) 10.3.1 20210621 (release)"
