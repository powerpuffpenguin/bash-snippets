[api](README.md)

[English](../en/log.md)

# log

log 提供了日誌功能

```
source dst/log.sh
```

- [generate_log.sh](#generate_log)

[example](https://github.com/powerpuffpenguin/bash-snippets/blob/main/example/example_log.sh)

variable list:

- [log_to_file](#log_to_file)
- [log_flag_tag](#log_flag_tag)
- [log_flag_line](#log_flag_line)
- [log_flag_sub](#log_flag_sub)
- [log_flag_file](#log_flag_file)
- [log_flag_level](#log_flag_level)
- [log_color](#log_color)
- [log_color_trace](#log_color_trace)
- [log_color_debug](#log_color_debug)
- [log_color_info](#log_color_info)
- [log_color_warn](#log_color_warn)
- [log_color_error](#log_color_error)
- [log_color_fatal](#log_color_fatal)

function list:

- [log_write_file](#log_write_file)
- [log_after_stdout](#log_after_stdout)
- [log_trace](#log_trace)
- [log_debug](#log_debug)
- [log_info](#log_info)
- [log_warn](#log_warn)
- [log_error](#log_error)
- [log_fatal](#log_fatal)

log 提供了很多全局變量，你可以設置它們來確定要如何記錄日誌。日誌分爲了 trace
debug info warn error fatal 幾個等級，你可以設置變量 log_flag_level
來確定要記錄的日誌等級。

無論 log_flag_level 如何設定，log_fatal 都會在日誌記錄後調用 `exit 1` 退出 bash

# generate_log

src/generate_log.sh 是一個 bash 腳本，它可以爲你生成一份帶獨特前綴的 log 代碼

```
# display help
./src/generate_log.sh -h

# print generated code to stdout
./src/generate_log.sh --prefix mylog_ --tag '[my]' --test

# generated code to my.sh
./src/generate_log.sh --prefix mylog_ --tag '[my]' --output my.sh
```

# log_to_file

```
log_to_file=''
```

如果這個變量爲空字符串，則日誌會被輸出到 stdout，否則將日誌輸出到 log_to_file
指定檔案中

# log_flag_tag

```
log_flag_tag='[DEFAULT]'
```

爲日誌設置一個標籤，它會作爲前綴被自動添加到輸出的日誌中

# log_flag_line

```
log_flag_line=1
```

如果不爲 0，則輸出調用日誌代碼所在行

# log_flag_sub

```
log_flag_sub=1
```

如果不爲 0，則輸出調用日誌代碼所在函數

# log_flag_file

```
log_flag_file=1
```

如何輸出調用日誌代碼所在檔案名稱

- **0** 不要輸出檔案名
- **1** 輸出簡短的檔案名
- **2** 輸出長檔案名

# log_flag_level

```
log_flag_level=0
```

要輸出的日誌等級

- **0** trace
- **1** debug
- **2** info
- **3** warn
- **4** error
- **5** fatal

# log_color

```
log_color=1
```

如何爲輸出到 stdout 的日誌上色

- **0** 不需要上色
- **1** 爲 level 標籤上色
- **2** 爲所有元信息上色
- **3** 爲日誌內容上色
- **4** 爲整個日誌上色

# log_color_trace

```
log_color_trace='97m'
```

將 trace 等級的日誌輸出到 stdout 時使用的顏色

# log_color_debug

```
log_color_debug='93m'
```

將 debug 等級的日誌輸出到 stdout 時使用的顏色

# log_color_info

```
log_color_info='92m'
```

將 info 等級的日誌輸出到 stdout 時使用的顏色

# log_color_warn

```
log_color_warn='95m'
```

將 warn 等級的日誌輸出到 stdout 時使用的顏色

# log_color_error

```
log_color_error='91m'
```

將 error 等級的日誌輸出到 stdout 時使用的顏色

# log_color_fatal

```
log_color_fatal='31m'
```

將 fatal 等級的日誌輸出到 stdout 時使用的顏色

# log_write_file

```
function log_write_file(...args)
{
    echo "$@" >> "$log_to_file"
}
```

這個函數只是簡單的將日誌寫入到檔案，你可以重寫這個函數來實現日誌輪替

# log_after_stdout

```
function log_after_stdout(...args)
{
    return 0
}
```

這個函數默認什麼都不做，但你可以重載它來實現同時將日誌輸出到 stdout
或其它地方，在日誌輸出到 stdout 後這個函數會被回調

```
function log_after_stdout(...args)
{
    echo "$@" >> your_log_filepath
}
```

# log_trace

```
log_trace(...msg)
```

輸出等級爲 trace 的日誌

# log_debug

```
log_debug(...msg)
```

輸出等級爲 debug 的日誌

# log_info

```
log_info(...msg)
```

輸出等級爲 info 的日誌

# log_warn

```
log_warn(...msg)
```

輸出等級爲 warn 的日誌

# log_error

```
log_error(...msg)
```

輸出等級爲 error 的日誌

# log_fatal

```
log_fatal(...msg)
```

輸出等級爲 fatal 的日誌
