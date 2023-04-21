[api](README.md)

[English](../en/log_writer.md)

# log_writer

log_writer 爲 log 重寫了 log_write_file 函數以實現日誌輪替

```
source dst/log.sh
source dst/log_writer.sh
```

- [generate_log_writer.sh](#generate_log_writer)

[example](https://github.com/powerpuffpenguin/bash-snippets/blob/main/example/example_log_writer.sh)

variable list:

- [log_file_backups](#log_file_backups)
- [log_file_size](#log_file_size)
- [log_file_name](#log_file_name)
- [log_file_check_times](#log_file_check_times)

function list:

- [log_write_file](#log_write_file)

# generate_log_writer

類似 log，你可以使用 src/generate_log_writer.sh 腳本，來生成一份帶獨特前綴的
writer 代碼

```
# display help
./src/generate_log_writer.sh -h

# print generated code to stdout
./src/generate_log_writer.sh --prefix mylog_ --test

# generated code to my.sh
./src/generate_log_writer.sh --prefix mylog_ --output my.sh
```

# log_file_backups

```
log_file_backups=3
```

最多同時保存多少個日誌檔案

# log_file_size

```
log_file_size=$((1*1024*1024))
```

當個日誌檔案的最大尺寸參考值

# log_file_name

```
log_file_name=''
```

writer 會首先使用 $log_file_name 作爲日誌檔案參考名稱，如果 $log_file_name
爲空白字符串則使用 $log_to_file 作爲參考名稱

# log_file_check_times

```
log_file_check_times=100
```

執行多少次寫入後，檢查檔案尺寸

# log_write_file

```
function log_write_file(...args)
```

將日誌寫入到檔案，並實現日誌輪替
