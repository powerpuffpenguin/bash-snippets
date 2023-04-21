[api](README.md)

[中文](../zh/assert.md)

# assert

Assertions to simplify unit testing

```
source dst/assert.sh
```

- [assert_equal](#assert_equal)
- [assert_false](#assert_equal)
- [assert_true](#assert_true)
- [assert_call_equal](#assert_call_equal)
- [assert_call_true](#assert_call_true)
- [assert_call_false](#assert_call_false)

Assert The provided functions should usually only be used in unit tests, they
are used to assert that certain conditions are met, and if the conditions are
not true, they will exit immediately after printing the call information and
error `exit 1`

Assert provides two types of assertions assert_XXX and assert_call_XXX

- assert_XXX asserts that a condition holds
- assert_call_XXX will proxy access to a function, assert that the function will
  not fail, and its return value 'result' meets specific requirements

# assert_equal

```
function assert_equal(expect, actual, ...msg)
```

Assert that expect == actual, msg is an optional custom message that will be
printed to stdout when the assertion is not true

# assert_false

```
function assert_false(actual, ...msg)
```

Assert that actual == '' or 'false' or 'FALSE' or 0, msg is an optional custom
message that will be printed to stdout when the assertion is not true

# assert_true

```
function assert_true(actual, ...msg)
```

Assert that actual != ('' or 'false' or 'FALSE' or 0), msg is an optional custom
message that will be printed to stdout when the assertion is not true

# assert_call_equal

```
function assert_call_equal(expect, f, ...args)
```

Call the function f(...args), assert that the function will not error, and the
function return value $result == $expect

# assert_call_true

```
function assert_call_true(f, ...args)
```

Call the function f(...args), assert that the function will not error

# assert_call_false

```
function assert_call_false(f, ...args)
```

Call the function f(...args), assert that the function will error
