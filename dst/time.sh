#/bin/bash
if [[ -v time_version ]] && [[ $time_version =~ ^[0-9]$ ]] && ((time_version>=1));then
    return
fi
time_version=1


# v: number
# result: join output string
# tag: tag of current number
function __time_string
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
time_second=1
time_minute=60
time_hour=3600
time_day=86400

# (duration: number) (s: string, errno)
time_string(){
    result=''

    if [[ ! $1 =~ ^[0-9]+$ ]]; then
        result_errno="not a duration: $1"
        return 1
    fi
    local v=$1

    local compare=86400
    local tag=d
    __time_string

    compare=3600
    tag=h
    __time_string

    compare=60
    tag=m
    __time_string

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

# (s: string) (duration: number, errno)
time_parse(){
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

# (): (unix: string, errno)
# returns the number of seconds elapsed since January 1, 1970 UTC.
time_unix(){
    local s=`date +%s.%N`
    if [[ $s == '' ]];then
        result_errno='command 'date' not found'
        return 1
    elif [[ ! $s =~ ^[0-9]+.[0-9]{9}$ ]];then
        result_errno="command 'date' returned unknown data: $s"
        return 1
    fi
    result=$s
}
__time_trim_start_0(){
    local i=0
    local n=${#1}
    for ((;i<n;i++));do
        if [[ ${1:i:1} != 0 ]];then
          local s=${1:i}
          if [[ $s == '' ]];then
            echo 0
            return
          fi
          echo $s
          return
        fi
    done
    echo 0
}
__time_trim_end_0(){
    local i=${#1}
    for ((i=i-1;i>=0;i--));do
        if [[ ${1:i:1} != 0 ]];then
          local s=${1:0:i}
          if [[ $s == '' ]];then
            echo 0
            return
          fi
          echo $s
          return
        fi
    done
    echo 0
}

# (from: unix, to: unix): string
# returns the elapsed time from 'from' to 'to'
time_used(){
    if [[ ! $1 != ^[0-9]+.[0-9]{9}$ ]];then
        result_errno="parameter 'from' not a valid unix string: $1"
        return 1
    elif [[ ! $2 != ^[0-9]+.[0-9]{9}$ ]];then
        result_errno="parameter 'from' not a valid unix string: $2"
        return 1
    fi
    local s0=${s%%.*}
    if [[ $s0 != 0 ]] && [[ $s0 == ^0[0-9]+$ ]];then
        result_errno="parameter 'from' not a valid unix string: $1"
        return 1
    fi
    local s1=${s%%.*}
    if [[ $1 != 0 ]] && [[ $s1 == ^0[0-9]+$ ]];then
        result_errno="parameter 'from' not a valid unix string: $2"
        return 1
    fi
    local ns0=${s##*.}
    ns0=`__time_trim_start_0 $ns0`
    local ns1=${s##*.}
    ns1=`__time_trim_start_0 $ns1`

    if ((ns1>ns0));then
        local s=$((s1-s0))
        local ns=$((ns1-ns0))
    else
        local s=$((s1-s0-1))
        local ns=$((ns1+1000000000-ns0))
    fi
    ns=`__time_trim_end_0 $ns`

    if [[ $ns == 0 ]];then
        result=$s
    else
        result=$s.$ns
    fi
}
# (from: unix): string
# returns the time elapsed since 'from'
time_since(){
    time_unix
    time_used "$result" $1
}