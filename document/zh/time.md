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
