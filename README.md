# bash-snippets

本喵寫的一些 bash 代碼片段

本喵以前打算[模塊化 bash](https://github.com/powerpuffpenguin/bash_module) (在
bash 中模擬 namespace/package)，但後來發現這樣反而使 bash
的使用變得複雜並且不如直接使用更高階的腳本語言方便。

本喵現在的做法是將 bash 代碼片段測試完畢後存儲在這個 git
中，需要哪個功能就直接將其複製過去使用即可。

- [result](#result)
- [test.sh](#test)
  - [assert](#assert)
- [const](#const)
- [strings](#strings)
- [log](#log)
  - [log_writer](#log_writer)

# result

衆所周知 bash
函數無法返回整數之外的內容，解決方案是可以使用全局變量進行返回，否則使用 echo
返回字符串，本庫採用全局變量的方式爲函數返回內容(echo
無法返回數組，並且在函數出錯時也難以 return errno 通知調用者函數錯誤)

1. 如果函數是判別式則使用 `return errno` 返回
2. 如果函數存在返回值則設置變量 `result=...` 作爲返回值

```
# return value
if ! get_value; then
  echo "errno: $?"
  exit 1
fi
echo "value=$result"


# return array
if ! get_array; then
  echo "errno: $?"
  exit 1
fi
i=0
for val in "${result[@]}";do
    echo "value[$i] = $val"
    i=$((i+1))
done
```

# test

**test.sh** 是一個 bash 測試腳本，可以傳入要測試的腳本，它將搜索腳本裏所有以
test_ 爲前綴的函數並調用它們(test 函數需要使用關鍵字 function 進行聲明)

```
$ ./test.sh dst/strings_test.sh dst/const_test.sh 
dst/strings_test.sh
 - test_start_with 0s
 - test_end_with 0s
 - test_index_ofchar 0s
 - test_last_ofchar 0s
 - test_split 0s
 - test_join_with 0s
 * 6 passed, used 0s
dst/const_test.sh
 - test_bool 0s
 - test_duration 0s
 - test_size 0s
 * 3 passed, used 0s
test 2 files, 9 passed, used 0s
```

你也可以不指定腳本而指定一個目錄，test.sh 會查找目錄下所有以 _test.sh
爲後綴的腳本並執行測試

```
$ ./test.sh -d dst -s
test 3 files, 11 passed, used 0s
```

test.sh 還支持其它的一些參數，你可以使用 -h 指令查看具體的使用方法

```
$ ./test.sh -h
test bash scripts

Usage:
  test.sh [flags]

Flags:
  -s, --silent         silent mode (default false)
  -d, --dir            test file dir (default "$(cd `dirname $BASH_SOURCE` && pwd)")
  -m, --method         function name to test
  -t, --test           print the test function to be executed, but don't actually execute the test
  -h, --help           help for test.sh
```

## assert

```
source dst/assert.sh
```

assert 提供了一些斷言，如果斷言失敗會在打印調試信息後調用 exit
1，通常用於書寫單元測試：

```
# assert expect == actual
function assert_equal(expect, actual, msg...)

# assert actual == '' or 'false' or 'FALSE' or 0
function assert_false(actual, msg...)

# assert actual != ('' or 'false' or 'FALSE' or 0)
function assert_true(actual, msg...)
```

另外可以調用下列函數來測試函數返回值：

```
# assert f(args...) == expect
function assert_call_equal(expect, f, args...)

# assert f(args) bash return 0
function assert_call_true(f, args...)

# assert f(args) bash return != 0
function assert_call_false(f, args...)
```

# const

```
source dst/const.sh
```

const 定義了一些 時間 檔案大小 相關的常量，並提供了一些相關方法

## bool

提供了三個 bool 相關的方法用於 bool 判斷

```
# false: '' or 'false' or 'FALSE' or 0
# true: != ('' or 'false' or 'FALSE' or 0)
function bool_string(val): 'true' | 'false'

# 判斷 val != ('' or 'false' or 'FALSE' or 0)
function bool_true(val): errno

# 判斷 val == ('' or 'false' or 'FALSE' or 0) 
function bool_false(val): errno
```

## duration

提供了幾個 duration 常量用於方便定義持續時間

```
duration_second=1
duration_minute=60
duration_hour=3600
duration_day=86400
```

提供了兩個函數用於將 duration 和 人類友好的字符串之間進行轉換

```
# errno
function duration_string(val) :string

# errno
function duration_parse(s: string): number
```

## size

提供了幾個 size 常量用於方便定義檔案大小

```
size_b=1
size_k=1024
size_m=1048576
size_g=1073741824
size_t=1099511627776
```

提供了兩個函數用於將 size 和 人類友好的字符串之間進行轉換

```
# errno
function size_string(val) :string

# errno
function size_parse(s: string): number
```

# strings

```
source dst/strings.sh
```

strings 中提供了多個字符串處理相關的函數

```
# 判斷 s 以 sub 結尾
function strings_end_with(s, sub): errno

# 判斷 s 以 sub 爲前綴
function strings_start_with(s, sub): errno

# 將 s 以 separators 中的字符分割
function strings_split(s, separators): []string

# 在 s 中查找首次出現 chars 指定的字符的位置，未找到返回 -1
function strings_index_ofchar(s, chars): number

# 在 s 中查找最後一次出現 chars 指定的字符的位置，未找到返回 -1
function strings_last_ofchar(s, chars): number

# 將數組連接在一起
function strings_join(s...): string
# 將數組使用 separator 連接在一起
function strings_join_with(separator,s...): string
```

# log

```
source dst/log.sh
```

log 提供了幾個記錄日誌的函數
[example](https://github.com/powerpuffpenguin/bash-snippets/blob/main/dst/example_log.sh)

```
log_trace this is trace
log_debug this is debug
log_info this is info
log_warn this is warn
log_error this is error
log_fatal this is fatal
```

log_fatal 會在日誌記錄後調用 exit 1 退出

**dst/generate_log.sh** 腳本可以用於生成自定義的 log.sh 代碼

```
./src/generate_log.sh -h
```

log 還提供了如下全局變量用於控制如何記錄日誌

```
# if != '', print log to this file
log_to_file=''
# you can override how to write log to file
function log_write_file
{
    echo "$1" >> "$log_to_file"
}
# call after log to stdout, you can override it
# * $1 log string
function log_after_stdout
{
    return 0
}

# if != '', print log tag
log_flag_tag='[DEFAULT]'

# if != 0, print log line
log_flag_line=1

# if != 0, print log sub
log_flag_sub=1

# * 0, not print filename
# * 1, print log short filename
# * 2, print log long filename
log_flag_file=1

# log print level
# * 0 trace
# * 1 debug
# * 2 info
# * 3 warn
# * 4 error
# * 5 fatal
log_flag_level=0

# * 0 no color
# * 1 color level
# * 2 color metadata
# * 3 color message
# * 4 color metadata+message
log_color=1
# trace color
log_color_trace='97m'
# debug color
log_color_debug='93m'
# info color
log_color_info='92m'
# warn color
log_color_warn='95m'
# error color
log_color_error='91m'
# fatal color
log_color_fatal='31m'
```

## log_writer

```
source log_writer.sh
```

log.sh 支持重載 log_write_file 函數以確定如何寫入日誌檔案，log_writer.sh
提供了一個默認的重載，它可以控制日誌檔案的最大尺寸和檔案數量，log_writer.sh
每當日誌超過指定尺寸就會將日誌寫入到新的檔案(檔案名以數字自增)。並且檔案數量超過指定數量時，log_writer.sh
還會自動刪除舊的日誌檔案

```
#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source log.sh
source log_writer.sh

# 每寫入100 次日誌檢查檔案大小
log_file_check_times=100
# 當個日誌檔案的最大參考尺寸是 1mb
log_file_size=$((1*1024*1024))
# 最多存在3個日誌檔案
log_file_backups=3
# 日誌檔案參考名稱
log_to_file="./log/writer.log"

# 寫入日誌
for ((i=0;i<102;i++));do
    log_info "writer $i"
done
```

最簡單的情況是你只需要設定 log_to_file 變量來告訴 log.sh
要將日誌寫入檔案，其它屬性都設置了一個默認的值，你可以只在需要時去修改這些默認設定！

你可以重寫 log_after_stdout 函數來實現同時將日誌寫入到 stdout 和檔案，但要注意將
log_to_file 設置爲空白字符串 log.sh 才會將日誌輸出到 stdout，此時你可以爲
log_writer.sh 指定 log_file_name 變量來設定日誌檔案名稱

```
source log.sh
source log_writer.sh

log_to_file=""
log_file_name="./log/writer.log"
function log_after_stdout
{
    log_write_file "$@"
}
```

**dst/generate_log_writer.sh** 腳本可以用於生成自定義的 log_writer.sh 代碼
