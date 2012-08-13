BITS 32
extern	dlopen,dlsym
extern	genmusic
global	_start
global	GetTicks,PollEvent,SwapBuffers
global	Recti,Color
global	music

%define F(f) [ebp + (f-sdlptrs)]

%macro EXIT 0
	call	[Quit]
	xor	eax,eax
	inc	eax
	int	128
	int	0
%endmacro

section .text
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


; load sdl and opengl
	xor	ebp,ebp
	inc	ebp
	; assumes df=0 ; cld
	mov	edi,sdlptrs
.loadloop:
	mov	eax,[libs+4*ebp]

	push	2	; RTLD_NOW
	push	eax
	call	dlopen
	push	eax

	mov	esi,f0
.symloop:
	mov	[esp+4],esi
	inc	esi
	call	dlsym
	test	eax,eax
	jz	.notfound
	stosd
.notfound:
	cmp	esi,endstrs
	jne	.symloop

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
	xor	ebx,ebx
	push	ebx ; 0
	call	F(ShowCursor)
	push	aspec
	call	F(OpenAudio)
	push	ebx ; 0
	call	F(PauseAudio)

	push	8b30h ; GL_FRAGMENT_SHADER
	call	F(CreateShader)
	push	ebx ; 0
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

;	add	esp,4+4*4+4
	times	6	pop	eax
	cmp	byte	[event],2
	jne	introloop
	int	0

playmusic:
	mov	edi,[esp+8]
	mov	ecx,[esp+12]
	mov	esi,music
	add	esi,[musicpos]
	add	[musicpos],ecx
	rep	movsb
;introloop:
;genmusic:
	ret

section .data
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
gllib:	db	"libGL.so",0
libs:	dd	gllib,sdllib

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

section .bss

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


MS	equ	44100*10
music:	resw	MS
musicpos:	resd	1

event:	resb	1000
