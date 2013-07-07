BITS 32

extern	music
global	genmusic, genmusic2, genmusic3
K	equ	44100/4

notes:	db	50,60,40,45,30,50
ncount	equ	$ - notes
N	equ	ncount*K

genmusic3:
	pushad
	mov	edi, music
	mov	esi, notes
	mov	ecx, ncount
.outer:
	lodsb
	xor	ebx, ebx
	mov	bl, al
;	imul	bx, 100
	shl	ebx, 11
	push	ecx
	mov	ecx, K
	mov	ebp, 1<<15
	xor	edx, edx
	.inner:
		; ebx: freq, ecx: pos, edx: wave, ebp: vol
		add	edx, ebx
		sub	ebp, (1<<15)/K

;		xor	eax, eax
		push	edx
		push	ebx
		xor	eax, eax
		xchg	eax, edx
		mov	ebx, eax
		shr	ebx, 13
		add	ebx, 10<<10
		div	ebx
		pop	ebx
		pop	edx
;		shl	eax, 8
		and	eax, 127
		imul	eax, 180

		and	eax, 0xffff ; TODO: cwd?
		imul	eax, ebp
		shr	eax, 16
;		sub	ebp, 1

		stosw
		loop	.inner
	pop	ecx
	loop	.outer
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
