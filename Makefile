all: main.o boot.o
	cat build/boot > build/snake.flp
	cat build/main >> build/snake.flp

main.o: src/main.asm
	nasm src/main.asm -o build/main	

boot.o: src/boot.asm
	nasm src/boot.asm -o build/boot 

Phony: clean
clean:
	rm build/*