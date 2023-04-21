[api](README.md)

[English](../zh/path.md)

# path

Manipulating slash-separated paths

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

By [golang](https://pkg.go.dev/path) Ported from the standard library, it only
performs syntax analysis, does not actually access the file system, and cannot
handle windows path of

# path_split_name

```
function path_split_name(filepath: string) (name: string, ext: string)
```

Split filepath, return path without extension, extension

# path_name

```
function path_name(filepath: string): string
```

Return filepath The path after removing the extension

# path_ext

```
function path_ext(filepath: string): string
```

Returns the extension of filepath

# [path_clean](https://pkg.go.dev/path#Clean)

```
function path_clean(path: string): string
```

Clean returns the shortest path name equivalent to path by purely lexical
processing. It applies the following rules iteratively until no further
processing can be done:

1. Replace multiple slashes with a single slash.
2. Eliminate each . path name element (the current directory).
3. Eliminate each inner .. path name element (the parent directory) along with
   the non-.. element that precedes it.
4. Eliminate .. elements that begin a rooted path: that is, replace "/.." by "/"
   at the beginning of a path.

The returned path ends in a slash only if it is the root "/".

If the result of this process is an empty string, Clean returns the string "."

See also [Rob Pike](https://9p.io/sys/doc/lexnames.html), 'Lexical File Names in
Plan 9 or Getting Dot-Dot Right'

# [path_split](https://pkg.go.dev/path#Split)

```
function path_split(path: string) (dir: string, name: string)
```

path_split splits path immediately following the final slash, separating it into
a directory and file name component. If there is no slash in path, Split returns
an empty dir and file set to path. The returned values have the property that
path = dir+file.

# [path_dir](https://pkg.go.dev/path#Dir)

```
function path_dir(path: string): string
```

Dir returns all but the last element of path, typically the path's directory.
After dropping the final element using Split, the path is Cleaned and trailing
slashes are removed. If the path is empty, Dir returns ".". If the path consists
entirely of slashes followed by non-slash bytes, Dir returns a single slash. In
any other case, the returned path does not end in a slash.

# [path_base](https://pkg.go.dev/path#Base)

```
function path_base(path string) string
```

Base returns the last element of path. Trailing slashes are removed before
extracting the last element. If the path is empty, Base returns ".". If the path
consists entirely of slashes, Base returns "/".

# [path_is_abs](https://pkg.go.dev/path#IsAbs)

```
function path_is_abs(path: string): errno
```

If path is an absolute path return `return 0`, otherwise return `return 1`

# [path_join](https://pkg.go.dev/path#Join)

```
function path_join(...elem: []string): string
```

Join joins any number of path elements into a single path, separating them with slashes. Empty elements are ignored. The result is Cleaned. However, if the argument list is empty or all its elements are empty, Join returns an empty string.