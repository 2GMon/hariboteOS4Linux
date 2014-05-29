SRC = helloos.nas
TARGET = helloos.img

all: run

run: $(TARGET)
	qemu-system-x86_64 $(TARGET)

$(TARGET): $(SRC)
	nasm $(SRC) -o $(TARGET)

clean: $(TARGET)
	rm $(TARGET)
