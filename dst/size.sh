#/bin/bash
if [[ -v size_version ]] && [[ $size_version =~ ^[0-9]$ ]] && ((size_version>=1));then
    return
fi
size_version=1

size_b=1
size_k=1024
size_m=1048576
size_g=1073741824
size_t=1099511627776

# v: number
# result: join output string
# tag: tag of current number
function __size_string
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
    __size_string

    compare=1073741824
    tag=g
    __size_string

    compare=1048576
    tag=m
    __size_string

    compare=1024
    tag=k
    __size_string

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