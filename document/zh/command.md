[api](README.md)

[English](../en/command.md)

# command

功能齊全的命令行解析程式

```
source dst/command.sh
```

- [如何工作](#如何工作)
- [示例](#示例)
- [子命令](#子命令)

features:

- 支持長標記(--) 和 短標記(-)
- 支持多種數據類型 bool/bools string/strings int/ints uint/uints
- 自動驗證標記合法性，支持多種驗證規則
- 支持子命令
- 自動爲 -h/--help 標記生成使用說明

function list:

- [command_begin](#command_begin)
- [command_flags](#command_flags)
- [command_children](#command_children)
- [command_string](#command_string)
- [command_commit](#command_commit)
- [command_execute](#command_execute)

# 如何工作

使用成對的 command_begin/command_commit 來完整定義一個命令。在此之間你可以調用
command_flags 指定支持的標記，調用 command_children
指定子命令。這些函數會自動生成 bash 代碼，並使用 eval
加載，它們完成了命令行參數的解析與驗證。調用 command_execute 傳入命令 id
和命令行參數來使用系統開始工作。

系統將按照下述規則解析命令行參數：

1. 如果存在子命令，優先匹配子命令
2. 優先匹配 -- 指定的長參數
3. 之後匹配 - 指定的短參數
4. 所有非 - 爲前綴的參數，作爲命令處理回調函數的位置參數
5. bool/bools 類型的標記，一旦出現默認爲 true，如果要設置false必須使用
   `-s=false` 或者 `--long=false` 的形式指定

# 示例

```
#!/bin/bash
set -e

cd `dirname $BASH_SOURCE`

source ../dst/command.sh

on_main(){
    echo "--- on_main ---"
    echo "debug=$debug"
    echo "listen=$listen"
    echo "port=$port"
    echo "thread=$thread"
    echo "zone=(${zone[@]})"
    echo "upload=(${upload[@]})"
    echo "tokens=(${tokens[@]})"
    echo "args[${#@}]=($@)"
}


command_begin --name "`basename $BASH_SOURCE`" \
    --short 'Example for command.sh' \
    --func on_main
root=$result

command_flags --type bool '--describe=Run as debug' \
    -v debug --long debug --short d
# if not specified -l|--long, will use same as -v|--var
command_flags --type string '--describe=Listen address' \
    -v listen -sl \
    --default=::
command_flags --type uint --describe 'Listen port' \
    -v port --long port --short p \
    --default 80
command_flags -t int '-d=Work threads, -1 number of CPUs' \
    -v thread -lthreads \
    -D-1 \
    --max 32 --min=-1
command_flags -t strings -d 'Time zone' \
    -v zone -l zone -s z \
    -V Taiwan -V Japan -V "T J" -V America \
    -D Taiwan -D Japan
command_flags -t strings -d 'Allowed upload file name' \
    -v upload -l upload -s u\
    -P '*.txt' -P '*.jpg'
command_flags -t strings -d 'Access token list' \
    -v tokens -l tokens \
    -R '^[a-zA-Z0-9]+$' -R 'king*'


command_commit

command_execute $root "$@"
```

1. 定義的 on_main
   作爲參數解析完畢後的回調函數被自動調用，它可以通過標記綁定的變量名來獲取對應標記的值
2. command_begin
   開始了一個命令，並且指定了描述信息以及命令的回調函數。隨後將命令 id 記錄到
   root 變量中
3. 重複調用 command_flags 指定了命令支持的標記，以及關於此標記的 長名稱 短名稱
   綁定變量 描述以及數據類型和取值規則
4. 調用 command_commit 結束命令定義，它將自動生成bash代碼並使用 eval 加載
5. 調用 command_execute 開始解析命令行參數並最終調用匹配的回調函數

# 子命令

你只需要在定義命令時使用 command_children 爲它指定子命令的id即可

```
#!/bin/bash
set -e

cd `dirname $BASH_SOURCE`

source ../dst/command.sh
source ../dst/core.sh

### subcommand web of root ###
on_web(){
    echo "--- on_web ---"
    echo "listen=$listen"
    echo "port=$port"
    echo "h2c=$h2c"
    echo "debug=$debug"
    echo "args[${#@}]=($@)"
}
# define web
command_begin --name web \
    --short 'Start a web server' \
    --func on_web
web=$result
# define flags of web
command_flags -t string -d "Listen address" \
    -v listen -l listen -s l \
    -D '::'
command_flags -t string -d "Listen port" \
    -v port -l port -s p \
    -D '80' --min 1 --max 65535
command_flags -t bool -d "Run as debug mode" \
    -v debug -l debug
command_flags -t bool -d "Enable h2c supported" \
    -v h2c -l h2c

# commit web
command_commit

### root ###
on_main(){
    echo "--- on_main ---"
    echo "version=$version"
    echo "args[${#@}]=($@)"
}
# define root
command_begin --name "`basename $BASH_SOURCE`" \
    --short 'Example of subcommand for command.sh' \
    --func on_main
root=$result

# define flags of root
command_flags -d "display version" \
    -v version -l version -s v

# set subcommand 
command_children "$web"

# commit root
command_commit

# parse and execute
command_execute "$root" "$@"
```

# command_begin

```
# -n, --name string   Name of command
# -l, --long string   Long describe of command
# -s, --short string   Short describe of command
# -f, --func string   Function name of command
function command_begin(...) (id: number, panic)
```

command_begin 開始定義一個新的命令，它以命令解析的方式支持命名參數

- **-n, --name** 指定新命令的名稱
- **-l, --long**
  指定命令的長描述信息，你可以在裏面書寫詳細的使用方法和使用示例。如果沒有指定或爲空字符串它將使用
  **-s, --short** 指定的值
- **-s, --short**
  指定命令的短描述信息，不要加入換行。當此命令作爲子命令時，它會顯示在子命令的簡短描述欄
- **-f, --func**
  指定處理此命令的回調函數名稱，如果爲空字符串或未指定，則不進行回調

```
command_begin --name "`basename $BASH_SOURCE`" \
    --short 'Example for command.sh' \
    --func on_main
```

# command_flags

```
# -v, --var string(^[a-zA-Z_][a-zA-Z0-9_]*$)  Varname of this flag 
# -l, --long string   Long name of this flag
# -s, --short char   Short name of this flag 
# -t, --type string     Flag type (default bool) (value [string, strings, int, ints, uint, uints, bool, bools])
# -d, --describe string     How to use descriptive information
#   , --max number  Max value, only valid for type int
#   , --min number  Min value, only valid for type int
# -V, --value string   Lists of valid values are compared using == "$value[i]"
# -P, --pattern string Lists of valid values are compared using == $pattern[i]
# -R, --regexp string Lists of valid values are compared using =~ $pattern[i]
# -D, --default string  Default value when not specified
function command_flags(): panic
```

command_flags 爲當前命令定義一個標記，它以命令解析的方式支持命名參數

- **-v, --var** 指定綁定的變量名稱，會將解析結果存儲到此名稱的變量
- **-l, --long** 指定長名稱，將和 --* 進行匹配。如果未指定或爲空字符串將使用
  **-v, --var** 指定的值
- **-s, --short** 指定短名稱，將和 -* 進行匹配
- **-t, --type** 指定標記類型
- **-d, --describe** 指定在幫助信息中爲此標記顯示的說明，不要加入換行
- **--max** 對於數字類型的標記可以指定允許的最大值
- **--min** 對於數字類型的標記可以指定允許的最小值
- **-V, --value** 可以多次指定來設置標記的有效值列表
- **-P, --pattern** 可以多次指定來設置標記的有效值模式匹配規則 ==
- **-R, --regexp** 可以多次指定來設置標記的有效值正則匹配規則 ==
- **-D, --default** 指定標記默認值，如果不指定，則爲對於數據類型的 0 值

1. 如果同時設置了 --max/--min 值必須同時滿足才認爲值有效
2. 如果設置了 --value/--pattern/--regexp 則其中任意一個規則匹配都認爲值有效

# command_children

```
function command_children(...children_id: []string): panic
```

爲當前命令指定子命令

# command_string

```
function command_string() (string, errno)
```

返回當前命令會生成的 bash 代碼

# command_commit

```
function command_commit(): panic
```

完成當前命令的定義，爲其生成 bash 代碼並加載

# command_execute

```
function command_execute(id: number, ...args: []string): panic
```

將命令行參數傳遞給 id 指定的命令進行解析並執行
