AOBJ=load.o synth.o
COBJ=
OBJ=$(AOBJ) $(COBJ)
#OBJ=$(AOBJ)
#CFLAGS=-Wall -m32 -Os -fomit-frame-pointer -flto -ffast-math
CFLAGS=-Wall -m32 -O1 -fomit-frame-pointer -ffast-math

all: packed editor soft-packed play notes

intro: intro.asm t.frag.small
	nasm -f bin $< -o $@
	chmod +x $@
	du -b $@

soft: soft.asm
	nasm -f bin $< -o $@
	chmod +x $@
	du -b $@

#intro: $(OBJ)
#	ld $(OBJ) -o $@ -dynamic-linker /lib/ld-linux.so.2 /usr/lib32/libdl.so -melf_i386 -s
#	strip -s -R .comment -R .gnu.version $@
#	sstrip -z $@
#	du -b $@

packed: intro unpack.header
#	gzip -n --best -f -c $< > $<.gz
	7z a -tGZip -mx=9 $<.gz $<
	cat unpack.header $<.gz > $@
	rm $<.gz
	chmod a+rx $@
	du -b $@

soft-packed: soft unpack.header
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

#t.frag.small: t.frag cshader
t.frag.small: march.frag cshader
	./cshader < $< > $@

cshader: %: %.cpp
	g++ $< -o $@ -Wall -O2

editor: %: %.cpp
	g++ $< -o $@ `sdl-config --cflags --libs` -lGL -lGLU -Wall -O2

play: synth.o play.c
	gcc $^ -Wall -O2 -o $@ `sdl-config --cflags` -lSDL -m32

notes: notes.cpp
	g++ $^ -Wall -O2 -o $@

clean:
	rm -f packed editor intro t.frag.small cshader $(AOBJ) play soft-packed
