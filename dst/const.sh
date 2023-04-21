#!/bin/bash
if [[ -v const_version ]] && [[ $const_version =~ ^[0-9]$ ]] && ((const_version>=1));then
    return
fi
const_version=1

# false: '' or 'false' or 'FALSE' or 0
# true: != ('' or 'false' or 'FALSE' or 0)
# (val): true | false
function bool_string
{
    if [[ "$1" == '' ]] || [[ "$1" == false ]] || [[ "$1" == FALSE ]] || [[ "$1" == 0 ]];then
        result=false
    else
        result=true
    fi
}
# != ('' or 'false' or 'FALSE' or 0) ? 0 : errno
function bool_true
{
    if [[ "$1" == '' ]] || [[ "$1" == false ]] || [[ "$1" == FALSE ]] || [[ "$1" == 0 ]];then
        result_errno="not true: $1"
        return 1
    else
        return 0
    fi
}
# == ('' or 'false' or 'FALSE' or 0) ? 0 : errno
function bool_false
{
    if [[ "$1" == '' ]] || [[ "$1" == false ]] || [[ "$1" == FALSE ]] || [[ "$1" == 0 ]];then
        return 0
    else
        result_errno="not false: $1"
        return 1
    fi
}
# v: number
# result: join output string
# tag: tag of current number
function __duration_string
{
    if ((v>=compare));then
        local div=$((v/compare))
        v=$((v%compare))
        if [[ $result == '' ]];then
            result="$div$tag"
        else
            result="$result$div$tag"
        fi
    fi
}
duration_second=1
duration_minute=60
duration_hour=3600
duration_day=86400

# errno
# (duration: number): string
function duration_string
{
    result=''

    if [[ ! $1 =~ ^[0-9]+$ ]]; then
        result_errno="not a duration: $1"
        return 1
    fi
    local v=$1

    local compare=86400
    local tag=d
    __duration_string

    compare=3600
    tag=h
    __duration_string

    compare=60
    tag=m
    __duration_string

    if ((v>0));then
        if [[ $result == '' ]];then
            result="${v}s"
        else
            result="$result${v}s"
        fi
        return
    fi
    
    if [[ $result == '' ]];then
        result=0s
    fi
}

# errno
# (s: string): number
function duration_parse
{
    result=''
    local s=$1
    local i=0
    local n=${#s}
    local sum=0
    local v
    local c
    for ((;i<n;i++));do
        c=${s:i:1}
        case "$c"  in
            0|1|2|3|4|5|6|7|8|9)
                v="$v$c"
            ;;
            d)
                if [[ $v == '' ]];then
                    result_errno="not a duration string: $1"
                    return 1
                fi
                sum=$((sum+v*86400))
                v=''
            ;;
            h)
                if [[ $v == '' ]];then
                    result_errno="not a duration string: $1"
                    return 1
                fi
                sum=$((sum+v*3600))
                v=''
            ;;
            m)
                if [[ $v == '' ]];then
                    result_errno="not a duration string: $1"
                    return 1
                fi
                sum=$((sum+v*60))
                v=''
            ;;
            s)
                if [[ $v == '' ]];then
                    result_errno="not a duration string: $1"
                    return 1
                fi
                sum=$((sum+v))
                v=''
            ;;
            *)
                result_errno="not a duration string: $1"
                return 1
            ;;
        esac
    done
    if [[ $v == '' ]];then
        result=$sum
    else
        result_errno="not a duration string: $1"
        return 1
    fi
}

size_b=1
size_k=1024
size_m=1048576
size_g=1073741824
size_t=1099511627776

# errno
# (size: number): string
function size_string
{
    result=''
    if [[ ! $1 =~ ^[0-9]+$ ]]; then
        result_errno="not a size: $1"
        return 1
    fi

    local v=$1

    local compare=1099511627776
    local tag=t
    __duration_string

    compare=1073741824
    tag=g
    __duration_string

    compare=1048576
    tag=m
    __duration_string

    compare=1024
    tag=k
    __duration_string

    if ((v>0));then
        if [[ $result == '' ]];then
            result="${v}b"
        else
            result="$result${v}b"
        fi
        return
    fi
    
    if [[ $result == '' ]];then
        result=0b
    fi
}

# errno
# (s: string): number
function size_parse
{
    result=''
    local s=$1
    local i=0
    local n=${#s}
    local sum=0
    local v
    local c
    for ((;i<n;i++));do
        c=${s:i:1}
        case "$c"  in
            0|1|2|3|4|5|6|7|8|9)
                v="$v$c"
            ;;
            t)
                if [[ $v == '' ]];then
                    result_errno="not a size string: $1"
                    return 1
                fi
                sum=$((sum+v*1099511627776))
                v=''
            ;;
            g)
                if [[ $v == '' ]];then
                    result_errno="not a size string: $1"
                    return 1
                fi
                sum=$((sum+v*1073741824))
                v=''
            ;;
            m)
                if [[ $v == '' ]];then
                    result_errno="not a size string: $1"
                    return 1
                fi
                sum=$((sum+v*1048576))
                v=''
            ;;
            k)
                if [[ $v == '' ]];then
                    result_errno="not a size string: $1"
                    return 1
                fi
                sum=$((sum+v*1024))
                v=''
            ;;
            b)
                if [[ $v == '' ]];then
                    result_errno="not a size string: $1"
                    return 1
                fi
                sum=$((sum+v))
                v=''
            ;;
            *)
                result_errno="not a size string: $1"
                return 1
            ;;
        esac
    done
    if [[ $v == '' ]];then
        result=$sum
    else
        result_errno="not a size string: $1"
        return 1
    fi
}