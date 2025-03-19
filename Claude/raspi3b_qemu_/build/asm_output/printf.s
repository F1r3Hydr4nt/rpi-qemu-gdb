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
	.file	"printf.c"
@ GNU C17 (15:10.3-2021.07-4) version 10.3.1 20210621 (release) (arm-none-eabi)
@	compiled by GNU C version 11.2.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

@ GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
@ options passed:  -I src -I src/common -imultilib thumb/v7-a/nofp
@ -D__USES_INITFINI__ src/printf.c -mcpu=cortex-a7 -mfloat-abi=soft -marm
@ -mlibarch=armv7ve -march=armv7ve -auxbase-strip build/asm_output/printf.s
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
	.section	.text.uli2a,"ax",%progbits
	.align	2
	.arch armv7ve
	.syntax unified
	.arm
	.fpu softvfp
	.type	uli2a, %function
uli2a:
.LVL0:
.LFB2:
	.file 1 "src/printf.c"
	.loc 1 50 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 51 5 view .LVU1
	.loc 1 52 5 view .LVU2
	.loc 1 53 5 view .LVU3
	.loc 1 53 11 view .LVU4
	cmp	r0, r1	@ num, base
@ src/printf.c:52:     unsigned int d = 1;
	.loc 1 52 18 is_stmt 0 view .LVU5
	mov	ip, #1	@ d,
@ src/printf.c:50: {
	.loc 1 50 1 view .LVU6
	push	{r4, r5, r6, lr}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 4, -16
	.cfi_offset 5, -12
	.cfi_offset 6, -8
	.cfi_offset 14, -4
@ src/printf.c:53:     while (num / d >= base)
	.loc 1 53 11 view .LVU7
	bcc	.L10		@,
.LVL1:
.L3:
	.loc 1 54 9 is_stmt 1 view .LVU8
@ src/printf.c:54:         d *= base;
	.loc 1 54 11 is_stmt 0 view .LVU9
	mul	ip, r1, ip	@ d, base, d
.LVL2:
	.loc 1 53 11 is_stmt 1 view .LVU10
@ src/printf.c:53:     while (num / d >= base)
	.loc 1 53 16 is_stmt 0 view .LVU11
	udiv	lr, r0, ip	@ _2, num, d
@ src/printf.c:53:     while (num / d >= base)
	.loc 1 53 11 view .LVU12
	cmp	lr, r1	@ _2, base
	bcs	.L3		@,
	.loc 1 55 11 is_stmt 1 view .LVU13
	cmp	ip, #0	@ d,
	beq	.L18		@,
.LVL3:
.L2:
@ src/printf.c:51:     int n = 0;
	.loc 1 51 9 is_stmt 0 view .LVU14
	mov	r4, #0	@ n,
.L9:
.LVL4:
.LBB7:
	.loc 1 57 9 is_stmt 1 view .LVU15
	.loc 1 58 9 view .LVU16
	.loc 1 62 13 view .LVU17
@ src/printf.c:60:         if (n || dgt > 0 || d == 0)
	.loc 1 60 12 is_stmt 0 view .LVU18
	cmp	lr, #0	@ _2,
	cmple	r4, #0	@, n,
@ src/printf.c:59:         d /= base;
	.loc 1 59 11 view .LVU19
	udiv	r6, ip, r1	@ d, d, base
@ src/printf.c:60:         if (n || dgt > 0 || d == 0)
	.loc 1 60 12 view .LVU20
	movne	r5, #1	@ tmp146,
	moveq	r5, #0	@ tmp146,
@ src/printf.c:58:         num %= d;
	.loc 1 58 13 view .LVU21
	mls	r0, ip, lr, r0	@ num, d, _2, num
	.loc 1 59 9 is_stmt 1 view .LVU22
.LVL5:
	.loc 1 60 9 view .LVU23
@ src/printf.c:60:         if (n || dgt > 0 || d == 0)
	.loc 1 60 12 is_stmt 0 view .LVU24
	bne	.L5		@,
.LVL6:
@ src/printf.c:60:         if (n || dgt > 0 || d == 0)
	.loc 1 60 26 discriminator 1 view .LVU25
	cmp	r1, ip	@ base, d
	mov	r4, r5	@ n, tmp146
	bls	.L7		@,
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 16 view .LVU26
	mov	ip, r3	@ bf, bf
.LVL7:
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 25 view .LVU27
	add	lr, lr, #48	@ tmp153, _2,
.LVL8:
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 19 view .LVU28
	strb	lr, [ip], #1	@ tmp153, *bf_40
.LVL9:
	.loc 1 63 13 is_stmt 1 view .LVU29
	.loc 1 63 13 is_stmt 0 view .LVU30
.LBE7:
	.loc 1 55 11 is_stmt 1 view .LVU31
.L4:
	.loc 1 66 5 view .LVU32
@ src/printf.c:66:     *bf = 0;
	.loc 1 66 9 is_stmt 0 view .LVU33
	mov	r3, #0	@ tmp150,
	strb	r3, [ip]	@ tmp150, *bf_42
@ src/printf.c:67: }
	.loc 1 67 1 view .LVU34
	pop	{r4, r5, r6, pc}	@
.LVL10:
.L5:
.LBB8:
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 25 view .LVU35
	cmp	lr, #9	@ _2,
	movle	r5, #48	@ iftmp.21_13,
	ble	.L8		@,
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 25 discriminator 1 view .LVU36
	cmp	r2, #0	@ uc,
	movne	r5, #55	@ iftmp.21_13,
	moveq	r5, #87	@ iftmp.21_13,
.L8:
	.loc 1 62 25 discriminator 1 view .LVU37
.LBE8:
@ src/printf.c:55:     while (d != 0)
	.loc 1 55 11 discriminator 8 view .LVU38
	cmp	r1, ip	@ base, d
.LBB9:
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 16 discriminator 8 view .LVU39
	mov	ip, r3	@ bf, bf
.LVL11:
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 25 discriminator 8 view .LVU40
	add	lr, r5, lr	@ tmp148, iftmp.21_13, _2
.LVL12:
@ src/printf.c:63:             ++n;
	.loc 1 63 13 discriminator 8 view .LVU41
	add	r4, r4, #1	@ n, n,
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 19 discriminator 8 view .LVU42
	strb	lr, [ip], #1	@ tmp148, *bf_40
.LVL13:
	.loc 1 63 13 is_stmt 1 discriminator 8 view .LVU43
	.loc 1 63 13 is_stmt 0 discriminator 8 view .LVU44
.LBE9:
	.loc 1 55 11 is_stmt 1 discriminator 8 view .LVU45
.LBB10:
@ src/printf.c:62:             *bf++ = dgt + (dgt < 10 ? '0' : (uc ? 'A' : 'a') - 10);
	.loc 1 62 16 is_stmt 0 discriminator 8 view .LVU46
	mov	r3, ip	@ bf, bf
.LBE10:
@ src/printf.c:55:     while (d != 0)
	.loc 1 55 11 discriminator 8 view .LVU47
	bhi	.L4		@,
.LVL14:
.L7:
	.loc 1 55 11 discriminator 8 view .LVU48
	udiv	lr, r0, r6	@ _2, num, d
@ src/printf.c:51:     int n = 0;
	.loc 1 51 9 view .LVU49
	mov	ip, r6	@ d, d
	b	.L9		@
.LVL15:
.L18:
@ src/printf.c:55:     while (d != 0)
	.loc 1 55 11 view .LVU50
	mov	ip, r3	@ bf, bf
.LVL16:
	.loc 1 55 11 view .LVU51
	b	.L4		@
.LVL17:
.L10:
	.loc 1 55 11 view .LVU52
	mov	lr, r0	@ _2, num
	b	.L2		@
	.cfi_endproc
.LFE2:
	.size	uli2a, .-uli2a
	.set	ui2a,uli2a
	.section	.text.putchw,"ax",%progbits
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	putchw, %function
putchw:
.LVL18:
.LFB9:
	.loc 1 147 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 4, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 148 5 view .LVU54
@ src/printf.c:147: {
	.loc 1 147 1 is_stmt 0 view .LVU55
	push	{r4, r5, r6, r7, r8, lr}	@
	.cfi_def_cfa_offset 24
	.cfi_offset 4, -24
	.cfi_offset 5, -20
	.cfi_offset 6, -16
	.cfi_offset 7, -12
	.cfi_offset 8, -8
	.cfi_offset 14, -4
@ src/printf.c:147: {
	.loc 1 147 1 view .LVU56
	mov	r7, r1	@ tmp129, putf
@ src/printf.c:151:     while (*p++ && n > 0)
	.loc 1 151 14 view .LVU57
	ldr	r5, [sp, #24]	@ bf, bf
@ src/printf.c:148:     char fc = z ? '0' : ' ';
	.loc 1 148 10 view .LVU58
	cmp	r3, #0	@ tmp131,
	movne	r8, #48	@ iftmp.31_6,
	moveq	r8, #32	@ iftmp.31_6,
.LVL19:
	.loc 1 149 5 is_stmt 1 view .LVU59
	.loc 1 150 5 view .LVU60
	.loc 1 151 5 view .LVU61
@ src/printf.c:151:     while (*p++ && n > 0)
	.loc 1 151 12 is_stmt 0 view .LVU62
	ldrb	r1, [r5], #1	@ zero_extendqisi2	@ ch, *bf_11(D)
.LVL20:
@ src/printf.c:147: {
	.loc 1 147 1 view .LVU63
	mov	r6, r0	@ putp, tmp128
	.loc 1 151 11 is_stmt 1 view .LVU64
.LVL21:
	.loc 1 151 11 is_stmt 0 view .LVU65
	cmp	r1, #0	@ ch,
	beq	.L21		@,
@ src/printf.c:151:     while (*p++ && n > 0)
	.loc 1 151 17 view .LVU66
	cmp	r2, #0	@ n,
	ble	.L26		@,
@ src/printf.c:151:     while (*p++ && n > 0)
	.loc 1 151 14 view .LVU67
	mov	r3, r5	@ p, bf
.LVL22:
	.loc 1 151 14 view .LVU68
	b	.L24		@
.LVL23:
.L35:
@ src/printf.c:151:     while (*p++ && n > 0)
	.loc 1 151 17 discriminator 1 view .LVU69
	cmp	r2, #0	@ n,
	beq	.L26		@,
.L24:
.LVL24:
	.loc 1 152 9 is_stmt 1 view .LVU70
@ src/printf.c:151:     while (*p++ && n > 0)
	.loc 1 151 11 is_stmt 0 view .LVU71
	ldrb	r0, [r3], #1	@ zero_extendqisi2	@ MEM[base: p_13, offset: 4294967295B], MEM[base: p_13, offset: 4294967295B]
.LVL25:
	.loc 1 151 11 view .LVU72
	mov	r4, r2	@ n, n
@ src/printf.c:152:         n--;
	.loc 1 152 10 view .LVU73
	sub	r2, r2, #1	@ n, n,
.LVL26:
	.loc 1 151 11 is_stmt 1 view .LVU74
	cmp	r0, #0	@ MEM[base: p_13, offset: 4294967295B],
	bne	.L35		@,
	.loc 1 153 11 view .LVU75
	cmp	r2, #0	@ n,
@ src/printf.c:153:     while (n-- > 0)
	.loc 1 153 13 is_stmt 0 view .LVU76
	sub	r4, r4, #2	@ n, n,
.LVL27:
@ src/printf.c:153:     while (n-- > 0)
	.loc 1 153 11 view .LVU77
	beq	.L26		@,
.L25:
	.loc 1 154 9 is_stmt 1 view .LVU78
	mov	r1, r8	@, iftmp.31_6
	mov	r0, r6	@, putp
	blx	r7		@ putf
.LVL28:
	.loc 1 153 11 view .LVU79
	cmp	r4, #0	@ n,
@ src/printf.c:153:     while (n-- > 0)
	.loc 1 153 13 is_stmt 0 view .LVU80
	sub	r4, r4, #1	@ n, n,
.LVL29:
@ src/printf.c:153:     while (n-- > 0)
	.loc 1 153 11 view .LVU81
	bgt	.L25		@,
.LVL30:
	.loc 1 155 11 is_stmt 1 view .LVU82
@ src/printf.c:155:     while ((ch = *bf++))
	.loc 1 155 16 is_stmt 0 view .LVU83
	ldr	r3, [sp, #24]	@ tmp133, bf
	ldrb	r1, [r3]	@ zero_extendqisi2	@ ch, *bf_11(D)
.LVL31:
@ src/printf.c:155:     while ((ch = *bf++))
	.loc 1 155 11 view .LVU84
	cmp	r1, #0	@ ch,
	popeq	{r4, r5, r6, r7, r8, pc}	@
.LVL32:
.L26:
	.loc 1 156 9 is_stmt 1 view .LVU85
	mov	r0, r6	@, putp
	blx	r7		@ putf
.LVL33:
	.loc 1 155 11 view .LVU86
@ src/printf.c:155:     while ((ch = *bf++))
	.loc 1 155 16 is_stmt 0 view .LVU87
	ldrb	r1, [r5], #1	@ zero_extendqisi2	@ ch, MEM[base: bf_17, offset: 4294967295B]
.LVL34:
@ src/printf.c:155:     while ((ch = *bf++))
	.loc 1 155 11 view .LVU88
	cmp	r1, #0	@ ch,
	bne	.L26		@,
	pop	{r4, r5, r6, r7, r8, pc}	@
.LVL35:
.L21:
	.loc 1 153 11 is_stmt 1 view .LVU89
	cmp	r2, #0	@ n,
@ src/printf.c:153:     while (n-- > 0)
	.loc 1 153 13 is_stmt 0 view .LVU90
	sub	r4, r2, #1	@ n, n,
.LVL36:
@ src/printf.c:153:     while (n-- > 0)
	.loc 1 153 11 view .LVU91
	bgt	.L25		@,
	pop	{r4, r5, r6, r7, r8, pc}	@
	.cfi_endproc
.LFE9:
	.size	putchw, .-putchw
	.section	.text.putcp,"ax",%progbits
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	putcp, %function
putcp:
.LVL37:
.LFB14:
	.loc 1 300 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 301 5 view .LVU93
@ src/printf.c:301:     *(*((char **)p))++ = c;
	.loc 1 301 7 is_stmt 0 view .LVU94
	ldr	r3, [r0]	@ _1, MEM[(char * *)p_4(D)]
@ src/printf.c:301:     *(*((char **)p))++ = c;
	.loc 1 301 21 view .LVU95
	add	r2, r3, #1	@ tmp117, _1,
	str	r2, [r0]	@ tmp117, MEM[(char * *)p_4(D)]
@ src/printf.c:301:     *(*((char **)p))++ = c;
	.loc 1 301 24 view .LVU96
	strb	r1, [r3]	@ tmp120, *_1
@ src/printf.c:302: }
	.loc 1 302 1 view .LVU97
	bx	lr	@
	.cfi_endproc
.LFE14:
	.size	putcp, .-putcp
	.section	.text.tfp_format,"ax",%progbits
	.align	2
	.global	tfp_format
	.syntax unified
	.arm
	.fpu softvfp
	.type	tfp_format, %function
tfp_format:
.LVL38:
.LFB11:
	.loc 1 181 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 0, uses_anonymous_args = 0
	.loc 1 181 1 is_stmt 0 view .LVU99
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}	@
	.cfi_def_cfa_offset 36
	.cfi_offset 4, -36
	.cfi_offset 5, -32
	.cfi_offset 6, -28
	.cfi_offset 7, -24
	.cfi_offset 8, -20
	.cfi_offset 9, -16
	.cfi_offset 10, -12
	.cfi_offset 11, -8
	.cfi_offset 14, -4
	mov	r4, r2	@ fmt, tmp274
	mov	r7, r1	@ tmp273, putf
	sub	sp, sp, #36	@,,
	.cfi_def_cfa_offset 72
@ src/printf.c:185:     while ((ch = *(fmt++)))
	.loc 1 185 16 view .LVU100
	ldrb	r1, [r2], #1	@ zero_extendqisi2	@ ch, *fmt_172(D)
.LVL39:
	.loc 1 182 5 is_stmt 1 view .LVU101
	.loc 1 184 5 view .LVU102
	.loc 1 185 5 view .LVU103
	.loc 1 185 11 view .LVU104
	.loc 1 185 11 is_stmt 0 view .LVU105
	cmp	r1, #0	@ ch,
	beq	.L37		@,
.LBB25:
.LBB26:
.LBB27:
.LBB28:
@ src/printf.c:37:         d /= 10;
	.loc 1 37 11 view .LVU106
	movw	r9, #52429	@ tmp271,
	mov	r6, r0	@ putp, tmp272
	movt	r9, 52428	@ tmp271,
	mov	r10, r3	@ va$__ap, tmp275
.LVL40:
	.loc 1 37 11 view .LVU107
.LBE28:
.LBE27:
.LBE26:
.LBB36:
.LBB37:
	add	fp, sp, #20	@ tmp269,,
	b	.L38		@
.LVL41:
.L112:
	.loc 1 37 11 view .LVU108
.LBE37:
.LBE36:
.LBE25:
	.loc 1 188 13 is_stmt 1 view .LVU109
	mov	r0, r6	@, putp
	mov	r4, r2	@ fmt, _32
	blx	r7		@ putf
.LVL42:
.L41:
	.loc 1 185 11 view .LVU110
@ src/printf.c:185:     while ((ch = *(fmt++)))
	.loc 1 185 23 is_stmt 0 view .LVU111
	mov	r2, r4	@ _32, fmt
.LVL43:
@ src/printf.c:185:     while ((ch = *(fmt++)))
	.loc 1 185 16 view .LVU112
	ldrb	r1, [r2], #1	@ zero_extendqisi2	@ ch, *fmt_44
.LVL44:
@ src/printf.c:185:     while ((ch = *(fmt++)))
	.loc 1 185 11 view .LVU113
	cmp	r1, #0	@ ch,
	beq	.L37		@,
.LVL45:
.L38:
	.loc 1 187 9 is_stmt 1 view .LVU114
@ src/printf.c:187:         if (ch != '%')
	.loc 1 187 12 is_stmt 0 view .LVU115
	cmp	r1, #37	@ ch,
	bne	.L112		@,
.LBB52:
	.loc 1 191 13 is_stmt 1 view .LVU116
.LVL46:
	.loc 1 193 13 view .LVU117
	.loc 1 195 13 view .LVU118
	.loc 1 196 13 view .LVU119
	.loc 1 197 13 view .LVU120
@ src/printf.c:197:             ch = *(fmt++);
	.loc 1 197 16 is_stmt 0 view .LVU121
	ldrb	r2, [r4, #1]	@ zero_extendqisi2	@ ch, MEM[(char *)fmt_180 + 1B]
.LVL47:
	.loc 1 198 13 is_stmt 1 view .LVU122
	.loc 1 200 17 view .LVU123
.LBB39:
.LBB40:
@ src/printf.c:126:     int num = 0;
	.loc 1 126 9 is_stmt 0 view .LVU124
	mov	r5, #0	@ w,
.LBE40:
.LBE39:
@ src/printf.c:198:             if (ch == '0')
	.loc 1 198 16 view .LVU125
	cmp	r2, #48	@ ch,
@ src/printf.c:197:             ch = *(fmt++);
	.loc 1 197 23 view .LVU126
	addne	r4, r4, #2	@ fmt, fmt,
.LVL48:
@ src/printf.c:191:             char lz = 0;
	.loc 1 191 18 view .LVU127
	movne	r8, #0	@ lz,
@ src/printf.c:200:                 ch = *(fmt++);
	.loc 1 200 20 view .LVU128
	ldrbeq	r2, [r4, #2]	@ zero_extendqisi2	@ ch, MEM[(char *)fmt_180 + 2B]
.LVL49:
	.loc 1 201 17 is_stmt 1 view .LVU129
@ src/printf.c:201:                 lz = 1;
	.loc 1 201 20 is_stmt 0 view .LVU130
	moveq	r8, #1	@ lz,
@ src/printf.c:200:                 ch = *(fmt++);
	.loc 1 200 27 view .LVU131
	addeq	r4, r4, #3	@ fmt, fmt,
.LVL50:
	.loc 1 203 13 is_stmt 1 view .LVU132
@ src/printf.c:203:             if (ch >= '0' && ch <= '9')
	.loc 1 203 27 is_stmt 0 view .LVU133
	sub	r1, r2, #48	@ tmp266, ch,
@ src/printf.c:203:             if (ch >= '0' && ch <= '9')
	.loc 1 203 16 view .LVU134
	uxtb	r3, r1	@ tmp187, tmp266
	cmp	r3, #9	@ tmp187,
	bls	.L77		@,
.LVL51:
.L45:
	.loc 1 208 13 is_stmt 1 view .LVU135
@ src/printf.c:208:             if (ch == 'l')
	.loc 1 208 16 is_stmt 0 view .LVU136
	cmp	r2, #108	@ ch,
	beq	.L113		@,
.L39:
	.loc 1 214 13 is_stmt 1 view .LVU137
	cmp	r2, #122	@ ch,
	bhi	.L41		@,
	cmp	r2, #87	@ ch,
	bls	.L109		@,
	.loc 1 214 13 is_stmt 0 view .LVU138
	sub	r3, r2, #88	@ tmp264, ch,
	cmp	r3, #34	@ tmp264,
	addls	pc, pc, r3, asl #2	@ tmp264
	b	.L41	@
.L76:
	b	.L69
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L60
	b	.L72
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L72
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L58
	b	.L41
	b	.L41
	b	.L57
	b	.L41
	b	.L67
	b	.L41
	b	.L41
	b	.L69
	b	.L41
	b	.L53
.LVL52:
	.p2align 1
.L109:
	.loc 1 214 13 view .LVU139
	cmp	r2, #0	@ ch,
	beq	.L37		@,
	cmp	r2, #37	@ ch,
	bne	.L41		@,
	.loc 1 276 17 is_stmt 1 view .LVU140
	mov	r1, #37	@,
	mov	r0, r6	@, putp
	blx	r7		@ putf
.LVL53:
	.loc 1 276 17 is_stmt 0 view .LVU141
.LBE52:
	.loc 1 185 11 is_stmt 1 view .LVU142
@ src/printf.c:185:     while ((ch = *(fmt++)))
	.loc 1 185 23 is_stmt 0 view .LVU143
	mov	r2, r4	@ _32, fmt
.LVL54:
@ src/printf.c:185:     while ((ch = *(fmt++)))
	.loc 1 185 16 view .LVU144
	ldrb	r1, [r2], #1	@ zero_extendqisi2	@ ch, *fmt_44
.LVL55:
@ src/printf.c:185:     while ((ch = *(fmt++)))
	.loc 1 185 11 view .LVU145
	cmp	r1, #0	@ ch,
	bne	.L38		@,
.LVL56:
.L37:
@ src/printf.c:283: }
	.loc 1 283 1 view .LVU146
	add	sp, sp, #36	@,,
	.cfi_remember_state
	.cfi_def_cfa_offset 36
	@ sp needed	@
	pop	{r4, r5, r6, r7, r8, r9, r10, fp, pc}	@
.LVL57:
.L113:
	.cfi_restore_state
.LBB53:
	.loc 1 210 17 is_stmt 1 view .LVU147
@ src/printf.c:210:                 ch = *(fmt++);
	.loc 1 210 20 is_stmt 0 view .LVU148
	ldrb	r2, [r4], #1	@ zero_extendqisi2	@ ch, *fmt_166
.LVL58:
	.loc 1 211 17 is_stmt 1 view .LVU149
	.loc 1 214 13 view .LVU150
	cmp	r2, #122	@ ch,
	bhi	.L41		@,
	cmp	r2, #87	@ ch,
	bls	.L109		@,
	sub	r3, r2, #88	@ tmp205, ch,
	cmp	r3, #34	@ tmp205,
	addls	pc, pc, r3, asl #2	@ tmp205
	b	.L41	@
.L54:
	b	.L55
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L60
	b	.L72
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L72
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L41
	b	.L58
	b	.L41
	b	.L41
	b	.L57
	b	.L41
	b	.L56
	b	.L41
	b	.L41
	b	.L55
	b	.L41
	b	.L53
.LVL59:
	.p2align 1
.L77:
.LBB44:
.LBB43:
@ src/printf.c:132:         num = num * base + digit;
	.loc 1 132 19 is_stmt 0 view .LVU151
	mov	lr, #10	@ tmp268,
	b	.L44		@
.LVL60:
.L47:
	.loc 1 132 9 is_stmt 1 view .LVU152
@ src/printf.c:133:         ch = *p++;
	.loc 1 133 12 is_stmt 0 view .LVU153
	ldrb	r2, [r4], #1	@ zero_extendqisi2	@ ch, MEM[base: p_102, offset: 4294967295B]
.LVL61:
@ src/printf.c:132:         num = num * base + digit;
	.loc 1 132 13 view .LVU154
	mla	r5, lr, r5, r3	@ w, tmp268, w, _55
.LVL62:
	.loc 1 133 9 is_stmt 1 view .LVU155
	.loc 1 133 9 is_stmt 0 view .LVU156
	sub	r1, r2, #48	@ tmp266, ch,
.LVL63:
.L44:
	.loc 1 128 11 is_stmt 1 view .LVU157
.LBB41:
.LBI41:
	.loc 1 111 12 view .LVU158
.LBB42:
	.loc 1 113 5 view .LVU159
	.loc 1 115 10 view .LVU160
	.loc 1 117 10 view .LVU161
	.loc 1 118 9 view .LVU162
@ src/printf.c:113:     if (ch >= '0' && ch <= '9')
	.loc 1 113 8 is_stmt 0 view .LVU163
	uxtb	r3, r1	@ tmp192, tmp266
@ src/printf.c:115:     else if (ch >= 'a' && ch <= 'f')
	.loc 1 115 13 view .LVU164
	sub	r0, r2, #97	@ tmp196, ch,
@ src/printf.c:113:     if (ch >= '0' && ch <= '9')
	.loc 1 113 8 view .LVU165
	cmp	r3, #9	@ tmp192,
@ src/printf.c:117:     else if (ch >= 'A' && ch <= 'F')
	.loc 1 117 13 view .LVU166
	sub	ip, r2, #65	@ tmp200, ch,
@ src/printf.c:118:         return ch - 'A' + 10;
	.loc 1 118 25 view .LVU167
	sub	r3, r2, #55	@ _55, ch,
@ src/printf.c:114:         return ch - '0';
	.loc 1 114 19 view .LVU168
	movls	r3, r1	@ _55, tmp266
@ src/printf.c:113:     if (ch >= '0' && ch <= '9')
	.loc 1 113 8 view .LVU169
	bls	.L47		@,
@ src/printf.c:115:     else if (ch >= 'a' && ch <= 'f')
	.loc 1 115 13 view .LVU170
	cmp	r0, #5	@ tmp196,
@ src/printf.c:116:         return ch - 'a' + 10;
	.loc 1 116 25 view .LVU171
	subls	r3, r2, #87	@ _55, ch,
@ src/printf.c:115:     else if (ch >= 'a' && ch <= 'f')
	.loc 1 115 13 view .LVU172
	bls	.L49		@,
@ src/printf.c:117:     else if (ch >= 'A' && ch <= 'F')
	.loc 1 117 13 view .LVU173
	cmp	ip, #5	@ tmp200,
	bhi	.L45		@,
.L49:
.LVL64:
	.loc 1 117 13 view .LVU174
.LBE42:
.LBE41:
	.loc 1 130 9 is_stmt 1 view .LVU175
@ src/printf.c:130:         if (digit > base)
	.loc 1 130 12 is_stmt 0 view .LVU176
	cmp	r3, #10	@ _55,
	beq	.L47		@,
	b	.L45		@
.LVL65:
.L72:
	.loc 1 130 12 view .LVU177
.LBE43:
.LBE44:
	.loc 1 261 17 is_stmt 1 view .LVU178
	.loc 1 265 21 view .LVU179
	.loc 1 265 21 is_stmt 0 view .LVU180
	ldr	r0, [r10], #4	@ num,
.LVL66:
.LBB45:
.LBI36:
	.loc 1 69 13 is_stmt 1 view .LVU181
.LBB38:
	.loc 1 71 5 view .LVU182
@ src/printf.c:76:     uli2a(num, 10, 0, bf);
	.loc 1 76 5 is_stmt 0 view .LVU183
	mov	r2, #0	@,
.LVL67:
	.loc 1 76 5 view .LVU184
	mov	r1, #10	@,
@ src/printf.c:71:     if (num < 0)
	.loc 1 71 8 view .LVU185
	cmp	r0, #0	@ num,
	.loc 1 73 9 is_stmt 1 view .LVU186
@ src/printf.c:74:         *bf++ = '-';
	.loc 1 74 15 is_stmt 0 view .LVU187
	movlt	r3, #45	@ tmp254,
@ src/printf.c:73:         num = -num;
	.loc 1 73 13 view .LVU188
	rsblt	r0, r0, #0	@ num, num
.LVL68:
	.loc 1 74 9 is_stmt 1 view .LVU189
@ src/printf.c:74:         *bf++ = '-';
	.loc 1 74 15 is_stmt 0 view .LVU190
	strblt	r3, [sp, #20]	@ tmp254, MEM[(char *)&bf]
	movge	r3, fp	@ bf, tmp269
@ src/printf.c:74:         *bf++ = '-';
	.loc 1 74 12 view .LVU191
	addlt	r3, sp, #21	@ bf,,
.LVL69:
	.loc 1 76 5 is_stmt 1 view .LVU192
	bl	uli2a(PLT)	@
.LVL70:
.L107:
	.loc 1 76 5 is_stmt 0 view .LVU193
.LBE38:
.LBE45:
	.loc 1 266 17 is_stmt 1 view .LVU194
	str	fp, [sp]	@ tmp269,
	mov	r3, r8	@, lz
	mov	r2, r5	@, w
	mov	r1, r7	@, putf
	mov	r0, r6	@, putp
	bl	putchw(PLT)	@
.LVL71:
	.loc 1 267 17 view .LVU195
	b	.L41		@
.LVL72:
.L60:
	.loc 1 270 17 view .LVU196
	.loc 1 270 17 is_stmt 0 view .LVU197
	ldr	r1, [r10], #4	@ MEM[(int *)va$__ap_82], MEM[(int *)va$__ap_82]
.LVL73:
	.loc 1 270 17 view .LVU198
	mov	r0, r6	@, putp
	uxtb	r1, r1	@, MEM[(int *)va$__ap_82]
	blx	r7		@ putf
.LVL74:
	.loc 1 271 17 is_stmt 1 view .LVU199
	b	.L41		@
.LVL75:
.L53:
	.loc 1 219 17 view .LVU200
	.loc 1 220 17 view .LVU201
@ src/printf.c:220:                 if (ch == 'u')
	.loc 1 220 20 is_stmt 0 view .LVU202
	ldrb	r3, [r4], #1	@ zero_extendqisi2	@ *fmt_192, *fmt_192
.LVL76:
	.loc 1 220 20 view .LVU203
	cmp	r3, #117	@ *fmt_192,
	bne	.L41		@,
	.loc 1 222 21 is_stmt 1 view .LVU204
	mov	r3, r10	@ D.4087, va$__ap
.LVL77:
	.loc 1 222 21 is_stmt 0 view .LVU205
	ldr	lr, [r3], #4	@ num, MEM[(size_t *)va$__ap_82]
.LVL78:
	.loc 1 222 21 view .LVU206
	str	r3, [sp, #8]	@ D.4087, %sfp
.LVL79:
.LBB46:
.LBI26:
	.loc 1 23 13 is_stmt 1 view .LVU207
.LBB32:
	.loc 1 25 5 view .LVU208
	.loc 1 26 5 view .LVU209
	.loc 1 29 5 view .LVU210
	.loc 1 29 11 view .LVU211
	cmp	lr, #9	@ num,
@ src/printf.c:26:     size_t d = 1;
	.loc 1 26 12 is_stmt 0 view .LVU212
	mov	r3, #1	@ d,
.LVL80:
@ src/printf.c:29:     while (num / d >= 10)
	.loc 1 29 11 view .LVU213
	bls	.L84		@,
@ src/printf.c:30:         d *= 10;
	.loc 1 30 11 view .LVU214
	mov	r1, #10	@ tmp207,
.LVL81:
.L62:
	.loc 1 30 9 is_stmt 1 view .LVU215
@ src/printf.c:30:         d *= 10;
	.loc 1 30 11 is_stmt 0 view .LVU216
	mul	r3, r1, r3	@ d, tmp207, d
.LVL82:
	.loc 1 29 11 is_stmt 1 view .LVU217
@ src/printf.c:29:     while (num / d >= 10)
	.loc 1 29 16 is_stmt 0 view .LVU218
	udiv	r2, lr, r3	@ _123, num, d
@ src/printf.c:29:     while (num / d >= 10)
	.loc 1 29 11 view .LVU219
	cmp	r2, #9	@ _123,
	bhi	.L62		@,
.LVL83:
	.loc 1 33 11 is_stmt 1 view .LVU220
	cmp	r3, #0	@ d,
	beq	.L114		@,
.LVL84:
.L61:
@ src/printf.c:25:     int n = 0;
	.loc 1 25 9 is_stmt 0 view .LVU221
	str	r8, [sp, #12]	@ lz, %sfp
	mov	r10, #0	@ n,
	mov	r8, fp	@ bf, bf
.LVL85:
	.loc 1 25 9 view .LVU222
	mov	ip, r2	@ _123, _123
	b	.L65		@
.LVL86:
.L115:
.LBB29:
@ src/printf.c:40:             *bf++ = dgt + '0';
	.loc 1 40 19 view .LVU223
	strb	ip, [r0], #1	@ tmp230, *bf_90
.LVL87:
	.loc 1 41 13 is_stmt 1 view .LVU224
	.loc 1 41 13 is_stmt 0 view .LVU225
.LBE29:
	.loc 1 33 11 is_stmt 1 view .LVU226
	cmp	r3, #9	@ d,
.LBB30:
@ src/printf.c:40:             *bf++ = dgt + '0';
	.loc 1 40 16 is_stmt 0 view .LVU227
	mov	r8, r0	@ bf, bf
.LBE30:
@ src/printf.c:33:     while (d != 0)
	.loc 1 33 11 view .LVU228
	bls	.L103		@,
.LVL88:
.L64:
	.loc 1 33 11 view .LVU229
	udiv	ip, lr, r1	@ _123, num, d
@ src/printf.c:25:     int n = 0;
	.loc 1 25 9 view .LVU230
	mov	r3, r1	@ d, d
.LVL89:
.L65:
.LBB31:
	.loc 1 35 9 is_stmt 1 view .LVU231
	.loc 1 36 9 view .LVU232
@ src/printf.c:37:         d /= 10;
	.loc 1 37 11 is_stmt 0 view .LVU233
	umull	r2, r1, r9, r3	@ tmp320, tmp216, tmp271, d
@ src/printf.c:38:         if (n || dgt > 0 || d == 0)
	.loc 1 38 13 view .LVU234
	subs	r2, r10, #0	@ tmp221, n,
@ src/printf.c:40:             *bf++ = dgt + '0';
	.loc 1 40 16 view .LVU235
	mov	r0, r8	@ bf, bf
@ src/printf.c:38:         if (n || dgt > 0 || d == 0)
	.loc 1 38 13 view .LVU236
	movne	r2, #1	@ tmp221,
@ src/printf.c:41:             ++n;
	.loc 1 41 13 view .LVU237
	add	r10, r10, #1	@ n, n,
.LVL90:
@ src/printf.c:36:         num %= d;
	.loc 1 36 13 view .LVU238
	mls	lr, r3, ip, lr	@ num, d, _123, num
.LVL91:
	.loc 1 37 9 is_stmt 1 view .LVU239
@ src/printf.c:38:         if (n || dgt > 0 || d == 0)
	.loc 1 38 26 is_stmt 0 view .LVU240
	cmp	r3, #9	@ d,
	orrls	r2, r2, #1	@,, tmp222, tmp221
@ src/printf.c:38:         if (n || dgt > 0 || d == 0)
	.loc 1 38 22 view .LVU241
	cmp	ip, #0	@ _123,
@ src/printf.c:38:         if (n || dgt > 0 || d == 0)
	.loc 1 38 26 view .LVU242
	orrgt	r2, r2, #1	@, tmp228, tmp222
@ src/printf.c:40:             *bf++ = dgt + '0';
	.loc 1 40 25 view .LVU243
	add	ip, ip, #48	@ tmp230, _123,
@ src/printf.c:37:         d /= 10;
	.loc 1 37 11 view .LVU244
	lsr	r1, r1, #3	@ d, tmp216,
.LVL92:
	.loc 1 38 9 is_stmt 1 view .LVU245
	.loc 1 40 13 view .LVU246
@ src/printf.c:38:         if (n || dgt > 0 || d == 0)
	.loc 1 38 26 is_stmt 0 view .LVU247
	cmp	r2, #0	@ tmp228,
	bne	.L115		@,
	mov	r10, r2	@ n, tmp228
.LVL93:
	.loc 1 38 26 view .LVU248
	b	.L64		@
.LVL94:
.L57:
	.loc 1 38 26 view .LVU249
.LBE31:
.LBE32:
.LBE46:
	.loc 1 273 17 is_stmt 1 view .LVU250
	.loc 1 273 17 is_stmt 0 view .LVU251
	ldr	r3, [r10], #4	@ MEM[(char * *)va$__ap_82], MEM[(char * *)va$__ap_82]
.LVL95:
	.loc 1 273 17 view .LVU252
	mov	r2, r5	@, w
.LVL96:
	.loc 1 273 17 view .LVU253
	mov	r1, r7	@, putf
	mov	r0, r6	@, putp
	str	r3, [sp]	@ MEM[(char * *)va$__ap_82],
	mov	r3, #0	@,
	bl	putchw(PLT)	@
.LVL97:
	.loc 1 274 17 is_stmt 1 view .LVU254
	b	.L41		@
.LVL98:
.L58:
	.loc 1 227 17 view .LVU255
	mov	r0, r6	@, putp
	mov	r1, #48	@,
	blx	r7		@ putf
.LVL99:
	.loc 1 228 17 view .LVU256
	mov	r0, r6	@, putp
	mov	r1, #120	@,
	blx	r7		@ putf
.LVL100:
	.loc 1 229 17 view .LVU257
.LBB47:
.LBI47:
	.loc 1 140 13 view .LVU258
.LBB48:
	.loc 1 142 5 view .LVU259
	.loc 1 143 5 view .LVU260
	ldr	r0, [r10], #4	@, MEM[(void * *)va$__ap_82]
.LVL101:
	.loc 1 143 5 is_stmt 0 view .LVU261
	mov	r3, fp	@, tmp269
	mov	r2, #1	@,
	mov	r1, #16	@,
	bl	ui2a(PLT)	@
.LVL102:
	.loc 1 143 5 view .LVU262
.LBE48:
.LBE47:
	.loc 1 230 17 is_stmt 1 view .LVU263
	str	fp, [sp]	@ tmp269,
	mov	r3, r8	@, lz
	mov	r2, r5	@, w
	mov	r1, r7	@, putf
	mov	r0, r6	@, putp
	bl	putchw(PLT)	@
.LVL103:
	.loc 1 231 17 view .LVU264
	b	.L41		@
.LVL104:
.L67:
	.loc 1 233 17 view .LVU265
	.loc 1 237 21 view .LVU266
	.loc 1 241 21 view .LVU267
	.loc 1 241 21 is_stmt 0 view .LVU268
	ldr	r0, [r10], #4	@, MEM[(unsigned int *)va$__ap_82]
.LVL105:
	.loc 1 241 21 view .LVU269
	mov	r3, fp	@, tmp269
	mov	r2, #0	@,
.LVL106:
	.loc 1 241 21 view .LVU270
	mov	r1, #10	@,
	bl	ui2a(PLT)	@
.LVL107:
	.loc 1 242 17 is_stmt 1 view .LVU271
	b	.L107		@
.LVL108:
.L69:
	.loc 1 254 21 view .LVU272
	.loc 1 254 21 is_stmt 0 view .LVU273
	ldr	r0, [r10], #4	@, MEM[(unsigned int *)va$__ap_82]
.LVL109:
	.loc 1 254 21 view .LVU274
	sub	r2, r2, #88	@, ch,
.LVL110:
	.loc 1 254 21 view .LVU275
	clz	r2, r2	@,
	mov	r3, fp	@, tmp269
	mov	r1, #16	@,
	lsr	r2, r2, #5	@,,
	bl	ui2a(PLT)	@
.LVL111:
	.loc 1 255 17 is_stmt 1 view .LVU276
	b	.L107		@
.LVL112:
.L55:
	.loc 1 246 17 view .LVU277
	.loc 1 250 21 view .LVU278
	.loc 1 251 21 view .LVU279
	.loc 1 251 21 is_stmt 0 view .LVU280
	ldr	r0, [r10], #4	@, MEM[(long unsigned int *)va$__ap_82]
.LVL113:
	.loc 1 251 21 view .LVU281
	sub	r2, r2, #88	@, ch,
.LVL114:
	.loc 1 251 21 view .LVU282
	clz	r2, r2	@,
.LVL115:
	.loc 1 251 21 view .LVU283
	mov	r3, fp	@, tmp269
.LVL116:
	.loc 1 251 21 view .LVU284
	mov	r1, #16	@,
	lsr	r2, r2, #5	@,,
	bl	uli2a(PLT)	@
.LVL117:
	.loc 1 251 21 view .LVU285
	b	.L107		@
.LVL118:
.L56:
	.loc 1 233 17 is_stmt 1 view .LVU286
	.loc 1 237 21 view .LVU287
	.loc 1 238 21 view .LVU288
	.loc 1 238 21 is_stmt 0 view .LVU289
	ldr	r0, [r10], #4	@, MEM[(long unsigned int *)va$__ap_82]
.LVL119:
	.loc 1 238 21 view .LVU290
	mov	r3, fp	@, tmp269
	mov	r2, #0	@,
.LVL120:
	.loc 1 238 21 view .LVU291
	mov	r1, #10	@,
	bl	uli2a(PLT)	@
.LVL121:
	.loc 1 238 21 view .LVU292
	b	.L107		@
.LVL122:
.L103:
	.loc 1 238 21 view .LVU293
	ldr	r8, [sp, #12]	@ lz, %sfp
.LVL123:
.L63:
.LBB49:
.LBB33:
	.loc 1 44 5 is_stmt 1 view .LVU294
.LBE33:
.LBE49:
@ src/printf.c:222:                     size2a(va_arg(va, size_t), bf);
	.loc 1 222 21 is_stmt 0 view .LVU295
	ldr	r10, [sp, #8]	@ va$__ap, %sfp
.LBB50:
.LBB34:
@ src/printf.c:44:     *bf = 0;
	.loc 1 44 9 view .LVU296
	mov	r1, #0	@ tmp232,
	strb	r1, [r0]	@ tmp232, *bf_59
.LVL124:
	.loc 1 44 9 view .LVU297
.LBE34:
.LBE50:
	.loc 1 223 21 is_stmt 1 view .LVU298
	mov	r3, r8	@, lz
	str	fp, [sp]	@ tmp269,
.LVL125:
	.loc 1 223 21 is_stmt 0 view .LVU299
	mov	r2, r5	@, w
	mov	r1, r7	@, putf
	mov	r0, r6	@, putp
	bl	putchw(PLT)	@
.LVL126:
	b	.L41		@
.LVL127:
.L84:
	.loc 1 223 21 view .LVU300
	mov	r2, lr	@ _123, num
	b	.L61		@
.LVL128:
.L114:
.LBB51:
.LBB35:
@ src/printf.c:33:     while (d != 0)
	.loc 1 33 11 view .LVU301
	mov	r0, fp	@ bf, tmp269
	b	.L63		@
.LBE35:
.LBE51:
.LBE53:
	.cfi_endproc
.LFE11:
	.size	tfp_format, .-tfp_format
	.section	.text.init_printf,"ax",%progbits
	.align	2
	.global	init_printf
	.syntax unified
	.arm
	.fpu softvfp
	.type	init_printf, %function
init_printf:
.LVL129:
.LFB12:
	.loc 1 286 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 287 5 view .LVU303
@ src/printf.c:287:     stdout_putf = putf;
	.loc 1 287 17 is_stmt 0 view .LVU304
	ldr	r2, .L117	@ tmp116,
@ src/printf.c:288:     stdout_putp = putp;
	.loc 1 288 17 view .LVU305
	ldr	r3, .L117+4	@ tmp118,
@ src/printf.c:287:     stdout_putf = putf;
	.loc 1 287 17 view .LVU306
.LPIC0:
	add	r2, pc, r2	@ tmp116, tmp116
@ src/printf.c:288:     stdout_putp = putp;
	.loc 1 288 17 view .LVU307
.LPIC1:
	add	r3, pc, r3	@ tmp118, tmp118
@ src/printf.c:287:     stdout_putf = putf;
	.loc 1 287 17 view .LVU308
	str	r1, [r2]	@ tmp120, stdout_putf
	.loc 1 288 5 is_stmt 1 view .LVU309
@ src/printf.c:288:     stdout_putp = putp;
	.loc 1 288 17 is_stmt 0 view .LVU310
	str	r0, [r3]	@ tmp119, stdout_putp
@ src/printf.c:289: }
	.loc 1 289 1 view .LVU311
	bx	lr	@
.L118:
	.align	2
.L117:
	.word	.LANCHOR0-(.LPIC0+8)
	.word	.LANCHOR1-(.LPIC1+8)
	.cfi_endproc
.LFE12:
	.size	init_printf, .-init_printf
	.section	.text.tfp_printf,"ax",%progbits
	.align	2
	.global	tfp_printf
	.syntax unified
	.arm
	.fpu softvfp
	.type	tfp_printf, %function
tfp_printf:
.LVL130:
.LFB13:
	.loc 1 292 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 4, pretend = 16, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 1
	.loc 1 293 5 view .LVU313
	.loc 1 294 5 view .LVU314
@ src/printf.c:292: {
	.loc 1 292 1 is_stmt 0 view .LVU315
	push	{r0, r1, r2, r3}	@
	.cfi_def_cfa_offset 16
	.cfi_offset 0, -16
	.cfi_offset 1, -12
	.cfi_offset 2, -8
	.cfi_offset 3, -4
@ src/printf.c:295:     tfp_format(stdout_putp, stdout_putf, fmt, va);
	.loc 1 295 5 view .LVU316
	ldr	r1, .L121	@ tmp119,
	ldr	r0, .L121+4	@ tmp122,
@ src/printf.c:292: {
	.loc 1 292 1 view .LVU317
	str	lr, [sp, #-4]!	@,
	.cfi_def_cfa_offset 20
	.cfi_offset 14, -20
	sub	sp, sp, #12	@,,
	.cfi_def_cfa_offset 32
@ src/printf.c:295:     tfp_format(stdout_putp, stdout_putf, fmt, va);
	.loc 1 295 5 view .LVU318
.LPIC2:
	add	r1, pc, r1	@ tmp119, tmp119
@ src/printf.c:294:     va_start(va, fmt);
	.loc 1 294 5 view .LVU319
	add	r3, sp, #20	@ tmp116,,
@ src/printf.c:295:     tfp_format(stdout_putp, stdout_putf, fmt, va);
	.loc 1 295 5 view .LVU320
.LPIC3:
	add	r0, pc, r0	@ tmp122, tmp122
	ldr	r2, [sp, #16]	@, fmt
	ldr	r1, [r1]	@, stdout_putf
	ldr	r0, [r0]	@, stdout_putp
@ src/printf.c:294:     va_start(va, fmt);
	.loc 1 294 5 view .LVU321
	str	r3, [sp, #4]	@ tmp116, MEM[(struct  *)&va].__ap
	.loc 1 295 5 is_stmt 1 view .LVU322
	bl	tfp_format(PLT)	@
.LVL131:
	.loc 1 296 5 view .LVU323
@ src/printf.c:297: }
	.loc 1 297 1 is_stmt 0 view .LVU324
	add	sp, sp, #12	@,,
	.cfi_def_cfa_offset 20
	@ sp needed	@
	ldr	lr, [sp], #4	@,
	.cfi_restore 14
	.cfi_def_cfa_offset 16
	add	sp, sp, #16	@,,
	.cfi_restore 3
	.cfi_restore 2
	.cfi_restore 1
	.cfi_restore 0
	.cfi_def_cfa_offset 0
	bx	lr	@
.L122:
	.align	2
.L121:
	.word	.LANCHOR0-(.LPIC2+8)
	.word	.LANCHOR1-(.LPIC3+8)
	.cfi_endproc
.LFE13:
	.size	tfp_printf, .-tfp_printf
	.section	.text.tfp_sprintf,"ax",%progbits
	.align	2
	.global	tfp_sprintf
	.syntax unified
	.arm
	.fpu softvfp
	.type	tfp_sprintf, %function
tfp_sprintf:
.LVL132:
.LFB15:
	.loc 1 305 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 4, pretend = 12, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 1
	.loc 1 306 5 view .LVU326
	.loc 1 307 5 view .LVU327
@ src/printf.c:305: {
	.loc 1 305 1 is_stmt 0 view .LVU328
	push	{r1, r2, r3}	@
	.cfi_def_cfa_offset 12
	.cfi_offset 1, -12
	.cfi_offset 2, -8
	.cfi_offset 3, -4
@ src/printf.c:308:     tfp_format(&s, putcp, fmt, va);
	.loc 1 308 5 view .LVU329
	ldr	r1, .L125	@,
@ src/printf.c:305: {
	.loc 1 305 1 view .LVU330
	str	lr, [sp, #-4]!	@,
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	sub	sp, sp, #16	@,,
	.cfi_def_cfa_offset 32
@ src/printf.c:308:     tfp_format(&s, putcp, fmt, va);
	.loc 1 308 5 view .LVU331
.LPIC4:
	add	r1, pc, r1	@,
@ src/printf.c:307:     va_start(va, fmt);
	.loc 1 307 5 view .LVU332
	add	r3, sp, #24	@ tmp115,,
@ src/printf.c:308:     tfp_format(&s, putcp, fmt, va);
	.loc 1 308 5 view .LVU333
	ldr	r2, [sp, #20]	@, fmt
@ src/printf.c:305: {
	.loc 1 305 1 view .LVU334
	str	r0, [sp, #4]	@ s, s
@ src/printf.c:308:     tfp_format(&s, putcp, fmt, va);
	.loc 1 308 5 view .LVU335
	add	r0, sp, #4	@,,
@ src/printf.c:307:     va_start(va, fmt);
	.loc 1 307 5 view .LVU336
	str	r3, [sp, #12]	@ tmp115, MEM[(struct  *)&va].__ap
	.loc 1 308 5 is_stmt 1 view .LVU337
	bl	tfp_format(PLT)	@
.LVL133:
	.loc 1 309 5 view .LVU338
.LBB54:
.LBI54:
	.loc 1 299 13 view .LVU339
.LBB55:
	.loc 1 301 5 view .LVU340
@ src/printf.c:301:     *(*((char **)p))++ = c;
	.loc 1 301 7 is_stmt 0 view .LVU341
	ldr	r3, [sp, #4]	@ _7, s
@ src/printf.c:301:     *(*((char **)p))++ = c;
	.loc 1 301 24 view .LVU342
	mov	r2, #0	@ tmp120,
	strb	r2, [r3]	@ tmp120, *_7
.LVL134:
	.loc 1 301 24 view .LVU343
.LBE55:
.LBE54:
	.loc 1 310 5 is_stmt 1 view .LVU344
@ src/printf.c:311: }
	.loc 1 311 1 is_stmt 0 view .LVU345
	add	sp, sp, #16	@,,
	.cfi_def_cfa_offset 16
	@ sp needed	@
	ldr	lr, [sp], #4	@,
	.cfi_restore 14
	.cfi_def_cfa_offset 12
	add	sp, sp, #12	@,,
	.cfi_restore 3
	.cfi_restore 2
	.cfi_restore 1
	.cfi_def_cfa_offset 0
	bx	lr	@
.L126:
	.align	2
.L125:
	.word	putcp-(.LPIC4+8)
	.cfi_endproc
.LFE15:
	.size	tfp_sprintf, .-tfp_sprintf
	.section	.bss.stdout_putf,"aw",%nobits
	.align	2
	.set	.LANCHOR0,. + 0
	.type	stdout_putf, %object
	.size	stdout_putf, 4
stdout_putf:
	.space	4
	.section	.bss.stdout_putp,"aw",%nobits
	.align	2
	.set	.LANCHOR1,. + 0
	.type	stdout_putp, %object
	.size	stdout_putp, 4
stdout_putp:
	.space	4
	.text
.Letext0:
	.file 2 "/usr/lib/gcc/arm-none-eabi/10.3.1/include/stdarg.h"
	.file 3 "/usr/lib/gcc/arm-none-eabi/10.3.1/include/stddef.h"
	.file 4 "<built-in>"
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.4byte	0x9b0
	.2byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF30
	.byte	0xc
	.4byte	.LASF31
	.4byte	.LASF32
	.4byte	.Ldebug_ranges0+0xd0
	.4byte	0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.4byte	.LASF0
	.byte	0x2
	.byte	0x28
	.byte	0x1b
	.4byte	0x31
	.uleb128 0x3
	.4byte	.LASF33
	.byte	0x4
	.byte	0x4
	.byte	0
	.4byte	0x48
	.uleb128 0x4
	.4byte	.LASF34
	.4byte	0x48
	.byte	0
	.byte	0
	.uleb128 0x5
	.byte	0x4
	.uleb128 0x2
	.4byte	.LASF1
	.byte	0x2
	.byte	0x63
	.byte	0x18
	.4byte	0x25
	.uleb128 0x6
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x2
	.4byte	.LASF2
	.byte	0x3
	.byte	0xd1
	.byte	0x17
	.4byte	0x69
	.uleb128 0x7
	.byte	0x4
	.byte	0x7
	.4byte	.LASF3
	.uleb128 0x7
	.byte	0x8
	.byte	0x5
	.4byte	.LASF4
	.uleb128 0x7
	.byte	0x8
	.byte	0x4
	.4byte	.LASF5
	.uleb128 0x2
	.4byte	.LASF6
	.byte	0x1
	.byte	0x13
	.byte	0x10
	.4byte	0x8a
	.uleb128 0x8
	.byte	0x4
	.4byte	0x90
	.uleb128 0x9
	.4byte	0xa0
	.uleb128 0xa
	.4byte	0x48
	.uleb128 0xa
	.4byte	0xa0
	.byte	0
	.uleb128 0x7
	.byte	0x1
	.byte	0x8
	.4byte	.LASF7
	.uleb128 0xb
	.4byte	.LASF8
	.byte	0x1
	.byte	0x14
	.byte	0xe
	.4byte	0x7e
	.uleb128 0x5
	.byte	0x3
	.4byte	stdout_putf
	.uleb128 0xb
	.4byte	.LASF9
	.byte	0x1
	.byte	0x15
	.byte	0xe
	.4byte	0x48
	.uleb128 0x5
	.byte	0x3
	.4byte	stdout_putp
	.uleb128 0xc
	.4byte	.LASF10
	.byte	0x1
	.2byte	0x130
	.byte	0x6
	.4byte	.LFB15
	.4byte	.LFE15-.LFB15
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x168
	.uleb128 0xd
	.ascii	"s\000"
	.byte	0x1
	.2byte	0x130
	.byte	0x18
	.4byte	0x168
	.4byte	.LLST36
	.4byte	.LVUS36
	.uleb128 0xe
	.ascii	"fmt\000"
	.byte	0x1
	.2byte	0x130
	.byte	0x21
	.4byte	0x168
	.uleb128 0x2
	.byte	0x91
	.sleb128 -12
	.uleb128 0xf
	.uleb128 0x10
	.ascii	"va\000"
	.byte	0x1
	.2byte	0x132
	.byte	0xd
	.4byte	0x4a
	.uleb128 0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x11
	.4byte	0x16e
	.4byte	.LBI54
	.byte	.LVU339
	.4byte	.LBB54
	.4byte	.LBE54-.LBB54
	.byte	0x1
	.2byte	0x135
	.byte	0x5
	.4byte	0x14a
	.uleb128 0x12
	.4byte	0x187
	.4byte	.LLST37
	.4byte	.LVUS37
	.uleb128 0x12
	.4byte	0x17c
	.4byte	.LLST38
	.4byte	.LVUS38
	.byte	0
	.uleb128 0x13
	.4byte	.LVL133
	.4byte	0x218
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x91
	.sleb128 -60
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x3
	.byte	0x91
	.sleb128 -44
	.byte	0x6
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.byte	0
	.byte	0
	.uleb128 0x8
	.byte	0x4
	.4byte	0xa0
	.uleb128 0x15
	.4byte	.LASF18
	.byte	0x1
	.2byte	0x12b
	.byte	0xd
	.byte	0x1
	.4byte	0x193
	.uleb128 0x16
	.ascii	"p\000"
	.byte	0x1
	.2byte	0x12b
	.byte	0x19
	.4byte	0x48
	.uleb128 0x16
	.ascii	"c\000"
	.byte	0x1
	.2byte	0x12b
	.byte	0x21
	.4byte	0xa0
	.byte	0
	.uleb128 0xc
	.4byte	.LASF11
	.byte	0x1
	.2byte	0x123
	.byte	0x6
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x1e2
	.uleb128 0xe
	.ascii	"fmt\000"
	.byte	0x1
	.2byte	0x123
	.byte	0x17
	.4byte	0x168
	.uleb128 0x2
	.byte	0x91
	.sleb128 -16
	.uleb128 0xf
	.uleb128 0x10
	.ascii	"va\000"
	.byte	0x1
	.2byte	0x125
	.byte	0xd
	.4byte	0x4a
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.uleb128 0x13
	.4byte	.LVL131
	.4byte	0x218
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x3
	.byte	0x91
	.sleb128 -56
	.byte	0x6
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x91
	.sleb128 -52
	.byte	0
	.byte	0
	.uleb128 0xc
	.4byte	.LASF12
	.byte	0x1
	.2byte	0x11d
	.byte	0x6
	.4byte	.LFB12
	.4byte	.LFE12-.LFB12
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x218
	.uleb128 0x17
	.4byte	.LASF13
	.byte	0x1
	.2byte	0x11d
	.byte	0x18
	.4byte	0x48
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x17
	.4byte	.LASF14
	.byte	0x1
	.2byte	0x11d
	.byte	0x25
	.4byte	0x8a
	.uleb128 0x1
	.byte	0x51
	.byte	0
	.uleb128 0x18
	.4byte	.LASF15
	.byte	0x1
	.byte	0xb4
	.byte	0x6
	.4byte	.LFB11
	.4byte	.LFE11-.LFB11
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x609
	.uleb128 0x19
	.4byte	.LASF13
	.byte	0x1
	.byte	0xb4
	.byte	0x17
	.4byte	0x48
	.4byte	.LLST13
	.4byte	.LVUS13
	.uleb128 0x19
	.4byte	.LASF14
	.byte	0x1
	.byte	0xb4
	.byte	0x23
	.4byte	0x7e
	.4byte	.LLST14
	.4byte	.LVUS14
	.uleb128 0x1a
	.ascii	"fmt\000"
	.byte	0x1
	.byte	0xb4
	.byte	0x2f
	.4byte	0x168
	.4byte	.LLST15
	.4byte	.LVUS15
	.uleb128 0x1a
	.ascii	"va\000"
	.byte	0x1
	.byte	0xb4
	.byte	0x3c
	.4byte	0x4a
	.4byte	.LLST16
	.4byte	.LVUS16
	.uleb128 0x1b
	.ascii	"bf\000"
	.byte	0x1
	.byte	0xb6
	.byte	0xa
	.4byte	0x609
	.uleb128 0x2
	.byte	0x91
	.sleb128 -52
	.uleb128 0x1c
	.ascii	"ch\000"
	.byte	0x1
	.byte	0xb8
	.byte	0xa
	.4byte	0xa0
	.4byte	.LLST17
	.4byte	.LVUS17
	.uleb128 0x1d
	.4byte	.LASF35
	.byte	0x1
	.2byte	0x11a
	.byte	0x1
	.4byte	.L39
	.uleb128 0x1e
	.4byte	.Ldebug_ranges0+0x28
	.4byte	0x5fc
	.uleb128 0x1c
	.ascii	"lz\000"
	.byte	0x1
	.byte	0xbf
	.byte	0x12
	.4byte	0xa0
	.4byte	.LLST18
	.4byte	.LVUS18
	.uleb128 0x1c
	.ascii	"lng\000"
	.byte	0x1
	.byte	0xc1
	.byte	0x12
	.4byte	0xa0
	.4byte	.LLST19
	.4byte	.LVUS19
	.uleb128 0x1f
	.4byte	.LASF16
	.byte	0x1
	.byte	0xc3
	.byte	0x12
	.4byte	0xa0
	.4byte	.LLST20
	.4byte	.LVUS20
	.uleb128 0x1c
	.ascii	"w\000"
	.byte	0x1
	.byte	0xc4
	.byte	0x11
	.4byte	0x56
	.4byte	.LLST21
	.4byte	.LVUS21
	.uleb128 0x20
	.4byte	0x94e
	.4byte	.LBI26
	.byte	.LVU207
	.4byte	.Ldebug_ranges0+0x48
	.byte	0x1
	.byte	0xde
	.byte	0x15
	.4byte	0x368
	.uleb128 0x12
	.4byte	0x967
	.4byte	.LLST22
	.4byte	.LVUS22
	.uleb128 0x12
	.4byte	0x95b
	.4byte	.LLST23
	.4byte	.LVUS23
	.uleb128 0x21
	.4byte	.Ldebug_ranges0+0x48
	.uleb128 0x22
	.4byte	0x972
	.4byte	.LLST24
	.4byte	.LVUS24
	.uleb128 0x22
	.4byte	0x97c
	.4byte	.LLST25
	.4byte	.LVUS25
	.uleb128 0x23
	.4byte	0x986
	.4byte	.Ldebug_ranges0+0x78
	.uleb128 0x22
	.4byte	0x987
	.4byte	.LLST26
	.4byte	.LVUS26
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x24
	.4byte	0x884
	.4byte	.LBI36
	.byte	.LVU181
	.4byte	.Ldebug_ranges0+0xa0
	.byte	0x1
	.2byte	0x109
	.byte	0x15
	.4byte	0x3af
	.uleb128 0x12
	.4byte	0x89d
	.4byte	.LLST27
	.4byte	.LVUS27
	.uleb128 0x12
	.4byte	0x891
	.4byte	.LLST28
	.4byte	.LVUS28
	.uleb128 0x13
	.4byte	.LVL70
	.4byte	0x8b0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x71
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x72
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x25
	.4byte	0x777
	.4byte	.Ldebug_ranges0+0xb8
	.byte	0x1
	.byte	0xcd
	.byte	0x16
	.4byte	0x42c
	.uleb128 0x26
	.4byte	0x79f
	.uleb128 0x26
	.4byte	0x7ab
	.uleb128 0x26
	.4byte	0x793
	.uleb128 0x12
	.4byte	0x788
	.4byte	.LLST29
	.4byte	.LVUS29
	.uleb128 0x21
	.4byte	.Ldebug_ranges0+0xb8
	.uleb128 0x22
	.4byte	0x7b7
	.4byte	.LLST30
	.4byte	.LVUS30
	.uleb128 0x22
	.4byte	0x7c1
	.4byte	.LLST31
	.4byte	.LVUS31
	.uleb128 0x22
	.4byte	0x7cd
	.4byte	.LLST32
	.4byte	.LVUS32
	.uleb128 0x27
	.4byte	0x7e6
	.4byte	.LBI41
	.byte	.LVU158
	.4byte	.LBB41
	.4byte	.LBE41-.LBB41
	.byte	0x1
	.byte	0x80
	.byte	0x15
	.uleb128 0x12
	.4byte	0x7f7
	.4byte	.LLST33
	.4byte	.LVUS33
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x28
	.4byte	0x746
	.4byte	.LBI47
	.byte	.LVU258
	.4byte	.LBB47
	.4byte	.LBE47-.LBB47
	.byte	0x1
	.byte	0xe5
	.byte	0x11
	.4byte	0x481
	.uleb128 0x12
	.4byte	0x75f
	.4byte	.LLST34
	.4byte	.LVUS34
	.uleb128 0x26
	.4byte	0x753
	.uleb128 0x22
	.4byte	0x76a
	.4byte	.LLST35
	.4byte	.LVUS35
	.uleb128 0x13
	.4byte	.LVL102
	.4byte	0x827
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x71
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x72
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x29
	.4byte	.LVL53
	.4byte	0x497
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x8
	.byte	0x25
	.byte	0
	.uleb128 0x2a
	.4byte	.LVL71
	.4byte	0x676
	.4byte	0x4c4
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x77
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x78
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x2
	.byte	0x7d
	.sleb128 0
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.uleb128 0x29
	.4byte	.LVL74
	.4byte	0x4d4
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.byte	0
	.uleb128 0x2a
	.4byte	.LVL97
	.4byte	0x676
	.4byte	0x4f9
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x77
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x1
	.byte	0x30
	.byte	0
	.uleb128 0x29
	.4byte	.LVL99
	.4byte	0x50f
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x8
	.byte	0x30
	.byte	0
	.uleb128 0x29
	.4byte	.LVL100
	.4byte	0x525
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x8
	.byte	0x78
	.byte	0
	.uleb128 0x2a
	.4byte	.LVL103
	.4byte	0x676
	.4byte	0x552
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x77
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x78
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x2
	.byte	0x7d
	.sleb128 0
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.uleb128 0x2a
	.4byte	.LVL107
	.4byte	0x827
	.4byte	0x572
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x71
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x72
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.uleb128 0x2a
	.4byte	.LVL111
	.4byte	0x827
	.4byte	0x592
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x71
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x72
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.uleb128 0x2a
	.4byte	.LVL117
	.4byte	0x8b0
	.4byte	0x5b2
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x71
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x72
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.uleb128 0x2a
	.4byte	.LVL121
	.4byte	0x8b0
	.4byte	0x5d2
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x71
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x72
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.uleb128 0x13
	.4byte	.LVL126
	.4byte	0x676
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x77
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x2
	.byte	0x75
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x53
	.uleb128 0x2
	.byte	0x78
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x2
	.byte	0x7d
	.sleb128 0
	.uleb128 0x2
	.byte	0x7b
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x2b
	.4byte	.LVL42
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x2c
	.4byte	0xa0
	.4byte	0x619
	.uleb128 0x2d
	.4byte	0x69
	.byte	0xb
	.byte	0
	.uleb128 0x2e
	.4byte	.LASF22
	.byte	0x1
	.byte	0xa0
	.byte	0xd
	.4byte	0x676
	.uleb128 0x2f
	.ascii	"num\000"
	.byte	0x1
	.byte	0xa0
	.byte	0x1d
	.4byte	0x5d
	.uleb128 0x30
	.4byte	.LASF17
	.byte	0x1
	.byte	0xa0
	.byte	0x2f
	.4byte	0x69
	.uleb128 0x2f
	.ascii	"uc\000"
	.byte	0x1
	.byte	0xa0
	.byte	0x39
	.4byte	0x56
	.uleb128 0x2f
	.ascii	"bf\000"
	.byte	0x1
	.byte	0xa0
	.byte	0x43
	.4byte	0x168
	.uleb128 0x31
	.ascii	"n\000"
	.byte	0x1
	.byte	0xa2
	.byte	0x9
	.4byte	0x56
	.uleb128 0x31
	.ascii	"d\000"
	.byte	0x1
	.byte	0xa3
	.byte	0xc
	.4byte	0x5d
	.uleb128 0x32
	.uleb128 0x31
	.ascii	"dgt\000"
	.byte	0x1
	.byte	0xa8
	.byte	0xd
	.4byte	0x56
	.byte	0
	.byte	0
	.uleb128 0x33
	.4byte	.LASF26
	.byte	0x1
	.byte	0x92
	.byte	0xd
	.4byte	.LFB9
	.4byte	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x746
	.uleb128 0x19
	.4byte	.LASF13
	.byte	0x1
	.byte	0x92
	.byte	0x1a
	.4byte	0x48
	.4byte	.LLST5
	.4byte	.LVUS5
	.uleb128 0x19
	.4byte	.LASF14
	.byte	0x1
	.byte	0x92
	.byte	0x26
	.4byte	0x7e
	.4byte	.LLST6
	.4byte	.LVUS6
	.uleb128 0x1a
	.ascii	"n\000"
	.byte	0x1
	.byte	0x92
	.byte	0x30
	.4byte	0x56
	.4byte	.LLST7
	.4byte	.LVUS7
	.uleb128 0x1a
	.ascii	"z\000"
	.byte	0x1
	.byte	0x92
	.byte	0x38
	.4byte	0xa0
	.4byte	.LLST8
	.4byte	.LVUS8
	.uleb128 0x1a
	.ascii	"bf\000"
	.byte	0x1
	.byte	0x92
	.byte	0x41
	.4byte	0x168
	.4byte	.LLST9
	.4byte	.LVUS9
	.uleb128 0x1c
	.ascii	"fc\000"
	.byte	0x1
	.byte	0x94
	.byte	0xa
	.4byte	0xa0
	.4byte	.LLST10
	.4byte	.LVUS10
	.uleb128 0x1c
	.ascii	"ch\000"
	.byte	0x1
	.byte	0x95
	.byte	0xa
	.4byte	0xa0
	.4byte	.LLST11
	.4byte	.LVUS11
	.uleb128 0x1c
	.ascii	"p\000"
	.byte	0x1
	.byte	0x96
	.byte	0xb
	.4byte	0x168
	.4byte	.LLST12
	.4byte	.LVUS12
	.uleb128 0x29
	.4byte	.LVL28
	.4byte	0x739
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x2
	.byte	0x78
	.sleb128 0
	.byte	0
	.uleb128 0x2b
	.4byte	.LVL33
	.uleb128 0x14
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x2
	.byte	0x76
	.sleb128 0
	.byte	0
	.byte	0
	.uleb128 0x34
	.4byte	.LASF19
	.byte	0x1
	.byte	0x8c
	.byte	0xd
	.byte	0x1
	.4byte	0x777
	.uleb128 0x2f
	.ascii	"ptr\000"
	.byte	0x1
	.byte	0x8c
	.byte	0x19
	.4byte	0x48
	.uleb128 0x2f
	.ascii	"bf\000"
	.byte	0x1
	.byte	0x8c
	.byte	0x24
	.4byte	0x168
	.uleb128 0x31
	.ascii	"num\000"
	.byte	0x1
	.byte	0x8e
	.byte	0x12
	.4byte	0x69
	.byte	0
	.uleb128 0x35
	.ascii	"a2i\000"
	.byte	0x1
	.byte	0x7b
	.byte	0xd
	.4byte	0xa0
	.byte	0x1
	.4byte	0x7da
	.uleb128 0x2f
	.ascii	"ch\000"
	.byte	0x1
	.byte	0x7b
	.byte	0x16
	.4byte	0xa0
	.uleb128 0x2f
	.ascii	"src\000"
	.byte	0x1
	.byte	0x7b
	.byte	0x21
	.4byte	0x7da
	.uleb128 0x30
	.4byte	.LASF17
	.byte	0x1
	.byte	0x7b
	.byte	0x2a
	.4byte	0x56
	.uleb128 0x30
	.4byte	.LASF20
	.byte	0x1
	.byte	0x7b
	.byte	0x35
	.4byte	0x7e0
	.uleb128 0x31
	.ascii	"p\000"
	.byte	0x1
	.byte	0x7d
	.byte	0xb
	.4byte	0x168
	.uleb128 0x31
	.ascii	"num\000"
	.byte	0x1
	.byte	0x7e
	.byte	0x9
	.4byte	0x56
	.uleb128 0x36
	.4byte	.LASF21
	.byte	0x1
	.byte	0x7f
	.byte	0x9
	.4byte	0x56
	.byte	0
	.uleb128 0x8
	.byte	0x4
	.4byte	0x168
	.uleb128 0x8
	.byte	0x4
	.4byte	0x56
	.uleb128 0x35
	.ascii	"a2d\000"
	.byte	0x1
	.byte	0x6f
	.byte	0xc
	.4byte	0x56
	.byte	0x1
	.4byte	0x803
	.uleb128 0x2f
	.ascii	"ch\000"
	.byte	0x1
	.byte	0x6f
	.byte	0x15
	.4byte	0xa0
	.byte	0
	.uleb128 0x37
	.ascii	"i2a\000"
	.byte	0x1
	.byte	0x65
	.byte	0xd
	.4byte	0x827
	.uleb128 0x2f
	.ascii	"num\000"
	.byte	0x1
	.byte	0x65
	.byte	0x15
	.4byte	0x56
	.uleb128 0x2f
	.ascii	"bf\000"
	.byte	0x1
	.byte	0x65
	.byte	0x20
	.4byte	0x168
	.byte	0
	.uleb128 0x2e
	.4byte	.LASF23
	.byte	0x1
	.byte	0x51
	.byte	0xd
	.4byte	0x884
	.uleb128 0x2f
	.ascii	"num\000"
	.byte	0x1
	.byte	0x51
	.byte	0x1f
	.4byte	0x69
	.uleb128 0x30
	.4byte	.LASF17
	.byte	0x1
	.byte	0x51
	.byte	0x31
	.4byte	0x69
	.uleb128 0x2f
	.ascii	"uc\000"
	.byte	0x1
	.byte	0x51
	.byte	0x3b
	.4byte	0x56
	.uleb128 0x2f
	.ascii	"bf\000"
	.byte	0x1
	.byte	0x51
	.byte	0x45
	.4byte	0x168
	.uleb128 0x31
	.ascii	"n\000"
	.byte	0x1
	.byte	0x53
	.byte	0x9
	.4byte	0x56
	.uleb128 0x31
	.ascii	"d\000"
	.byte	0x1
	.byte	0x54
	.byte	0x12
	.4byte	0x69
	.uleb128 0x32
	.uleb128 0x31
	.ascii	"dgt\000"
	.byte	0x1
	.byte	0x59
	.byte	0xd
	.4byte	0x56
	.byte	0
	.byte	0
	.uleb128 0x34
	.4byte	.LASF24
	.byte	0x1
	.byte	0x45
	.byte	0xd
	.byte	0x1
	.4byte	0x8a9
	.uleb128 0x2f
	.ascii	"num\000"
	.byte	0x1
	.byte	0x45
	.byte	0x17
	.4byte	0x8a9
	.uleb128 0x2f
	.ascii	"bf\000"
	.byte	0x1
	.byte	0x45
	.byte	0x22
	.4byte	0x168
	.byte	0
	.uleb128 0x7
	.byte	0x4
	.byte	0x5
	.4byte	.LASF25
	.uleb128 0x33
	.4byte	.LASF27
	.byte	0x1
	.byte	0x31
	.byte	0xd
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x947
	.uleb128 0x1a
	.ascii	"num\000"
	.byte	0x1
	.byte	0x31
	.byte	0x25
	.4byte	0x947
	.4byte	.LLST0
	.4byte	.LVUS0
	.uleb128 0x38
	.4byte	.LASF17
	.byte	0x1
	.byte	0x31
	.byte	0x37
	.4byte	0x69
	.uleb128 0x1
	.byte	0x51
	.uleb128 0x39
	.ascii	"uc\000"
	.byte	0x1
	.byte	0x31
	.byte	0x41
	.4byte	0x56
	.uleb128 0x1
	.byte	0x52
	.uleb128 0x1a
	.ascii	"bf\000"
	.byte	0x1
	.byte	0x31
	.byte	0x4b
	.4byte	0x168
	.4byte	.LLST1
	.4byte	.LVUS1
	.uleb128 0x1c
	.ascii	"n\000"
	.byte	0x1
	.byte	0x33
	.byte	0x9
	.4byte	0x56
	.4byte	.LLST2
	.4byte	.LVUS2
	.uleb128 0x1c
	.ascii	"d\000"
	.byte	0x1
	.byte	0x34
	.byte	0x12
	.4byte	0x69
	.4byte	.LLST3
	.4byte	.LVUS3
	.uleb128 0x21
	.4byte	.Ldebug_ranges0+0
	.uleb128 0x1c
	.ascii	"dgt\000"
	.byte	0x1
	.byte	0x39
	.byte	0xd
	.4byte	0x56
	.4byte	.LLST4
	.4byte	.LVUS4
	.byte	0
	.byte	0
	.uleb128 0x7
	.byte	0x4
	.byte	0x7
	.4byte	.LASF28
	.uleb128 0x34
	.4byte	.LASF29
	.byte	0x1
	.byte	0x17
	.byte	0xd
	.byte	0x1
	.4byte	0x995
	.uleb128 0x2f
	.ascii	"num\000"
	.byte	0x1
	.byte	0x17
	.byte	0x1b
	.4byte	0x5d
	.uleb128 0x2f
	.ascii	"bf\000"
	.byte	0x1
	.byte	0x17
	.byte	0x26
	.4byte	0x168
	.uleb128 0x31
	.ascii	"n\000"
	.byte	0x1
	.byte	0x19
	.byte	0x9
	.4byte	0x56
	.uleb128 0x31
	.ascii	"d\000"
	.byte	0x1
	.byte	0x1a
	.byte	0xc
	.4byte	0x5d
	.uleb128 0x32
	.uleb128 0x31
	.ascii	"dgt\000"
	.byte	0x1
	.byte	0x23
	.byte	0xd
	.4byte	0x56
	.byte	0
	.byte	0
	.uleb128 0x3a
	.4byte	0x16e
	.4byte	.LFB14
	.4byte	.LFE14-.LFB14
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x3b
	.4byte	0x17c
	.uleb128 0x1
	.byte	0x50
	.uleb128 0x3b
	.4byte	0x187
	.uleb128 0x1
	.byte	0x51
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
	.uleb128 0x3
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
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.uleb128 0x34
	.uleb128 0x19
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
	.uleb128 0x7
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
	.uleb128 0x8
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x15
	.byte	0x1
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x5
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xb
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
	.uleb128 0xc
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
	.uleb128 0xd
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
	.uleb128 0xe
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
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x18
	.byte	0
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
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x1d
	.byte	0x1
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x52
	.uleb128 0x1
	.uleb128 0x2138
	.uleb128 0xb
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x58
	.uleb128 0xb
	.uleb128 0x59
	.uleb128 0x5
	.uleb128 0x57
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x5
	.byte	0
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x410a
	.byte	0
	.uleb128 0x2
	.uleb128 0x18
	.uleb128 0x2111
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x20
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x16
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
	.byte	0
	.byte	0
	.uleb128 0x17
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
	.uleb128 0x18
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
	.uleb128 0x1b
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
	.uleb128 0x18
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
	.uleb128 0xa
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x11
	.uleb128 0x1
	.byte	0
	.byte	0
	.uleb128 0x1e
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x55
	.uleb128 0x17
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1f
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
	.uleb128 0x20
	.uleb128 0x1d
	.byte	0x1
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
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x21
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x55
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x22
	.uleb128 0x34
	.byte	0
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x17
	.uleb128 0x2137
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x23
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x55
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x24
	.uleb128 0x1d
	.byte	0x1
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
	.uleb128 0x5
	.uleb128 0x57
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x25
	.uleb128 0x1d
	.byte	0x1
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x55
	.uleb128 0x17
	.uleb128 0x58
	.uleb128 0xb
	.uleb128 0x59
	.uleb128 0xb
	.uleb128 0x57
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x26
	.uleb128 0x5
	.byte	0
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x27
	.uleb128 0x1d
	.byte	0x1
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x52
	.uleb128 0x1
	.uleb128 0x2138
	.uleb128 0xb
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x58
	.uleb128 0xb
	.uleb128 0x59
	.uleb128 0xb
	.uleb128 0x57
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x28
	.uleb128 0x1d
	.byte	0x1
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x52
	.uleb128 0x1
	.uleb128 0x2138
	.uleb128 0xb
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x6
	.uleb128 0x58
	.uleb128 0xb
	.uleb128 0x59
	.uleb128 0xb
	.uleb128 0x57
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x29
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x2a
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
	.uleb128 0x2b
	.uleb128 0x4109
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.byte	0
	.byte	0
	.uleb128 0x2c
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x2d
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x2e
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x2f
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
	.byte	0
	.byte	0
	.uleb128 0x30
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
	.byte	0
	.byte	0
	.uleb128 0x31
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
	.byte	0
	.byte	0
	.uleb128 0x32
	.uleb128 0xb
	.byte	0x1
	.byte	0
	.byte	0
	.uleb128 0x33
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x34
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x35
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3
	.uleb128 0x8
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
	.uleb128 0x20
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x36
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
	.byte	0
	.byte	0
	.uleb128 0x37
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x38
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
	.uleb128 0x39
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
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x3a
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x31
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
	.uleb128 0x3b
	.uleb128 0x5
	.byte	0
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_loc,"",%progbits
.Ldebug_loc0:
.LVUS36:
	.uleb128 0
	.uleb128 .LVU338
.LLST36:
	.4byte	.LVL132
	.4byte	.LVL133-1
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS37:
	.uleb128 .LVU339
	.uleb128 .LVU343
.LLST37:
	.4byte	.LVL133
	.4byte	.LVL134
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS38:
	.uleb128 .LVU339
	.uleb128 .LVU343
.LLST38:
	.4byte	.LVL133
	.4byte	.LVL134
	.2byte	0x3
	.byte	0x91
	.sleb128 -60
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS13:
	.uleb128 0
	.uleb128 .LVU108
	.uleb128 .LVU108
	.uleb128 .LVU146
	.uleb128 .LVU146
	.uleb128 .LVU147
	.uleb128 .LVU147
	.uleb128 0
.LLST13:
	.4byte	.LVL38
	.4byte	.LVL41
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL41
	.4byte	.LVL56
	.2byte	0x1
	.byte	0x56
	.4byte	.LVL56
	.4byte	.LVL57
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	.LVL57
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x56
	.4byte	0
	.4byte	0
.LVUS14:
	.uleb128 0
	.uleb128 .LVU101
	.uleb128 .LVU101
	.uleb128 0
.LLST14:
	.4byte	.LVL38
	.4byte	.LVL39
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL39
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x57
	.4byte	0
	.4byte	0
.LVUS15:
	.uleb128 0
	.uleb128 .LVU101
	.uleb128 .LVU101
	.uleb128 .LVU105
	.uleb128 .LVU108
	.uleb128 .LVU110
	.uleb128 .LVU110
	.uleb128 .LVU112
	.uleb128 .LVU112
	.uleb128 .LVU113
	.uleb128 .LVU113
	.uleb128 .LVU121
	.uleb128 .LVU121
	.uleb128 .LVU127
	.uleb128 .LVU127
	.uleb128 .LVU132
	.uleb128 .LVU132
	.uleb128 .LVU144
	.uleb128 .LVU144
	.uleb128 .LVU145
	.uleb128 .LVU145
	.uleb128 .LVU146
	.uleb128 .LVU147
	.uleb128 .LVU148
	.uleb128 .LVU148
	.uleb128 .LVU149
	.uleb128 .LVU149
	.uleb128 .LVU152
	.uleb128 .LVU177
	.uleb128 .LVU201
	.uleb128 .LVU201
	.uleb128 .LVU203
	.uleb128 .LVU203
	.uleb128 0
.LLST15:
	.4byte	.LVL38
	.4byte	.LVL39
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL39
	.4byte	.LVL39
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL41
	.4byte	.LVL42-1
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL42-1
	.4byte	.LVL43
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL43
	.4byte	.LVL44
	.2byte	0x3
	.byte	0x74
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL44
	.4byte	.LVL46
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL46
	.4byte	.LVL48
	.2byte	0x3
	.byte	0x74
	.sleb128 2
	.byte	0x9f
	.4byte	.LVL48
	.4byte	.LVL50
	.2byte	0x3
	.byte	0x74
	.sleb128 3
	.byte	0x9f
	.4byte	.LVL50
	.4byte	.LVL54
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL54
	.4byte	.LVL55
	.2byte	0x3
	.byte	0x74
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL55
	.4byte	.LVL56
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL57
	.4byte	.LVL57
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL57
	.4byte	.LVL58
	.2byte	0x3
	.byte	0x74
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL58
	.4byte	.LVL60
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL65
	.4byte	.LVL75
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL75
	.4byte	.LVL76
	.2byte	0x3
	.byte	0x74
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL76
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS16:
	.uleb128 0
	.uleb128 .LVU101
	.uleb128 .LVU101
	.uleb128 .LVU107
	.uleb128 .LVU108
	.uleb128 .LVU110
	.uleb128 .LVU110
	.uleb128 .LVU114
	.uleb128 .LVU114
	.uleb128 .LVU146
	.uleb128 .LVU147
	.uleb128 .LVU180
	.uleb128 .LVU180
	.uleb128 .LVU181
	.uleb128 .LVU181
	.uleb128 .LVU197
	.uleb128 .LVU197
	.uleb128 .LVU198
	.uleb128 .LVU198
	.uleb128 .LVU205
	.uleb128 .LVU205
	.uleb128 .LVU206
	.uleb128 .LVU206
	.uleb128 .LVU213
	.uleb128 .LVU213
	.uleb128 .LVU249
	.uleb128 .LVU249
	.uleb128 .LVU251
	.uleb128 .LVU251
	.uleb128 .LVU252
	.uleb128 .LVU252
	.uleb128 .LVU258
	.uleb128 .LVU258
	.uleb128 .LVU261
	.uleb128 .LVU261
	.uleb128 .LVU268
	.uleb128 .LVU268
	.uleb128 .LVU269
	.uleb128 .LVU269
	.uleb128 .LVU273
	.uleb128 .LVU273
	.uleb128 .LVU274
	.uleb128 .LVU274
	.uleb128 .LVU280
	.uleb128 .LVU280
	.uleb128 .LVU281
	.uleb128 .LVU281
	.uleb128 .LVU289
	.uleb128 .LVU289
	.uleb128 .LVU290
	.uleb128 .LVU290
	.uleb128 .LVU293
	.uleb128 .LVU293
	.uleb128 0
.LLST16:
	.4byte	.LVL38
	.4byte	.LVL39
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL39
	.4byte	.LVL40
	.2byte	0x3
	.byte	0x53
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL41
	.4byte	.LVL42
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL42
	.4byte	.LVL45
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL45
	.4byte	.LVL56
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL57
	.4byte	.LVL65
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL65
	.4byte	.LVL66
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL66
	.4byte	.LVL72
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL72
	.4byte	.LVL73
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL73
	.4byte	.LVL77
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL77
	.4byte	.LVL78
	.2byte	0x5
	.byte	0x73
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL78
	.4byte	.LVL80
	.2byte	0x3
	.byte	0x53
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL80
	.4byte	.LVL94
	.2byte	0x5
	.byte	0x91
	.sleb128 -72
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL94
	.4byte	.LVL94
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL94
	.4byte	.LVL95
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL95
	.4byte	.LVL100
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL100
	.4byte	.LVL101
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL101
	.4byte	.LVL104
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL104
	.4byte	.LVL105
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL105
	.4byte	.LVL108
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL108
	.4byte	.LVL109
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL109
	.4byte	.LVL112
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL112
	.4byte	.LVL113
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL113
	.4byte	.LVL118
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL118
	.4byte	.LVL119
	.2byte	0x5
	.byte	0x7a
	.sleb128 4
	.byte	0x9f
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL119
	.4byte	.LVL122
	.2byte	0x3
	.byte	0x5a
	.byte	0x93
	.uleb128 0x4
	.4byte	.LVL122
	.4byte	.LFE11
	.2byte	0x5
	.byte	0x91
	.sleb128 -72
	.byte	0x93
	.uleb128 0x4
	.4byte	0
	.4byte	0
.LVUS17:
	.uleb128 .LVU105
	.uleb128 .LVU110
	.uleb128 .LVU113
	.uleb128 .LVU122
	.uleb128 .LVU122
	.uleb128 .LVU141
	.uleb128 .LVU145
	.uleb128 .LVU146
	.uleb128 .LVU147
	.uleb128 .LVU152
	.uleb128 .LVU177
	.uleb128 .LVU184
	.uleb128 .LVU196
	.uleb128 .LVU199
	.uleb128 .LVU200
	.uleb128 .LVU201
	.uleb128 .LVU201
	.uleb128 .LVU203
	.uleb128 .LVU203
	.uleb128 .LVU249
	.uleb128 .LVU249
	.uleb128 .LVU253
	.uleb128 .LVU255
	.uleb128 .LVU256
	.uleb128 .LVU265
	.uleb128 .LVU270
	.uleb128 .LVU272
	.uleb128 .LVU275
	.uleb128 .LVU277
	.uleb128 .LVU282
	.uleb128 .LVU282
	.uleb128 .LVU283
	.uleb128 .LVU283
	.uleb128 .LVU284
	.uleb128 .LVU284
	.uleb128 .LVU285
	.uleb128 .LVU286
	.uleb128 .LVU291
	.uleb128 .LVU291
	.uleb128 .LVU292
	.uleb128 .LVU293
	.uleb128 .LVU299
	.uleb128 .LVU300
	.uleb128 0
.LLST17:
	.4byte	.LVL39
	.4byte	.LVL42-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL44
	.4byte	.LVL47
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL47
	.4byte	.LVL53-1
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL55
	.4byte	.LVL56
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL57
	.4byte	.LVL60
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL65
	.4byte	.LVL67
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL72
	.4byte	.LVL74-1
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL75
	.4byte	.LVL75
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL75
	.4byte	.LVL76
	.2byte	0x2
	.byte	0x74
	.sleb128 0
	.4byte	.LVL76
	.4byte	.LVL94
	.2byte	0x2
	.byte	0x74
	.sleb128 -1
	.4byte	.LVL94
	.4byte	.LVL96
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL98
	.4byte	.LVL99-1
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL104
	.4byte	.LVL106
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL108
	.4byte	.LVL110
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL112
	.4byte	.LVL114
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL114
	.4byte	.LVL115
	.2byte	0x4
	.byte	0x72
	.sleb128 88
	.byte	0x9f
	.4byte	.LVL115
	.4byte	.LVL116
	.2byte	0x4
	.byte	0x73
	.sleb128 88
	.byte	0x9f
	.4byte	.LVL116
	.4byte	.LVL117-1
	.2byte	0x2
	.byte	0x74
	.sleb128 -1
	.4byte	.LVL118
	.4byte	.LVL120
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL120
	.4byte	.LVL121-1
	.2byte	0x2
	.byte	0x74
	.sleb128 -1
	.4byte	.LVL122
	.4byte	.LVL125
	.2byte	0x2
	.byte	0x74
	.sleb128 -1
	.4byte	.LVL127
	.4byte	.LFE11
	.2byte	0x2
	.byte	0x74
	.sleb128 -1
	.4byte	0
	.4byte	0
.LVUS18:
	.uleb128 .LVU117
	.uleb128 .LVU130
	.uleb128 .LVU130
	.uleb128 .LVU132
	.uleb128 .LVU132
	.uleb128 .LVU146
	.uleb128 .LVU147
	.uleb128 .LVU222
	.uleb128 .LVU222
	.uleb128 .LVU249
	.uleb128 .LVU249
	.uleb128 .LVU293
	.uleb128 .LVU293
	.uleb128 .LVU294
	.uleb128 .LVU300
	.uleb128 0
.LLST18:
	.4byte	.LVL46
	.4byte	.LVL49
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL49
	.4byte	.LVL50
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	.LVL50
	.4byte	.LVL56
	.2byte	0x1
	.byte	0x58
	.4byte	.LVL57
	.4byte	.LVL85
	.2byte	0x1
	.byte	0x58
	.4byte	.LVL85
	.4byte	.LVL94
	.2byte	0x3
	.byte	0x91
	.sleb128 -68
	.4byte	.LVL94
	.4byte	.LVL122
	.2byte	0x1
	.byte	0x58
	.4byte	.LVL122
	.4byte	.LVL123
	.2byte	0x3
	.byte	0x91
	.sleb128 -68
	.4byte	.LVL127
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x58
	.4byte	0
	.4byte	0
.LVUS19:
	.uleb128 .LVU118
	.uleb128 .LVU139
	.uleb128 .LVU147
	.uleb128 .LVU150
	.uleb128 .LVU150
	.uleb128 .LVU151
	.uleb128 .LVU151
	.uleb128 .LVU177
	.uleb128 .LVU265
	.uleb128 .LVU277
	.uleb128 .LVU277
	.uleb128 .LVU293
.LLST19:
	.4byte	.LVL46
	.4byte	.LVL52
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL57
	.4byte	.LVL58
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL58
	.4byte	.LVL59
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	.LVL59
	.4byte	.LVL65
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL104
	.4byte	.LVL112
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL112
	.4byte	.LVL122
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS20:
	.uleb128 .LVU119
	.uleb128 .LVU146
	.uleb128 .LVU147
	.uleb128 0
.LLST20:
	.4byte	.LVL46
	.4byte	.LVL56
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL57
	.4byte	.LFE11
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS21:
	.uleb128 .LVU120
	.uleb128 .LVU135
	.uleb128 .LVU135
	.uleb128 .LVU141
	.uleb128 .LVU147
	.uleb128 .LVU151
	.uleb128 .LVU151
	.uleb128 .LVU177
	.uleb128 .LVU177
	.uleb128 0
.LLST21:
	.4byte	.LVL46
	.4byte	.LVL51
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL51
	.4byte	.LVL53
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL57
	.4byte	.LVL59
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL59
	.4byte	.LVL65
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL65
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x55
	.4byte	0
	.4byte	0
.LVUS22:
	.uleb128 .LVU207
	.uleb128 .LVU221
	.uleb128 .LVU223
	.uleb128 .LVU224
	.uleb128 .LVU224
	.uleb128 .LVU225
	.uleb128 .LVU225
	.uleb128 .LVU229
	.uleb128 .LVU229
	.uleb128 .LVU247
	.uleb128 .LVU247
	.uleb128 .LVU249
	.uleb128 .LVU293
	.uleb128 .LVU294
	.uleb128 .LVU300
	.uleb128 0
.LLST22:
	.4byte	.LVL79
	.4byte	.LVL84
	.2byte	0x3
	.byte	0x91
	.sleb128 -60
	.byte	0x9f
	.4byte	.LVL86
	.4byte	.LVL87
	.2byte	0x3
	.byte	0x70
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL87
	.4byte	.LVL87
	.2byte	0x3
	.byte	0x78
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL87
	.4byte	.LVL88
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL88
	.4byte	.LVL92
	.2byte	0x1
	.byte	0x58
	.4byte	.LVL92
	.4byte	.LVL94
	.2byte	0x3
	.byte	0x78
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL122
	.4byte	.LVL123
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL127
	.4byte	.LFE11
	.2byte	0x3
	.byte	0x91
	.sleb128 -60
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS23:
	.uleb128 .LVU220
	.uleb128 .LVU221
	.uleb128 .LVU223
	.uleb128 .LVU249
	.uleb128 .LVU293
	.uleb128 .LVU297
	.uleb128 .LVU301
	.uleb128 0
.LLST23:
	.4byte	.LVL83
	.4byte	.LVL84
	.2byte	0x1
	.byte	0x5e
	.4byte	.LVL86
	.4byte	.LVL94
	.2byte	0x1
	.byte	0x5e
	.4byte	.LVL122
	.4byte	.LVL124
	.2byte	0x1
	.byte	0x5e
	.4byte	.LVL128
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x5e
	.4byte	0
	.4byte	0
.LVUS24:
	.uleb128 .LVU209
	.uleb128 .LVU221
	.uleb128 .LVU223
	.uleb128 .LVU225
	.uleb128 .LVU225
	.uleb128 .LVU238
	.uleb128 .LVU238
	.uleb128 .LVU248
	.uleb128 .LVU293
	.uleb128 .LVU294
	.uleb128 .LVU300
	.uleb128 0
.LLST24:
	.4byte	.LVL79
	.4byte	.LVL84
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL86
	.4byte	.LVL87
	.2byte	0x3
	.byte	0x7a
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL87
	.4byte	.LVL90
	.2byte	0x1
	.byte	0x5a
	.4byte	.LVL90
	.4byte	.LVL93
	.2byte	0x3
	.byte	0x7a
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL122
	.4byte	.LVL123
	.2byte	0x1
	.byte	0x5a
	.4byte	.LVL127
	.4byte	.LFE11
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS25:
	.uleb128 .LVU210
	.uleb128 .LVU215
	.uleb128 .LVU215
	.uleb128 .LVU221
	.uleb128 .LVU223
	.uleb128 .LVU231
	.uleb128 .LVU231
	.uleb128 .LVU245
	.uleb128 .LVU245
	.uleb128 .LVU249
	.uleb128 .LVU293
	.uleb128 .LVU294
	.uleb128 .LVU300
	.uleb128 .LVU301
	.uleb128 .LVU301
	.uleb128 0
.LLST25:
	.4byte	.LVL79
	.4byte	.LVL81
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	.LVL81
	.4byte	.LVL84
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL86
	.4byte	.LVL89
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL89
	.4byte	.LVL92
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL92
	.4byte	.LVL94
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL122
	.4byte	.LVL123
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL127
	.4byte	.LVL128
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	.LVL128
	.4byte	.LFE11
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS26:
	.uleb128 .LVU232
	.uleb128 .LVU233
.LLST26:
	.4byte	.LVL89
	.4byte	.LVL89
	.2byte	0x1
	.byte	0x5c
	.4byte	0
	.4byte	0
.LVUS27:
	.uleb128 .LVU181
	.uleb128 .LVU190
	.uleb128 .LVU190
	.uleb128 .LVU192
	.uleb128 .LVU192
	.uleb128 .LVU193
.LLST27:
	.4byte	.LVL66
	.4byte	.LVL68
	.2byte	0x3
	.byte	0x91
	.sleb128 -60
	.byte	0x9f
	.4byte	.LVL68
	.4byte	.LVL69
	.2byte	0x3
	.byte	0x91
	.sleb128 -59
	.byte	0x9f
	.4byte	.LVL69
	.4byte	.LVL70-1
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS28:
	.uleb128 .LVU189
	.uleb128 .LVU193
.LLST28:
	.4byte	.LVL68
	.4byte	.LVL70-1
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS29:
	.uleb128 .LVU152
	.uleb128 .LVU154
	.uleb128 .LVU156
	.uleb128 .LVU177
.LLST29:
	.4byte	.LVL60
	.4byte	.LVL61
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL62
	.4byte	.LVL65
	.2byte	0x1
	.byte	0x52
	.4byte	0
	.4byte	0
.LVUS30:
	.uleb128 .LVU152
	.uleb128 .LVU154
	.uleb128 .LVU154
	.uleb128 .LVU156
	.uleb128 .LVU157
	.uleb128 .LVU177
.LLST30:
	.4byte	.LVL60
	.4byte	.LVL61
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL61
	.4byte	.LVL62
	.2byte	0x3
	.byte	0x74
	.sleb128 -1
	.byte	0x9f
	.4byte	.LVL63
	.4byte	.LVL65
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS31:
	.uleb128 .LVU152
	.uleb128 .LVU177
.LLST31:
	.4byte	.LVL60
	.4byte	.LVL65
	.2byte	0x1
	.byte	0x55
	.4byte	0
	.4byte	0
.LVUS32:
	.uleb128 .LVU152
	.uleb128 .LVU157
	.uleb128 .LVU174
	.uleb128 .LVU177
.LLST32:
	.4byte	.LVL60
	.4byte	.LVL63
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL64
	.4byte	.LVL65
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS33:
	.uleb128 .LVU158
	.uleb128 .LVU174
.LLST33:
	.4byte	.LVL63
	.4byte	.LVL64
	.2byte	0x1
	.byte	0x52
	.4byte	0
	.4byte	0
.LVUS34:
	.uleb128 .LVU258
	.uleb128 .LVU262
.LLST34:
	.4byte	.LVL100
	.4byte	.LVL102
	.2byte	0x3
	.byte	0x91
	.sleb128 -60
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS35:
	.uleb128 .LVU260
	.uleb128 .LVU261
	.uleb128 .LVU261
	.uleb128 .LVU262
.LLST35:
	.4byte	.LVL100
	.4byte	.LVL101
	.2byte	0x2
	.byte	0x7a
	.sleb128 0
	.4byte	.LVL101
	.4byte	.LVL102-1
	.2byte	0x2
	.byte	0x7a
	.sleb128 -4
	.4byte	0
	.4byte	0
.LVUS5:
	.uleb128 0
	.uleb128 .LVU69
	.uleb128 .LVU69
	.uleb128 .LVU89
	.uleb128 .LVU89
	.uleb128 0
.LLST5:
	.4byte	.LVL18
	.4byte	.LVL23
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL23
	.4byte	.LVL35
	.2byte	0x1
	.byte	0x56
	.4byte	.LVL35
	.4byte	.LFE9
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS6:
	.uleb128 0
	.uleb128 .LVU63
	.uleb128 .LVU63
	.uleb128 0
.LLST6:
	.4byte	.LVL18
	.4byte	.LVL20
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL20
	.4byte	.LFE9
	.2byte	0x1
	.byte	0x57
	.4byte	0
	.4byte	0
.LVUS7:
	.uleb128 0
	.uleb128 .LVU74
	.uleb128 .LVU74
	.uleb128 .LVU77
	.uleb128 .LVU77
	.uleb128 .LVU82
	.uleb128 .LVU89
	.uleb128 .LVU91
	.uleb128 .LVU91
	.uleb128 0
.LLST7:
	.4byte	.LVL18
	.4byte	.LVL26
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL26
	.4byte	.LVL27
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL27
	.4byte	.LVL30
	.2byte	0x1
	.byte	0x54
	.4byte	.LVL35
	.4byte	.LVL36
	.2byte	0x1
	.byte	0x52
	.4byte	.LVL36
	.4byte	.LFE9
	.2byte	0x1
	.byte	0x54
	.4byte	0
	.4byte	0
.LVUS8:
	.uleb128 0
	.uleb128 .LVU68
	.uleb128 .LVU68
	.uleb128 .LVU89
	.uleb128 .LVU89
	.uleb128 0
.LLST8:
	.4byte	.LVL18
	.4byte	.LVL22
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL22
	.4byte	.LVL35
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x53
	.byte	0x9f
	.4byte	.LVL35
	.4byte	.LFE9
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS9:
	.uleb128 0
	.uleb128 .LVU82
	.uleb128 .LVU82
	.uleb128 .LVU83
	.uleb128 .LVU83
	.uleb128 .LVU87
	.uleb128 .LVU87
	.uleb128 .LVU88
	.uleb128 .LVU88
	.uleb128 .LVU89
	.uleb128 .LVU89
	.uleb128 0
.LLST9:
	.4byte	.LVL18
	.4byte	.LVL30
	.2byte	0x2
	.byte	0x91
	.sleb128 0
	.4byte	.LVL30
	.4byte	.LVL30
	.2byte	0x2
	.byte	0x91
	.sleb128 -8
	.4byte	.LVL30
	.4byte	.LVL33
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL33
	.4byte	.LVL34
	.2byte	0x3
	.byte	0x75
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL34
	.4byte	.LVL35
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL35
	.4byte	.LFE9
	.2byte	0x2
	.byte	0x91
	.sleb128 0
	.4byte	0
	.4byte	0
.LVUS10:
	.uleb128 .LVU59
	.uleb128 0
.LLST10:
	.4byte	.LVL19
	.4byte	.LFE9
	.2byte	0x1
	.byte	0x58
	.4byte	0
	.4byte	0
.LVUS11:
	.uleb128 .LVU84
	.uleb128 .LVU86
	.uleb128 .LVU88
	.uleb128 .LVU89
.LLST11:
	.4byte	.LVL31
	.4byte	.LVL33-1
	.2byte	0x1
	.byte	0x51
	.4byte	.LVL34
	.4byte	.LVL35
	.2byte	0x1
	.byte	0x51
	.4byte	0
	.4byte	0
.LVUS12:
	.uleb128 .LVU61
	.uleb128 .LVU63
	.uleb128 .LVU63
	.uleb128 .LVU65
	.uleb128 .LVU70
	.uleb128 .LVU72
	.uleb128 .LVU72
	.uleb128 .LVU74
.LLST12:
	.4byte	.LVL19
	.4byte	.LVL20
	.2byte	0x1
	.byte	0x55
	.4byte	.LVL20
	.4byte	.LVL21
	.2byte	0x2
	.byte	0x91
	.sleb128 -8
	.4byte	.LVL24
	.4byte	.LVL25
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL25
	.4byte	.LVL26
	.2byte	0x3
	.byte	0x73
	.sleb128 -1
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS0:
	.uleb128 0
	.uleb128 .LVU14
	.uleb128 .LVU50
	.uleb128 0
.LLST0:
	.4byte	.LVL0
	.4byte	.LVL3
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL15
	.4byte	.LFE2
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS1:
	.uleb128 0
	.uleb128 .LVU14
	.uleb128 .LVU15
	.uleb128 .LVU27
	.uleb128 .LVU27
	.uleb128 .LVU29
	.uleb128 .LVU29
	.uleb128 .LVU35
	.uleb128 .LVU35
	.uleb128 .LVU40
	.uleb128 .LVU40
	.uleb128 .LVU43
	.uleb128 .LVU43
	.uleb128 .LVU48
	.uleb128 .LVU48
	.uleb128 0
.LLST1:
	.4byte	.LVL0
	.4byte	.LVL3
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL4
	.4byte	.LVL7
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL7
	.4byte	.LVL9
	.2byte	0x3
	.byte	0x73
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL9
	.4byte	.LVL10
	.2byte	0x1
	.byte	0x5c
	.4byte	.LVL10
	.4byte	.LVL11
	.2byte	0x1
	.byte	0x53
	.4byte	.LVL11
	.4byte	.LVL13
	.2byte	0x3
	.byte	0x7c
	.sleb128 1
	.byte	0x9f
	.4byte	.LVL13
	.4byte	.LVL14
	.2byte	0x1
	.byte	0x5c
	.4byte	.LVL14
	.4byte	.LFE2
	.2byte	0x1
	.byte	0x53
	.4byte	0
	.4byte	0
.LVUS2:
	.uleb128 .LVU2
	.uleb128 .LVU14
	.uleb128 .LVU25
	.uleb128 .LVU30
	.uleb128 .LVU30
	.uleb128 .LVU32
	.uleb128 .LVU50
	.uleb128 0
.LLST2:
	.4byte	.LVL0
	.4byte	.LVL3
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL6
	.4byte	.LVL9
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	.LVL9
	.4byte	.LVL9
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	.LVL15
	.4byte	.LFE2
	.2byte	0x2
	.byte	0x30
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS3:
	.uleb128 .LVU3
	.uleb128 .LVU8
	.uleb128 .LVU8
	.uleb128 .LVU14
	.uleb128 .LVU15
	.uleb128 .LVU23
	.uleb128 .LVU23
	.uleb128 .LVU32
	.uleb128 .LVU35
	.uleb128 .LVU50
	.uleb128 .LVU50
	.uleb128 .LVU51
	.uleb128 .LVU52
	.uleb128 0
.LLST3:
	.4byte	.LVL0
	.4byte	.LVL1
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	.LVL1
	.4byte	.LVL3
	.2byte	0x1
	.byte	0x5c
	.4byte	.LVL4
	.4byte	.LVL5
	.2byte	0x1
	.byte	0x5c
	.4byte	.LVL5
	.4byte	.LVL9
	.2byte	0x1
	.byte	0x56
	.4byte	.LVL10
	.4byte	.LVL15
	.2byte	0x1
	.byte	0x56
	.4byte	.LVL15
	.4byte	.LVL16
	.2byte	0x1
	.byte	0x5c
	.4byte	.LVL17
	.4byte	.LFE2
	.2byte	0x2
	.byte	0x31
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS4:
	.uleb128 .LVU16
	.uleb128 .LVU28
	.uleb128 .LVU28
	.uleb128 .LVU32
	.uleb128 .LVU35
	.uleb128 .LVU41
.LLST4:
	.4byte	.LVL4
	.4byte	.LVL8
	.2byte	0x1
	.byte	0x5e
	.4byte	.LVL8
	.4byte	.LVL9
	.2byte	0x3
	.byte	0x7e
	.sleb128 -48
	.byte	0x9f
	.4byte	.LVL10
	.4byte	.LVL12
	.2byte	0x1
	.byte	0x5e
	.4byte	0
	.4byte	0
	.section	.debug_aranges,"",%progbits
	.4byte	0x4c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB2
	.4byte	.LFE2-.LFB2
	.4byte	.LFB9
	.4byte	.LFE9-.LFB9
	.4byte	.LFB14
	.4byte	.LFE14-.LFB14
	.4byte	.LFB11
	.4byte	.LFE11-.LFB11
	.4byte	.LFB12
	.4byte	.LFE12-.LFB12
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.4byte	.LFB15
	.4byte	.LFE15-.LFB15
	.4byte	0
	.4byte	0
	.section	.debug_ranges,"",%progbits
.Ldebug_ranges0:
	.4byte	.LBB7
	.4byte	.LBE7
	.4byte	.LBB8
	.4byte	.LBE8
	.4byte	.LBB9
	.4byte	.LBE9
	.4byte	.LBB10
	.4byte	.LBE10
	.4byte	0
	.4byte	0
	.4byte	.LBB25
	.4byte	.LBE25
	.4byte	.LBB52
	.4byte	.LBE52
	.4byte	.LBB53
	.4byte	.LBE53
	.4byte	0
	.4byte	0
	.4byte	.LBB26
	.4byte	.LBE26
	.4byte	.LBB46
	.4byte	.LBE46
	.4byte	.LBB49
	.4byte	.LBE49
	.4byte	.LBB50
	.4byte	.LBE50
	.4byte	.LBB51
	.4byte	.LBE51
	.4byte	0
	.4byte	0
	.4byte	.LBB28
	.4byte	.LBE28
	.4byte	.LBB29
	.4byte	.LBE29
	.4byte	.LBB30
	.4byte	.LBE30
	.4byte	.LBB31
	.4byte	.LBE31
	.4byte	0
	.4byte	0
	.4byte	.LBB36
	.4byte	.LBE36
	.4byte	.LBB45
	.4byte	.LBE45
	.4byte	0
	.4byte	0
	.4byte	.LBB39
	.4byte	.LBE39
	.4byte	.LBB44
	.4byte	.LBE44
	.4byte	0
	.4byte	0
	.4byte	.LFB2
	.4byte	.LFE2
	.4byte	.LFB9
	.4byte	.LFE9
	.4byte	.LFB14
	.4byte	.LFE14
	.4byte	.LFB11
	.4byte	.LFE11
	.4byte	.LFB12
	.4byte	.LFE12
	.4byte	.LFB13
	.4byte	.LFE13
	.4byte	.LFB15
	.4byte	.LFE15
	.4byte	0
	.4byte	0
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.section	.debug_str,"MS",%progbits,1
.LASF9:
	.ascii	"stdout_putp\000"
.LASF2:
	.ascii	"size_t\000"
.LASF25:
	.ascii	"long int\000"
.LASF29:
	.ascii	"size2a\000"
.LASF15:
	.ascii	"tfp_format\000"
.LASF16:
	.ascii	"size_mod\000"
.LASF0:
	.ascii	"__gnuc_va_list\000"
.LASF6:
	.ascii	"putcf\000"
.LASF8:
	.ascii	"stdout_putf\000"
.LASF12:
	.ascii	"init_printf\000"
.LASF17:
	.ascii	"base\000"
.LASF18:
	.ascii	"putcp\000"
.LASF1:
	.ascii	"va_list\000"
.LASF32:
	.ascii	"/home/fred/code/rpi-qemu-gdb/Claude/raspi3b_qemu_\000"
.LASF28:
	.ascii	"long unsigned int\000"
.LASF19:
	.ascii	"ptr2a\000"
.LASF31:
	.ascii	"src/printf.c\000"
.LASF10:
	.ascii	"tfp_sprintf\000"
.LASF3:
	.ascii	"unsigned int\000"
.LASF21:
	.ascii	"digit\000"
.LASF7:
	.ascii	"char\000"
.LASF34:
	.ascii	"__ap\000"
.LASF14:
	.ascii	"putf\000"
.LASF11:
	.ascii	"tfp_printf\000"
.LASF33:
	.ascii	"__va_list\000"
.LASF4:
	.ascii	"long long int\000"
.LASF22:
	.ascii	"size_t2a\000"
.LASF27:
	.ascii	"uli2a\000"
.LASF26:
	.ascii	"putchw\000"
.LASF20:
	.ascii	"nump\000"
.LASF13:
	.ascii	"putp\000"
.LASF35:
	.ascii	"abort\000"
.LASF5:
	.ascii	"long double\000"
.LASF24:
	.ascii	"li2a\000"
.LASF30:
	.ascii	"GNU C17 10.3.1 20210621 (release) -mcpu=cortex-a7 -"
	.ascii	"mfloat-abi=soft -marm -march=armv7ve -g -O2 -fpic -"
	.ascii	"ffreestanding -ffunction-sections -fdata-sections -"
	.ascii	"fno-common\000"
.LASF23:
	.ascii	"ui2a\000"
	.ident	"GCC: (15:10.3-2021.07-4) 10.3.1 20210621 (release)"
