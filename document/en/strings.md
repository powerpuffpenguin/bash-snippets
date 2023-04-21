[api](README.md)

[中文](../zh/strings.md)

# strings

strings provides some common string processing functions

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

`return 0` if the string 's' is suffixed by 'suffix', otherwise `return 1`

# strings_start_with

```
function strings_start_with(s: string, prefix: string): errno
```

`return 0` if the string 's' is prefixed by 'prefix', otherwise `return 1`

# strings_index_ofchar

```
function strings_index_ofchar(s: string, chars: string): number
```

Find the first occurrence of the characters specified by 'chars' in the string
's', if not found, return `result=-1`

# strings_last_ofchar

```
function strings_last_ofchar(s: string, chars: string): number
```

Find the last occurrence of the character specified by 'chars' in the string
's', if not found, return `result=-1`

# strings_split

```
function strings_split(s: string, separator_chars: string): []string
```

Separate the string 's' with the characters specified by 'separator_chars' and
return the separated array

# strings_join

```
function strings_join(...s: []string): string
```

Concatenates the string arrays s together and returns the concatenated string

# strings_join_with

```
function strings_join_with(separator: string, ...s: []string): string
```

Concatenates the string array 's' using 'separator' as the separator and returns
the concatenated string
