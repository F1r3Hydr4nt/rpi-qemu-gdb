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
	.file	"status.c"
@ GNU C17 (15:10.3-2021.07-4) version 10.3.1 20210621 (release) (arm-none-eabi)
@	compiled by GNU C version 11.2.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

@ GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
@ options passed:  -I src -I src/common -imultilib thumb/v7-a/nofp
@ -D__USES_INITFINI__ src/common/status.c -mcpu=cortex-a7 -mfloat-abi=soft
@ -marm -mlibarch=armv7ve -march=armv7ve
@ -auxbase-strip build/asm_output/common/status.s -g -O2 -Wall -Wextra
@ -fpic -ffreestanding -ffunction-sections -fdata-sections -fno-common
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
	.section	.rodata.get_status_string.str1.4,"aMS",%progbits,1
	.align	2
.LC0:
	.ascii	"?\000"
	.section	.text.get_status_string,"ax",%progbits
	.align	2
	.global	get_status_string
	.arch armv7ve
	.syntax unified
	.arm
	.fpu softvfp
	.type	get_status_string, %function
get_status_string:
.LVL0:
.LFB13:
	.file 1 "src/common/status.c"
	.loc 1 41 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 42 3 view .LVU1
@ src/common/status.c:42:   int idx = statusstr_msgidxof (no);
	.loc 1 42 13 is_stmt 0 view .LVU2
	cmp	r0, #101	@ no,
	bhi	.L3		@,
.LVL1:
	.loc 1 43 3 is_stmt 1 view .LVU3
	.loc 1 46 5 view .LVU4
@ src/common/status.c:46:     return statusstr_msgstr + statusstr_msgidx[idx];
	.loc 1 46 47 is_stmt 0 view .LVU5
	ldr	r2, .L5	@ tmp122,
@ src/common/status.c:46:     return statusstr_msgstr + statusstr_msgidx[idx];
	.loc 1 46 29 view .LVU6
	ldr	r3, .L5+4	@ tmp120,
@ src/common/status.c:46:     return statusstr_msgstr + statusstr_msgidx[idx];
	.loc 1 46 47 view .LVU7
.LPIC2:
	add	r2, pc, r2	@ tmp122, tmp122
@ src/common/status.c:46:     return statusstr_msgstr + statusstr_msgidx[idx];
	.loc 1 46 29 view .LVU8
.LPIC1:
	add	r3, pc, r3	@ tmp120, tmp120
	ldr	r2, [r2, r0, lsl #2]	@ statusstr_msgidx[no_5(D)], statusstr_msgidx[no_5(D)]
	add	r0, r3, r2	@ <retval>, tmp120, statusstr_msgidx[no_5(D)]
.LVL2:
	.loc 1 46 29 view .LVU9
	bx	lr	@
.LVL3:
.L3:
@ src/common/status.c:44:     return "?";
	.loc 1 44 12 view .LVU10
	ldr	r0, .L5+8	@ <retval>,
.LVL4:
	.loc 1 44 12 view .LVU11
.LPIC0:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:47: }
	.loc 1 47 1 view .LVU12
	bx	lr	@
.L6:
	.align	2
.L5:
	.word	.LANCHOR1-(.LPIC2+8)
	.word	.LANCHOR0-(.LPIC1+8)
	.word	.LC0-(.LPIC0+8)
	.cfi_endproc
.LFE13:
	.size	get_status_string, .-get_status_string
	.section	.rodata.get_inv_recpsgnr_code.str1.4,"aMS",%progbits,1
	.align	2
.LC1:
	.ascii	"0\000"
	.align	2
.LC2:
	.ascii	"1\000"
	.align	2
.LC3:
	.ascii	"3\000"
	.align	2
.LC4:
	.ascii	"4\000"
	.align	2
.LC5:
	.ascii	"5\000"
	.align	2
.LC6:
	.ascii	"6\000"
	.align	2
.LC7:
	.ascii	"7\000"
	.align	2
.LC8:
	.ascii	"8\000"
	.align	2
.LC9:
	.ascii	"9\000"
	.align	2
.LC10:
	.ascii	"10\000"
	.align	2
.LC11:
	.ascii	"11\000"
	.align	2
.LC12:
	.ascii	"2\000"
	.align	2
.LC13:
	.ascii	"12\000"
	.section	.text.get_inv_recpsgnr_code,"ax",%progbits
	.align	2
	.global	get_inv_recpsgnr_code
	.syntax unified
	.arm
	.fpu softvfp
	.type	get_inv_recpsgnr_code, %function
get_inv_recpsgnr_code:
.LVL5:
.LFB14:
	.loc 1 52 1 is_stmt 1 view -0
	.cfi_startproc
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	.loc 1 53 3 view .LVU14
	.loc 1 55 3 view .LVU15
.LBB4:
.LBI4:
	.file 2 "src/common/../gpg-error.h"
	.loc 2 972 1 view .LVU16
.LBB5:
	.loc 2 974 3 view .LVU17
@ src/common/../gpg-error.h:974:   return (gpg_err_code_t) (err & GPG_ERR_CODE_MASK);
	.loc 2 974 10 is_stmt 0 view .LVU18
	uxth	r0, r0	@ _4, err
.LVL6:
	.loc 2 974 10 view .LVU19
.LBE5:
.LBE4:
@ src/common/status.c:55:   switch (gpg_err_code (err))
	.loc 1 55 3 view .LVU20
	cmp	r0, #125	@ _4,
	bhi	.L8		@,
	cmp	r0, #53	@ _4,
	bls	.L26		@,
	sub	r0, r0, #54	@ tmp133, _4,
	cmp	r0, #71	@ tmp133,
	addls	pc, pc, r0, asl #2	@ tmp133
	b	.L12	@
.L13:
	b	.L22
	b	.L12
	b	.L12
	b	.L21
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L20
	b	.L19
	b	.L18
	b	.L12
	b	.L17
	b	.L12
	b	.L12
	b	.L16
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L15
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L14
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L12
	b	.L24
	.p2align 1
.L12:
@ src/common/status.c:72:     default:                      errstr = "0"; break;
	.loc 1 72 42 view .LVU21
	ldr	r0, .L28	@ <retval>,
.LPIC17:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L26:
@ src/common/status.c:55:   switch (gpg_err_code (err))
	.loc 1 55 3 view .LVU22
	cmp	r0, #9	@ _4,
	beq	.L23		@,
	cmp	r0, #17	@ _4,
	bne	.L27		@,
@ src/common/status.c:67:     case GPG_ERR_NO_SECKEY:       errstr = "9"; break;
	.loc 1 67 42 view .LVU23
	ldr	r0, .L28+4	@ <retval>,
.LPIC16:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L8:
@ src/common/status.c:55:   switch (gpg_err_code (err))
	.loc 1 55 3 view .LVU24
	cmp	r0, #185	@ _4,
	bne	.L25		@,
@ src/common/status.c:71:     case GPG_ERR_MISSING_ISSUER_CERT: errstr = "12"; break;
	.loc 1 71 46 view .LVU25
	ldr	r0, .L28+8	@ <retval>,
.LPIC15:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L23:
@ src/common/status.c:57:     case GPG_ERR_NO_PUBKEY:       errstr = "1"; break;
	.loc 1 57 42 view .LVU26
	ldr	r0, .L28+12	@ <retval>,
.LPIC4:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L25:
@ src/common/status.c:72:     default:                      errstr = "0"; break;
	.loc 1 72 42 view .LVU27
	ldr	r0, .L28+16	@ <retval>,
.LPIC18:
	add	r0, pc, r0	@ <retval>, <retval>
.LVL7:
	.loc 1 75 3 is_stmt 1 view .LVU28
@ src/common/status.c:76: }
	.loc 1 76 1 is_stmt 0 view .LVU29
	bx	lr	@
.LVL8:
.L14:
	.loc 1 64 35 is_stmt 1 view .LVU30
	.loc 1 64 49 view .LVU31
@ src/common/status.c:64:     case GPG_ERR_NO_POLICY_MATCH: errstr = "8"; break;
	.loc 1 64 42 is_stmt 0 view .LVU32
	ldr	r0, .L28+20	@ <retval>,
.LPIC10:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:64:     case GPG_ERR_NO_POLICY_MATCH: errstr = "8"; break;
	.loc 1 64 5 view .LVU33
	bx	lr	@
.LVL9:
.L21:
	.loc 1 70 35 is_stmt 1 view .LVU34
	.loc 1 70 50 view .LVU35
@ src/common/status.c:70:     case GPG_ERR_MISSING_CERT:    errstr = "11"; break;
	.loc 1 70 42 is_stmt 0 view .LVU36
	ldr	r0, .L28+24	@ <retval>,
.LPIC13:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:70:     case GPG_ERR_MISSING_CERT:    errstr = "11"; break;
	.loc 1 70 5 view .LVU37
	bx	lr	@
.LVL10:
.L20:
	.loc 1 60 35 is_stmt 1 view .LVU38
	.loc 1 60 49 view .LVU39
@ src/common/status.c:60:     case GPG_ERR_CERT_REVOKED:    errstr = "4"; break;
	.loc 1 60 42 is_stmt 0 view .LVU40
	ldr	r0, .L28+28	@ <retval>,
.LPIC6:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:60:     case GPG_ERR_CERT_REVOKED:    errstr = "4"; break;
	.loc 1 60 5 view .LVU41
	bx	lr	@
.LVL11:
.L19:
	.loc 1 62 35 is_stmt 1 view .LVU42
	.loc 1 62 49 view .LVU43
@ src/common/status.c:62:     case GPG_ERR_NO_CRL_KNOWN:    errstr = "6"; break;
	.loc 1 62 42 is_stmt 0 view .LVU44
	ldr	r0, .L28+32	@ <retval>,
.LPIC8:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:62:     case GPG_ERR_NO_CRL_KNOWN:    errstr = "6"; break;
	.loc 1 62 5 view .LVU45
	bx	lr	@
.LVL12:
.L18:
	.loc 1 63 35 is_stmt 1 view .LVU46
	.loc 1 63 49 view .LVU47
@ src/common/status.c:63:     case GPG_ERR_CRL_TOO_OLD:     errstr = "7"; break;
	.loc 1 63 42 is_stmt 0 view .LVU48
	ldr	r0, .L28+36	@ <retval>,
.LPIC9:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:63:     case GPG_ERR_CRL_TOO_OLD:     errstr = "7"; break;
	.loc 1 63 5 view .LVU49
	bx	lr	@
.LVL13:
.L17:
	.loc 1 69 35 is_stmt 1 view .LVU50
	.loc 1 69 50 view .LVU51
@ src/common/status.c:69:     case GPG_ERR_NOT_TRUSTED:     errstr = "10"; break;
	.loc 1 69 42 is_stmt 0 view .LVU52
	ldr	r0, .L28+40	@ <retval>,
.LPIC12:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:69:     case GPG_ERR_NOT_TRUSTED:     errstr = "10"; break;
	.loc 1 69 5 view .LVU53
	bx	lr	@
.LVL14:
.L16:
	.loc 1 61 35 is_stmt 1 view .LVU54
	.loc 1 61 49 view .LVU55
@ src/common/status.c:61:     case GPG_ERR_CERT_EXPIRED:    errstr = "5"; break;
	.loc 1 61 42 is_stmt 0 view .LVU56
	ldr	r0, .L28+44	@ <retval>,
.LPIC7:
	add	r0, pc, r0	@ <retval>, <retval>
@ src/common/status.c:61:     case GPG_ERR_CERT_EXPIRED:    errstr = "5"; break;
	.loc 1 61 5 view .LVU57
	bx	lr	@
.LVL15:
.L24:
@ src/common/status.c:59:     case GPG_ERR_WRONG_KEY_USAGE: errstr = "3"; break;
	.loc 1 59 42 view .LVU58
	ldr	r0, .L28+48	@ <retval>,
.LPIC5:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L22:
@ src/common/status.c:67:     case GPG_ERR_NO_SECKEY:       errstr = "9"; break;
	.loc 1 67 42 view .LVU59
	ldr	r0, .L28+52	@ <retval>,
.LPIC11:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L15:
@ src/common/status.c:55:   switch (gpg_err_code (err))
	.loc 1 55 3 view .LVU60
	ldr	r0, .L28+56	@ <retval>,
.LPIC14:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L27:
@ src/common/status.c:72:     default:                      errstr = "0"; break;
	.loc 1 72 42 view .LVU61
	ldr	r0, .L28+60	@ <retval>,
.LPIC3:
	add	r0, pc, r0	@ <retval>, <retval>
	bx	lr	@
.L29:
	.align	2
.L28:
	.word	.LC1-(.LPIC17+8)
	.word	.LC9-(.LPIC16+8)
	.word	.LC13-(.LPIC15+8)
	.word	.LC2-(.LPIC4+8)
	.word	.LC1-(.LPIC18+8)
	.word	.LC8-(.LPIC10+8)
	.word	.LC11-(.LPIC13+8)
	.word	.LC4-(.LPIC6+8)
	.word	.LC6-(.LPIC8+8)
	.word	.LC7-(.LPIC9+8)
	.word	.LC10-(.LPIC12+8)
	.word	.LC5-(.LPIC7+8)
	.word	.LC3-(.LPIC5+8)
	.word	.LC9-(.LPIC11+8)
	.word	.LC12-(.LPIC14+8)
	.word	.LC1-(.LPIC3+8)
	.cfi_endproc
.LFE14:
	.size	get_inv_recpsgnr_code, .-get_inv_recpsgnr_code
	.section	.rodata.statusstr_msgidx,"a"
	.align	2
	.set	.LANCHOR1,. + 0
	.type	statusstr_msgidx, %object
	.size	statusstr_msgidx, 408
statusstr_msgidx:
	.word	0
	.word	6
	.word	12
	.word	18
	.word	35
	.word	43
	.word	50
	.word	57
	.word	66
	.word	82
	.word	94
	.word	109
	.word	121
	.word	136
	.word	152
	.word	161
	.word	168
	.word	175
	.word	182
	.word	197
	.word	207
	.word	217
	.word	237
	.word	252
	.word	268
	.word	286
	.word	302
	.word	321
	.word	337
	.word	345
	.word	352
	.word	359
	.word	368
	.word	378
	.word	393
	.word	404
	.word	417
	.word	426
	.word	437
	.word	448
	.word	458
	.word	469
	.word	486
	.word	501
	.word	518
	.word	533
	.word	547
	.word	562
	.word	571
	.word	580
	.word	591
	.word	598
	.word	607
	.word	619
	.word	631
	.word	645
	.word	660
	.word	674
	.word	685
	.word	697
	.word	709
	.word	720
	.word	729
	.word	738
	.word	746
	.word	754
	.word	769
	.word	784
	.word	795
	.word	806
	.word	813
	.word	823
	.word	833
	.word	843
	.word	850
	.word	864
	.word	874
	.word	891
	.word	907
	.word	927
	.word	936
	.word	950
	.word	964
	.word	983
	.word	997
	.word	1012
	.word	1022
	.word	1033
	.word	1050
	.word	1066
	.word	1093
	.word	1120
	.word	1149
	.word	1159
	.word	1170
	.word	1179
	.word	1197
	.word	1215
	.word	1221
	.word	1229
	.word	1237
	.word	1245
	.section	.rodata.statusstr_msgstr,"a"
	.align	2
	.set	.LANCHOR0,. + 0
	.type	statusstr_msgstr, %object
	.size	statusstr_msgstr, 1260
statusstr_msgstr:
	.ascii	"ENTER\000LEAVE\000ABORT\000CANCELED_BY_USER\000GOOD"
	.ascii	"SIG\000BADSIG\000ERRSIG\000BADARMOR\000TRUST_UNDEFI"
	.ascii	"NED\000TRUST_NEVER\000TRUST_MARGINAL\000TRUST_FULLY"
	.ascii	"\000TRUST_ULTIMATE\000NEED_PASSPHRASE\000VALIDSIG\000"
	.ascii	"SIG_ID\000ENC_TO\000NODATA\000BAD_PASSPHRASE\000NO_"
	.ascii	"PUBKEY\000NO_SECKEY\000NEED_PASSPHRASE_SYM\000DECRY"
	.ascii	"PTION_KEY\000DECRYPTION_INFO\000DECRYPTION_FAILED\000"
	.ascii	"DECRYPTION_OKAY\000MISSING_PASSPHRASE\000GOOD_PASSP"
	.ascii	"HRASE\000GOODMDC\000BADMDC\000ERRMDC\000IMPORTED\000"
	.ascii	"IMPORT_OK\000IMPORT_PROBLEM\000IMPORT_RES\000IMPORT"
	.ascii	"_CHECK\000EXPORTED\000EXPORT_RES\000FILE_START\000F"
	.ascii	"ILE_DONE\000FILE_ERROR\000BEGIN_DECRYPTION\000END_D"
	.ascii	"ECRYPTION\000BEGIN_ENCRYPTION\000END_ENCRYPTION\000"
	.ascii	"BEGIN_SIGNING\000DELETE_PROBLEM\000GET_BOOL\000GET_"
	.ascii	"LINE\000GET_HIDDEN\000GOT_IT\000PROGRESS\000SIG_CRE"
	.ascii	"ATED\000SESSION_KEY\000NOTATION_NAME\000NOTATION_FL"
	.ascii	"AGS\000NOTATION_DATA\000POLICY_URL\000KEY_CREATED\000"
	.ascii	"USERID_HINT\000UNEXPECTED\000INV_RECP\000INV_SGNR\000"
	.ascii	"NO_RECP\000NO_SGNR\000KEY_CONSIDERED\000ALREADY_SIG"
	.ascii	"NED\000KEYEXPIRED\000KEYREVOKED\000EXPSIG\000EXPKEY"
	.ascii	"SIG\000ATTRIBUTE\000REVKEYSIG\000NEWSIG\000SIG_SUBP"
	.ascii	"ACKET\000PLAINTEXT\000PLAINTEXT_LENGTH\000KEY_NOT_C"
	.ascii	"REATED\000NEED_PASSPHRASE_PIN\000CARDCTRL\000SC_OP_"
	.ascii	"FAILURE\000SC_OP_SUCCESS\000BACKUP_KEY_CREATED\000P"
	.ascii	"KA_TRUST_BAD\000PKA_TRUST_GOOD\000TOFU_USER\000TOFU"
	.ascii	"_STATS\000TOFU_STATS_SHORT\000TOFU_STATS_LONG\000EN"
	.ascii	"CRYPTION_COMPLIANCE_MODE\000DECRYPTION_COMPLIANCE_M"
	.ascii	"ODE\000VERIFICATION_COMPLIANCE_MODE\000TRUNCATED\000"
	.ascii	"MOUNTPOINT\000BLOCKDEV\000PINENTRY_LAUNCHED\000PLAI"
	.ascii	"NTEXT_FOLLOWS\000ERROR\000WARNING\000SUCCESS\000FAI"
	.ascii	"LURE\000INQUIRE_MAXLEN\000"
	.text
.Letext0:
	.file 3 "src/common/status-codes.h"
	.section	.debug_info,"",%progbits
.Ldebug_info0:
	.4byte	0x10b8
	.2byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x4
	.uleb128 0x1
	.4byte	.LASF601
	.byte	0xc
	.4byte	.LASF602
	.4byte	.LASF603
	.4byte	.Ldebug_ranges0+0
	.4byte	0
	.4byte	.Ldebug_line0
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF0
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.ascii	"int\000"
	.uleb128 0x4
	.4byte	0x2c
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.4byte	.LASF1
	.uleb128 0x2
	.byte	0x8
	.byte	0x4
	.4byte	.LASF2
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.4byte	.LASF3
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF4
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.4byte	.LASF5
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.4byte	.LASF6
	.uleb128 0x2
	.byte	0x4
	.byte	0x5
	.4byte	.LASF7
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.4byte	.LASF8
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.4byte	.LASF9
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.4byte	.LASF10
	.uleb128 0x4
	.4byte	0x77
	.uleb128 0x5
	.byte	0x4
	.4byte	0x7e
	.uleb128 0x6
	.byte	0x7
	.byte	0x4
	.4byte	0x25
	.byte	0x2
	.byte	0x90
	.byte	0x3
	.4byte	0xf8e
	.uleb128 0x7
	.4byte	.LASF11
	.byte	0
	.uleb128 0x7
	.4byte	.LASF12
	.byte	0x1
	.uleb128 0x7
	.4byte	.LASF13
	.byte	0x2
	.uleb128 0x7
	.4byte	.LASF14
	.byte	0x3
	.uleb128 0x7
	.4byte	.LASF15
	.byte	0x4
	.uleb128 0x7
	.4byte	.LASF16
	.byte	0x5
	.uleb128 0x7
	.4byte	.LASF17
	.byte	0x6
	.uleb128 0x7
	.4byte	.LASF18
	.byte	0x7
	.uleb128 0x7
	.4byte	.LASF19
	.byte	0x8
	.uleb128 0x7
	.4byte	.LASF20
	.byte	0x9
	.uleb128 0x7
	.4byte	.LASF21
	.byte	0xa
	.uleb128 0x7
	.4byte	.LASF22
	.byte	0xb
	.uleb128 0x7
	.4byte	.LASF23
	.byte	0xc
	.uleb128 0x7
	.4byte	.LASF24
	.byte	0xd
	.uleb128 0x7
	.4byte	.LASF25
	.byte	0xe
	.uleb128 0x7
	.4byte	.LASF26
	.byte	0xf
	.uleb128 0x7
	.4byte	.LASF27
	.byte	0x10
	.uleb128 0x7
	.4byte	.LASF28
	.byte	0x11
	.uleb128 0x7
	.4byte	.LASF29
	.byte	0x12
	.uleb128 0x7
	.4byte	.LASF30
	.byte	0x13
	.uleb128 0x7
	.4byte	.LASF31
	.byte	0x14
	.uleb128 0x7
	.4byte	.LASF32
	.byte	0x15
	.uleb128 0x7
	.4byte	.LASF33
	.byte	0x16
	.uleb128 0x7
	.4byte	.LASF34
	.byte	0x17
	.uleb128 0x7
	.4byte	.LASF35
	.byte	0x18
	.uleb128 0x7
	.4byte	.LASF36
	.byte	0x19
	.uleb128 0x7
	.4byte	.LASF37
	.byte	0x1a
	.uleb128 0x7
	.4byte	.LASF38
	.byte	0x1b
	.uleb128 0x7
	.4byte	.LASF39
	.byte	0x1c
	.uleb128 0x7
	.4byte	.LASF40
	.byte	0x1d
	.uleb128 0x7
	.4byte	.LASF41
	.byte	0x1e
	.uleb128 0x7
	.4byte	.LASF42
	.byte	0x1f
	.uleb128 0x7
	.4byte	.LASF43
	.byte	0x20
	.uleb128 0x7
	.4byte	.LASF44
	.byte	0x21
	.uleb128 0x7
	.4byte	.LASF45
	.byte	0x22
	.uleb128 0x7
	.4byte	.LASF46
	.byte	0x23
	.uleb128 0x7
	.4byte	.LASF47
	.byte	0x24
	.uleb128 0x7
	.4byte	.LASF48
	.byte	0x25
	.uleb128 0x7
	.4byte	.LASF49
	.byte	0x26
	.uleb128 0x7
	.4byte	.LASF50
	.byte	0x27
	.uleb128 0x7
	.4byte	.LASF51
	.byte	0x28
	.uleb128 0x7
	.4byte	.LASF52
	.byte	0x29
	.uleb128 0x7
	.4byte	.LASF53
	.byte	0x2a
	.uleb128 0x7
	.4byte	.LASF54
	.byte	0x2b
	.uleb128 0x7
	.4byte	.LASF55
	.byte	0x2c
	.uleb128 0x7
	.4byte	.LASF56
	.byte	0x2d
	.uleb128 0x7
	.4byte	.LASF57
	.byte	0x2e
	.uleb128 0x7
	.4byte	.LASF58
	.byte	0x2f
	.uleb128 0x7
	.4byte	.LASF59
	.byte	0x30
	.uleb128 0x7
	.4byte	.LASF60
	.byte	0x31
	.uleb128 0x7
	.4byte	.LASF61
	.byte	0x32
	.uleb128 0x7
	.4byte	.LASF62
	.byte	0x33
	.uleb128 0x7
	.4byte	.LASF63
	.byte	0x34
	.uleb128 0x7
	.4byte	.LASF64
	.byte	0x35
	.uleb128 0x7
	.4byte	.LASF65
	.byte	0x36
	.uleb128 0x7
	.4byte	.LASF66
	.byte	0x37
	.uleb128 0x7
	.4byte	.LASF67
	.byte	0x38
	.uleb128 0x7
	.4byte	.LASF68
	.byte	0x39
	.uleb128 0x7
	.4byte	.LASF69
	.byte	0x3a
	.uleb128 0x7
	.4byte	.LASF70
	.byte	0x3b
	.uleb128 0x7
	.4byte	.LASF71
	.byte	0x3c
	.uleb128 0x7
	.4byte	.LASF72
	.byte	0x3d
	.uleb128 0x7
	.4byte	.LASF73
	.byte	0x3e
	.uleb128 0x7
	.4byte	.LASF74
	.byte	0x3f
	.uleb128 0x7
	.4byte	.LASF75
	.byte	0x40
	.uleb128 0x7
	.4byte	.LASF76
	.byte	0x41
	.uleb128 0x7
	.4byte	.LASF77
	.byte	0x42
	.uleb128 0x7
	.4byte	.LASF78
	.byte	0x43
	.uleb128 0x7
	.4byte	.LASF79
	.byte	0x44
	.uleb128 0x7
	.4byte	.LASF80
	.byte	0x45
	.uleb128 0x7
	.4byte	.LASF81
	.byte	0x46
	.uleb128 0x7
	.4byte	.LASF82
	.byte	0x47
	.uleb128 0x7
	.4byte	.LASF83
	.byte	0x48
	.uleb128 0x7
	.4byte	.LASF84
	.byte	0x49
	.uleb128 0x7
	.4byte	.LASF85
	.byte	0x4a
	.uleb128 0x7
	.4byte	.LASF86
	.byte	0x4b
	.uleb128 0x7
	.4byte	.LASF87
	.byte	0x4c
	.uleb128 0x7
	.4byte	.LASF88
	.byte	0x4d
	.uleb128 0x7
	.4byte	.LASF89
	.byte	0x4e
	.uleb128 0x7
	.4byte	.LASF90
	.byte	0x4f
	.uleb128 0x7
	.4byte	.LASF91
	.byte	0x50
	.uleb128 0x7
	.4byte	.LASF92
	.byte	0x51
	.uleb128 0x7
	.4byte	.LASF93
	.byte	0x52
	.uleb128 0x7
	.4byte	.LASF94
	.byte	0x53
	.uleb128 0x7
	.4byte	.LASF95
	.byte	0x54
	.uleb128 0x7
	.4byte	.LASF96
	.byte	0x55
	.uleb128 0x7
	.4byte	.LASF97
	.byte	0x56
	.uleb128 0x7
	.4byte	.LASF98
	.byte	0x57
	.uleb128 0x7
	.4byte	.LASF99
	.byte	0x58
	.uleb128 0x7
	.4byte	.LASF100
	.byte	0x59
	.uleb128 0x7
	.4byte	.LASF101
	.byte	0x5a
	.uleb128 0x7
	.4byte	.LASF102
	.byte	0x5b
	.uleb128 0x7
	.4byte	.LASF103
	.byte	0x5c
	.uleb128 0x7
	.4byte	.LASF104
	.byte	0x5d
	.uleb128 0x7
	.4byte	.LASF105
	.byte	0x5e
	.uleb128 0x7
	.4byte	.LASF106
	.byte	0x5f
	.uleb128 0x7
	.4byte	.LASF107
	.byte	0x60
	.uleb128 0x7
	.4byte	.LASF108
	.byte	0x61
	.uleb128 0x7
	.4byte	.LASF109
	.byte	0x62
	.uleb128 0x7
	.4byte	.LASF110
	.byte	0x63
	.uleb128 0x7
	.4byte	.LASF111
	.byte	0x64
	.uleb128 0x7
	.4byte	.LASF112
	.byte	0x65
	.uleb128 0x7
	.4byte	.LASF113
	.byte	0x66
	.uleb128 0x7
	.4byte	.LASF114
	.byte	0x67
	.uleb128 0x7
	.4byte	.LASF115
	.byte	0x68
	.uleb128 0x7
	.4byte	.LASF116
	.byte	0x69
	.uleb128 0x7
	.4byte	.LASF117
	.byte	0x6a
	.uleb128 0x7
	.4byte	.LASF118
	.byte	0x6b
	.uleb128 0x7
	.4byte	.LASF119
	.byte	0x6c
	.uleb128 0x7
	.4byte	.LASF120
	.byte	0x6d
	.uleb128 0x7
	.4byte	.LASF121
	.byte	0x6e
	.uleb128 0x7
	.4byte	.LASF122
	.byte	0x6f
	.uleb128 0x7
	.4byte	.LASF123
	.byte	0x70
	.uleb128 0x7
	.4byte	.LASF124
	.byte	0x71
	.uleb128 0x7
	.4byte	.LASF125
	.byte	0x72
	.uleb128 0x7
	.4byte	.LASF126
	.byte	0x73
	.uleb128 0x7
	.4byte	.LASF127
	.byte	0x74
	.uleb128 0x7
	.4byte	.LASF128
	.byte	0x75
	.uleb128 0x7
	.4byte	.LASF129
	.byte	0x76
	.uleb128 0x7
	.4byte	.LASF130
	.byte	0x77
	.uleb128 0x7
	.4byte	.LASF131
	.byte	0x78
	.uleb128 0x7
	.4byte	.LASF132
	.byte	0x79
	.uleb128 0x7
	.4byte	.LASF133
	.byte	0x7a
	.uleb128 0x7
	.4byte	.LASF134
	.byte	0x7b
	.uleb128 0x7
	.4byte	.LASF135
	.byte	0x7c
	.uleb128 0x7
	.4byte	.LASF136
	.byte	0x7d
	.uleb128 0x7
	.4byte	.LASF137
	.byte	0x7e
	.uleb128 0x7
	.4byte	.LASF138
	.byte	0x7f
	.uleb128 0x7
	.4byte	.LASF139
	.byte	0x80
	.uleb128 0x7
	.4byte	.LASF140
	.byte	0x81
	.uleb128 0x7
	.4byte	.LASF141
	.byte	0x82
	.uleb128 0x7
	.4byte	.LASF142
	.byte	0x83
	.uleb128 0x7
	.4byte	.LASF143
	.byte	0x84
	.uleb128 0x7
	.4byte	.LASF144
	.byte	0x85
	.uleb128 0x7
	.4byte	.LASF145
	.byte	0x86
	.uleb128 0x7
	.4byte	.LASF146
	.byte	0x87
	.uleb128 0x7
	.4byte	.LASF147
	.byte	0x88
	.uleb128 0x7
	.4byte	.LASF148
	.byte	0x89
	.uleb128 0x7
	.4byte	.LASF149
	.byte	0x8a
	.uleb128 0x7
	.4byte	.LASF150
	.byte	0x8b
	.uleb128 0x7
	.4byte	.LASF151
	.byte	0x8c
	.uleb128 0x7
	.4byte	.LASF152
	.byte	0x8d
	.uleb128 0x7
	.4byte	.LASF153
	.byte	0x8e
	.uleb128 0x7
	.4byte	.LASF154
	.byte	0x8f
	.uleb128 0x7
	.4byte	.LASF155
	.byte	0x90
	.uleb128 0x7
	.4byte	.LASF156
	.byte	0x91
	.uleb128 0x7
	.4byte	.LASF157
	.byte	0x92
	.uleb128 0x7
	.4byte	.LASF158
	.byte	0x93
	.uleb128 0x7
	.4byte	.LASF159
	.byte	0x94
	.uleb128 0x7
	.4byte	.LASF160
	.byte	0x95
	.uleb128 0x7
	.4byte	.LASF161
	.byte	0x96
	.uleb128 0x7
	.4byte	.LASF162
	.byte	0x97
	.uleb128 0x7
	.4byte	.LASF163
	.byte	0x98
	.uleb128 0x7
	.4byte	.LASF164
	.byte	0x99
	.uleb128 0x7
	.4byte	.LASF165
	.byte	0x9a
	.uleb128 0x7
	.4byte	.LASF166
	.byte	0x9b
	.uleb128 0x7
	.4byte	.LASF167
	.byte	0x9c
	.uleb128 0x7
	.4byte	.LASF168
	.byte	0x9d
	.uleb128 0x7
	.4byte	.LASF169
	.byte	0x9e
	.uleb128 0x7
	.4byte	.LASF170
	.byte	0x9f
	.uleb128 0x7
	.4byte	.LASF171
	.byte	0xa0
	.uleb128 0x7
	.4byte	.LASF172
	.byte	0xa1
	.uleb128 0x7
	.4byte	.LASF173
	.byte	0xa2
	.uleb128 0x7
	.4byte	.LASF174
	.byte	0xa3
	.uleb128 0x7
	.4byte	.LASF175
	.byte	0xa4
	.uleb128 0x7
	.4byte	.LASF176
	.byte	0xa5
	.uleb128 0x7
	.4byte	.LASF177
	.byte	0xa6
	.uleb128 0x7
	.4byte	.LASF178
	.byte	0xa7
	.uleb128 0x7
	.4byte	.LASF179
	.byte	0xa8
	.uleb128 0x7
	.4byte	.LASF180
	.byte	0xa9
	.uleb128 0x7
	.4byte	.LASF181
	.byte	0xaa
	.uleb128 0x7
	.4byte	.LASF182
	.byte	0xab
	.uleb128 0x7
	.4byte	.LASF183
	.byte	0xac
	.uleb128 0x7
	.4byte	.LASF184
	.byte	0xad
	.uleb128 0x7
	.4byte	.LASF185
	.byte	0xae
	.uleb128 0x7
	.4byte	.LASF186
	.byte	0xaf
	.uleb128 0x7
	.4byte	.LASF187
	.byte	0xb0
	.uleb128 0x7
	.4byte	.LASF188
	.byte	0xb1
	.uleb128 0x7
	.4byte	.LASF189
	.byte	0xb2
	.uleb128 0x7
	.4byte	.LASF190
	.byte	0xb3
	.uleb128 0x7
	.4byte	.LASF191
	.byte	0xb4
	.uleb128 0x7
	.4byte	.LASF192
	.byte	0xb5
	.uleb128 0x7
	.4byte	.LASF193
	.byte	0xb6
	.uleb128 0x7
	.4byte	.LASF194
	.byte	0xb7
	.uleb128 0x7
	.4byte	.LASF195
	.byte	0xb8
	.uleb128 0x7
	.4byte	.LASF196
	.byte	0xb9
	.uleb128 0x7
	.4byte	.LASF197
	.byte	0xba
	.uleb128 0x7
	.4byte	.LASF198
	.byte	0xbb
	.uleb128 0x7
	.4byte	.LASF199
	.byte	0xbc
	.uleb128 0x7
	.4byte	.LASF200
	.byte	0xbd
	.uleb128 0x7
	.4byte	.LASF201
	.byte	0xbe
	.uleb128 0x7
	.4byte	.LASF202
	.byte	0xbf
	.uleb128 0x7
	.4byte	.LASF203
	.byte	0xc0
	.uleb128 0x7
	.4byte	.LASF204
	.byte	0xc1
	.uleb128 0x7
	.4byte	.LASF205
	.byte	0xc2
	.uleb128 0x7
	.4byte	.LASF206
	.byte	0xc3
	.uleb128 0x7
	.4byte	.LASF207
	.byte	0xc4
	.uleb128 0x7
	.4byte	.LASF208
	.byte	0xc5
	.uleb128 0x7
	.4byte	.LASF209
	.byte	0xc6
	.uleb128 0x7
	.4byte	.LASF210
	.byte	0xc7
	.uleb128 0x7
	.4byte	.LASF211
	.byte	0xc8
	.uleb128 0x7
	.4byte	.LASF212
	.byte	0xc9
	.uleb128 0x7
	.4byte	.LASF213
	.byte	0xca
	.uleb128 0x7
	.4byte	.LASF214
	.byte	0xcb
	.uleb128 0x7
	.4byte	.LASF215
	.byte	0xcc
	.uleb128 0x7
	.4byte	.LASF216
	.byte	0xcd
	.uleb128 0x7
	.4byte	.LASF217
	.byte	0xce
	.uleb128 0x7
	.4byte	.LASF218
	.byte	0xcf
	.uleb128 0x7
	.4byte	.LASF219
	.byte	0xd0
	.uleb128 0x7
	.4byte	.LASF220
	.byte	0xd1
	.uleb128 0x7
	.4byte	.LASF221
	.byte	0xd2
	.uleb128 0x7
	.4byte	.LASF222
	.byte	0xd3
	.uleb128 0x7
	.4byte	.LASF223
	.byte	0xd4
	.uleb128 0x7
	.4byte	.LASF224
	.byte	0xd5
	.uleb128 0x7
	.4byte	.LASF225
	.byte	0xd9
	.uleb128 0x7
	.4byte	.LASF226
	.byte	0xda
	.uleb128 0x7
	.4byte	.LASF227
	.byte	0xdb
	.uleb128 0x7
	.4byte	.LASF228
	.byte	0xdc
	.uleb128 0x7
	.4byte	.LASF229
	.byte	0xdd
	.uleb128 0x7
	.4byte	.LASF230
	.byte	0xde
	.uleb128 0x7
	.4byte	.LASF231
	.byte	0xdf
	.uleb128 0x7
	.4byte	.LASF232
	.byte	0xe0
	.uleb128 0x7
	.4byte	.LASF233
	.byte	0xe1
	.uleb128 0x7
	.4byte	.LASF234
	.byte	0xe2
	.uleb128 0x7
	.4byte	.LASF235
	.byte	0xe3
	.uleb128 0x7
	.4byte	.LASF236
	.byte	0xe4
	.uleb128 0x7
	.4byte	.LASF237
	.byte	0xe5
	.uleb128 0x7
	.4byte	.LASF238
	.byte	0xe6
	.uleb128 0x7
	.4byte	.LASF239
	.byte	0xe7
	.uleb128 0x7
	.4byte	.LASF240
	.byte	0xe8
	.uleb128 0x7
	.4byte	.LASF241
	.byte	0xe9
	.uleb128 0x7
	.4byte	.LASF242
	.byte	0xea
	.uleb128 0x7
	.4byte	.LASF243
	.byte	0xeb
	.uleb128 0x7
	.4byte	.LASF244
	.byte	0xec
	.uleb128 0x7
	.4byte	.LASF245
	.byte	0xed
	.uleb128 0x7
	.4byte	.LASF246
	.byte	0xee
	.uleb128 0x7
	.4byte	.LASF247
	.byte	0xef
	.uleb128 0x7
	.4byte	.LASF248
	.byte	0xf0
	.uleb128 0x7
	.4byte	.LASF249
	.byte	0xf1
	.uleb128 0x7
	.4byte	.LASF250
	.byte	0xf2
	.uleb128 0x7
	.4byte	.LASF251
	.byte	0xf3
	.uleb128 0x7
	.4byte	.LASF252
	.byte	0xf4
	.uleb128 0x7
	.4byte	.LASF253
	.byte	0xf5
	.uleb128 0x7
	.4byte	.LASF254
	.byte	0xf6
	.uleb128 0x7
	.4byte	.LASF255
	.byte	0xf7
	.uleb128 0x7
	.4byte	.LASF256
	.byte	0xf8
	.uleb128 0x7
	.4byte	.LASF257
	.byte	0xf9
	.uleb128 0x7
	.4byte	.LASF258
	.byte	0xfa
	.uleb128 0x7
	.4byte	.LASF259
	.byte	0xfb
	.uleb128 0x7
	.4byte	.LASF260
	.byte	0xfc
	.uleb128 0x7
	.4byte	.LASF261
	.byte	0xfd
	.uleb128 0x7
	.4byte	.LASF262
	.byte	0xfe
	.uleb128 0x7
	.4byte	.LASF263
	.byte	0xff
	.uleb128 0x8
	.4byte	.LASF264
	.2byte	0x100
	.uleb128 0x8
	.4byte	.LASF265
	.2byte	0x101
	.uleb128 0x8
	.4byte	.LASF266
	.2byte	0x102
	.uleb128 0x8
	.4byte	.LASF267
	.2byte	0x103
	.uleb128 0x8
	.4byte	.LASF268
	.2byte	0x104
	.uleb128 0x8
	.4byte	.LASF269
	.2byte	0x105
	.uleb128 0x8
	.4byte	.LASF270
	.2byte	0x106
	.uleb128 0x8
	.4byte	.LASF271
	.2byte	0x107
	.uleb128 0x8
	.4byte	.LASF272
	.2byte	0x108
	.uleb128 0x8
	.4byte	.LASF273
	.2byte	0x109
	.uleb128 0x8
	.4byte	.LASF274
	.2byte	0x10a
	.uleb128 0x8
	.4byte	.LASF275
	.2byte	0x10b
	.uleb128 0x8
	.4byte	.LASF276
	.2byte	0x10c
	.uleb128 0x8
	.4byte	.LASF277
	.2byte	0x10d
	.uleb128 0x8
	.4byte	.LASF278
	.2byte	0x10e
	.uleb128 0x8
	.4byte	.LASF279
	.2byte	0x10f
	.uleb128 0x8
	.4byte	.LASF280
	.2byte	0x111
	.uleb128 0x8
	.4byte	.LASF281
	.2byte	0x112
	.uleb128 0x8
	.4byte	.LASF282
	.2byte	0x113
	.uleb128 0x8
	.4byte	.LASF283
	.2byte	0x114
	.uleb128 0x8
	.4byte	.LASF284
	.2byte	0x115
	.uleb128 0x8
	.4byte	.LASF285
	.2byte	0x116
	.uleb128 0x8
	.4byte	.LASF286
	.2byte	0x117
	.uleb128 0x8
	.4byte	.LASF287
	.2byte	0x118
	.uleb128 0x8
	.4byte	.LASF288
	.2byte	0x119
	.uleb128 0x8
	.4byte	.LASF289
	.2byte	0x12c
	.uleb128 0x8
	.4byte	.LASF290
	.2byte	0x12d
	.uleb128 0x8
	.4byte	.LASF291
	.2byte	0x12e
	.uleb128 0x8
	.4byte	.LASF292
	.2byte	0x12f
	.uleb128 0x8
	.4byte	.LASF293
	.2byte	0x130
	.uleb128 0x8
	.4byte	.LASF294
	.2byte	0x131
	.uleb128 0x8
	.4byte	.LASF295
	.2byte	0x132
	.uleb128 0x8
	.4byte	.LASF296
	.2byte	0x133
	.uleb128 0x8
	.4byte	.LASF297
	.2byte	0x134
	.uleb128 0x8
	.4byte	.LASF298
	.2byte	0x135
	.uleb128 0x8
	.4byte	.LASF299
	.2byte	0x136
	.uleb128 0x8
	.4byte	.LASF300
	.2byte	0x137
	.uleb128 0x8
	.4byte	.LASF301
	.2byte	0x138
	.uleb128 0x8
	.4byte	.LASF302
	.2byte	0x139
	.uleb128 0x8
	.4byte	.LASF303
	.2byte	0x13a
	.uleb128 0x8
	.4byte	.LASF304
	.2byte	0x13b
	.uleb128 0x8
	.4byte	.LASF305
	.2byte	0x13c
	.uleb128 0x8
	.4byte	.LASF306
	.2byte	0x13d
	.uleb128 0x8
	.4byte	.LASF307
	.2byte	0x13e
	.uleb128 0x8
	.4byte	.LASF308
	.2byte	0x13f
	.uleb128 0x8
	.4byte	.LASF309
	.2byte	0x140
	.uleb128 0x8
	.4byte	.LASF310
	.2byte	0x141
	.uleb128 0x8
	.4byte	.LASF311
	.2byte	0x142
	.uleb128 0x8
	.4byte	.LASF312
	.2byte	0x29a
	.uleb128 0x8
	.4byte	.LASF313
	.2byte	0x2c7
	.uleb128 0x8
	.4byte	.LASF314
	.2byte	0x2c8
	.uleb128 0x8
	.4byte	.LASF315
	.2byte	0x2c9
	.uleb128 0x8
	.4byte	.LASF316
	.2byte	0x2ca
	.uleb128 0x8
	.4byte	.LASF317
	.2byte	0x2cb
	.uleb128 0x8
	.4byte	.LASF318
	.2byte	0x2cc
	.uleb128 0x8
	.4byte	.LASF319
	.2byte	0x2cd
	.uleb128 0x8
	.4byte	.LASF320
	.2byte	0x2ce
	.uleb128 0x8
	.4byte	.LASF321
	.2byte	0x2d1
	.uleb128 0x8
	.4byte	.LASF322
	.2byte	0x2d2
	.uleb128 0x8
	.4byte	.LASF323
	.2byte	0x2d3
	.uleb128 0x8
	.4byte	.LASF324
	.2byte	0x2d4
	.uleb128 0x8
	.4byte	.LASF325
	.2byte	0x2d5
	.uleb128 0x8
	.4byte	.LASF326
	.2byte	0x2d6
	.uleb128 0x8
	.4byte	.LASF327
	.2byte	0x2d7
	.uleb128 0x8
	.4byte	.LASF328
	.2byte	0x2d8
	.uleb128 0x8
	.4byte	.LASF329
	.2byte	0x2d9
	.uleb128 0x8
	.4byte	.LASF330
	.2byte	0x2ee
	.uleb128 0x8
	.4byte	.LASF331
	.2byte	0x2ef
	.uleb128 0x8
	.4byte	.LASF332
	.2byte	0x2f0
	.uleb128 0x8
	.4byte	.LASF333
	.2byte	0x2f2
	.uleb128 0x8
	.4byte	.LASF334
	.2byte	0x2f3
	.uleb128 0x8
	.4byte	.LASF335
	.2byte	0x2f4
	.uleb128 0x8
	.4byte	.LASF336
	.2byte	0x2f5
	.uleb128 0x8
	.4byte	.LASF337
	.2byte	0x2f6
	.uleb128 0x8
	.4byte	.LASF338
	.2byte	0x2f7
	.uleb128 0x8
	.4byte	.LASF339
	.2byte	0x2f8
	.uleb128 0x8
	.4byte	.LASF340
	.2byte	0x2f9
	.uleb128 0x8
	.4byte	.LASF341
	.2byte	0x2fa
	.uleb128 0x8
	.4byte	.LASF342
	.2byte	0x2fb
	.uleb128 0x8
	.4byte	.LASF343
	.2byte	0x2fc
	.uleb128 0x8
	.4byte	.LASF344
	.2byte	0x2fd
	.uleb128 0x8
	.4byte	.LASF345
	.2byte	0x2fe
	.uleb128 0x8
	.4byte	.LASF346
	.2byte	0x2ff
	.uleb128 0x8
	.4byte	.LASF347
	.2byte	0x300
	.uleb128 0x8
	.4byte	.LASF348
	.2byte	0x301
	.uleb128 0x8
	.4byte	.LASF349
	.2byte	0x302
	.uleb128 0x8
	.4byte	.LASF350
	.2byte	0x303
	.uleb128 0x8
	.4byte	.LASF351
	.2byte	0x304
	.uleb128 0x8
	.4byte	.LASF352
	.2byte	0x305
	.uleb128 0x8
	.4byte	.LASF353
	.2byte	0x306
	.uleb128 0x8
	.4byte	.LASF354
	.2byte	0x307
	.uleb128 0x8
	.4byte	.LASF355
	.2byte	0x308
	.uleb128 0x8
	.4byte	.LASF356
	.2byte	0x309
	.uleb128 0x8
	.4byte	.LASF357
	.2byte	0x30a
	.uleb128 0x8
	.4byte	.LASF358
	.2byte	0x30b
	.uleb128 0x8
	.4byte	.LASF359
	.2byte	0x30c
	.uleb128 0x8
	.4byte	.LASF360
	.2byte	0x30d
	.uleb128 0x8
	.4byte	.LASF361
	.2byte	0x30e
	.uleb128 0x8
	.4byte	.LASF362
	.2byte	0x310
	.uleb128 0x8
	.4byte	.LASF363
	.2byte	0x311
	.uleb128 0x8
	.4byte	.LASF364
	.2byte	0x312
	.uleb128 0x8
	.4byte	.LASF365
	.2byte	0x313
	.uleb128 0x8
	.4byte	.LASF366
	.2byte	0x314
	.uleb128 0x8
	.4byte	.LASF367
	.2byte	0x315
	.uleb128 0x8
	.4byte	.LASF368
	.2byte	0x320
	.uleb128 0x8
	.4byte	.LASF369
	.2byte	0x321
	.uleb128 0x8
	.4byte	.LASF370
	.2byte	0x322
	.uleb128 0x8
	.4byte	.LASF371
	.2byte	0x323
	.uleb128 0x8
	.4byte	.LASF372
	.2byte	0x324
	.uleb128 0x8
	.4byte	.LASF373
	.2byte	0x32f
	.uleb128 0x8
	.4byte	.LASF374
	.2byte	0x330
	.uleb128 0x8
	.4byte	.LASF375
	.2byte	0x331
	.uleb128 0x8
	.4byte	.LASF376
	.2byte	0x332
	.uleb128 0x8
	.4byte	.LASF377
	.2byte	0x333
	.uleb128 0x8
	.4byte	.LASF378
	.2byte	0x334
	.uleb128 0x8
	.4byte	.LASF379
	.2byte	0x335
	.uleb128 0x8
	.4byte	.LASF380
	.2byte	0x336
	.uleb128 0x8
	.4byte	.LASF381
	.2byte	0x340
	.uleb128 0x8
	.4byte	.LASF382
	.2byte	0x341
	.uleb128 0x8
	.4byte	.LASF383
	.2byte	0x342
	.uleb128 0x8
	.4byte	.LASF384
	.2byte	0x343
	.uleb128 0x8
	.4byte	.LASF385
	.2byte	0x344
	.uleb128 0x8
	.4byte	.LASF386
	.2byte	0x345
	.uleb128 0x8
	.4byte	.LASF387
	.2byte	0x346
	.uleb128 0x8
	.4byte	.LASF388
	.2byte	0x347
	.uleb128 0x8
	.4byte	.LASF389
	.2byte	0x34c
	.uleb128 0x8
	.4byte	.LASF390
	.2byte	0x350
	.uleb128 0x8
	.4byte	.LASF391
	.2byte	0x371
	.uleb128 0x8
	.4byte	.LASF392
	.2byte	0x372
	.uleb128 0x8
	.4byte	.LASF393
	.2byte	0x373
	.uleb128 0x8
	.4byte	.LASF394
	.2byte	0x374
	.uleb128 0x8
	.4byte	.LASF395
	.2byte	0x375
	.uleb128 0x8
	.4byte	.LASF396
	.2byte	0x376
	.uleb128 0x8
	.4byte	.LASF397
	.2byte	0x377
	.uleb128 0x8
	.4byte	.LASF398
	.2byte	0x378
	.uleb128 0x8
	.4byte	.LASF399
	.2byte	0x379
	.uleb128 0x8
	.4byte	.LASF400
	.2byte	0x37a
	.uleb128 0x8
	.4byte	.LASF401
	.2byte	0x37b
	.uleb128 0x8
	.4byte	.LASF402
	.2byte	0x400
	.uleb128 0x8
	.4byte	.LASF403
	.2byte	0x401
	.uleb128 0x8
	.4byte	.LASF404
	.2byte	0x402
	.uleb128 0x8
	.4byte	.LASF405
	.2byte	0x403
	.uleb128 0x8
	.4byte	.LASF406
	.2byte	0x404
	.uleb128 0x8
	.4byte	.LASF407
	.2byte	0x405
	.uleb128 0x8
	.4byte	.LASF408
	.2byte	0x406
	.uleb128 0x8
	.4byte	.LASF409
	.2byte	0x407
	.uleb128 0x8
	.4byte	.LASF410
	.2byte	0x408
	.uleb128 0x8
	.4byte	.LASF411
	.2byte	0x409
	.uleb128 0x8
	.4byte	.LASF412
	.2byte	0x40a
	.uleb128 0x8
	.4byte	.LASF413
	.2byte	0x40b
	.uleb128 0x8
	.4byte	.LASF414
	.2byte	0x40c
	.uleb128 0x8
	.4byte	.LASF415
	.2byte	0x40d
	.uleb128 0x8
	.4byte	.LASF416
	.2byte	0x40e
	.uleb128 0x8
	.4byte	.LASF417
	.2byte	0x40f
	.uleb128 0x8
	.4byte	.LASF418
	.2byte	0x5dc
	.uleb128 0x8
	.4byte	.LASF419
	.2byte	0x5dd
	.uleb128 0x8
	.4byte	.LASF420
	.2byte	0x5de
	.uleb128 0x8
	.4byte	.LASF421
	.2byte	0x5df
	.uleb128 0x8
	.4byte	.LASF422
	.2byte	0x5e0
	.uleb128 0x8
	.4byte	.LASF423
	.2byte	0x5e1
	.uleb128 0x8
	.4byte	.LASF424
	.2byte	0x5e2
	.uleb128 0x8
	.4byte	.LASF425
	.2byte	0x5e3
	.uleb128 0x8
	.4byte	.LASF426
	.2byte	0x5e4
	.uleb128 0x8
	.4byte	.LASF427
	.2byte	0x5e5
	.uleb128 0x8
	.4byte	.LASF428
	.2byte	0x5e6
	.uleb128 0x8
	.4byte	.LASF429
	.2byte	0x5e7
	.uleb128 0x8
	.4byte	.LASF430
	.2byte	0x5e8
	.uleb128 0x8
	.4byte	.LASF431
	.2byte	0x5e9
	.uleb128 0x8
	.4byte	.LASF432
	.2byte	0x5ea
	.uleb128 0x8
	.4byte	.LASF433
	.2byte	0x5eb
	.uleb128 0x8
	.4byte	.LASF434
	.2byte	0x5ec
	.uleb128 0x8
	.4byte	.LASF435
	.2byte	0x5ed
	.uleb128 0x8
	.4byte	.LASF436
	.2byte	0x5ee
	.uleb128 0x8
	.4byte	.LASF437
	.2byte	0x5ef
	.uleb128 0x8
	.4byte	.LASF438
	.2byte	0x5f0
	.uleb128 0x8
	.4byte	.LASF439
	.2byte	0x5f1
	.uleb128 0x8
	.4byte	.LASF440
	.2byte	0x5f2
	.uleb128 0x8
	.4byte	.LASF441
	.2byte	0x5f3
	.uleb128 0x8
	.4byte	.LASF442
	.2byte	0x5f4
	.uleb128 0x8
	.4byte	.LASF443
	.2byte	0x5f5
	.uleb128 0x8
	.4byte	.LASF444
	.2byte	0x5f6
	.uleb128 0x8
	.4byte	.LASF445
	.2byte	0x5f7
	.uleb128 0x8
	.4byte	.LASF446
	.2byte	0x5f8
	.uleb128 0x8
	.4byte	.LASF447
	.2byte	0x640
	.uleb128 0x8
	.4byte	.LASF448
	.2byte	0x641
	.uleb128 0x8
	.4byte	.LASF449
	.2byte	0x3ffd
	.uleb128 0x8
	.4byte	.LASF450
	.2byte	0x3ffe
	.uleb128 0x8
	.4byte	.LASF451
	.2byte	0x3fff
	.uleb128 0x8
	.4byte	.LASF452
	.2byte	0x8000
	.uleb128 0x8
	.4byte	.LASF453
	.2byte	0x8001
	.uleb128 0x8
	.4byte	.LASF454
	.2byte	0x8002
	.uleb128 0x8
	.4byte	.LASF455
	.2byte	0x8003
	.uleb128 0x8
	.4byte	.LASF456
	.2byte	0x8004
	.uleb128 0x8
	.4byte	.LASF457
	.2byte	0x8005
	.uleb128 0x8
	.4byte	.LASF458
	.2byte	0x8006
	.uleb128 0x8
	.4byte	.LASF459
	.2byte	0x8007
	.uleb128 0x8
	.4byte	.LASF460
	.2byte	0x8008
	.uleb128 0x8
	.4byte	.LASF461
	.2byte	0x8009
	.uleb128 0x8
	.4byte	.LASF462
	.2byte	0x800a
	.uleb128 0x8
	.4byte	.LASF463
	.2byte	0x800b
	.uleb128 0x8
	.4byte	.LASF464
	.2byte	0x800c
	.uleb128 0x8
	.4byte	.LASF465
	.2byte	0x800d
	.uleb128 0x8
	.4byte	.LASF466
	.2byte	0x800e
	.uleb128 0x8
	.4byte	.LASF467
	.2byte	0x800f
	.uleb128 0x8
	.4byte	.LASF468
	.2byte	0x8010
	.uleb128 0x8
	.4byte	.LASF469
	.2byte	0x8011
	.uleb128 0x8
	.4byte	.LASF470
	.2byte	0x8012
	.uleb128 0x8
	.4byte	.LASF471
	.2byte	0x8013
	.uleb128 0x8
	.4byte	.LASF472
	.2byte	0x8014
	.uleb128 0x8
	.4byte	.LASF473
	.2byte	0x8015
	.uleb128 0x8
	.4byte	.LASF474
	.2byte	0x8016
	.uleb128 0x8
	.4byte	.LASF475
	.2byte	0x8017
	.uleb128 0x8
	.4byte	.LASF476
	.2byte	0x8018
	.uleb128 0x8
	.4byte	.LASF477
	.2byte	0x8019
	.uleb128 0x8
	.4byte	.LASF478
	.2byte	0x801a
	.uleb128 0x8
	.4byte	.LASF479
	.2byte	0x801b
	.uleb128 0x8
	.4byte	.LASF480
	.2byte	0x801c
	.uleb128 0x8
	.4byte	.LASF481
	.2byte	0x801d
	.uleb128 0x8
	.4byte	.LASF482
	.2byte	0x801e
	.uleb128 0x8
	.4byte	.LASF483
	.2byte	0x801f
	.uleb128 0x8
	.4byte	.LASF484
	.2byte	0x8020
	.uleb128 0x8
	.4byte	.LASF485
	.2byte	0x8021
	.uleb128 0x8
	.4byte	.LASF486
	.2byte	0x8022
	.uleb128 0x8
	.4byte	.LASF487
	.2byte	0x8023
	.uleb128 0x8
	.4byte	.LASF488
	.2byte	0x8024
	.uleb128 0x8
	.4byte	.LASF489
	.2byte	0x8025
	.uleb128 0x8
	.4byte	.LASF490
	.2byte	0x8026
	.uleb128 0x8
	.4byte	.LASF491
	.2byte	0x8027
	.uleb128 0x8
	.4byte	.LASF492
	.2byte	0x8028
	.uleb128 0x8
	.4byte	.LASF493
	.2byte	0x8029
	.uleb128 0x8
	.4byte	.LASF494
	.2byte	0x802a
	.uleb128 0x8
	.4byte	.LASF495
	.2byte	0x802b
	.uleb128 0x8
	.4byte	.LASF496
	.2byte	0x802c
	.uleb128 0x8
	.4byte	.LASF497
	.2byte	0x802d
	.uleb128 0x8
	.4byte	.LASF498
	.2byte	0x802e
	.uleb128 0x8
	.4byte	.LASF499
	.2byte	0x802f
	.uleb128 0x8
	.4byte	.LASF500
	.2byte	0x8030
	.uleb128 0x8
	.4byte	.LASF501
	.2byte	0x8031
	.uleb128 0x8
	.4byte	.LASF502
	.2byte	0x8032
	.uleb128 0x8
	.4byte	.LASF503
	.2byte	0x8033
	.uleb128 0x8
	.4byte	.LASF504
	.2byte	0x8034
	.uleb128 0x8
	.4byte	.LASF505
	.2byte	0x8035
	.uleb128 0x8
	.4byte	.LASF506
	.2byte	0x8036
	.uleb128 0x8
	.4byte	.LASF507
	.2byte	0x8037
	.uleb128 0x8
	.4byte	.LASF508
	.2byte	0x8038
	.uleb128 0x8
	.4byte	.LASF509
	.2byte	0x8039
	.uleb128 0x8
	.4byte	.LASF510
	.2byte	0x803a
	.uleb128 0x8
	.4byte	.LASF511
	.2byte	0x803b
	.uleb128 0x8
	.4byte	.LASF512
	.2byte	0x803c
	.uleb128 0x8
	.4byte	.LASF513
	.2byte	0x803d
	.uleb128 0x8
	.4byte	.LASF514
	.2byte	0x803e
	.uleb128 0x8
	.4byte	.LASF515
	.2byte	0x803f
	.uleb128 0x8
	.4byte	.LASF516
	.2byte	0x8040
	.uleb128 0x8
	.4byte	.LASF517
	.2byte	0x8041
	.uleb128 0x8
	.4byte	.LASF518
	.2byte	0x8042
	.uleb128 0x8
	.4byte	.LASF519
	.2byte	0x8043
	.uleb128 0x8
	.4byte	.LASF520
	.2byte	0x8044
	.uleb128 0x8
	.4byte	.LASF521
	.2byte	0x8045
	.uleb128 0x8
	.4byte	.LASF522
	.2byte	0x8046
	.uleb128 0x8
	.4byte	.LASF523
	.2byte	0x8047
	.uleb128 0x8
	.4byte	.LASF524
	.2byte	0x8048
	.uleb128 0x8
	.4byte	.LASF525
	.2byte	0x8049
	.uleb128 0x8
	.4byte	.LASF526
	.2byte	0x804a
	.uleb128 0x8
	.4byte	.LASF527
	.2byte	0x804b
	.uleb128 0x8
	.4byte	.LASF528
	.2byte	0x804c
	.uleb128 0x8
	.4byte	.LASF529
	.2byte	0x804d
	.uleb128 0x8
	.4byte	.LASF530
	.2byte	0x804e
	.uleb128 0x8
	.4byte	.LASF531
	.2byte	0x804f
	.uleb128 0x8
	.4byte	.LASF532
	.2byte	0x8050
	.uleb128 0x8
	.4byte	.LASF533
	.2byte	0x8051
	.uleb128 0x8
	.4byte	.LASF534
	.2byte	0x8052
	.uleb128 0x8
	.4byte	.LASF535
	.2byte	0x8053
	.uleb128 0x8
	.4byte	.LASF536
	.2byte	0x8054
	.uleb128 0x8
	.4byte	.LASF537
	.2byte	0x8055
	.uleb128 0x8
	.4byte	.LASF538
	.2byte	0x8056
	.uleb128 0x8
	.4byte	.LASF539
	.2byte	0x8057
	.uleb128 0x8
	.4byte	.LASF540
	.2byte	0x8058
	.uleb128 0x8
	.4byte	.LASF541
	.2byte	0x8059
	.uleb128 0x8
	.4byte	.LASF542
	.2byte	0x805a
	.uleb128 0x8
	.4byte	.LASF543
	.2byte	0x805b
	.uleb128 0x8
	.4byte	.LASF544
	.2byte	0x805c
	.uleb128 0x8
	.4byte	.LASF545
	.2byte	0x805d
	.uleb128 0x8
	.4byte	.LASF546
	.2byte	0x805e
	.uleb128 0x8
	.4byte	.LASF547
	.2byte	0x805f
	.uleb128 0x8
	.4byte	.LASF548
	.2byte	0x8060
	.uleb128 0x8
	.4byte	.LASF549
	.2byte	0x8061
	.uleb128 0x8
	.4byte	.LASF550
	.2byte	0x8062
	.uleb128 0x8
	.4byte	.LASF551
	.2byte	0x8063
	.uleb128 0x8
	.4byte	.LASF552
	.2byte	0x8064
	.uleb128 0x8
	.4byte	.LASF553
	.2byte	0x8065
	.uleb128 0x8
	.4byte	.LASF554
	.2byte	0x8066
	.uleb128 0x8
	.4byte	.LASF555
	.2byte	0x8067
	.uleb128 0x8
	.4byte	.LASF556
	.2byte	0x8068
	.uleb128 0x8
	.4byte	.LASF557
	.2byte	0x8069
	.uleb128 0x8
	.4byte	.LASF558
	.2byte	0x806a
	.uleb128 0x8
	.4byte	.LASF559
	.2byte	0x806b
	.uleb128 0x8
	.4byte	.LASF560
	.2byte	0x806c
	.uleb128 0x8
	.4byte	.LASF561
	.2byte	0x806d
	.uleb128 0x8
	.4byte	.LASF562
	.2byte	0x806e
	.uleb128 0x8
	.4byte	.LASF563
	.2byte	0x806f
	.uleb128 0x8
	.4byte	.LASF564
	.2byte	0x8070
	.uleb128 0x8
	.4byte	.LASF565
	.2byte	0x8071
	.uleb128 0x8
	.4byte	.LASF566
	.2byte	0x8072
	.uleb128 0x8
	.4byte	.LASF567
	.2byte	0x8073
	.uleb128 0x8
	.4byte	.LASF568
	.2byte	0x8074
	.uleb128 0x8
	.4byte	.LASF569
	.2byte	0x8075
	.uleb128 0x8
	.4byte	.LASF570
	.2byte	0x8076
	.uleb128 0x8
	.4byte	.LASF571
	.2byte	0x8077
	.uleb128 0x8
	.4byte	.LASF572
	.2byte	0x8078
	.uleb128 0x8
	.4byte	.LASF573
	.2byte	0x8079
	.uleb128 0x8
	.4byte	.LASF574
	.2byte	0x807a
	.uleb128 0x8
	.4byte	.LASF575
	.2byte	0x807b
	.uleb128 0x8
	.4byte	.LASF576
	.2byte	0x807c
	.uleb128 0x8
	.4byte	.LASF577
	.2byte	0x807d
	.uleb128 0x8
	.4byte	.LASF578
	.2byte	0x807e
	.uleb128 0x8
	.4byte	.LASF579
	.2byte	0x807f
	.uleb128 0x8
	.4byte	.LASF580
	.2byte	0x8080
	.uleb128 0x8
	.4byte	.LASF581
	.2byte	0x8081
	.uleb128 0x8
	.4byte	.LASF582
	.2byte	0x8082
	.uleb128 0x8
	.4byte	.LASF583
	.2byte	0x8083
	.uleb128 0x8
	.4byte	.LASF584
	.2byte	0x8084
	.uleb128 0x8
	.4byte	.LASF585
	.2byte	0x8085
	.uleb128 0x8
	.4byte	.LASF586
	.2byte	0x8086
	.uleb128 0x8
	.4byte	.LASF587
	.2byte	0x8087
	.uleb128 0x8
	.4byte	.LASF588
	.2byte	0x8088
	.uleb128 0x8
	.4byte	.LASF589
	.2byte	0x8089
	.uleb128 0x8
	.4byte	.LASF590
	.2byte	0x808a
	.uleb128 0x8
	.4byte	.LASF591
	.2byte	0x808b
	.uleb128 0x8
	.4byte	.LASF592
	.2byte	0x808c
	.uleb128 0x9
	.4byte	.LASF593
	.4byte	0x10000
	.byte	0
	.uleb128 0xa
	.4byte	.LASF594
	.byte	0x2
	.2byte	0x2dd
	.byte	0x5
	.4byte	0x89
	.uleb128 0xa
	.4byte	.LASF595
	.byte	0x2
	.2byte	0x2e6
	.byte	0x16
	.4byte	0x25
	.uleb128 0xb
	.4byte	0x7e
	.4byte	0xfb9
	.uleb128 0xc
	.4byte	0x25
	.2byte	0x4eb
	.byte	0
	.uleb128 0x4
	.4byte	0xfa8
	.uleb128 0xd
	.4byte	.LASF596
	.byte	0x3
	.byte	0x23
	.byte	0x13
	.4byte	0xfb9
	.uleb128 0x5
	.byte	0x3
	.4byte	statusstr_msgstr
	.uleb128 0xb
	.4byte	0x33
	.4byte	0xfe0
	.uleb128 0xe
	.4byte	0x25
	.byte	0x65
	.byte	0
	.uleb128 0x4
	.4byte	0xfd0
	.uleb128 0xd
	.4byte	.LASF597
	.byte	0x3
	.byte	0x8b
	.byte	0x12
	.4byte	0xfe0
	.uleb128 0x5
	.byte	0x3
	.4byte	statusstr_msgidx
	.uleb128 0xf
	.4byte	.LASF598
	.byte	0x1
	.byte	0x33
	.byte	0x1
	.4byte	0x83
	.4byte	.LFB14
	.4byte	.LFE14-.LFB14
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x105d
	.uleb128 0x10
	.ascii	"err\000"
	.byte	0x1
	.byte	0x33
	.byte	0x24
	.4byte	0xf9b
	.4byte	.LLST2
	.4byte	.LVUS2
	.uleb128 0x11
	.4byte	.LASF600
	.byte	0x1
	.byte	0x35
	.byte	0xf
	.4byte	0x83
	.4byte	.LLST3
	.4byte	.LVUS3
	.uleb128 0x12
	.4byte	0x109f
	.4byte	.LBI4
	.byte	.LVU16
	.4byte	.LBB4
	.4byte	.LBE4-.LBB4
	.byte	0x1
	.byte	0x37
	.byte	0xb
	.uleb128 0x13
	.4byte	0x10ad
	.4byte	.LLST4
	.4byte	.LVUS4
	.byte	0
	.byte	0
	.uleb128 0xf
	.4byte	.LASF599
	.byte	0x1
	.byte	0x28
	.byte	0x1
	.4byte	0x83
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.uleb128 0x1
	.byte	0x9c
	.4byte	0x109f
	.uleb128 0x10
	.ascii	"no\000"
	.byte	0x1
	.byte	0x28
	.byte	0x19
	.4byte	0x2c
	.4byte	.LLST0
	.4byte	.LVUS0
	.uleb128 0x14
	.ascii	"idx\000"
	.byte	0x1
	.byte	0x2a
	.byte	0x7
	.4byte	0x2c
	.4byte	.LLST1
	.4byte	.LVUS1
	.byte	0
	.uleb128 0x15
	.4byte	.LASF604
	.byte	0x2
	.2byte	0x3cc
	.byte	0x1
	.4byte	0xf8e
	.byte	0x3
	.uleb128 0x16
	.ascii	"err\000"
	.byte	0x2
	.2byte	0x3cc
	.byte	0x1b
	.4byte	0xf9b
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
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x6
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
	.uleb128 0x7
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x16
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
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0x5
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
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xf
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
	.uleb128 0x10
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
	.uleb128 0x11
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
	.uleb128 0x12
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
	.uleb128 0x13
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
	.uleb128 0x14
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
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x20
	.uleb128 0xb
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
	.byte	0
	.section	.debug_loc,"",%progbits
.Ldebug_loc0:
.LVUS2:
	.uleb128 0
	.uleb128 .LVU19
	.uleb128 .LVU19
	.uleb128 0
.LLST2:
	.4byte	.LVL5
	.4byte	.LVL6
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL6
	.4byte	.LFE14
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS3:
	.uleb128 .LVU28
	.uleb128 .LVU30
	.uleb128 .LVU31
	.uleb128 .LVU34
	.uleb128 .LVU35
	.uleb128 .LVU38
	.uleb128 .LVU39
	.uleb128 .LVU42
	.uleb128 .LVU43
	.uleb128 .LVU46
	.uleb128 .LVU47
	.uleb128 .LVU50
	.uleb128 .LVU51
	.uleb128 .LVU54
	.uleb128 .LVU55
	.uleb128 .LVU58
.LLST3:
	.4byte	.LVL7
	.4byte	.LVL8
	.2byte	0x1
	.byte	0x50
	.4byte	.LVL8
	.4byte	.LVL9
	.2byte	0x6
	.byte	0x3
	.4byte	.LC8
	.byte	0x9f
	.4byte	.LVL9
	.4byte	.LVL10
	.2byte	0x6
	.byte	0x3
	.4byte	.LC11
	.byte	0x9f
	.4byte	.LVL10
	.4byte	.LVL11
	.2byte	0x6
	.byte	0x3
	.4byte	.LC4
	.byte	0x9f
	.4byte	.LVL11
	.4byte	.LVL12
	.2byte	0x6
	.byte	0x3
	.4byte	.LC6
	.byte	0x9f
	.4byte	.LVL12
	.4byte	.LVL13
	.2byte	0x6
	.byte	0x3
	.4byte	.LC7
	.byte	0x9f
	.4byte	.LVL13
	.4byte	.LVL14
	.2byte	0x6
	.byte	0x3
	.4byte	.LC10
	.byte	0x9f
	.4byte	.LVL14
	.4byte	.LVL15
	.2byte	0x6
	.byte	0x3
	.4byte	.LC5
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS4:
	.uleb128 .LVU16
	.uleb128 .LVU19
.LLST4:
	.4byte	.LVL5
	.4byte	.LVL6
	.2byte	0x1
	.byte	0x50
	.4byte	0
	.4byte	0
.LVUS0:
	.uleb128 0
	.uleb128 .LVU9
	.uleb128 .LVU9
	.uleb128 .LVU10
	.uleb128 .LVU10
	.uleb128 .LVU11
	.uleb128 .LVU11
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
	.2byte	0x4
	.byte	0xf3
	.uleb128 0x1
	.byte	0x50
	.byte	0x9f
	.4byte	0
	.4byte	0
.LVUS1:
	.uleb128 .LVU3
	.uleb128 .LVU9
	.uleb128 .LVU9
	.uleb128 .LVU10
.LLST1:
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
	.4byte	.LFB13
	.4byte	.LFE13-.LFB13
	.4byte	.LFB14
	.4byte	.LFE14-.LFB14
	.4byte	0
	.4byte	0
	.section	.debug_ranges,"",%progbits
.Ldebug_ranges0:
	.4byte	.LFB13
	.4byte	.LFE13
	.4byte	.LFB14
	.4byte	.LFE14
	.4byte	0
	.4byte	0
	.section	.debug_line,"",%progbits
.Ldebug_line0:
	.section	.debug_str,"MS",%progbits,1
.LASF250:
	.ascii	"GPG_ERR_BAD_HS_CERT_VER\000"
.LASF153:
	.ascii	"GPG_ERR_NOT_DER_ENCODED\000"
.LASF304:
	.ascii	"GPG_ERR_BAD_AUTH\000"
.LASF428:
	.ascii	"GPG_ERR_SQL_IOERR\000"
.LASF284:
	.ascii	"GPG_ERR_ASS_CANCELED\000"
.LASF23:
	.ascii	"GPG_ERR_CIPHER_ALGO\000"
.LASF381:
	.ascii	"GPG_ERR_LDAP_NAMING_VIOLATION\000"
.LASF158:
	.ascii	"GPG_ERR_UNSUPPORTED_ENCODING\000"
.LASF568:
	.ascii	"GPG_ERR_EPROTOTYPE\000"
.LASF161:
	.ascii	"GPG_ERR_INV_ENGINE\000"
.LASF239:
	.ascii	"GPG_ERR_COMPR_FAILED\000"
.LASF216:
	.ascii	"GPG_ERR_SEXP_BAD_CHARACTER\000"
.LASF40:
	.ascii	"GPG_ERR_SYNTAX\000"
.LASF183:
	.ascii	"GPG_ERR_UNKNOWN_CRIT_EXTN\000"
.LASF432:
	.ascii	"GPG_ERR_SQL_CANTOPEN\000"
.LASF452:
	.ascii	"GPG_ERR_E2BIG\000"
.LASF245:
	.ascii	"GPG_ERR_TICKET_EXPIRED\000"
.LASF89:
	.ascii	"GPG_ERR_AGENT\000"
.LASF77:
	.ascii	"GPG_ERR_TOO_SHORT\000"
.LASF127:
	.ascii	"GPG_ERR_NO_POLICY_MATCH\000"
.LASF326:
	.ascii	"GPG_ERR_LDAP_UPDATE_GENERAL\000"
.LASF354:
	.ascii	"GPG_ERR_LDAP_UNSUPPORTED_AUTH\000"
.LASF318:
	.ascii	"GPG_ERR_DNS_CLOSED\000"
.LASF444:
	.ascii	"GPG_ERR_SQL_NOTADB\000"
.LASF184:
	.ascii	"GPG_ERR_LOCKED\000"
.LASF118:
	.ascii	"GPG_ERR_AMBIGUOUS_NAME\000"
.LASF34:
	.ascii	"GPG_ERR_NO_ENCRYPTION_SCHEME\000"
.LASF418:
	.ascii	"GPG_ERR_SQL_OK\000"
.LASF237:
	.ascii	"GPG_ERR_BAD_MAC\000"
.LASF526:
	.ascii	"GPG_ERR_ENETUNREACH\000"
.LASF136:
	.ascii	"GPG_ERR_WRONG_KEY_USAGE\000"
.LASF385:
	.ascii	"GPG_ERR_LDAP_ALREADY_EXISTS\000"
.LASF17:
	.ascii	"GPG_ERR_BAD_PUBKEY\000"
.LASF80:
	.ascii	"GPG_ERR_NOT_IMPLEMENTED\000"
.LASF401:
	.ascii	"GPG_ERR_LDAP_PROX_AUTH_DENIED\000"
.LASF179:
	.ascii	"GPG_ERR_PROTOCOL_VIOLATION\000"
.LASF559:
	.ascii	"GPG_ERR_EPERM\000"
.LASF477:
	.ascii	"GPG_ERR_ECONNREFUSED\000"
.LASF107:
	.ascii	"GPG_ERR_CRL_TOO_OLD\000"
.LASF113:
	.ascii	"GPG_ERR_CERT_TOO_YOUNG\000"
.LASF343:
	.ascii	"GPG_ERR_LDAP_DECODING\000"
.LASF219:
	.ascii	"GPG_ERR_SEXP_NESTED_DH\000"
.LASF198:
	.ascii	"GPG_ERR_INV_CURVE\000"
.LASF537:
	.ascii	"GPG_ERR_ENOMEDIUM\000"
.LASF487:
	.ascii	"GPG_ERR_EEXIST\000"
.LASF96:
	.ascii	"GPG_ERR_NO_PIN_ENTRY\000"
.LASF323:
	.ascii	"GPG_ERR_LDAP_NAME_GENERAL\000"
.LASF485:
	.ascii	"GPG_ERR_EDOTDOT\000"
.LASF182:
	.ascii	"GPG_ERR_UNKNOWN_EXTN\000"
.LASF162:
	.ascii	"GPG_ERR_PUBKEY_NOT_TRUSTED\000"
.LASF109:
	.ascii	"GPG_ERR_NOT_TRUSTED\000"
.LASF288:
	.ascii	"GPG_ERR_ASS_UNKNOWN_INQUIRE\000"
.LASF507:
	.ascii	"GPG_ERR_EL3HLT\000"
.LASF319:
	.ascii	"GPG_ERR_DNS_VERIFY\000"
.LASF384:
	.ascii	"GPG_ERR_LDAP_NOT_ALLOW_ON_RDN\000"
.LASF157:
	.ascii	"GPG_ERR_UNSUPPORTED_CMS_OBJ\000"
.LASF302:
	.ascii	"GPG_ERR_WRONG_NAME\000"
.LASF392:
	.ascii	"GPG_ERR_LDAP_CUP_SEC_VIOLATION\000"
.LASF400:
	.ascii	"GPG_ERR_LDAP_ASSERTION_FAILED\000"
.LASF130:
	.ascii	"GPG_ERR_NO_SCDAEMON\000"
.LASF214:
	.ascii	"GPG_ERR_SEXP_UNMATCHED_PAREN\000"
.LASF303:
	.ascii	"GPG_ERR_NO_AUTH\000"
.LASF544:
	.ascii	"GPG_ERR_ENOSR\000"
.LASF257:
	.ascii	"GPG_ERR_BAD_HS_CLIENT_KEX\000"
.LASF489:
	.ascii	"GPG_ERR_EFBIG\000"
.LASF316:
	.ascii	"GPG_ERR_DNS_NO_QUERY\000"
.LASF387:
	.ascii	"GPG_ERR_LDAP_RESULTS_TOO_LARGE\000"
.LASF47:
	.ascii	"GPG_ERR_BAD_CERT\000"
.LASF255:
	.ascii	"GPG_ERR_BAD_HS_FINISHED\000"
.LASF513:
	.ascii	"GPG_ERR_ELIBSCN\000"
.LASF119:
	.ascii	"GPG_ERR_CARD\000"
.LASF125:
	.ascii	"GPG_ERR_NOT_CONFIRMED\000"
.LASF247:
	.ascii	"GPG_ERR_UNKNOWN_IDENTITY\000"
.LASF190:
	.ascii	"GPG_ERR_NOT_ENABLED\000"
.LASF7:
	.ascii	"long int\000"
.LASF438:
	.ascii	"GPG_ERR_SQL_MISMATCH\000"
.LASF178:
	.ascii	"GPG_ERR_NOT_LOCKED\000"
.LASF270:
	.ascii	"GPG_ERR_ASS_INCOMPLETE_LINE\000"
.LASF597:
	.ascii	"statusstr_msgidx\000"
.LASF134:
	.ascii	"GPG_ERR_CARD_NOT_INITIALIZED\000"
.LASF61:
	.ascii	"GPG_ERR_SELFTEST_FAILED\000"
.LASF248:
	.ascii	"GPG_ERR_BAD_HS_CERT\000"
.LASF236:
	.ascii	"GPG_ERR_INV_RECORD\000"
.LASF600:
	.ascii	"errstr\000"
.LASF99:
	.ascii	"GPG_ERR_INV_NAME\000"
.LASF146:
	.ascii	"GPG_ERR_INV_BER\000"
.LASF97:
	.ascii	"GPG_ERR_PIN_ENTRY\000"
.LASF539:
	.ascii	"GPG_ERR_ENOMSG\000"
.LASF42:
	.ascii	"GPG_ERR_INV_PASSPHRASE\000"
.LASF455:
	.ascii	"GPG_ERR_EADDRNOTAVAIL\000"
.LASF181:
	.ascii	"GPG_ERR_INV_REQUEST\000"
.LASF274:
	.ascii	"GPG_ERR_ASS_NO_INQUIRE_CB\000"
.LASF215:
	.ascii	"GPG_ERR_SEXP_NOT_CANONICAL\000"
.LASF369:
	.ascii	"GPG_ERR_LDAP_ALIAS_PROBLEM\000"
.LASF474:
	.ascii	"GPG_ERR_ECHRNG\000"
.LASF497:
	.ascii	"GPG_ERR_EILSEQ\000"
.LASF450:
	.ascii	"GPG_ERR_UNKNOWN_ERRNO\000"
.LASF266:
	.ascii	"GPG_ERR_ASS_ACCEPT_FAILED\000"
.LASF329:
	.ascii	"GPG_ERR_LDAP_OTHER_GENERAL\000"
.LASF330:
	.ascii	"GPG_ERR_LDAP_X_CONNECTING\000"
.LASF32:
	.ascii	"GPG_ERR_NO_PRIME\000"
.LASF202:
	.ascii	"GPG_ERR_NO_CRYPT_CTX\000"
.LASF399:
	.ascii	"GPG_ERR_LDAP_CANNOT_CANCEL\000"
.LASF88:
	.ascii	"GPG_ERR_NO_AGENT\000"
.LASF249:
	.ascii	"GPG_ERR_BAD_HS_CERT_REQ\000"
.LASF431:
	.ascii	"GPG_ERR_SQL_FULL\000"
.LASF501:
	.ascii	"GPG_ERR_EIO\000"
.LASF195:
	.ascii	"GPG_ERR_NOT_INITIALIZED\000"
.LASF3:
	.ascii	"signed char\000"
.LASF281:
	.ascii	"GPG_ERR_ASS_UNEXPECTED_CMD\000"
.LASF259:
	.ascii	"GPG_ERR_FORBIDDEN\000"
.LASF104:
	.ascii	"GPG_ERR_DIRMNGR\000"
.LASF227:
	.ascii	"GPG_ERR_SERVER_FAILED\000"
.LASF402:
	.ascii	"GPG_ERR_USER_1\000"
.LASF403:
	.ascii	"GPG_ERR_USER_2\000"
.LASF404:
	.ascii	"GPG_ERR_USER_3\000"
.LASF405:
	.ascii	"GPG_ERR_USER_4\000"
.LASF406:
	.ascii	"GPG_ERR_USER_5\000"
.LASF407:
	.ascii	"GPG_ERR_USER_6\000"
.LASF408:
	.ascii	"GPG_ERR_USER_7\000"
.LASF409:
	.ascii	"GPG_ERR_USER_8\000"
.LASF410:
	.ascii	"GPG_ERR_USER_9\000"
.LASF317:
	.ascii	"GPG_ERR_DNS_NO_ANSWER\000"
.LASF525:
	.ascii	"GPG_ERR_ENETRESET\000"
.LASF267:
	.ascii	"GPG_ERR_ASS_CONNECT_FAILED\000"
.LASF74:
	.ascii	"GPG_ERR_INTERNAL\000"
.LASF486:
	.ascii	"GPG_ERR_EDQUOT\000"
.LASF59:
	.ascii	"GPG_ERR_NETWORK\000"
.LASF27:
	.ascii	"GPG_ERR_NO_USER_ID\000"
.LASF159:
	.ascii	"GPG_ERR_UNSUPPORTED_CMS_VERSION\000"
.LASF4:
	.ascii	"unsigned char\000"
.LASF35:
	.ascii	"GPG_ERR_NO_SIGNATURE_SCHEME\000"
.LASF470:
	.ascii	"GPG_ERR_EBFONT\000"
.LASF379:
	.ascii	"GPG_ERR_LDAP_UNWILL_TO_PERFORM\000"
.LASF110:
	.ascii	"GPG_ERR_CANCELED\000"
.LASF18:
	.ascii	"GPG_ERR_BAD_SECKEY\000"
.LASF436:
	.ascii	"GPG_ERR_SQL_TOOBIG\000"
.LASF275:
	.ascii	"GPG_ERR_ASS_NOT_A_SERVER\000"
.LASF595:
	.ascii	"gpg_error_t\000"
.LASF378:
	.ascii	"GPG_ERR_LDAP_UNAVAILABLE\000"
.LASF57:
	.ascii	"GPG_ERR_BAD_URI\000"
.LASF188:
	.ascii	"GPG_ERR_NO_PASSPHRASE\000"
.LASF294:
	.ascii	"GPG_ERR_NAME_EXISTS\000"
.LASF493:
	.ascii	"GPG_ERR_EHOSTDOWN\000"
.LASF180:
	.ascii	"GPG_ERR_INV_MAC\000"
.LASF498:
	.ascii	"GPG_ERR_EINPROGRESS\000"
.LASF573:
	.ascii	"GPG_ERR_ERESTART\000"
.LASF440:
	.ascii	"GPG_ERR_SQL_NOLFS\000"
.LASF52:
	.ascii	"GPG_ERR_WRONG_PUBKEY_ALGO\000"
.LASF472:
	.ascii	"GPG_ERR_ECANCELED\000"
.LASF128:
	.ascii	"GPG_ERR_INV_INDEX\000"
.LASF263:
	.ascii	"GPG_ERR_TRUE\000"
.LASF496:
	.ascii	"GPG_ERR_EIEIO\000"
.LASF490:
	.ascii	"GPG_ERR_EFTYPE\000"
.LASF336:
	.ascii	"GPG_ERR_LDAP_CONNECT\000"
.LASF430:
	.ascii	"GPG_ERR_SQL_NOTFOUND\000"
.LASF307:
	.ascii	"GPG_ERR_NO_SERVICE\000"
.LASF10:
	.ascii	"char\000"
.LASF447:
	.ascii	"GPG_ERR_SQL_ROW\000"
.LASF529:
	.ascii	"GPG_ERR_ENOBUFS\000"
.LASF370:
	.ascii	"GPG_ERR_LDAP_INV_DN_SYNTAX\000"
.LASF199:
	.ascii	"GPG_ERR_UNKNOWN_CURVE\000"
.LASF300:
	.ascii	"GPG_ERR_ALREADY_FETCHED\000"
.LASF581:
	.ascii	"GPG_ERR_ESTALE\000"
.LASF396:
	.ascii	"GPG_ERR_LDAP_CANCELLED\000"
.LASF543:
	.ascii	"GPG_ERR_ENOSPC\000"
.LASF569:
	.ascii	"GPG_ERR_ERANGE\000"
.LASF533:
	.ascii	"GPG_ERR_ENOENT\000"
.LASF366:
	.ascii	"GPG_ERR_LDAP_TYPE_VALUE_EXISTS\000"
.LASF413:
	.ascii	"GPG_ERR_USER_12\000"
.LASF415:
	.ascii	"GPG_ERR_USER_14\000"
.LASF86:
	.ascii	"GPG_ERR_INCOMPLETE_LINE\000"
.LASF322:
	.ascii	"GPG_ERR_LDAP_ATTR_GENERAL\000"
.LASF451:
	.ascii	"GPG_ERR_EOF\000"
.LASF201:
	.ascii	"GPG_ERR_AMBIGUOUS\000"
.LASF578:
	.ascii	"GPG_ERR_ESPIPE\000"
.LASF473:
	.ascii	"GPG_ERR_ECHILD\000"
.LASF213:
	.ascii	"GPG_ERR_SEXP_STRING_TOO_LONG\000"
.LASF197:
	.ascii	"GPG_ERR_NO_KEYSERVER\000"
.LASF356:
	.ascii	"GPG_ERR_LDAP_PARTIAL_RESULTS\000"
.LASF349:
	.ascii	"GPG_ERR_LDAP_PROTOCOL\000"
.LASF231:
	.ascii	"GPG_ERR_REQUEST_TOO_SHORT\000"
.LASF124:
	.ascii	"GPG_ERR_NO_PKCS15_APP\000"
.LASF68:
	.ascii	"GPG_ERR_MISSING_CERT\000"
.LASF204:
	.ascii	"GPG_ERR_BAD_CRYPT_CTX\000"
.LASF492:
	.ascii	"GPG_ERR_EGREGIOUS\000"
.LASF185:
	.ascii	"GPG_ERR_UNKNOWN_OPTION\000"
.LASF325:
	.ascii	"GPG_ERR_LDAP_SERVICE_GENERAL\000"
.LASF335:
	.ascii	"GPG_ERR_LDAP_NOT_SUPPORTED\000"
.LASF166:
	.ascii	"GPG_ERR_ENCODING_PROBLEM\000"
.LASF324:
	.ascii	"GPG_ERR_LDAP_SECURITY_GENERAL\000"
.LASF373:
	.ascii	"GPG_ERR_LDAP_X_PROXY_AUTH_FAIL\000"
.LASF549:
	.ascii	"GPG_ERR_ENOTDIR\000"
.LASF368:
	.ascii	"GPG_ERR_LDAP_NO_SUCH_OBJ\000"
.LASF15:
	.ascii	"GPG_ERR_PUBKEY_ALGO\000"
.LASF210:
	.ascii	"GPG_ERR_UNFINISHED\000"
.LASF133:
	.ascii	"GPG_ERR_BAD_PIN_METHOD\000"
.LASF309:
	.ascii	"GPG_ERR_BAD_PUK\000"
.LASF226:
	.ascii	"GPG_ERR_DB_CORRUPTED\000"
.LASF321:
	.ascii	"GPG_ERR_LDAP_GENERAL\000"
.LASF39:
	.ascii	"GPG_ERR_VALUE_NOT_FOUND\000"
.LASF265:
	.ascii	"GPG_ERR_ASS_GENERAL\000"
.LASF419:
	.ascii	"GPG_ERR_SQL_ERROR\000"
.LASF591:
	.ascii	"GPG_ERR_EXDEV\000"
.LASF524:
	.ascii	"GPG_ERR_ENETDOWN\000"
.LASF223:
	.ascii	"GPG_ERR_SEXP_ODD_HEX_NUMBERS\000"
.LASF90:
	.ascii	"GPG_ERR_INV_DATA\000"
.LASF289:
	.ascii	"GPG_ERR_ENGINE_TOO_OLD\000"
.LASF534:
	.ascii	"GPG_ERR_ENOEXEC\000"
.LASF16:
	.ascii	"GPG_ERR_DIGEST_ALGO\000"
.LASF508:
	.ascii	"GPG_ERR_EL3RST\000"
.LASF457:
	.ascii	"GPG_ERR_EAFNOSUPPORT\000"
.LASF358:
	.ascii	"GPG_ERR_LDAP_ADMINLIMIT\000"
.LASF55:
	.ascii	"GPG_ERR_INV_KEYLEN\000"
.LASF314:
	.ascii	"GPG_ERR_DNS_SECTION\000"
.LASF21:
	.ascii	"GPG_ERR_CHECKSUM\000"
.LASF469:
	.ascii	"GPG_ERR_EBADSLT\000"
.LASF186:
	.ascii	"GPG_ERR_UNKNOWN_COMMAND\000"
.LASF365:
	.ascii	"GPG_ERR_LDAP_CONST_VIOLATION\000"
.LASF108:
	.ascii	"GPG_ERR_LINE_TOO_LONG\000"
.LASF527:
	.ascii	"GPG_ERR_ENFILE\000"
.LASF476:
	.ascii	"GPG_ERR_ECONNABORTED\000"
.LASF475:
	.ascii	"GPG_ERR_ECOMM\000"
.LASF19:
	.ascii	"GPG_ERR_BAD_SIGNATURE\000"
.LASF598:
	.ascii	"get_inv_recpsgnr_code\000"
.LASF423:
	.ascii	"GPG_ERR_SQL_BUSY\000"
.LASF422:
	.ascii	"GPG_ERR_SQL_ABORT\000"
.LASF152:
	.ascii	"GPG_ERR_UNEXPECTED_TAG\000"
.LASF585:
	.ascii	"GPG_ERR_ETOOMANYREFS\000"
.LASF51:
	.ascii	"GPG_ERR_KEYSERVER\000"
.LASF439:
	.ascii	"GPG_ERR_SQL_MISUSE\000"
.LASF45:
	.ascii	"GPG_ERR_INV_KEYRING\000"
.LASF56:
	.ascii	"GPG_ERR_INV_ARG\000"
.LASF25:
	.ascii	"GPG_ERR_INV_PACKET\000"
.LASF552:
	.ascii	"GPG_ERR_ENOTSOCK\000"
.LASF256:
	.ascii	"GPG_ERR_BAD_HS_SERVER_KEX\000"
.LASF337:
	.ascii	"GPG_ERR_LDAP_NO_MEMORY\000"
.LASF347:
	.ascii	"GPG_ERR_LDAP_SUCCESS\000"
.LASF106:
	.ascii	"GPG_ERR_NO_CRL_KNOWN\000"
.LASF254:
	.ascii	"GPG_ERR_BAD_HS_SERVER_HELLO_DONE\000"
.LASF483:
	.ascii	"GPG_ERR_EDIED\000"
.LASF285:
	.ascii	"GPG_ERR_ASS_NO_INPUT\000"
.LASF571:
	.ascii	"GPG_ERR_EREMOTE\000"
.LASF20:
	.ascii	"GPG_ERR_NO_PUBKEY\000"
.LASF233:
	.ascii	"GPG_ERR_OBJ_TERM_STATE\000"
.LASF375:
	.ascii	"GPG_ERR_LDAP_INV_CREDENTIALS\000"
.LASF64:
	.ascii	"GPG_ERR_UNUSABLE_PUBKEY\000"
.LASF8:
	.ascii	"long unsigned int\000"
.LASF14:
	.ascii	"GPG_ERR_UNKNOWN_VERSION\000"
.LASF425:
	.ascii	"GPG_ERR_SQL_NOMEM\000"
.LASF327:
	.ascii	"GPG_ERR_LDAP_E_GENERAL\000"
.LASF276:
	.ascii	"GPG_ERR_ASS_NOT_A_CLIENT\000"
.LASF545:
	.ascii	"GPG_ERR_ENOSTR\000"
.LASF58:
	.ascii	"GPG_ERR_INV_URI\000"
.LASF377:
	.ascii	"GPG_ERR_LDAP_BUSY\000"
.LASF264:
	.ascii	"GPG_ERR_FALSE\000"
.LASF228:
	.ascii	"GPG_ERR_NO_NAME\000"
.LASF242:
	.ascii	"GPG_ERR_NO_CIPHER\000"
.LASF426:
	.ascii	"GPG_ERR_SQL_READONLY\000"
.LASF499:
	.ascii	"GPG_ERR_EINTR\000"
.LASF536:
	.ascii	"GPG_ERR_ENOLINK\000"
.LASF582:
	.ascii	"GPG_ERR_ESTRPIPE\000"
.LASF207:
	.ascii	"GPG_ERR_BROKEN_SECKEY\000"
.LASF484:
	.ascii	"GPG_ERR_EDOM\000"
.LASF433:
	.ascii	"GPG_ERR_SQL_PROTOCOL\000"
.LASF235:
	.ascii	"GPG_ERR_CERT_TOO_LARGE\000"
.LASF193:
	.ascii	"GPG_ERR_TOO_MANY\000"
.LASF75:
	.ascii	"GPG_ERR_EOF_GCRYPT\000"
.LASF165:
	.ascii	"GPG_ERR_SIG_EXPIRED\000"
.LASF535:
	.ascii	"GPG_ERR_ENOLCK\000"
.LASF553:
	.ascii	"GPG_ERR_ENOTSUP\000"
.LASF174:
	.ascii	"GPG_ERR_UNSUPPORTED_CRL_VERSION\000"
.LASF435:
	.ascii	"GPG_ERR_SQL_SCHEMA\000"
.LASF576:
	.ascii	"GPG_ERR_ESHUTDOWN\000"
.LASF147:
	.ascii	"GPG_ERR_ELEMENT_NOT_FOUND\000"
.LASF160:
	.ascii	"GPG_ERR_UNKNOWN_ALGORITHM\000"
.LASF138:
	.ascii	"GPG_ERR_WRONG_BLOB_TYPE\000"
.LASF79:
	.ascii	"GPG_ERR_NO_OBJ\000"
.LASF234:
	.ascii	"GPG_ERR_NO_CERT_CHAIN\000"
.LASF123:
	.ascii	"GPG_ERR_CARD_NOT_PRESENT\000"
.LASF63:
	.ascii	"GPG_ERR_NOT_PROCESSED\000"
.LASF420:
	.ascii	"GPG_ERR_SQL_INTERNAL\000"
.LASF262:
	.ascii	"GPG_ERR_INV_LOCK_OBJ\000"
.LASF593:
	.ascii	"GPG_ERR_CODE_DIM\000"
.LASF224:
	.ascii	"GPG_ERR_SEXP_BAD_OCT_CHAR\000"
.LASF572:
	.ascii	"GPG_ERR_EREMOTEIO\000"
.LASF121:
	.ascii	"GPG_ERR_CARD_REMOVED\000"
.LASF33:
	.ascii	"GPG_ERR_NO_ENCODING_METHOD\000"
.LASF258:
	.ascii	"GPG_ERR_BOGUS_STRING\000"
.LASF339:
	.ascii	"GPG_ERR_LDAP_USER_CANCELLED\000"
.LASF502:
	.ascii	"GPG_ERR_EISCONN\000"
.LASF175:
	.ascii	"GPG_ERR_INV_CERT_OBJ\000"
.LASF467:
	.ascii	"GPG_ERR_EBADRPC\000"
.LASF454:
	.ascii	"GPG_ERR_EADDRINUSE\000"
.LASF196:
	.ascii	"GPG_ERR_MISSING_ISSUER_CERT\000"
.LASF478:
	.ascii	"GPG_ERR_ECONNRESET\000"
.LASF555:
	.ascii	"GPG_ERR_ENOTUNIQ\000"
.LASF1:
	.ascii	"long long int\000"
.LASF48:
	.ascii	"GPG_ERR_INV_USER_ID\000"
.LASF117:
	.ascii	"GPG_ERR_CORRUPTED_PROTECTION\000"
.LASF344:
	.ascii	"GPG_ERR_LDAP_ENCODING\000"
.LASF78:
	.ascii	"GPG_ERR_TOO_LARGE\000"
.LASF342:
	.ascii	"GPG_ERR_LDAP_TIMEOUT\000"
.LASF389:
	.ascii	"GPG_ERR_LDAP_VLV\000"
.LASF509:
	.ascii	"GPG_ERR_ELIBACC\000"
.LASF243:
	.ascii	"GPG_ERR_MISSING_CLIENT_CERT\000"
.LASF46:
	.ascii	"GPG_ERR_TRUSTDB\000"
.LASF290:
	.ascii	"GPG_ERR_WINDOW_TOO_SMALL\000"
.LASF468:
	.ascii	"GPG_ERR_EBADRQC\000"
.LASF541:
	.ascii	"GPG_ERR_ENOPKG\000"
.LASF437:
	.ascii	"GPG_ERR_SQL_CONSTRAINT\000"
.LASF203:
	.ascii	"GPG_ERR_WRONG_CRYPT_CTX\000"
.LASF353:
	.ascii	"GPG_ERR_LDAP_COMPARE_TRUE\000"
.LASF54:
	.ascii	"GPG_ERR_WEAK_KEY\000"
.LASF71:
	.ascii	"GPG_ERR_NOT_SUPPORTED\000"
.LASF599:
	.ascii	"get_status_string\000"
.LASF211:
	.ascii	"GPG_ERR_BUFFER_TOO_SHORT\000"
.LASF246:
	.ascii	"GPG_ERR_BAD_TICKET\000"
.LASF560:
	.ascii	"GPG_ERR_EPFNOSUPPORT\000"
.LASF37:
	.ascii	"GPG_ERR_NO_VALUE\000"
.LASF511:
	.ascii	"GPG_ERR_ELIBEXEC\000"
.LASF95:
	.ascii	"GPG_ERR_UNSUPPORTED_ALGORITHM\000"
.LASF348:
	.ascii	"GPG_ERR_LDAP_OPERATIONS\000"
.LASF588:
	.ascii	"GPG_ERR_EUNATCH\000"
.LASF176:
	.ascii	"GPG_ERR_UNKNOWN_NAME\000"
.LASF458:
	.ascii	"GPG_ERR_EAGAIN\000"
.LASF0:
	.ascii	"unsigned int\000"
.LASF238:
	.ascii	"GPG_ERR_UNEXPECTED_MSG\000"
.LASF22:
	.ascii	"GPG_ERR_BAD_PASSPHRASE\000"
.LASF298:
	.ascii	"GPG_ERR_UNKNOWN_FLAG\000"
.LASF28:
	.ascii	"GPG_ERR_NO_SECKEY\000"
.LASF41:
	.ascii	"GPG_ERR_BAD_MPI\000"
.LASF391:
	.ascii	"GPG_ERR_LDAP_CUP_RESOURCE_LIMIT\000"
.LASF65:
	.ascii	"GPG_ERR_UNUSABLE_SECKEY\000"
.LASF222:
	.ascii	"GPG_ERR_SEXP_BAD_HEX_CHAR\000"
.LASF398:
	.ascii	"GPG_ERR_LDAP_TOO_LATE\000"
.LASF564:
	.ascii	"GPG_ERR_EPROGMISMATCH\000"
.LASF305:
	.ascii	"GPG_ERR_NO_KEYBOXD\000"
.LASF170:
	.ascii	"GPG_ERR_MODULE_NOT_FOUND\000"
.LASF205:
	.ascii	"GPG_ERR_CRYPT_CTX_CONFLICT\000"
.LASF271:
	.ascii	"GPG_ERR_ASS_LINE_TOO_LONG\000"
.LASF465:
	.ascii	"GPG_ERR_EBADMSG\000"
.LASF516:
	.ascii	"GPG_ERR_EMEDIUMTYPE\000"
.LASF301:
	.ascii	"GPG_ERR_TRY_LATER\000"
.LASF567:
	.ascii	"GPG_ERR_EPROTONOSUPPORT\000"
.LASF340:
	.ascii	"GPG_ERR_LDAP_FILTER\000"
.LASF209:
	.ascii	"GPG_ERR_FULLY_CANCELED\000"
.LASF575:
	.ascii	"GPG_ERR_ERPCMISMATCH\000"
.LASF448:
	.ascii	"GPG_ERR_SQL_DONE\000"
.LASF38:
	.ascii	"GPG_ERR_NOT_FOUND\000"
.LASF393:
	.ascii	"GPG_ERR_LDAP_CUP_INV_DATA\000"
.LASF434:
	.ascii	"GPG_ERR_SQL_EMPTY\000"
.LASF442:
	.ascii	"GPG_ERR_SQL_FORMAT\000"
.LASF546:
	.ascii	"GPG_ERR_ENOSYS\000"
.LASF297:
	.ascii	"GPG_ERR_TOO_OLD\000"
.LASF225:
	.ascii	"GPG_ERR_SUBKEYS_EXP_OR_REV\000"
.LASF480:
	.ascii	"GPG_ERR_EDEADLK\000"
.LASF221:
	.ascii	"GPG_ERR_SEXP_UNEXPECTED_PUNC\000"
.LASF151:
	.ascii	"GPG_ERR_INV_KEYINFO\000"
.LASF570:
	.ascii	"GPG_ERR_EREMCHG\000"
.LASF528:
	.ascii	"GPG_ERR_ENOANO\000"
.LASF592:
	.ascii	"GPG_ERR_EXFULL\000"
.LASF386:
	.ascii	"GPG_ERR_LDAP_NO_OBJ_CLASS_MODS\000"
.LASF293:
	.ascii	"GPG_ERR_USER_ID_EXISTS\000"
.LASF446:
	.ascii	"GPG_ERR_SQL_WARNING\000"
.LASF505:
	.ascii	"GPG_ERR_EL2HLT\000"
.LASF154:
	.ascii	"GPG_ERR_NO_CMS_OBJ\000"
.LASF522:
	.ascii	"GPG_ERR_ENAVAIL\000"
.LASF101:
	.ascii	"GPG_ERR_INV_PARAMETER\000"
.LASF206:
	.ascii	"GPG_ERR_BROKEN_PUBKEY\000"
.LASF69:
	.ascii	"GPG_ERR_NO_DATA\000"
.LASF397:
	.ascii	"GPG_ERR_LDAP_NO_SUCH_OPERATION\000"
.LASF50:
	.ascii	"GPG_ERR_TIME_CONFLICT\000"
.LASF556:
	.ascii	"GPG_ERR_ENXIO\000"
.LASF141:
	.ascii	"GPG_ERR_PIN_BLOCKED\000"
.LASF171:
	.ascii	"GPG_ERR_INV_OID_STRING\000"
.LASF268:
	.ascii	"GPG_ERR_ASS_INV_RESPONSE\000"
.LASF167:
	.ascii	"GPG_ERR_INV_STATE\000"
.LASF328:
	.ascii	"GPG_ERR_LDAP_X_GENERAL\000"
.LASF333:
	.ascii	"GPG_ERR_LDAP_NO_RESULTS\000"
.LASF13:
	.ascii	"GPG_ERR_UNKNOWN_PACKET\000"
.LASF200:
	.ascii	"GPG_ERR_DUP_KEY\000"
.LASF554:
	.ascii	"GPG_ERR_ENOTTY\000"
.LASF445:
	.ascii	"GPG_ERR_SQL_NOTICE\000"
.LASF269:
	.ascii	"GPG_ERR_ASS_INV_VALUE\000"
.LASF491:
	.ascii	"GPG_ERR_EGRATUITOUS\000"
.LASF142:
	.ascii	"GPG_ERR_USE_CONDITIONS\000"
.LASF510:
	.ascii	"GPG_ERR_ELIBBAD\000"
.LASF2:
	.ascii	"long double\000"
.LASF355:
	.ascii	"GPG_ERR_LDAP_STRONG_AUTH_RQRD\000"
.LASF194:
	.ascii	"GPG_ERR_LIMIT_REACHED\000"
.LASF230:
	.ascii	"GPG_ERR_LEGACY_KEY\000"
.LASF251:
	.ascii	"GPG_ERR_BAD_HS_CHANGE_CIPHER\000"
.LASF26:
	.ascii	"GPG_ERR_INV_ARMOR\000"
.LASF92:
	.ascii	"GPG_ERR_ASSUAN\000"
.LASF53:
	.ascii	"GPG_ERR_TRIBUTE_TO_D_A\000"
.LASF421:
	.ascii	"GPG_ERR_SQL_PERM\000"
.LASF601:
	.ascii	"GNU C17 10.3.1 20210621 (release) -mcpu=cortex-a7 -"
	.ascii	"mfloat-abi=soft -marm -march=armv7ve -g -O2 -fpic -"
	.ascii	"ffreestanding -ffunction-sections -fdata-sections -"
	.ascii	"fno-common\000"
.LASF81:
	.ascii	"GPG_ERR_CONFLICT\000"
.LASF149:
	.ascii	"GPG_ERR_INV_TAG\000"
.LASF43:
	.ascii	"GPG_ERR_SIG_CLASS\000"
.LASF164:
	.ascii	"GPG_ERR_KEY_EXPIRED\000"
.LASF252:
	.ascii	"GPG_ERR_BAD_HS_CLIENT_HELLO\000"
.LASF500:
	.ascii	"GPG_ERR_EINVAL\000"
.LASF36:
	.ascii	"GPG_ERR_INV_ATTR\000"
.LASF140:
	.ascii	"GPG_ERR_HARDWARE\000"
.LASF82:
	.ascii	"GPG_ERR_INV_CIPHER_MODE\000"
.LASF338:
	.ascii	"GPG_ERR_LDAP_PARAM\000"
.LASF548:
	.ascii	"GPG_ERR_ENOTCONN\000"
.LASF449:
	.ascii	"GPG_ERR_MISSING_ERRNO\000"
.LASF85:
	.ascii	"GPG_ERR_TRUNCATED\000"
.LASF62:
	.ascii	"GPG_ERR_NOT_ENCRYPTED\000"
.LASF315:
	.ascii	"GPG_ERR_DNS_ADDRESS\000"
.LASF115:
	.ascii	"GPG_ERR_UNKNOWN_SEXP\000"
.LASF173:
	.ascii	"GPG_ERR_INV_CRL_OBJ\000"
.LASF139:
	.ascii	"GPG_ERR_MISSING_VALUE\000"
.LASF519:
	.ascii	"GPG_ERR_EMSGSIZE\000"
.LASF76:
	.ascii	"GPG_ERR_INV_OBJ\000"
.LASF9:
	.ascii	"long long unsigned int\000"
.LASF244:
	.ascii	"GPG_ERR_CLOSE_NOTIFY\000"
.LASF596:
	.ascii	"statusstr_msgstr\000"
.LASF169:
	.ascii	"GPG_ERR_MISSING_ACTION\000"
.LASF345:
	.ascii	"GPG_ERR_LDAP_LOCAL\000"
.LASF531:
	.ascii	"GPG_ERR_ENODATA\000"
.LASF515:
	.ascii	"GPG_ERR_ELOOP\000"
.LASF352:
	.ascii	"GPG_ERR_LDAP_COMPARE_FALSE\000"
.LASF587:
	.ascii	"GPG_ERR_EUCLEAN\000"
.LASF456:
	.ascii	"GPG_ERR_EADV\000"
.LASF277:
	.ascii	"GPG_ERR_ASS_SERVER_START\000"
.LASF459:
	.ascii	"GPG_ERR_EALREADY\000"
.LASF332:
	.ascii	"GPG_ERR_LDAP_CLIENT_LOOP\000"
.LASF547:
	.ascii	"GPG_ERR_ENOTBLK\000"
.LASF429:
	.ascii	"GPG_ERR_SQL_CORRUPT\000"
.LASF296:
	.ascii	"GPG_ERR_TOO_YOUNG\000"
.LASF481:
	.ascii	"GPG_ERR_EDEADLOCK\000"
.LASF538:
	.ascii	"GPG_ERR_ENOMEM\000"
.LASF464:
	.ascii	"GPG_ERR_EBADFD\000"
.LASF310:
	.ascii	"GPG_ERR_NO_RESET_CODE\000"
.LASF91:
	.ascii	"GPG_ERR_ASSUAN_SERVER_FAULT\000"
.LASF523:
	.ascii	"GPG_ERR_ENEEDAUTH\000"
.LASF102:
	.ascii	"GPG_ERR_WRONG_CARD\000"
.LASF116:
	.ascii	"GPG_ERR_UNSUPPORTED_PROTECTION\000"
.LASF574:
	.ascii	"GPG_ERR_EROFS\000"
.LASF361:
	.ascii	"GPG_ERR_LDAP_SASL_BIND_INPROG\000"
.LASF283:
	.ascii	"GPG_ERR_ASS_SYNTAX\000"
.LASF73:
	.ascii	"GPG_ERR_TIMEOUT\000"
.LASF351:
	.ascii	"GPG_ERR_LDAP_SIZELIMIT\000"
.LASF579:
	.ascii	"GPG_ERR_ESRCH\000"
.LASF488:
	.ascii	"GPG_ERR_EFAULT\000"
.LASF504:
	.ascii	"GPG_ERR_EISNAM\000"
.LASF341:
	.ascii	"GPG_ERR_LDAP_AUTH_UNKNOWN\000"
.LASF31:
	.ascii	"GPG_ERR_COMPR_ALGO\000"
.LASF112:
	.ascii	"GPG_ERR_CERT_EXPIRED\000"
.LASF411:
	.ascii	"GPG_ERR_USER_10\000"
.LASF412:
	.ascii	"GPG_ERR_USER_11\000"
.LASF163:
	.ascii	"GPG_ERR_DECRYPT_FAILED\000"
.LASF414:
	.ascii	"GPG_ERR_USER_13\000"
.LASF278:
	.ascii	"GPG_ERR_ASS_READ_ERROR\000"
.LASF416:
	.ascii	"GPG_ERR_USER_15\000"
.LASF417:
	.ascii	"GPG_ERR_USER_16\000"
.LASF313:
	.ascii	"GPG_ERR_DNS_UNKNOWN\000"
.LASF517:
	.ascii	"GPG_ERR_EMFILE\000"
.LASF462:
	.ascii	"GPG_ERR_EBADE\000"
.LASF463:
	.ascii	"GPG_ERR_EBADF\000"
.LASF583:
	.ascii	"GPG_ERR_ETIME\000"
.LASF542:
	.ascii	"GPG_ERR_ENOPROTOOPT\000"
.LASF466:
	.ascii	"GPG_ERR_EBADR\000"
.LASF187:
	.ascii	"GPG_ERR_NOT_OPERATIONAL\000"
.LASF12:
	.ascii	"GPG_ERR_GENERAL\000"
.LASF24:
	.ascii	"GPG_ERR_KEYRING_OPEN\000"
.LASF604:
	.ascii	"gpg_err_code\000"
.LASF87:
	.ascii	"GPG_ERR_INV_RESPONSE\000"
.LASF229:
	.ascii	"GPG_ERR_NO_KEY\000"
.LASF376:
	.ascii	"GPG_ERR_LDAP_INSUFFICIENT_ACC\000"
.LASF272:
	.ascii	"GPG_ERR_ASS_NESTED_COMMANDS\000"
.LASF346:
	.ascii	"GPG_ERR_LDAP_SERVER_DOWN\000"
.LASF577:
	.ascii	"GPG_ERR_ESOCKTNOSUPPORT\000"
.LASF253:
	.ascii	"GPG_ERR_BAD_HS_SERVER_HELLO\000"
.LASF232:
	.ascii	"GPG_ERR_REQUEST_TOO_LONG\000"
.LASF602:
	.ascii	"src/common/status.c\000"
.LASF60:
	.ascii	"GPG_ERR_UNKNOWN_HOST\000"
.LASF122:
	.ascii	"GPG_ERR_INV_CARD\000"
.LASF67:
	.ascii	"GPG_ERR_BAD_CERT_CHAIN\000"
.LASF114:
	.ascii	"GPG_ERR_UNSUPPORTED_CERT\000"
.LASF590:
	.ascii	"GPG_ERR_EWOULDBLOCK\000"
.LASF443:
	.ascii	"GPG_ERR_SQL_RANGE\000"
.LASF11:
	.ascii	"GPG_ERR_NO_ERROR\000"
.LASF29:
	.ascii	"GPG_ERR_WRONG_SECKEY\000"
.LASF372:
	.ascii	"GPG_ERR_LDAP_ALIAS_DEREF\000"
.LASF291:
	.ascii	"GPG_ERR_WINDOW_TOO_LARGE\000"
.LASF129:
	.ascii	"GPG_ERR_INV_ID\000"
.LASF192:
	.ascii	"GPG_ERR_MISSING_KEY\000"
.LASF144:
	.ascii	"GPG_ERR_INV_CRL\000"
.LASF137:
	.ascii	"GPG_ERR_NOTHING_FOUND\000"
.LASF530:
	.ascii	"GPG_ERR_ENOCSI\000"
.LASF460:
	.ascii	"GPG_ERR_EAUTH\000"
.LASF66:
	.ascii	"GPG_ERR_INV_VALUE\000"
.LASF506:
	.ascii	"GPG_ERR_EL2NSYNC\000"
.LASF565:
	.ascii	"GPG_ERR_EPROGUNAVAIL\000"
.LASF603:
	.ascii	"/home/fred/code/rpi-qemu-gdb/Claude/raspi3b_qemu_\000"
.LASF30:
	.ascii	"GPG_ERR_BAD_KEY\000"
.LASF172:
	.ascii	"GPG_ERR_INV_TIME\000"
.LASF5:
	.ascii	"short int\000"
.LASF566:
	.ascii	"GPG_ERR_EPROTO\000"
.LASF514:
	.ascii	"GPG_ERR_ELNRNG\000"
.LASF561:
	.ascii	"GPG_ERR_EPIPE\000"
.LASF584:
	.ascii	"GPG_ERR_ETIMEDOUT\000"
.LASF383:
	.ascii	"GPG_ERR_LDAP_NOT_ALLOW_NONLEAF\000"
.LASF357:
	.ascii	"GPG_ERR_LDAP_REFERRAL\000"
.LASF482:
	.ascii	"GPG_ERR_EDESTADDRREQ\000"
.LASF260:
	.ascii	"GPG_ERR_KEY_DISABLED\000"
.LASF503:
	.ascii	"GPG_ERR_EISDIR\000"
.LASF132:
	.ascii	"GPG_ERR_UNSUPPORTED_PROTOCOL\000"
.LASF191:
	.ascii	"GPG_ERR_NO_ENGINE\000"
.LASF364:
	.ascii	"GPG_ERR_LDAP_BAD_MATCHING\000"
.LASF312:
	.ascii	"GPG_ERR_SYSTEM_BUG\000"
.LASF363:
	.ascii	"GPG_ERR_LDAP_UNDEFINED_TYPE\000"
.LASF394:
	.ascii	"GPG_ERR_LDAP_CUP_UNSUP_SCHEME\000"
.LASF518:
	.ascii	"GPG_ERR_EMLINK\000"
.LASF521:
	.ascii	"GPG_ERR_ENAMETOOLONG\000"
.LASF388:
	.ascii	"GPG_ERR_LDAP_AFFECTS_MULT_DSAS\000"
.LASF359:
	.ascii	"GPG_ERR_LDAP_UNAVAIL_CRIT_EXTN\000"
.LASF471:
	.ascii	"GPG_ERR_EBUSY\000"
.LASF168:
	.ascii	"GPG_ERR_DUP_VALUE\000"
.LASF374:
	.ascii	"GPG_ERR_LDAP_BAD_AUTH\000"
.LASF143:
	.ascii	"GPG_ERR_PIN_NOT_SYNCED\000"
.LASF334:
	.ascii	"GPG_ERR_LDAP_CONTROL_NOT_FOUND\000"
.LASF84:
	.ascii	"GPG_ERR_INV_HANDLE\000"
.LASF287:
	.ascii	"GPG_ERR_ASS_PARAMETER\000"
.LASF94:
	.ascii	"GPG_ERR_INV_SEXP\000"
.LASF512:
	.ascii	"GPG_ERR_ELIBMAX\000"
.LASF218:
	.ascii	"GPG_ERR_SEXP_ZERO_PREFIX\000"
.LASF131:
	.ascii	"GPG_ERR_SCDAEMON\000"
.LASF331:
	.ascii	"GPG_ERR_LDAP_REFERRAL_LIMIT\000"
.LASF155:
	.ascii	"GPG_ERR_INV_CMS_OBJ\000"
.LASF594:
	.ascii	"gpg_err_code_t\000"
.LASF306:
	.ascii	"GPG_ERR_KEYBOXD\000"
.LASF208:
	.ascii	"GPG_ERR_MAC_ALGO\000"
.LASF148:
	.ascii	"GPG_ERR_IDENTIFIER_NOT_FOUND\000"
.LASF111:
	.ascii	"GPG_ERR_BAD_CA_CERT\000"
.LASF308:
	.ascii	"GPG_ERR_SERVICE\000"
.LASF189:
	.ascii	"GPG_ERR_NO_PIN\000"
.LASF299:
	.ascii	"GPG_ERR_INV_ORDER\000"
.LASF100:
	.ascii	"GPG_ERR_BAD_DATA\000"
.LASF441:
	.ascii	"GPG_ERR_SQL_AUTH\000"
.LASF103:
	.ascii	"GPG_ERR_NO_DIRMNGR\000"
.LASF427:
	.ascii	"GPG_ERR_SQL_INTERRUPT\000"
.LASF390:
	.ascii	"GPG_ERR_LDAP_OTHER\000"
.LASF150:
	.ascii	"GPG_ERR_INV_LENGTH\000"
.LASF120:
	.ascii	"GPG_ERR_CARD_RESET\000"
.LASF282:
	.ascii	"GPG_ERR_ASS_UNKNOWN_CMD\000"
.LASF240:
	.ascii	"GPG_ERR_WOULD_WRAP\000"
.LASF532:
	.ascii	"GPG_ERR_ENODEV\000"
.LASF220:
	.ascii	"GPG_ERR_SEXP_UNMATCHED_DH\000"
.LASF586:
	.ascii	"GPG_ERR_ETXTBSY\000"
.LASF280:
	.ascii	"GPG_ERR_ASS_TOO_MUCH_DATA\000"
.LASF453:
	.ascii	"GPG_ERR_EACCES\000"
.LASF558:
	.ascii	"GPG_ERR_EOVERFLOW\000"
.LASF551:
	.ascii	"GPG_ERR_ENOTNAM\000"
.LASF557:
	.ascii	"GPG_ERR_EOPNOTSUPP\000"
.LASF494:
	.ascii	"GPG_ERR_EHOSTUNREACH\000"
.LASF540:
	.ascii	"GPG_ERR_ENONET\000"
.LASF286:
	.ascii	"GPG_ERR_ASS_NO_OUTPUT\000"
.LASF126:
	.ascii	"GPG_ERR_CONFIGURATION\000"
.LASF589:
	.ascii	"GPG_ERR_EUSERS\000"
.LASF6:
	.ascii	"short unsigned int\000"
.LASF395:
	.ascii	"GPG_ERR_LDAP_CUP_RELOAD\000"
.LASF177:
	.ascii	"GPG_ERR_LOCALE_PROBLEM\000"
.LASF563:
	.ascii	"GPG_ERR_EPROCUNAVAIL\000"
.LASF98:
	.ascii	"GPG_ERR_BAD_PIN\000"
.LASF520:
	.ascii	"GPG_ERR_EMULTIHOP\000"
.LASF261:
	.ascii	"GPG_ERR_KEY_ON_CARD\000"
.LASF44:
	.ascii	"GPG_ERR_RESOURCE_LIMIT\000"
.LASF562:
	.ascii	"GPG_ERR_EPROCLIM\000"
.LASF371:
	.ascii	"GPG_ERR_LDAP_IS_LEAF\000"
.LASF292:
	.ascii	"GPG_ERR_MISSING_ENVVAR\000"
.LASF83:
	.ascii	"GPG_ERR_INV_FLAG\000"
.LASF49:
	.ascii	"GPG_ERR_UNEXPECTED\000"
.LASF424:
	.ascii	"GPG_ERR_SQL_LOCKED\000"
.LASF461:
	.ascii	"GPG_ERR_EBACKGROUND\000"
.LASF135:
	.ascii	"GPG_ERR_UNSUPPORTED_OPERATION\000"
.LASF241:
	.ascii	"GPG_ERR_FATAL_ALERT\000"
.LASF212:
	.ascii	"GPG_ERR_SEXP_INV_LEN_SPEC\000"
.LASF580:
	.ascii	"GPG_ERR_ESRMNT\000"
.LASF380:
	.ascii	"GPG_ERR_LDAP_LOOP_DETECT\000"
.LASF105:
	.ascii	"GPG_ERR_CERT_REVOKED\000"
.LASF382:
	.ascii	"GPG_ERR_LDAP_OBJ_CLS_VIOLATION\000"
.LASF495:
	.ascii	"GPG_ERR_EIDRM\000"
.LASF279:
	.ascii	"GPG_ERR_ASS_WRITE_ERROR\000"
.LASF273:
	.ascii	"GPG_ERR_ASS_NO_DATA_CB\000"
.LASF362:
	.ascii	"GPG_ERR_LDAP_NO_SUCH_ATTRIBUTE\000"
.LASF350:
	.ascii	"GPG_ERR_LDAP_TIMELIMIT\000"
.LASF360:
	.ascii	"GPG_ERR_LDAP_CONFIDENT_RQRD\000"
.LASF156:
	.ascii	"GPG_ERR_UNKNOWN_CMS_OBJ\000"
.LASF479:
	.ascii	"GPG_ERR_ED\000"
.LASF550:
	.ascii	"GPG_ERR_ENOTEMPTY\000"
.LASF320:
	.ascii	"GPG_ERR_DNS_TIMEOUT\000"
.LASF367:
	.ascii	"GPG_ERR_LDAP_INV_SYNTAX\000"
.LASF70:
	.ascii	"GPG_ERR_BUG\000"
.LASF311:
	.ascii	"GPG_ERR_BAD_RESET_CODE\000"
.LASF93:
	.ascii	"GPG_ERR_INV_SESSION_KEY\000"
.LASF145:
	.ascii	"GPG_ERR_BAD_BER\000"
.LASF217:
	.ascii	"GPG_ERR_SEXP_BAD_QUOTATION\000"
.LASF295:
	.ascii	"GPG_ERR_DUP_NAME\000"
.LASF72:
	.ascii	"GPG_ERR_INV_OP\000"
	.ident	"GCC: (15:10.3-2021.07-4) 10.3.1 20210621 (release)"
