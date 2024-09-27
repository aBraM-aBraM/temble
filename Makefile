
all: temble.S
	gcc -m32 -no-pie -o temble temble.S 
clean:
	rm temble
