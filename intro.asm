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
;	dd	10,strtab_size
;	dd	11,symtab_size
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

sdllib:	db	"libSDL-1.2.so.0",0
gllib:	db	"libGL.so",0
;libs:	dd	gllib,sdllib


;inotes:	dw	490, 327, 367, 245
inotes:	db	490/2, 327/2, 367/2, 245/2

notetime	equ	4410*2

bp0	equ	(1|8|16)
bassplay	equ	bp0 | (bp0<<8) | (bp0<<16) | (bp0<<24)

curmusic:	dd music


intplay:	; eax: start, ebx: freqptr
	pushad
	mov	ecx, notetime
	imul	eax, ecx
	mov	edi, [curmusic]
	add	edi, eax
	add	edi, eax

	xor	edx, edx
	imul	ebx, [ifreqmod]
	shr	ebx, 16
	xor	edx, edx
	.samples:
		; edx: wave, esi: vol
		add	edx, ebx
		mov	eax, edx
		and	eax, 0xffff
		imul	eax, ecx
		shr	eax, 16
		add	ax, [edi]
		stosw
		loop	.samples
	popad
	ret

musiciters	equ	8
_start:
	mov	ecx, musiciters
.imusicgen:
	pushad
	mov	dword [ifreqmod], 4<<16
	test	cl, 1
	jz	.ihighround
	mov	dword [ifreqmod], 116771*2
.ihighround:
	mov	cl, 32
	.ihighmelody:
		mov	eax, ecx
		dec	eax
		mov	ebx, eax
		and	bl, 3
		mov	bl, [inotes+ebx]
		call	intplay
		loop	.ihighmelody

	mov	cl, 11
	.ilowmelody:
		mov	eax, ecx
		dec	eax
		mov	ebx, eax
		and	bl, 3
		mov	bl, [inotes+ebx]
		shr	ebx, 1
		imul	eax, 3
		call	intplay
		loop	.ilowmelody

	mov	cl, 32
	.ibassmelody:
		mov	eax, ecx
		dec	eax
		mov	edx, bassplay
		bt	edx, eax
		jnc	.inobass
		mov	bl, 327/8
		test	al, 16
		jz	.ihighbass
		mov	bl, 260/8
	.ihighbass:
		call	intplay
	.inobass:
		loop	.ibassmelody

	add	dword [curmusic], 2*32*notetime
	popad
	loop	.imusicgen


; load sdl and opengl
	xor	ebp,ebp
	inc	ebp
	; assumes df=0 ; cld
	mov	edi,sdlptrs
	push	2
	push	sdllib
.loadloop:
;	mov	eax,[libs+4*ebp]

;	push	2	; RTLD_NOW
;	push	eax
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

	push	2
	push	gllib
	dec	ebp
	jz	.loadloop

	; for smaller addressing
	mov	ebp,sdlptrs


; initialize opengl
	push	2	; SDL_OPENGL
	push	0
	push	600
	push	800
	call	F(SetVideoMode)
	push	0
	call	F(ShowCursor)
	push	aspec
	call	F(OpenAudio)
	push	0
	call	F(PauseAudio)

	push	8b30h ; GL_FRAGMENT_SHADER
	call	F(CreateShader)
	push	0
	push	fshaderptr
	push	1
	push	eax
	mov	ebx,eax
	call	F(ShaderSource)
	call	F(CompileShader)
	call	F(CreateProgram)
	; nvidia glCompileShader overwrites shader param
	push	ebx
	push	eax
	call	F(AttachShader)
	call	F(LinkProgram)
	call	F(UseProgram)

	; main loop
introloop:
	call	F(GetTicks)
;endtime	equ	1000*60
;	cmp	eax, endtime
;	jg	end
	push	eax
	call	F(Color)

	push	-1
	push	-1
	push	1
	push	1
	call	F(Recti)
	call	F(SwapBuffers)

	push	event
	call	F(PollEvent)

	add	esp,6*4
;	times	6	pop	eax
	cmp	byte	[event],2
	jne	introloop
;end:
;	int	0

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
aspec:	dd	44100 ; freq
;aspec:	dd	8000 ; freq
	dw	8010h ; AUDIO_S16
	db	1 ; channels
	db	0 ; silence
	dw	1024 ; samples
	dw	0 ; padding
	dd	0 ; size
	dd	playmusic
;	dd	music ; not used

f0:
S_SetVideoMode:	db	"SDL_SetVideoMode",0
S_GetTicks:	db	"SDL_GetTicks",0
S_PollEvent:	db	"SDL_PollEvent",0
S_Swap:	db	"SDL_GL_SwapBuffers",0
S_ShowCursor:	db	"SDL_ShowCursor",0
S_OpenAudio:	db	"SDL_OpenAudio",0
S_PauseAudio:	db	"SDL_PauseAudio",0
;S_Quit:	db	"SDL_Quit",0

gRecti:	db	"glRecti",0
gCreateShader:	db	"glCreateShader",0
gShaderSource:	db	"glShaderSource",0
gCompileShader:	db	"glCompileShader",0
gCreateProgram:	db	"glCreateProgram",0
gAttachShader:	db	"glAttachShader",0
gLinkProgram:	db	"glLinkProgram",0
gUseProgram:	db	"glUseProgram",0
gColor:	db	"glColor3us",0
;gGetError:	db	"glGetError",0

endstrs:

;fshader:	db	"void main(){gl_FragColor=vec4(1,0,0,1);}",0
fshader:	incbin	"t.frag.small"
		db 0
fshaderptr:	dd	fshader

filesize	equ	$ - $$

; section .bss
ABSOLUTE $

;dlopen	resd	1
;dlsym	resd	1

sdlptrs:
SetVideoMode:	resd	1
GetTicks:	resd	1
PollEvent:	resd	1
SwapBuffers:	resd	1
ShowCursor:	resd	1
OpenAudio:	resd	1
PauseAudio:	resd	1
;Quit:	resd	1

glptrs:
Recti:	resd	1
CreateShader	resd 1
ShaderSource	resd 1
CompileShader	resd 1
CreateProgram	resd 1
AttachShader	resd 1
LinkProgram	resd 1
UseProgram	resd 1
Color	resd 1
;GetError:	resd 1


MS	equ	32*musiciters*notetime
musicpos:	resd	1

ifreqmod:	resd	1

event:	resb	1000

music:	resw	MS

memsize	equ	$ - $$
