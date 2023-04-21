[api](README.md)

[English](../en/core.md)

# core

影響編程風格的核心代碼

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

core_panic 引發恐慌，它首先會在 stdout 中打印 msg，之後會打印調用棧，最後調用
`exit 1` 退出 bash 腳本

在腳本出現錯誤需要退出時，推薦調用它，它提供的調用棧信息對調試錯誤很有幫助

# core_call

```
function core_call(...)
```

core_call
使用方式比較特殊，它用於代理請求命令，與直接訪問命令比起來的好處時，它可以提供一些自動化的處理

- `-f name args...` name 指定要訪問的命令，args指定傳遞給命令的參數
- `-a` 如果指定了可選的 a 標記，命令出錯後會自動退出腳本 `exit $?`
- `-t` 如果指定了可選的 t 標記，命令出錯後會自動將錯誤打印到 stdout
  `echo "Error: $? $result_errno"`
- `-c` 如果指定了可選的 t 標記 和 c 標記，命令出錯後會自動打印調用棧信息
- `-v varname` 如果指定了 -v，則將返回值 result 設置到 varname 指定的變量
- `-e varname` 如果指定了 -e，則在出錯時將錯誤描述 result_errno 設置到 varname
  指定的變量

```
# -f name args...
# ?-a # assert not error, if any error exit bash
# ?-t # trace on error
# ?-c # output caller on trace
# ?-v varname # result var name
# ?-e varname # result_errno var name
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
