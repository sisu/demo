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

ehdrsize	equ	$ - ehdr

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
	dd	4,hash
	dd	5,strtab
	dd	6,symtab
	dd	10,strtab_size
	dd	11,symtab_size
	dd	17,reltext
	dd	18,reltext_size
	dd	19,8
;	dd	0,0
dynamic_size	equ	$ - dynamic

symtab:
	dd	0,0
	dd	0
	dw	0,0
	dd	dlopen_name,0,0
	dw	0x12,0
	dd	dlsym_name,0,0
	dw	0x12,0
symtab_size	equ	$ - symtab

hash:	dd	1,3,0,0,0,0

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


_start:
;	push	1
;	push	0
;	call	[dlopen]
	xor	eax,eax
	inc	eax
	int	128


filesize	equ	$ - $$

ABSOLUTE $

dlopen	resd	1
dlsym	resd	1

memsize	equ	$ - $$
