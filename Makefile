SRC = ipl10.nas
IMG = os.img
IPL = ipl.bin
LST = ipl.list
BIN = asmhead
PCK = bootpack
FNC = func

all: $(IMG)
	make run

$(IPL): $(SRC)
	nasm $(SRC) -o $(IPL) -l $(LST)

$(FNC).o: $(FNC).nas
	nasm $(FNC).nas -f elf32 -o $(FNC).o -l $(FNC).list

$(PCK).bin: $(PCK).c $(FNC).o
	gcc $(PCK).c -nostdlib -m32 -Wl,--oformat=binary -c -o $(PCK).o
	ld -T harimain.ls -m elf_i386 -o $(PCK).bin --oformat=binary $(PCK).o $(FNC).o

$(BIN).bin: $(BIN).nas $(PCK).bin
	echo "$^"
	nasm $(BIN).nas -o $(BIN).bin
	cat $(BIN).bin $(PCK).bin > os.bin

$(IMG): $(IPL) $(BIN).bin $(PCK).bin
	mformat -f 1440 -C -B $(IPL) -i $(IMG)
	mcopy os.bin -i $(IMG) ::

run: $(IMG)
	qemu-system-x86_64 -fda $(IMG)

clean:
	rm *.o *.bin $(IMG) *.list
