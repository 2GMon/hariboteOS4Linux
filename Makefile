.SUFFIXES: .nas .o
.SUFFIXES: .c .o

.nas.o:
	nasm $< -f elf32 -o $@ -l $(@:.o=.list)

.c.o:
	gcc $< -m32 -c -o $@

all: os.img
	make run

ipl.bin: ipl10.nas
	nasm $^ -o $@ -l $(@:.bin=.list)

hankaku.c: hankaku.txt
	ruby makefont.rb $^ $@

asmhead.bin: asmhead.nas
	nasm $^ -o $@

bootpack.bin: bootpack.o func.o hankaku.o dsctbl.o graphic.o
	ld -T harimain.ls -m elf_i386 -o $@ $^

os.bin: asmhead.bin bootpack.bin
	cat $^ > $@

os.img: ipl.bin os.bin
	mformat -f 1440 -C -B ipl.bin -i $@
	mcopy os.bin -i $@ ::

run: os.img
	qemu-system-x86_64 -fda os.img

clean:
	rm *.o *.bin os.img *.list hankaku.c
