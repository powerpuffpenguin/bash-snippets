[api](README.md)

[中文](../zh/time.md)

# time

time provides functions related to some time and date

```
source dst/time.sh
```

The functions provided by time need to rely on the external command date to get
the time, although 99.99% of bash Environments all have date built in, but it
doesn't work without

const list:

- [time_second](#time_second)
- [time_minute](#time_minute)
- [time_hour](#time_hour)
- [time_day](#time_day)

function list:

- [time_string](#time_string)
- [time_parse](#time_parse)
- [time_unix](#time_unix)
- [time_used](#time_used)
- [time_since](#time_since)

# time_second

```
time_second=1
```

# time_minute

```
time_minute=60
```

# time_hour

```
time_hour=3600
```

# time_day

```
time_day=86400
```

# time_string

```
function(duration: number) (s: string, errno)
```

Convert seconds to a human-friendly string

# time_parse

```
function (s: string) (duration: number, errno)
```

Convert a human-friendly string to seconds

# time_unix

```
function time_unix() (unix: string, errno)
```

returns the number of seconds elapsed since January 1, 1970 UTC

# time_used

```
function time_used(from: unix, to: unix) (s: string, errno)
```

returns the elapsed time from 'from' to 'to'

# time_since

```
function time_since(from: unix) (s: string, errno)
```

returns the time elapsed since 'from'
