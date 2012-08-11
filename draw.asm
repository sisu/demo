BITS 32
extern	PollEvent,SwapBuffers,GetTicks
extern	Begin,End,Vertex2i,Color
global	introloop

section .text
introloop:
	call	[GetTicks]
	push	eax
	call	[Color]

	push	6	; GL_TRIANGLE_FAN
	call	[Begin]

	mov	esi,xcoord
	push	-1
	mov	ebx,4
.drawloop:
	lodsb
	cbw
	cwde
	push	eax
	call	[Vertex2i]
	dec	ebx
	jnz	.drawloop

;	mov	ebx,-1
;	xor	esi,esi
;	inc	esi
;	push	ebx
;	push	ebx
;	call	[Vertex2i]
;	push	esi
;	call	[Vertex2i]
;	push	esi
;	call	[Vertex2i]
;	push	ebx
;	call	[Vertex2i]

;	push	-1
;	mov	esi,xcoord
;	lodsb
;	cbw
;	cwde
;	push	eax
;	call	[Vertex2i]
;	lodsb
;	cbw
;	cwde
;	push	eax
;	call	[Vertex2i]
;	lodsb
;	cbw
;	cwde
;	push	eax
;	call	[Vertex2i]
;	lodsb
;	cbw
;	cwde
;	push	eax
;	call	[Vertex2i]

	call	[End]
	call	[SwapBuffers]

	push	event
	call	[PollEvent]

	add	esp,4+4+4+4*4+4
	cmp	byte	[event],2
	jne	introloop
	int	0

section .data
;ycoord:	db	-1
xcoord:	db	-1,1,1,-1

section .bss
event:	resd	1000

; x = 0,1,1,0
; y = 0,0,1,1
; y,x = 0,0,1,1,0
