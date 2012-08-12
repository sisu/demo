BITS 32
extern	PollEvent,SwapBuffers,GetTicks
extern	Recti,Color
global	introloop

section .text
introloop:
	call	[GetTicks]
	push	eax
	call	[Color]

	push	-1
	push	-1
	push	1
	push	1
	call	[Recti]
	call	[SwapBuffers]

	push	event
	call	[PollEvent]

	add	esp,4+4*4+4
	cmp	byte	[event],2
	jne	introloop
	int	0

section .data

section .bss
event:	resd	1000

; x = 0,1,1,0
; y = 0,0,1,1
; y,x = 0,0,1,1,0
