
all: temble.S
	gcc -m32 -masm=intel -o temble temble.S
clean:
	rm temble