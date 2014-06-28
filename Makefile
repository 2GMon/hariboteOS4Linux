.SUFFIXES: .nas .o
.SUFFIXES: .c .o
.SUFFIXES: .nas .hrb

LIB = sprintf.o vsprintf.o strtol.o strtoul0.o strtoul.o strlen.o errno.o strcmp.o strncmp.o
APP = a.hrb hello.hrb hello2.hrb hello3.hrb crack1.hrb

.nas.o:
	nasm $< -f elf32 -o $@ -l $(@:.o=.list)

.c.o:
	gcc $< -m32 -c -o $@

.nas.hrb:
	nasm $< -o $@

all: os.img
	make run

ipl.bin: ipl10.nas
	nasm $^ -o $@ -l $(@:.bin=.list)

hankaku.c: hankaku.txt
	ruby makefont.rb $^ $@

asmhead.bin: asmhead.nas
	nasm $^ -o $@

bootpack.bin: bootpack.o func.o hankaku.o dsctbl.o graphic.o int.o fifo.o keyboard.o mouse.o memory.o sheet.o timer.o mtask.o window.o console.o file.o $(LIB)
	ld -T harimain.ls -m elf_i386 -o $@ $^

os.bin: asmhead.bin bootpack.bin
	cat $^ > $@

a.hrb: a.o a_nas.o
	ld -T app.ls -m elf_i386 -o $@ $^

hello3.hrb: hello3.o a_nas.o
	ld -T app.ls -m elf_i386 -o $@ $^

crack1.hrb: crack1.o
	ld -T app.ls -m elf_i386 -o $@ $^

os.img: ipl.bin os.bin bootpack.bin $(APP)
	mformat -f 1440 -C -B ipl.bin -i $@
	mcopy os.bin -i $@ ::
	mcopy bootpack.bin -i $@ ::
	mcopy $(APP) -i $@ ::

run: os.img
	qemu-system-x86_64 -fda os.img

clean:
	rm *.o *.bin os.img *.list *.hrb hankaku.c
