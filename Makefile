
all: temble.S
	gcc -Wl,-z noexecstack -m32 -no-pie -o temble temble.S linked_list.S lexer.S
test: test/*
	gcc -Wl,-z noexecstack -m32 -no-pie -o test_linked_list test/test_linked_list.S linked_list.S
clean:
	rm temble
