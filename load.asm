BITS 32
extern	dlopen,dlsym
extern	introloop,genmusic
global	_start
global	GetTicks,PollEvent,SwapBuffers
global	Vertex2i,Begin,End,Color
global	music

%macro EXIT 0
	call	[Quit]
	xor	eax,eax
	inc	eax
	int	128
	int	0
%endmacro

section .text
_start:
	call	genmusic

	xor	ebp,ebp
	inc	ebp
	; assumes df=0 ; cld
	mov	esi,sdlfuncs
	mov	edi,sdlptrs
.loadloop:
	mov	eax,[libs+4*ebp]

	push	2	; RTLD_NOW
	push	eax
	call	dlopen
	mov	[esp],eax

	xor	ebx,ebx
	mov	bl,[funcounts+ebp]

.symloop:
	xor	eax,eax
	lodsb
	add	eax,f0
	mov	[esp+4],eax
	call	dlsym
	stosd
	dec	ebx
	jnz	.symloop

	dec	ebp
	jz	.loadloop

	push	2	; SDL_OPENGL
	push	0
	push	600
	push	800
	call	[SetVideoMode]
	push	ebx ; 0
	call	[ShowCursor]
	push	aspec
	call	[OpenAudio]
	push	ebx ; 0
	call	[PauseAudio]

	push	8b30h ; GL_FRAGMENT_SHADER
	call	[CreateShader]
	push	ebx ; 0
	push	fshaderptr
	push	1
	push	eax
	mov	ebx,eax
	call	[ShaderSource]
	call	[CompileShader]
	call	[CreateProgram]
	push	ebx
	push	eax
	call	[AttachShader]
	call	[LinkProgram]
	call	[UseProgram]

	call	introloop

;	call	[Quit]
	EXIT

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

sdlfuncs:	db	S_SetVideoMode-f0,S_GetTicks-f0,S_PollEvent-f0,S_Swap-f0,S_ShowCursor-f0,S_OpenAudio-f0,S_PauseAudio-f0,S_Quit-f0
glfuncs:	db	gVertex2i-f0,gBegin-f0,gEnd-f0,gCreateShader-f0,gShaderSource-f0,gCompileShader-f0,gCreateProgram-f0,gAttachShader-f0,gLinkProgram-f0,gUseProgram-f0,gColor-f0,gGetError-f0
funcounts:	db	(funcounts-glfuncs),(glfuncs-sdlfuncs)

f0:
S_SetVideoMode:	db	"SDL_SetVideoMode",0
S_GetTicks:	db	"SDL_GetTicks",0
S_PollEvent:	db	"SDL_PollEvent",0
S_Swap:	db	"SDL_GL_SwapBuffers",0
S_ShowCursor:	db	"SDL_ShowCursor",0
S_OpenAudio:	db	"SDL_OpenAudio",0
S_PauseAudio:	db	"SDL_PauseAudio",0
S_Quit:	db	"SDL_Quit",0

gVertex2i:	db	"glVertex2i",0
gBegin:	db	"glBegin",0
gEnd:	db	"glEnd",0
gCreateShader:	db	"glCreateShader",0
gShaderSource:	db	"glShaderSource",0
gCompileShader:	db	"glCompileShader",0
gCreateProgram:	db	"glCreateProgram",0
gAttachShader:	db	"glAttachShader",0
gLinkProgram:	db	"glLinkProgram",0
gUseProgram:	db	"glUseProgram",0
gColor:	db	"glColor3us",0
gGetError:	db	"glGetError",0

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
Quit:	resd	1

glptrs:
Vertex2i:	resd	1
Begin:	resd	1
End:	resd	1
CreateShader	resd 1
ShaderSource	resd 1
CompileShader	resd 1
CreateProgram	resd 1
AttachShader	resd 1
LinkProgram	resd 1
UseProgram	resd 1
Color	resd 1
GetError:	resd 1


music:	resw	(44100*10)
musicpos:	resd	1
