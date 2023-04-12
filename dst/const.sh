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
duration_second=1
duration_minute=60
duration_hour=3600
duration_day=86400

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

    if ((v>=86400));then
        div=$((v/86400))
        v=$((v%86400))
        s="${div}d"
    fi

    if ((v>=3600));then
        div=$((v/3600))
        v=$((v%3600))
        if [ "$s" == '' ];then
            s="${div}h"
        else
            s="$s${div}h"
        fi
    fi

    if ((v>=60));then
        div=$((v/60))
        v=$((v%60))
        if [ "$s" == '' ];then
            s="${div}m"
        else
            s="$s${div}m"
        fi
    fi

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