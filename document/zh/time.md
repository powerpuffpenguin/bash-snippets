[api](README.md)

[English](../en/time.md)

# time

time 提供了與一些時間日期相關的功能

```
source dst/time.sh
```

time 提供的函數需要依賴外部指令 date 來獲取時間，雖然 99.99% 的 bash
環境都內置了date，但如果沒有則它無法正常工作

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

將秒數轉爲人類友好的字符串

# time_parse

```
function (s: string) (duration: number, errno)
```

將人類友好的字符串轉爲秒數

# time_unix

```
function time_unix() (unix: string, errno)
```

返回自 1970年1月1日至今經歷過的秒數

# time_used

```
function time_used(from: unix, to: unix) (s: string, errno)
```

返回從 from 到 to 經過秒數的人類友好字符串

# time_since

```
function time_since(from: unix) (s: string, errno)
```

返回從 from 到當前時間 經過秒數的人類友好字符串
