BITS 32

extern	music
global	genmusic, genmusic2, genmusic3
K	equ	44100/4

; instrument: silence, slowdown, notelen, basefreq

notes:	db	2,13,14,11,  1,1,1,1,1,1,0
	db	4,31,13,6,  50,60,40,45,30,50,40,60,30,70,40,80,-1

ncount	equ	$ - notes - 4
N	equ	ncount*K

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
;		xor	eax, eax
;		cdq
		xor	edx, edx
		mov	ebx, eax
		mov	cl, [slowdown]
		shr	ebx, cl
;		shr	ebx, 13
		add	ebx, 10<<10
;		mov	ebx, 10<<10
		div	ebx
;		shl	eax, 8
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
