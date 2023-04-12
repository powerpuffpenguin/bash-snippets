# bash-snippets

本喵寫的一些 bash 代碼片段

本喵以前打算[模塊化 bash](https://github.com/powerpuffpenguin/bash_module) (在
bash 中模擬 namespace/package)，但後來發現這樣反而使用 bash
使用變得複雜並且不如直接使用更高階的腳本語言方便。

本喵現在的做法是將 bash 代碼片段測試完畢後存儲在這個 git
中，需要哪個功能就直接將其複製過去使用即可。

- [result](#result)
- [const](#const)
- [log](#log)

# result

衆所周知 bash
函數無法返回整數之外的內容，解決方案是可以使用全局變量進行返回，否則使用 echo
返回字符串，本庫代碼採用了全局變量的方案

如果函數存在返回值則必然會設置 errno 和 result 兩個全局變量

1. 如果發生了任何錯誤 errno 將是一個非0 整數，而 result 會是錯誤描述信息
2. 如果一切正常，則 errno 爲 0，並且 result 將是返回的內容

```
get_value; ec=$errno; value=$result;
if [ $ec != 0 ];then
    echo "$value"
    exit 1
fi

get_array; value=("${result[@]}");
echo "len=${#value[@]}"
i=0
for val in "${value[@]}";do
    echo "value[$i] = $val"
    i=$((i+1))
done
```

# const

```
source dst/const.sh
```

const 定義了一些 時間 檔案大小 相關的常量，並提供了一些相關方法

## bool

提供了三個 bool 相關的方法用於明確的 bool 判斷

```
# false: '' or 'false' or 'FALSE' or 0
# true: != ('' or 'false' or 'FALSE' or 0)
function bool_string(val): 'true' | 'false'

# != ('' or 'false' or 'FALSE' or 0) ? 1 : 0
function bool_true(val): 1|0

# == ('' or 'false' or 'FALSE' or 0) ? 1 : 0
function bool_false(val): 1|0
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
function duration_string(val) :string
function duration_
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

**src/generate_log.sh** 腳本可以用於生成自定義的 log.sh 代碼

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
