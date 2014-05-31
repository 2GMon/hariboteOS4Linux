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

$(FNC).bin: $(FNC).nas
	nasm $(FNC).nas -f elf32 -o $(FNC).bin -l $(FNC).list

$(PCK).bin: $(PCK).c $(FNC).bin
	gcc $(PCK).c -nostdlib -m32 -Wl,--oformat=binary -c -o $(PCK).o
	ld -T harimain.ls -m elf_i386 -o $(PCK).bin --oformat=binary $(PCK).o $(FNC).bin

$(BIN).bin: $(BIN).nas $(PCK).bin
	echo "$^"
	nasm $(BIN).nas -o $(BIN)_tmp.bin
	cat $(BIN)_tmp.bin $(PCK).bin > $(BIN).bin

$(IMG): $(IPL) $(BIN).bin $(PCK).bin
	mformat -f 1440 -C -B $(IPL) -i $(IMG)
	mcopy $(BIN).bin -i $(IMG) ::

run: $(IMG)
	qemu-system-x86_64 -fda $(IMG)

clean:
	rm *.o *.bin $(IMG) *.list
