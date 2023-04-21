[api](README.md)

[中文](../zh/log.md)

# log

log provides logging functionality

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

log provides many global variables that you can set to determine how to log. The
log is divided into trace debug info warn error fatal several levels, you can
set the variable log_flag_level To determine the log level to be recorded.

log_fatal calls `exit 1` to exit bash after logging regardless of log_flag_level

# generate_log

src/generate_log.sh is a bash script that can generate a log code with a unique
prefix for you

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

If this variable is an empty string, the log will be output to stdout, otherwise
the log will be output to the file specified by log_to_file

# log_flag_tag

```
log_flag_tag='[DEFAULT]'
```

Set a tag for the log, which will be automatically added as a prefix to the
output log

# log_flag_line

```
log_flag_line=1
```

If not 0, output the line where the log code is called

# log_flag_sub

```
log_flag_sub=1
```

If not 0, output the function where the log code is called

# log_flag_file

```
log_flag_file=1
```

How to output the name of the file where the calling log code is located

- **0** do not output filename
- **1** output short filename
- **2** output long filename

# log_flag_level

```
log_flag_level=0
```

log level to output

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

How to color the log output to stdout

- **0** no coloring required
- **1** color the level
- **2** color the metadata
- **3** color the message
- **4** color all log

# log_color_trace

```
log_color_trace='97m'
```

The color to use when outputting trace level logs to stdout

# log_color_debug

```
log_color_debug='93m'
```

The color to use when outputting debug level logs to stdout

# log_color_info

```
log_color_info='92m'
```

The color to use when outputting info level logs to stdout

# log_color_warn

```
log_color_warn='95m'
```

The color to use when outputting warn level logs to stdout

# log_color_error

```
log_color_error='91m'
```

The color to use when outputting error level logs to stdout

# log_color_fatal

```
log_color_fatal='31m'
```

The color to use when outputting fatal level logs to stdout

# log_write_file

```
function log_write_file(...args)
{
    echo "$@" >> "$log_to_file"
}
```

This function simply writes the log to the file, you can override this function
to implement log rotation

# log_after_stdout

```
function log_after_stdout(...args)
{
    return 0
}
```

This function does nothing by default, but you can override it to also log to
stdout or elsewhere, this function will be called back after logging to stdout

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

Output logs with level trace

# log_debug

```
log_debug(...msg)
```

Output logs with level debug

# log_info

```
log_info(...msg)
```

Output logs with level info

# log_warn

```
log_warn(...msg)
```

Output logs with level warn

# log_error

```
log_error(...msg)
```

Output logs with level error

# log_fatal

```
log_fatal(...msg)
```

Output logs with level fatal
