#!/bin/bash

# false: '' or 'false' or 'FALSE' or 0
# true: != ('' or 'false' or 'FALSE' or 0)
# (val): true | false
function bool_string
{
    if [ "$1" == '' ] || [ "$1" == false ] || [ "$1" == FALSE ] || [ "$1" == 0 ];then
        result=false
    else
        result=true
    fi
    errno=0
}
# != ('' or 'false' or 'FALSE' or 0) ? 1 : 0
# (val): 1|0
function bool_true
{
    if [ "$1" == '' ] || [ "$1" == false ] || [ "$1" == FALSE ] || [ "$1" == 0 ];then
        result=0
    else
        result=1
    fi
    errno=0
}
# == ('' or 'false' or 'FALSE' or 0) ? 1 : 0
# (val): 1|0
function bool_false
{
    if [ "$1" == '' ] || [ "$1" == false ] || [ "$1" == FALSE ] || [ "$1" == 0 ];then
        result=1
    else
        result=0
    fi
    errno=0
}

function __duration_string
{
    if ((v>=compare));then
        div=$((v/compare))
        v=$((v%compare))
        if [ "$s" == '' ];then
            s="$div$tag"
        else
            s="$s$div$tag"
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
    errno=0
    result=''

    if echo "$1" | egrep -vsq '^[0-9]+$'; then
        errno=1
        result="not a duration: $1"
        return 0
    fi

    local v="$1"
    local s=''
    local div

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
        if [ "$s" == '' ];then
            s="${v}s"
        else
            s="$s${v}s"
        fi
    fi
    
    if [ "$s" == '' ];then
        result=0s
    else
        result=$s
    fi
}

# errno
# (s: string): number
function duration_parse
{
    errno=0
    result=''
    local s="$1"
    local i=0
    local n=${#s}
    local sum=0
    local v=''
    local c
    for ((;i<n;i++));do
        c=${s:i:1}
        case "$c"  in
            0|1|2|3|4|5|6|7|8|9)
                v="$v$c"
            ;;
            d)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a duration string: $1"
                    return
                fi
                sum=$((sum+v*86400))
                v=''
            ;;
            h)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a duration string: $1"
                    return
                fi
                sum=$((sum+v*3600))
                v=''
            ;;
            m)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a duration string: $1"
                    return
                fi
                sum=$((sum+v*60))
                v=''
            ;;
            s)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a duration string: $1"
                    return
                fi
                sum=$((sum+v))
                v=''
            ;;
            *)
                errno=1
                result="not a duration string: $1"
                return
            ;;
        esac
    done
    if [ "$v" == '' ];then
        result=$sum
    else
        errno=1
        result="not a duration string: $1"
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
    errno=0
    result=''

    if echo "$1" | egrep -vsq '^[0-9]+$'; then
        errno=1
        result="not a size: $1"
        return 0
    fi

    local v="$1"
    local s=''
    local div

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
        if [ "$s" == '' ];then
            s="${v}b"
        else
            s="$s${v}b"
        fi
    fi
    
    if [ "$s" == '' ];then
        result=0b
    else
        result=$s
    fi
}

# errno
# (s: string): number
function size_parse
{
    errno=0
    result=''
    local s="$1"
    local i=0
    local n=${#s}
    local sum=0
    local v=''
    local c
    for ((;i<n;i++));do
        c=${s:i:1}
        case "$c"  in
            0|1|2|3|4|5|6|7|8|9)
                v="$v$c"
            ;;
            t)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a size string: $1"
                    return
                fi
                sum=$((sum+v*1099511627776))
                v=''
            ;;
            g)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a size string: $1"
                    return
                fi
                sum=$((sum+v*1073741824))
                v=''
            ;;
            m)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a size string: $1"
                    return
                fi
                sum=$((sum+v*1048576))
                v=''
            ;;
            k)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a size string: $1"
                    return
                fi
                sum=$((sum+v*1024))
                v=''
            ;;
            b)
                if [ "$v" == '' ];then
                    errno=1
                    result="not a size string: $1"
                    return
                fi
                sum=$((sum+v))
                v=''
            ;;
            *)
                errno=1
                result="not a size string: $1"
                return
            ;;
        esac
    done
    if [ "$v" == '' ];then
        result=$sum
    else
        errno=1
        result="not a size string: $1"
    fi
}