[api](README.md)

[中文](../zh/command.md)

# command

Full-featured command-line parser

```
source dst/command.sh
```

- [How to work](#How)
- [Example](#Example)
- [Subcommand](#Subcommand) features:

- Both long flags (--) and short flags (-) are supported
- Support multiple data types bool/bools string/strings int/ints uint/uints
- Automatically verify the legitimacy of the flags, supporting multiple
  verification rules
- Support subcommands
- Automatically generate usage instructions for -h/--help flags

function list:

- [command_begin](#command_begin)
- [command_flags](#command_flags)
- [command_children](#command_children)
- [command_string](#command_string)
- [command_commit](#command_commit)

# How

Use the command_begin/command_commit pair to fully define a command. In between
you can call command_flags to specify supported flags and command_children to
specify subcommands. These functions automatically generate bash code and use
eval Loading, they complete the parsing and verification of command line
parameters. Call command_execute to pass the command id and command line
parameters to use the system to start working.

The system will parse the command line parameters according to the following
rules:

1. If there are subcommands, subcommands are matched first
2. Prioritize matching long parameter(--)
3. Match after short argument(-)
4. All parameters not prefixed with - are used as positional parameters of the
   command handler callback function
5. bool/bools type flag, once present, defaults to true. If you want to set
   false, you must specify it in the form of `-s=false` or `--long=false`

# Example

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

1. The defined on_main is automatically called as a callback function after the
   parameters are parsed, and it can obtain the value of the corresponding flags
   through the variable name bound by the flags
2. command_begin starts a command, and specifies the description information and
   the callback function of the command. Then save the command id into the root
   variable
3. Call command_flags repeatedly to specify the flags supported by the command,
   as well as the long name, short name, binding variable description, data type
   and value rules for this flag
4. Call command_commit to end the command definition, it will automatically
   generate bash code and load it with eval
5. Call command_execute to start parsing the command line arguments and
   eventually call the matching callback function

# Subcommand

You only need to use command_children to specify the id of the subcommand when
defining the command

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

command_begin begins to define a new command, which supports named parameters in
the way of command parsing

- **-n, --name** Specifies the name of the new command
- **-l, --long** Specify the long description information of the command, you
  can write detailed usage methods and usage examples in it. If not specified or
  empty string it will use the value specified by **-s, --short**
- **-s, --short** Specify a short description of the command without newlines.
  When this command is used as a subcommand, it will be displayed in the short
  description column of the subcommand
- **-f, --func** Specify the name of the callback function that handles this
  command, if it is an empty string or not specified, no callback will be made

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
function command_flags(): errno
```

command_flags defines a flag for the current command, which supports named
parameters in the way of command parsing

- **-v, --var** Specify the bound variable name, and the parsing result will be
  stored in the variable of this name
- **-l, --long** Specifying a long name will match --*. If not specified or
  empty string the value specified by **-v, --var** will be used
- **-s, --short** Specify a short name, will match with -*
- **-t, --type** Specify the flag type
- **-d, --describe** Specifies the description to display for this flag in the
  help message, without line breaks
- **--max** For numeric flag, you can specify the maximum value allowed
- **--min** For numeric flag, you can specify the maximum value allowed
- **-V, --value** Can be specified multiple times to set the list of valid
  values for the flag
- **-P, --pattern** Can be specified multiple times to set valid values for the
  flag pattern matching rules ==
- **-R, --regexp** Can be specified multiple times to set valid values for the
  flag regexp matching rules ==
- **-D, --default** Specifies the flag default value, or 0 for the data type if
  not specified

1. If you set --max/--min at the same time, the value must be satisfied at the
   same time, the value is considered valid
2. If --value/--pattern/--regexp is set, any one of the rules matches, the value
   is considered valid

# command_children

```
function command_children(...children_id: []string): errno
```

specify subcommands for the current command

# command_string

```
function command_string() (string, errno)
```

Returns the bash code that would be generated by the current command

# command_commit

```
function command_commit(): errno
```

Complete the definition of the current command, generate bash code for it and
load

# command_execute

```
function command_execute(id: number, ...args: []string): errno
```

Pass command-line arguments to the command specified by id for parsing and
execution
