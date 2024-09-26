
all: temble.S
	gcc -m32 -static -o temble temble.S
clean:
	rm temble