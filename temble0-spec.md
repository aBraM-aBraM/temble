# temble0 specifications

only one file

lexer (tokens)

tokens:

`func` - function definition
`return` - return value from function
`str` - str type
`int` - int type
`while <int>` - while loop
`if` - branch
`printf` - calls saved printf function to bound libc printf
`:` - scope opener
`\t` - scope counter (function/branch/loop)

example:

```python
func add_twice(first: int, second: int) -> int:
    sum: int = first
    for i: int = 0..2 {
        sum += second
    }
    return sum

func main() -> int:
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
