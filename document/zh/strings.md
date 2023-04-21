[api](README.md)

[English](../en/strings.md)

# strings

strings 提供了一些常用的字符串处理函数

```
source dst/strings.sh
```

- [strings_end_with](#strings_end_with)
- [strings_start_with](#strings_start_with)
- [strings_index_ofchar](#strings_index_ofchar)
- [strings_last_ofchar](#strings_last_ofchar)
- [strings_split](#strings_split)
- [strings_join](#strings_join)
- [strings_join_with](#strings_join_with)

# strings_end_with

```
function strings_end_with(s: string, suffix: string): errno
```

如果字符串 s 以 suffix 爲後綴 `return 0`,否則 `return 1`

# strings_start_with

```
function strings_start_with(s: string, prefix: string): errno
```

如果字符串 s 以 prefix 爲前綴 `return 0`,否則 `return 1`

# strings_index_ofchar

```
function strings_index_ofchar(s: string, chars: string): number
```

在字符串 s 中查找 chars 指定的字符首次出現的位置，如果沒找到返回 `result=-1`

# strings_last_ofchar

```
function strings_last_ofchar(s: string, chars: string): number
```

在字符串 s 中查找 chars 指定的字符最後出現的位置，如果沒找到返回 `result=-1`

# strings_split

```
function strings_split(s: string, separator_chars: string): []string
```

將字符串 s 以 separator_chars 指定的字符分隔，並返回分隔後的數組

# strings_join

```
function strings_join(...s: []string): string
```

將字符串數組 s 連接到一起並返回連接後的字符串

# strings_join_with

```
function strings_join_with(separator: string, ...s: []string): string
```

將字符串數組 s 以 separator 爲分隔符連接到一起並返回連接後的字符串
