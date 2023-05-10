[中文](README.zh.md)

# bash-snippets

Here's some reusable bash code and tools I've written with the primary goal of
simplicity and ease of use.

If not specified otherwise, download the individual files and they will work
without any additional dependencies.

```
source dst/strings.sh

if strings_end_with "$s" "$end";then
    echo "yes, '$s' end with '$end'"
fi
```

- [layout](#layout)
- [result](#result)
- [declaration](#declaration)
- [test.sh](#test)
- [api](document/en/README.md)

# layout

- **dst** This folder contains all reusable code repositories
- **example** This folder contains some usage examples
- **src** Some code generated from source in src
- **generate.sh** Executing this script regenerates the archive created by the
  code
- **test.sh** A bash unit testing tool

# result

The bash function cannot return anything other than an integer. The solution is
to use a global variable to return, or use echo return string. This library uses
global variables to return content for functions (echo cannot return an array,
and it is difficult to return the error reason when the function fails).

1. If an error occurs in the function, the description string of the error will
   be set to the variable `result_errno=...`, after which the function returns
   an error code `return errno`
2. If the function has a return value, set the return content to the variable
   `result=...`

```
# return value
if ! get_value; then
  echo "errno: $?"
  exit 1
fi
echo "value=$result"


# return array
if ! get_array; then
  echo "errno: $?"
  exit 1
fi
i=0
for val in "${result[@]}";do
    echo "value[$i] = $val"
    i=$((i+1))
done
```

# declaration

A good function declaration tells humans how it should be used and what it will
return. I provides functions declarations like 'typescript' format.
Understanding how to understand the declaration is the most concise and fast way
to master the use of functions, Here are some examples:

```
function strings_split(s: string, separators: string): []string
```

> The strings_split function accepts two positional parameters, a string 's' and
> 'separators', and the function returns a string array after separating 's'.

```
(separator: string, ...s: []string): string
```

> The above declaration omits the function name, which is usually written above
> the function in the source code, because the name already exists in the source
> code. In addition... s means variable length parameter.

```
(): errno
```

> The errno return value indicates that this function is a discriminant, usually
> only for use with if, it has no return content

```
() (id: number, errno)
```

> The above function returns a number to the result variable, and because of the
> existence of errno, this function may have an error `return errno`

```
(): panic
() (id: number, panic)
```

> panic means that when the function fails, bash will be automatically terminated, and the call stack and available error messages will be printed


# test

Only tested code should be used with confidence, especially bash Scripts are
often used for system administration and can cause system crashes directly if
not tested.

test.sh is a unit test tool I wrote for bash, it found in the source code
starting with test_ prefix the function and execute, at the same time, some
test-related information can be printed. There are many files suffixed with
_test.sh under the dst folder, you can refer to them to write unit test code,
[dst/assert.sh](document/en/assert.md) some functions are provided to simplify
the test code.

View instructions for use:

```
./test.sh -h
```

Test specified file:

```
./test.sh dst/strings_test.sh dst/path_test.sh
```

Test all files (*_test.sh) under the specified folder:

```
./test.sh
./test.sh -d dst
```
