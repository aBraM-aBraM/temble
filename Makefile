
all: temble.S
	gcc -m32 -static -o temble temble.S lexer.S
clean:
	rm temble