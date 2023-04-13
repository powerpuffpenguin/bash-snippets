#!/bin/bash

# 0 end_with
# 1 start_with
# (s, sub, 1|0 ): 1|0
function __strings_with
{
    errno=0
    local sub="$2"
    if [ "$sub" = '' ];then
        result=1
        return
    fi
    local n0=${#sub}
    local s="$1"
    local n1=${#s}
    if ((n1<n0));then
        result=0
        return
    elif ((n1>n0));then
        if [ $3 == 0 ];then # end with
            local i=$((n1-n0))
            s=${s:i}
        else
            s=${s:0:n0}
        fi
    fi
    if [ "$s" == "$sub" ];then
        result=1
    else
        result=0
    fi
}
# (s, sub): 1|0
function strings_end_with
{
    __strings_with "$1" "$2" 0
}
# (s, sub): 1|0
function strings_start_with
{
    __strings_with "$1" "$2" 1
}

# split string
# (s, separators): []string
function strings_split
{
    local ifs=$IFS
    IFS="$2"
    errno=0
    result=($1)
    IFS=$ifs
}
# (s...): string
function strings_join
{
    errno=0
    result=''
    local s
    for s in "${@}";do
        result="$result$s"
    done
}
# (separator,s...): string
function strings_join_with
{
    errno=0
    result=''
    local sep="$1"
    shift

    local n=${#@}
    local i=0
    for ((;i<n;i++));do
        if [ $i == 0 ];then
            result="$1"
        else
            result="$result$sep$1"
        fi
        shift
    done
}