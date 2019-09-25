all: main.o boot.o
	cat build/boot.bin > build/snake.bin
	cat build/main.bin >> build/snake.bin

main.o: src/main.asm
	nasm src/main.asm -o build/main.bin

boot.o: src/boot.asm
	nasm src/boot.asm -o build/boot.bin

Phony: clean
clean:
	rm build/*