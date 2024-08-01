BITS 32

SECTION .DATA

FREQ	equ	44100
notetime	equ	FREQ/10*2

bp0	equ	(1|8|16)
bassplay	equ	bp0 | (bp0<<8) | (bp0<<16) | (bp0<<24)

SECTION	.bss
ifreqmod:	resd	1

music:	resw	MS + (1<<20)
MS	equ	32*musiciters*notetime

;curmusic:	dd music

SECTION .TEXT
GLOBAL _start

intplay:	; ebx: freqptr
	pushad
	mov	ecx, notetime

	imul	ebx, [ifreqmod]
;	imul	ebx, 1<<16	; constant will be replaced
;	ifreqmod	equ	$-4
	shr	ebx, 16
	xor	edx, edx
	.samples:
		; edx: wave, esi: vol
		add	edx, ebx
		mov	ax, dx
		imul	eax, ecx
		shr	eax, 16

		cmp	ebx, 80
		jg	.lol
		add	eax, eax
	.lol:
		add	ax, [edi]
		stosw
		loop	.samples
	mov	[esp], edi
	popad
	ret

musiciters	equ	8
_start:
	mov	edi, music
	mov	ecx, musiciters
.imusicgen:
	pushad
	mov	dword [ifreqmod], 4<<16
	test	cl, 1
	jz	.ihighround
	mov	dword [ifreqmod], 116771*2
.ihighround:
	xor	ebx, ebx
	mov	edx, (490/2) | (327/2<<8) | (367/2<<16) | (245/2<<24)
	mov	cl, 32
	pushad
	.ihighmelody:
		mov	bl, dl
		ror	edx, 8
		call	intplay
		loop	.ihighmelody
	popad

	mov	cl, 11
	pushad
	.ilowmelody:
		mov	bl, dl
		ror	edx, 8
		shr	ebx, 2
		call	intplay
		add	edi, 4*notetime
		loop	.ilowmelody
	popad

	xor	eax, eax
	mov	cl, 32
	.ibassmelody:
		xor	ebx, ebx
		mov	edx, bassplay
		bt	edx, eax
		jnc	.inobass
		mov	bl, 327/16
		test	al, 16
		jz	.ihighbass
		mov	bl, 260/16
	.ihighbass:
	.inobass:
		call	intplay
		inc	eax
		loop	.ibassmelody

	mov	[esp], edi
	popad
	loop	.imusicgen


	mov	eax,4
	mov	ebx,1
	mov	ecx, music
	mov	edx, MS
	int	128

	xor	eax, eax
	inc	eax
	mov	ebx, 15
	int	128
	int	0
