#!/bin/bash

# current command id
__command_id=0

# command name
# __command_${id}_name='get'
# 
# short description of the command
# __command_${id}_short='download file from url'
# 
# detailed description of the command
# __command_${id}_long='download file from url

# Example:
#   get url
#   get --socks5 127.0.0.1:1080
# '
# 
# command callback function name
# __command_${id}_func='execute_get'
# 
# subcommand ids
# __command_${id}_children=()
# 
# long parameters
# __command_${id}_flags_long=()
# short parameters
# __command_${id}_flags_short=()
# parameter parsing result storage variable name
# __command_${id}_flags_var=()
# parameter type
# * 0 string
# * 1 []string
# * 2 int
# * 3 []int
# __command_${id}_flags_type=()

# parameter default value
# __command_${id}_flags_default_%i=?
# specify matching rules( == ) for legal values
# __command_${id}_flags_rule_%i=?
# specify matching regexp rules( =~ ) for legal values
# __command_${id}_flags_regexp_%i=?
# legal value of parameter
# __command_${id}_flags_value_%i=?

# begin a new command
# (name: string, short?: string, long?: string) (id: string)
command_begin(){
    local errno=0

    if [[ $1 == '' ]];then
        result_errno="[command_begin] name invalid: $1"
        errno=1
    else
        local id=$__command_id
        if eval "__command_${id}_name=\$1
__command_${id}_short=\$2
__command_${id}_long=\$3
__command_${id}_func=''
__command_${id}_children=()

__command_${id}_flags_long=()
__command_${id}_flags_short=()
__command_${id}_flags_var=()
__command_${id}_flags_type=()
";then
            result=$id
            __command_id=$((__command_id+1))
        else
            result_errno="[command_begin] eval $1 error"
            errno=$?
        fi
    fi
    if [[ $errno != 0 ]] && [[ $- == *e* ]];then
        echo "$result_errno"
    fi
    return $errno
}

# return the generated bash script
# (id: number) (source: string, errno)
__command_source(){
    local errno=0
    if [[ $1 == ]]
    local s=''

    return $errno
}