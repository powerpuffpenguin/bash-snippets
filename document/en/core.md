[api](README.md)

[中文](../zh/core.md)

# core

Core code that affects programming style

```
source dst/core.sh
```

- [core_panic](#core_panic)
- [core_call](#core_call)
- [core_call_default](#core_call_default)
- [core_call_assert](#core_call_assert)

# core_panic

```
function core_panic(...msg)
```

core_panic causes a panic, it first prints msg in stdout, then prints the call
stack, and finally calls `exit 1` to exit the bash script

It is recommended to call it when an error occurs in the script and needs to
exit. The call stack information it provides is very helpful for debugging
errors

# core_call

```
# -f name args...
# ?-a # assert not error, if any error exit bash
# ?-t # trace on error
# ?-c # output caller on trace
# ?-v varname # result var name
# ?-e varname # result_errno var name
function core_call(...)
```

core_call
使用方式比較特殊，它用於代理請求命令，與直接訪問命令比起來的好處時，它可以提供一些自動化的處理

- `-f name args...` name specifies the command to access, and args specifies the
  arguments passed to the command
- `-a` If the optional a flag is specified, the command will automatically exit
  the script on error `exit $?`
- `-t` If the optional t flag is specified, the command will automatically print
  the error to stdout after an error `echo "Error: $? $result_errno"`
- `-c` If the optional t flag and c flag are specified, the command will
  automatically print the call stack information after an error
- `-v varname` If -v is specified, set the return value $result to the variable
  specified by varname
- `-e varname` If -e is specified, set the error description $result_errno to
  varname on error specified variable

```
core_call -f echo ok

# Automatically exit bash after outputting error and stack
core_call -atcf echo1 ok

echo never
```

# core_call_default

```
function core_call_default(f: string, ...args)
```

`core_call -tcf "$@"` 的語法糖

# core_call_assert

```
function core_call_assert(f: string, ...args)
```

`core_call -atcf "$@"` 的語法糖
