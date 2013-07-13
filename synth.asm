BITS 32

extern	music
global	genmusic, genmusic2, genmusic3, genmusic4
K	equ	44100/4

; instrument: silence, slowdown, notelen, basefreq

notes:	db	2,13,14,11,  1,1,1,1,1,1,0
	db	4,31,13,6,  50,60,40,45,30,50,40,60,30,70,40,80,-1

ncount	equ	$ - notes - 4
N	equ	ncount*K

;asd:	dd	0.05
asd:	dd	0.105
aslow:	dw	100
bslow:	dw	-5
ampl:	dw	15000
;snddown:	dd	0.001
snddown:	dd	0.680272108844

genmusic4:
	pushad
	mov	esi, notes
	mov	edi, music

.notes:
	xor	eax, eax
	lodsb
	test	al,al
	jle	.endgen

	mov	ecx, 2*K
;	mov	ebx, eax
	fild	word [ampl]
	fldz
	.samples:
		fld	dword	[snddown]
		fsubp	st2, st0
;		fld1
		fadd	dword	[asd]
		fld	st0
;		fmul	dword	[aslow]

		fidiv	word	[aslow]
		fld1
		faddp
		fdivr	st1

		fsin
;		fimul	word	[ampl]
		fmul	st2
		fadd	dword	[edi]
		fistp	dword	[edi]
		times	2	inc	edi
		loop	.samples
	fstp	st0
	fstp	st0
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
		add	ebx, 10<<10
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
	pusha
	mov	edi, music
	mov	esi, notes
	mov	ecx, N
	xor	eax, eax
	mov	ebx, 500
.loop:
	add	eax, ebx
	stosw
	loop	.loop
	popa
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
