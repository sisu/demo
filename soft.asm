BITS 32

org 0x40000

ehdr:
	db	0x7F, "ELF", 1, 1, 1, 0 ; e_ident
	times	8 db 0
	dw	2 ; e_type
	dw	3 ; e_machine
	dd	1 ; e_version
	dd	_start ; e_entry
	dd	phdr - $$ ; e_phoff
	dd	0 ; e_shoff
	dd	0 ; e_flags
	dw	ehdrsize ; e_ehsize
	dw	phdrsize ; e_phentsize
	dw	3 ; e_phnum
;	dw	0 ; e_shentsize
;	dw	0 ; e_shnum
;	dw	0 ; e_shstrndx

ehdrsize	equ	$ - ehdr + 6

phdr: ; Elf32_Phdr
	dd	1 ; p_type = PT_LOAD
	dd	0 ; p_offset
	dd	$$ ; p_vaddr
	dd	$$ ; p_paddr
	dd	filesize ; p_filesz
	dd	memsize ; p_memsz
	dd	7 ; p_flags
	dd	0x1000 ; p_align
	phdrsize	equ	$ - phdr

	dd	2	; PT_DYNAMIC
	dd	dynamic - $$
	dd	dynamic
	dd	dynamic
	dd	dynamic_size
	dd	dynamic_size
	dd	6 ; RW
	dd	4

	dd	3	; PT_INTERP
	dd	interp - $$
	dd	interp
	dd	interp
	dd	interp_size
	dd	interp_size
	dd	4
;	dd	1

dynamic:
	dd	1,libdl_name
;	dd	4,hash
	dd	5,strtab
	dd	6,symtab
	dd	10,strtab_size
	dd	11,symtab_size
	dd	17,reltext
	dd	18,reltext_size
	dd	19,8
;	dd	0,0

symtab:
	dd	0,0
dynamic_size	equ	$ - dynamic
	dd	0
	dw	0,0
	dd	dlopen_name,0,0
	dw	0x12,0
	dd	dlsym_name,0,0
	dw	0x12,0
symtab_size	equ	$ - symtab

;hash:	dd	1,3,0,0,0,0

reltext:
	dd	dlopen
	db	1,1,0,0
	dd	dlsym
	db	1,2,0,0
reltext_size	equ	$ - reltext

interp:	db	'/lib/ld-linux.so.2',0
interp_size	equ	$ - interp

strtab:
	libdl_name	equ	$ - strtab
	db	'libdl.so.2',0
	dlopen_name	equ	$ - strtab
	db	'dlopen',0
	dlsym_name	equ	$ - strtab
	db	'dlsym',0
strtab_size	equ	$ - strtab


%define F(f) [ebp + (f-sdlptrs)]

%macro EXIT 0
	xor	eax,eax
	inc	eax
	int	128
	int	0
%endmacro

_start:
; generate music
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
	cmp	ecx,MS
	jl	.genloop

; load sdl
	; assumes df=0 ; cld
	mov	edi,sdlptrs
	; for smaller addressing
	mov	ebp,edi

	push	2	; RTLD_NOW
	push	sdllib
dlopen	equ	$+1
	call	0
;	call	[dlopen]
	push	eax

	mov	esi,f0
.symloop:
	mov	[esp+4],esi
	inc	esi
dlsym	equ	$+1
	call	0
;	call	[dlsym]
	test	eax,eax
	jz	.notfound
	stosd
.notfound:
	cmp	esi,endstrs
	jne	.symloop


; initialize opengl
	push	0	; SDL_SWSURFACE
	push	32	; bpp
	push	600
	push	800
	call	F(SetVideoMode)
	mov	ebx, eax
	push	0 ; 0
	call	F(ShowCursor)
	push	aspec
	call	F(OpenAudio)
	push	0 ; 0
	call	F(PauseAudio)

	; main loop
.introloop:
	call	F(GetTicks)
	mov	esi, eax
	mov	ecx, 600
	.drawloop:
		mov	edi, [ebx+20]
		xor	eax,eax
		mov	ax, [ebx+16]
		mov	edx, ecx
		dec	edx
		imul	eax, edx
		add	edi, eax

		mov	edx,800
		.innerdraw:
			mov	eax, ecx
			add	eax, esi
			xor	eax, edx
			stosd
			dec	edx
			jnz	.innerdraw
		loop	.drawloop
	push	ebx
	call	F(Flip)

	push	event
	call	F(PollEvent)

;	add	esp,4+4*4+4
	times	2	pop	eax
	cmp	byte	[event],2
	jne	.introloop
	int	0

playmusic:
	mov	edi,[esp+8]
	mov	ecx,[esp+12]
	mov	esi, musicpos
	add	[esi], ecx
	lodsd
	sub	eax, ecx
	add	esi, eax
	rep	movsb
;introloop:
;genmusic:
	ret

; section .data
;aspec:	dd	44100 ; freq
aspec:	dd	8000 ; freq
	dw	8010h ; AUDIO_S16
        db	1 ; channels
        db	0 ; silence
        dw	1024 ; samples
        dw	0 ; padding
        dd	0 ; size
        dd	playmusic
;        dd	music ; not used

sdllib:	db	"libSDL-1.2.so.0",0

f0:
S_SetVideoMode:	db	"SDL_SetVideoMode",0
S_GetTicks:	db	"SDL_GetTicks",0
S_PollEvent:	db	"SDL_PollEvent",0
S_Flip:	db	"SDL_Flip",0
S_ShowCursor:	db	"SDL_ShowCursor",0
S_OpenAudio:	db	"SDL_OpenAudio",0
S_PauseAudio:	db	"SDL_PauseAudio",0
;S_Quit:	db	"SDL_Quit",0

endstrs:
filesize	equ	$ - $$

; section .bss
ABSOLUTE $

;dlopen	resd	1
;dlsym	resd	1

sdlptrs:
SetVideoMode:	resd	1
GetTicks:	resd	1
PollEvent:	resd	1
Flip:	resd	1
ShowCursor:	resd	1
OpenAudio:	resd	1
PauseAudio:	resd	1
;Quit:	resd	1

MS	equ	44100*10
musicpos:	resd	1
music:	resw	MS

event:	resb	1000

memsize	equ	$ - $$
