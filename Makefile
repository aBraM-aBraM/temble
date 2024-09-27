
all: temble.S
	gcc -m32 -no-pie -o temble temble.S linked_list.S
clean:
	rm temble
