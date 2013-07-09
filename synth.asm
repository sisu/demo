BITS 32

extern	music
global	genmusic, genmusic2, genmusic3
K	equ	44100/4

; instrument: (freq-scale, time, volume, slowdown)
; (time, slowdown)
;instrs:	db	11, 2, 15, 
;instrs:	db	2, 13

notes:	db	8,13,  50,60,40,45,30,50
ncount	equ	$ - notes - 2
N	equ	ncount*K

genmusic3:
	pushad
	mov	edi, music
	mov	esi, notes
	mov	ecx, ncount

.instrs:
	xor	eax,eax
	lodsb
	mov	[instrtime], eax
	lodsb
	mov	[instrslow], eax
;	mov	[curinstr], ax

.notes:
	xor	eax, eax
	lodsb
	mov	ebx, eax
;	imul	bx, 100
	shl	ebx, 11
	push	ecx
	mov	ecx, K
	mov	ebp, [instrtime]
	imul	ebp, ecx
;	mov	ebp, 1<<15
;	xor	edx, edx
	xor	eax, eax
	xor	edx, edx
	.samples:
		; eax: wave, ebx: freq, ecx: pos, ebp: vol
		add	eax, ebx
		sub	ebp, [instrtime]

		pushad
;		xor	eax, eax
;		cdq
		xor	edx, edx
		mov	ebx, eax
		shr	ebx, 13
		add	ebx, 10<<10
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
	pop	ecx
	loop	.notes
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
	instrtime:	resd	1
	instrslow:	resd	1
