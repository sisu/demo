#!/bin/bash
rm -rf out
mkdir -p out
for t in fullscreen window; do
	for r in "800 600" "1024 768" "1280 720" "1280 800"; do
		read x y <<< $r
		./cshader WIDTH $x HEIGHT $y < march.frag > t.frag.small
		if [ $t == fullscreen ]; then f=0x80000000; else f=0; fi
		nasm -f bin intro.asm -o t -dWIDTH=$x -dHEIGHT=$y -dFULLSCREEN=$f
		7z a -tGZip -mx=9 t.gz t
		p="out/intro_${x}x${y}_${t}"
		cat unpack.header t.gz > $p
		rm t t.gz
		chmod a+rx $p
	done
done
ls -l out
