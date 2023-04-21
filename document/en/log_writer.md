[api](README.md)

[中文](../zh/log_writer.md)

# log_writer

log_writer rewrites the log_write_file function for log to implement log
rotation

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

Similar to log, you can use the src/generate_log_writer.sh script to generate a
writer code with a unique prefix

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

How many log files can be saved at the same time

# log_file_size

```
log_file_size=$((1*1024*1024))
```

The maximum size reference value of a log file

# log_file_name

```
log_file_name=''
```

The writer will first use $log_file_name as the log file reference name, or
$log_to_file if $log_file_name is an empty string

# log_file_check_times

```
log_file_check_times=100
```

After how many writes have been performed, check the file size

# log_write_file

```
function log_write_file(...args)
```

Write logs to files and implement log rotation
