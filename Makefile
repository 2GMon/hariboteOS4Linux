SRC = ipl.nas
IMG = os.img
IPL = ipl.bin
LST = ipl.list

all: ipl.nas
	make $(IPL)
	make $(IMG)
	make run

$(IPL): $(SRC)
	nasm $(SRC) -o $(IPL) -l $(LST)

$(IMG): $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG)

run: $(IMG)
	qemu-system-x86_64 -fda $(IMG)

clean: $(IMG) $(IPL) $(LST)
	rm $(IMG) $(IPL) $(LST)
