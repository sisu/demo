#AOBJ=load.o
#COBJ=draw.o synth.o
AOBJ=load.o draw.o
COBJ=synth.o
OBJ=$(AOBJ) $(COBJ)
#OBJ=$(AOBJ)
#CFLAGS=-Wall -m32 -Os -fomit-frame-pointer -flto -ffast-math
CFLAGS=-Wall -m32 -O1 -fomit-frame-pointer -ffast-math

all: packed

intro: $(OBJ)
#	gcc $(OBJ) -o $@ -nostdlib -s $(CFLAGS) -ldl -fwhole-program -fuse-linker-plugin
#	ld $(OBJ) -o $@ -ldl --oformat=elf32-i386
#	ld $(OBJ) -o $@ -ldl -melf_i386 -s
#	ld $(OBJ) -o $@ -dynamic-linker /lib/ld-linux.so.2 /usr/lib32/libSDL.so /usr/lib32/libGL.so -melf_i386 -s
	ld $(OBJ) -o $@ -dynamic-linker /lib/ld-linux.so.2 /usr/lib32/libdl.so -melf_i386 -s
	strip -s -R .comment -R .gnu.version $@
	sstrip -z $@
	du -b $@

packed: intro
#	gzip -n --best -f -c $< > $<.gz
	7z a -tGZip -mx=9 $<.gz $<
	cat unpack.header $<.gz > $@
	rm $<.gz
	chmod a+rx $@
	du -b $@

$(AOBJ): %.o: %.asm
	nasm -f elf $< -o $@

load.o:	t.frag.small

$(COBJ): %.o: %.c load.h
	gcc $< -c -o $@ $(CFLAGS) `sdl-config --cflags`

t.frag.small: t.frag cshader
	./cshader < $< > $@

cshader: %: %.cpp
	g++ $< -o $@ -Wall -O2
