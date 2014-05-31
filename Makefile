SRC = ipl10.nas
IMG = os.img
IPL = ipl.bin
LST = ipl.list
BIN = haribote

all: $(SRC)
	make $(IPL)
	make $(IMG)
	make run

$(IPL): $(SRC)
	nasm $(SRC) -o $(IPL) -l $(LST)

$(BIN).bin: $(BIN).nas
	nasm $(BIN).nas -o $(BIN).bin

$(IMG): $(IPL) $(BIN).bin
	mformat -f 1440 -C -B $(IPL) -i $(IMG)
	mcopy $(BIN).bin -i $(IMG) ::

run: $(IMG)
	qemu-system-x86_64 -fda $(IMG)

clean: $(IMG) $(IPL) $(LST) $(BIN).bin
	rm $(IMG) $(IPL) $(LST) $(BIN).bin
