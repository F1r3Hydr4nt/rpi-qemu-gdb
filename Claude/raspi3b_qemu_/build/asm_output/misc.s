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
	.file	"misc.c"
@ GNU C17 (15:10.3-2021.07-4) version 10.3.1 20210621 (release) (arm-none-eabi)
@	compiled by GNU C version 11.2.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

@ GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
@ options passed:  -I src -I src/common -imultilib thumb/v7-a/nofp
@ -D__USES_INITFINI__ src/misc.c -mcpu=cortex-a7 -mfloat-abi=soft -marm
@ -mlibarch=armv7ve -march=armv7ve -auxbase-strip build/asm_output/misc.s
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
	.section	.text.pubkey_get_nsig,"ax",%progbits
	.align	2
	.global	pubkey_get_nsig
	.arch armv7ve
	.syntax unified
	.arm
	.fpu softvfp
	.type	pubkey_get_nsig, %function
pubkey_get_nsig:
.LVL0:
.LFB1:
	.file 1 "src/misc.c"
	.loc 1 1714 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 1715 3 view .LVU1
	sub	r0, r0, #1	@ tmp116, tmp122,
.LVL1:
	.loc 1 1715 3 is_stmt 0 view .LVU2
	uxtb	r0, r0	@ _1, tmp116
	cmp	r0, #21	@ _1,
	bhi	.L3		@,
	ldr	r3, .L5	@ tmp120,
.LPIC0:
	add	r3, pc, r3	@ tmp120, tmp120
	ldr	r0, [r3, r0, lsl #2]	@ <retval>, CSWTCH.1[_1]
	bx	lr	@
.L3:
@ src/misc.c:1714: {
	.loc 1 1714 1 view .LVU3
	mov	r0, #0	@ <retval>,
@ src/misc.c:1728: }
	.loc 1 1728 1 view .LVU4
	bx	lr	@
.L6:
	.align	2
.L5:
	.word	.LANCHOR0-(.LPIC0+8)
	.cfi_endproc
.LFE1:
	.size	pubkey_get_nsig, .-pubkey_get_nsig
	.section	.text.pubkey_get_nenc,"ax",%progbits
	.align	2
	.global	pubkey_get_nenc
	.syntax unified
	.arm
	.fpu softvfp
	.type	pubkey_get_nenc, %function
pubkey_get_nenc:
.LVL2:
.LFB2:
	.loc 1 1734 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 1735 3 view .LVU6
	sub	r0, r0, #1	@ tmp116, tmp122,
.LVL3:
	.loc 1 1735 3 is_stmt 0 view .LVU7
	uxtb	r0, r0	@ _1, tmp116
	cmp	r0, #21	@ _1,
	bhi	.L9		@,
	ldr	r3, .L10	@ tmp120,
.LPIC1:
	add	r3, pc, r3	@ tmp120, tmp120
	ldr	r0, [r3, r0, lsl #2]	@ <retval>, CSWTCH.3[_1]
	bx	lr	@
.L9:
@ src/misc.c:1734: {
	.loc 1 1734 1 view .LVU8
	mov	r0, #0	@ <retval>,
@ src/misc.c:1748: }
	.loc 1 1748 1 view .LVU9
	bx	lr	@
.L11:
	.align	2
.L10:
	.word	.LANCHOR1-(.LPIC1+8)
	.cfi_endproc
.LFE2:
	.size	pubkey_get_nenc, .-pubkey_get_nenc
	.section	.rodata.CSWTCH.1,"a"
	.align	2
	.set	.LANCHOR0,. + 0
	.type	CSWTCH.1, %object
	.size	CSWTCH.1, 88
CSWTCH.1:
	.word	1
	.word	1
	.word	1
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	2
	.word	0
	.word	2
	.word	2
	.word	0
	.word	2
	.section	.rodata.CSWTCH.3,"a"
	.align	2
	.set	.LANCHOR1,. + 0
	.type	CSWTCH.3, %object
	.size	CSWTCH.3, 88
CSWTCH.3:
	.word	1
	.word	1
	.word	1
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	0
	.word	2
	.word	0
	.word	2
	.word	0
	.word	2
	.word	0
	.word	0
	.text
.Letext0:
	.file 2 "src/common/openpgpdefs.h"
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.4byte	0xec
	.2byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF13
	.byte	0xc
	.4byte	.LASF14
	.4byte	.LASF15
	.4byte	.Ldebug_ranges0+0
	.4byte	0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF0
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.4byte	.LASF1
	.uleb128 0x3
	.byte	0x7
	.byte	0x1
	.4byte	0x25
	.byte	0x2
	.byte	0xa0
	.byte	0x3
	.4byte	0x7e
	.uleb128 0x4
	.4byte	.LASF2
	.byte	0x1
	.uleb128 0x4
	.4byte	.LASF3
	.byte	0x2
	.uleb128 0x4
	.4byte	.LASF4
	.byte	0x3
	.uleb128 0x4
	.4byte	.LASF5
	.byte	0x10
	.uleb128 0x4
	.4byte	.LASF6
	.byte	0x11
	.uleb128 0x4
	.4byte	.LASF7
	.byte	0x12
	.uleb128 0x4
	.4byte	.LASF8
	.byte	0x13
	.uleb128 0x4
	.4byte	.LASF9
	.byte	0x14
	.uleb128 0x4
	.4byte	.LASF10
	.byte	0x16
	.uleb128 0x4
	.4byte	.LASF11
	.byte	0x6e
	.byte	0
	.uleb128 0x5
	.4byte	.LASF16
	.byte	0x2
	.byte	0xad
	.byte	0x1
	.4byte	0x33
	.uleb128 0x6
	.4byte	.LASF17
	.byte	0x1
	.2byte	0x6c5
	.byte	0x1
	.4byte	0xbb
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.4byte	0xbb
	.uleb128 0x7
	.4byte	.LASF12
	.byte	0x1
	.2byte	0x6c5
	.byte	0x20
	.4byte	0x7e
	.4byte	.LLST1
	.4byte	.LVUS1
	.byte	0
	.uleb128 0x8
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x9
	.4byte	.LASF18
	.byte	0x1
	.2byte	0x6b1
	.byte	0x1
	.4byte	0xbb
	.4byte	.LFB1
	.4byte	.LFE1-.LFB1
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x7
	.4byte	.LASF12
	.byte	0x1
	.2byte	0x6b1
	.byte	0x20
	.4byte	0x7e
	.4byte	.LLST0
	.4byte	.LVUS0
	.byte	0
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
	.uleb128 0x4
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x5
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
	.uleb128 0x6
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
	.uleb128 0x7
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
	.uleb128 0x8
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
	.uleb128 0x9
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
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_loc,"",%progbits
.Ldebug_loc0:
.LVUS1:
	.uleb128 0
	.uleb128 .LVU7
	.uleb128 .LVU7
	.uleb128 0
.LLST1:
	.4byte	.LVL2
	.4byte	.LVL3
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL3
	.4byte	.LFE2
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS0:
	.uleb128 0
	.uleb128 .LVU2
	.uleb128 .LVU2
	.uleb128 0
.LLST0:
	.4byte	.LVL0
	.4byte	.LVL1
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL1
	.4byte	.LFE1
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
	.section	.debug_aranges,"",%progbits
	.4byte	0x24
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB1
	.4byte	.LFE1-.LFB1
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.4byte	0
	.4byte	0
	.section	.debug_ranges,"",%progbits
.Ldebug_ranges0:
	.4byte	.LFB1
	.4byte	.LFE1
	.4byte	.LFB2
	.4byte	.LFE2
	.4byte	0
	.4byte	0
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.section	.debug_str,"MS",%progbits,1
.LASF16:
	.ascii	"pubkey_algo_t\000"
.LASF14:
	.ascii	"src/misc.c\000"
.LASF9:
	.ascii	"PUBKEY_ALGO_ELGAMAL\000"
.LASF15:
	.ascii	"/home/fred/code/rpi-qemu-gdb/Claude/raspi3b_qemu_\000"
.LASF3:
	.ascii	"PUBKEY_ALGO_RSA_E\000"
.LASF12:
	.ascii	"algo\000"
.LASF5:
	.ascii	"PUBKEY_ALGO_ELGAMAL_E\000"
.LASF11:
	.ascii	"PUBKEY_ALGO_PRIVATE10\000"
.LASF0:
	.ascii	"unsigned char\000"
.LASF10:
	.ascii	"PUBKEY_ALGO_EDDSA\000"
.LASF4:
	.ascii	"PUBKEY_ALGO_RSA_S\000"
.LASF6:
	.ascii	"PUBKEY_ALGO_DSA\000"
.LASF13:
	.ascii	"GNU C17 10.3.1 20210621 (release) -mcpu=cortex-a7 -"
	.ascii	"mfloat-abi=soft -marm -march=armv7ve -g -O2 -fpic -"
	.ascii	"ffreestanding -ffunction-sections -fdata-sections -"
	.ascii	"fno-common\000"
.LASF2:
	.ascii	"PUBKEY_ALGO_RSA\000"
.LASF18:
	.ascii	"pubkey_get_nsig\000"
.LASF7:
	.ascii	"PUBKEY_ALGO_ECDH\000"
.LASF1:
	.ascii	"short int\000"
.LASF8:
	.ascii	"PUBKEY_ALGO_ECDSA\000"
.LASF17:
	.ascii	"pubkey_get_nenc\000"
	.ident	"GCC: (15:10.3-2021.07-4) 10.3.1 20210621 (release)"
