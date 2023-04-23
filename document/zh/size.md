[api](README.md)

[English](../en/size.md)

# size

size 提供了一些方便定義檔案大小的常量

```
source dst/size.sh
```

const list:

- [size_b](#size_b)
- [size_k](#size_k)
- [size_m](#size_m)
- [size_g](#size_g)
- [size_t](#size_t)

function list:

- [size_string](#size_string)
- [size_parse](#size_parse)

# size_b

```
size_b=1
```

# size_k

```
size_k=1024
```

# size_m

```
size_m=1048576
```

# size_g

```
size_g=1073741824
```

# size_t

```
size_t=1099511627776
```

# size_string

```
function size_string(size: number) (s: string, errno)
```

將 size 轉爲人類友好的字符串 s

# size_parse

```
function size_parse(s: string) (size: number, errno)
```

將人類友好的字符串轉爲數字並返回
