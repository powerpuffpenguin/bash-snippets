#!/bin/bash
if [[ -v strings_version ]] && [[ $strings_version == 1 ]];then
    return
fi
strings_version=1

# (s, sub): errno
function strings_end_with
{
    local i=$((${#1}-${#2}))
    if ((i>=0)) && [[ "${1:i}" == "$2" ]];then
        return 0
    else
        result_errno="strings_end_with: false"
        return 1
    fi
}
# (s, sub): errno
function strings_start_with
{
    local n=${#2}
    if [[ "${1:0:n}" == "$2" ]];then
        return 0
    else
        result_errno="strings_start_with: false"
        return 1
    fi
}

# if not found return -1
# (s, chars): number
function strings_index_ofchar
{
    result=-1
    if [[ $1 == '' ]] || [[ $2 == '' ]];then
        return
    fi
    local s=$1
    local ns=${#s}
    local chars=$2
    local nchars=${#chars}
    local i
    local j
    local c0
    local c1
    for ((i=0;i<ns;i++));do
        c0=${s:i:1}
        if [[ $nchars == 1 ]];then
            if [[ $c0 == $chars ]];then
                result=$i
                return
            fi
        else
            for ((j=0;j<nchars;j++));do
                c1=${chars:j:1}
                if [[ $c0 == $c1 ]];then
                    result=$i
                    return
                fi
            done
        fi
    done
}

# if not found return -1
# (s, chars): number
function strings_last_ofchar
{
    result=-1
    if [[ $1 == '' ]] || [[ $2 == '' ]];then
        return
    fi
    local s=$1
    local ns=${#s}
    local chars=$2
    local nchars=${#chars}
    local i
    local j
    local c0
    local c1
    for ((i=ns-1;i>=0;i--));do
        c0=${s:i:1}
        if [[ $nchars == 1 ]];then
            if [[ $c0 == $chars ]];then
                result=$i
                return
            fi
        else
            for ((j=0;j<nchars;j++));do
                c1=${chars:j:1}
                if [[ $c0 == $c1 ]];then
                    result=$i
                    return
                fi
            done
        fi
    done
}

# split string
# (s, separators): []string
function strings_split
{
    local ifs=$IFS
    IFS="$2"
    result=($1)
    IFS=$ifs
}

# (s...): string
function strings_join
{
    result=''
    local s
    for s in "${@}";do
        result="$result$s"
    done
}
# (separator,s...): string
function strings_join_with
{
    result=''
    local sep=$1
    shift

    local n=${#@}
    local i=0
    for ((;i<n;i++));do
        if [[ $i == 0 ]];then
            result="$1"
        else
            result="$result$sep$1"
        fi
        shift
    done
}