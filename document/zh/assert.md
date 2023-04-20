[api](README.md)

[English](../en/assert.md)

# assert

簡化單元測試的斷言

```
source dst/assert.sh
```

- [assert_equal](#assert_equal)
- [assert_false](#assert_equal)
- [assert_true](#assert_true)
- [assert_call_equal](#assert_call_equal)
- [assert_call_true](#assert_call_true)
- [assert_call_false](#assert_call_false)

assert
提供的函數通常只應該在單元測試中使用，它們都用來斷言滿足某些條件，如果條件不成立則會在打印調用信息和錯誤之後立刻退出
`exit 1`

assert 提供了兩種類型的斷言 assert_XXX 和 assert_call_XXX

- assert_XXX 斷言一個條件成立
- assert_call_XXX 會代理訪問一個函數，斷言函數不會出錯，並且其返回值 result
  滿足特定要求

# assert_equal

```
function assert_equal(expect, actual, ...msg)
```

斷言 expect == actual，msg 是可選的自定義信息，在斷言不成立時會被打印到 stdout

# assert_false

```
function assert_false(actual, ...msg)
```

斷言 actual == '' or 'false' or 'FALSE' or 0，msg
是可選的自定義信息，在斷言不成立時會被打印到 stdout

# assert_true

```
function assert_true(actual, ...msg)
```

斷言 actual != ('' or 'false' or 'FALSE' or 0)，msg
是可選的自定義信息，在斷言不成立時會被打印到 stdout

# assert_call_equal

```
function assert_call_equal(expect, f, ...args)
```

調用函數 f(...args)，斷言函數不會出錯，並且函數返回值 $result == $expect

# assert_call_true

```
function assert_call_true(f, ...args)
```

調用函數 f(...args)，斷言函數不會出錯

# assert_call_false

```
function assert_call_false(f, ...args)
```

調用函數 f(...args)，斷言函數會出錯
