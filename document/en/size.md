[api](README.md)

[中文](../zh/size.md)

# size

size provides some constants for conveniently defining the file size

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

Convert size to a human-friendly string s

# size_parse

```
function size_parse(s: string) (size: number, errno)
```

Convert human-friendly string to numbers and back
