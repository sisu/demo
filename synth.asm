BITS 32

extern	music
global	genmusic, genmusic2, genmusic3, genmusic4
K	equ	44100/4

; instrument: silence, slowdown, notelen, basefreq

notes:
	db	3,12,14,11,  1,1,1,1,1,1,0
	db	4,31,13,3,  50,60,40,45,30,50,40,60,30,70,40,80,-1

ncount	equ	$ - notes - 4
N	equ	ncount*K

ampl:	dw	15000

; instr: slow count

notetime	equ	4410*2
fnotes:	dd	0,notetime,  0.06, 0.05, 0.07, 0.04, 0.08, 0.06, 0.05, 0.04, 0
	dd	0.01,2*notetime,  0.1, 0.1, 0.1, 0.1, -1

genmusic4:
	pushad
	mov	esi, fnotes

.instr:
	mov	edi, music
	lodsd
	mov	[fslow], eax
	lodsd
	mov	[fcount], eax
.notes:
;	xor	eax, eax
;	lodsb
;	test	al,al
;	jle	.endgen

	mov	ecx, [fcount]
;	mov	ebx, eax
	fild	dword	[fcount]
	fld1
	fdivrp
	fild	word [ampl]
	fmul	st1, st0
	fldz
	.samples:
		; fpu stack: wave, vol, voldown
		fld	st2
		fsubp	st2, st0

		fadd	dword	[esi]
		fld	st0
		fmul	dword	[fslow]

		fld1
		faddp
		fdivr	st1

		fsin

		fld	st0
		fabs
		fdivp

		fmul	st2
		fiadd	dword	[edi]
		fistp	dword	[edi]
		times	2	inc	edi
		loop	.samples
	fstp	st0
	fstp	st0
	fstp	st0

	lodsd
	test	eax, eax
	jg	.notes
	jz	.instr
;	test	eax, eax
;	jg	.notes
;	jz	.instr
.endgen:
	popad
	ret


genmusic3:
	pushad
	mov	esi, notes
;	mov	ecx, ncount

.instrloop:
	mov	edi, music
	lodsd
	mov	[curinstr], eax

.notes:
	xor	eax, eax
	lodsb
	test	al,al
	jz	.instrloop
	jl	.endgen
	mov	ebx, eax
;	imul	bx, 100
;	push	ecx
	mov	cl, [basefreq]
	shl	ebx, cl
	xor	eax, eax
	inc	eax
	mov	cl, [notelen]
	shl	eax, cl
	mov	ecx, eax
;	mov	ecx, K
	cdq
	mov	dl, [silence]
	mov	ebp, edx
	imul	ebp, ecx
;	mov	ebp, 1<<15
;	xor	edx, edx
	xor	eax, eax
	.samples:
		; eax: wave, ebx: freq, ecx: pos, ebp: vol
		add	eax, ebx
		cdq
		mov	dl, [silence]
		sub	ebp, edx

		pushad
		xor	edx, edx
		mov	ebx, eax
		mov	cl, [slowdown]
		shr	ebx, cl
		add	ebx, 1<<10
		div	ebx
		and	eax, 127
		imul	eax, 180

		and	eax, 0xffff ; TODO: cwd?
		imul	eax, ebp
		shr	eax, 16
;		sub	ebp, 1

;		stosw
		add	[edi], ax
		popad
		times	2	inc	edi
		loop	.samples
	jmp	.notes
;	pop	ecx
;	loop	.notes
.endgen:
	popad
	ret

genmusic2:
	pushad
	mov	edi, music
	mov	esi, notes
	mov	ecx, N
	xor	eax, eax
	mov	ebx, 500
.loop:
	add	eax, ebx
	stosw
	loop	.loop
	popad
	ret

genmusic:
	mov	edi,music
	xor	ecx,ecx
.genloop:
	mov	eax,ecx
	sar	eax,12
	mov	edx,ecx
	sar	edx,8
	or	eax,edx
	mov	edx,ecx
	sar	edx,4
	and	eax,edx
	and	eax,63
	imul	eax,ecx
	sal	eax,8

	stosw
	inc	ecx
	cmp	ecx,N
	jl	.genloop
	ret

section .bss
curinstr:
	silence:	resb	1
	slowdown:	resb	1
	notelen:	resb	1
	basefreq:	resb	1

fslow:	resd	1
fcount:	resd	1
