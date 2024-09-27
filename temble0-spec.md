# temble0 specifications

only one file, code only knows what is defined above it and builtins

tokens:

`#` - comment until end of line
`func` - function definition
`(` - func-params
`)` - func-params
`,` - func params separator
`return` - return value from function
`str` - str type
`int` - int type
`while <int>` - while loop
`if` - branch
`printf` - calls saved printf function to bound libc printf
`:` - scope opener
`\t` - scope counter (function/branch/loop)
`SYMBOL` - used to give function/variables names
`+`,`-`,`*`,`/` - binary-operators
`=` - assignment operator
`<`, `>`, `==` - condition operators
`asm` - inline assembly scope

example:

```python
func add_twice(first: int, second: int) int:
    sum: int = first
    i: int = 0
    while i < 2 {
        sum += second
        i = i + 1;
    }
    return sum

func crash(value: int) int:
    # write value to memory address 0 causing a segfault
    asm:
        pop %ebx # pops value into ebx
        mov $0, %eax
        mov %ebx, (%eax)

func main() int:
    result: int = add_twice(1,2)

    if result > 1:
        msg: str = "Big result %d\n"
        printf(msg, result)
        return 1

    if result < 1 :
        msg: str = "Small result %d\n"
        printf(msg, result)
        return 1
    
    if result == 1 
        msg: str = "Result is one\n"
        printf(msg)
    

    return 0
```

## Compiler Design

* Lexer finds all tokens. Size is unknown upon start thus must be a linked list
* Parses validates tokens' order must make sense (this is a list of what is expected to follow what)
    * empty/`\t` 
        * `func` - func define
            * `SYMBOL` - func name
                * `(` - func params start (params are optional)
                    * `var-define`
                        * `,`
                        * `)`
                            * `type` - return type
                                * `:` - func content scope [X]
        * `SYMBOL: (str/int)` - var-define / assignment
            * `=`
                * `SYMBOL` / int literal - other variable
                    * binary operator
                        * `SYMBOL` / int literal [X]
        * `if` - branch
            * `SYMBOL` (int) / condition operator
                * `:` - branch content scope [X]
        * `return` - return value of current function
            * `SYMBOL`  / literal 
        * `while` - loop
            * `SYMBOL` (int) / condition operator
                * `:` - loop content scope
        * `asm` - start inline assembly
            * `:` - inline asm content code [X]
        * `ASM_CONTENT` - inline assembly content in inline assembly scope
* Symbol Table Construction - while checking parser creates a map between symbol names to line numbers (linked list of pointer:int)
* Code Generation