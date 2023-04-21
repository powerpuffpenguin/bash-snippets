[api](README.md)

[English](../en/path.md)

# path

path 提供了一些常用的字符串处理函数

```
source dst/path.sh
```

- [path_split_name](#path_split_name)
- [path_name](#path_name)
- [path_ext](#path_ext)
- [path_clean](#path_clean)
- [path_split](#path_split)
- [path_dir](#path_dir)
- [path_base](#path_base)
- [path_is_abs](#path_is_abs)
- [path_join](#path_join)

由 [golang](https://pkg.go.dev/path)
標準庫移植而來，只進行了語法分析，不會真實訪問檔案系統，也無法處理 windows
的路徑

# path_split_name

```
function path_split_name(filepath: string) (name: string, ext: string)
```

將 filepath 分割，分別返回不帶擴展名的路徑和擴展名

# path_name

```
function path_name(filepath: string): string
```

返回 filepath 去除擴展名後的路徑

# path_ext

```
function path_ext(filepath: string): string
```

返回 filepath 的擴展名

# [path_clean](https://pkg.go.dev/path#Clean)

```
function path_clean(path: string): string
```

Clean 通过纯词法处理返回相当于 path 的最短路径名。
它迭代地应用以下规则，直到无法进行进一步处理：

1. 使用單個 / 替換多個連續的 /
2. 消除每個 . 元素(. 表示當前檔案夾)
3. 消除內部的 .. 元素(.. 表示父檔案夾)以及 .. 前面的非 .. 元素
4. 消除以 / 開頭的 .. 元素: 將 '/..' 替換爲 '/'

只有當路徑是 '/' 時才會返回以 '/' 結尾的路徑

如果最終結果是空字符串，將會返回 '.' 表示當前檔案夾

See also [Rob Pike](https://9p.io/sys/doc/lexnames.html), 'Lexical File Names in
Plan 9 or Getting Dot-Dot Right'

# [path_split](https://pkg.go.dev/path#Split)

```
function path_split(path: string) (dir: string, name: string)
```

Split 在最后一个 / 之后立即拆分路径，将其分成目录和文件名部分。 如果路径中没有
/，Split 返回一个空目录并将文件名设置为 path。 返回值具有 path = dir+file
的属性。

# [path_dir](https://pkg.go.dev/path#Dir)

```
function path_dir(path: string): string
```

Dir 返回路径的最后一个元素以外的所有元素，通常是路径的目录。 使用 Split
删除最后一个元素后，路径将被清理并删除尾部斜杠。 如果路径为空，Dir 返回“.”。
如果路径完全由斜杠后跟非斜杠字节组成，则 Dir 返回单个斜杠。
在任何其他情况下，返回的路径不以斜杠结尾。

# [path_base](https://pkg.go.dev/path#Base)

```
function path_base(path string) string
```

Base 返回路径的最后一个元素。 在提取最后一个元素之前删除尾部斜杠。
如果路径为空，则 Base 返回“.”。 如果路径完全由斜杠组成，则 Base 返回“/”。

# [path_is_abs](https://pkg.go.dev/path#IsAbs)

```
function path_is_abs(path: string): errno
```

如果 path 是絕對路徑返回 `return 0`，否則返回 `return 1`

# [path_join](https://pkg.go.dev/path#Join)

```
function path_join(...elem: []string): string
```

Join 将任意数量的路径元素连接到一个路径中，并用 / 分隔它们。 空元素将被忽略。
结果是干净的。 但是，如果参数列表为空或其所有元素都为空，则 Join 返回空字符串。
