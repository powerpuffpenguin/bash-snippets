#!/bin/bash
set -e

Command=`basename $BASH_SOURCE`

### time begin

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
            break
          fi
          result=$s
          return
        fi
    done
    result=0
}
__time_trim_end_0(){
    local i=${#1}
    for ((i=i-1;i>=0;i--));do
        if [[ ${1:i:1} != 0 ]];then
          local s=${1:0:i+1}
          if [[ $s == '' ]];then
            break
          fi
          result=$s
          return
        fi
    done
    result=0
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
    local s0=${1%%.*}
    if [[ $s0 != 0 ]] && [[ $s0 == ^0[0-9]+$ ]];then
        result_errno="parameter 'from' not a valid unix string: $1"
        return 1
    fi
    local s1=${2%%.*}
    if [[ $1 != 0 ]] && [[ $s1 == ^0[0-9]+$ ]];then
        result_errno="parameter 'from' not a valid unix string: $2"
        return 1
    fi
    __time_trim_start_0 ${1##*.}
    local ns0=$result
    __time_trim_start_0 ${2##*.}
    local ns1=$result

    if ((ns1>=ns0));then
        local s=$((s1-s0))
        local ns=$((ns1-ns0))
    else
        local s=$((s1-s0-1))
        local ns=$((ns1+1000000000-ns0))
    fi
    if [[ $ns == 0 ]];then
        result=$s
    else
        case ${#ns} in
            1)
                ns="00000000$ns"
            ;;
            2)
                ns="0000000$ns"
            ;;
            3)
                ns="000000$ns"
            ;;
            4)
                ns="00000$ns"
            ;;
            5)
                ns="0000$ns"
            ;;
            6)
                ns="000$ns"
            ;;
            7)
                ns="00$ns"
            ;;
            8)
                ns="0$ns"
            ;;
            *)
            ;;
        esac
        __time_trim_end_0 $ns
        result=$s.$result
    fi
}
# (from: unix): string
# returns the time elapsed since 'from'
time_since(){
    time_unix
    time_used $1 "$result" 
}
### time end

# * $1 flag
# * $2 message
function print_flag
{
    printf "  %-20s %s\n" "$1" "$2"
}

TestMethod=""
TestSilent=0
TestDir="$(cd `dirname $BASH_SOURCE` && pwd)"
Test=0
function help
{
    echo "test bash scripts"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    print_flag "-s, --silent" "silent mode (default false)"
    print_flag "-d, --dir" "test file dir (default \"$TestDir\")"
    print_flag "-m, --method" "function name to test (match by egrep)"
    print_flag "-t, --test" "print the test function to be executed, but don't actually execute the test"
    print_flag "-h, --help" "help for $Command"
}

ARGS=`getopt -o hsd:m:t --long help,silent,dir:method:test -n "$Command" -- "$@"`
eval set -- "${ARGS}"

while true; do
    case "$1" in
        -h|--help)
            help
            exit 0
        ;;
        -s|--silent)
            TestSilent=1
            shift
        ;;
        -d|--dir)
            TestDir="$2"
            shift 2
        ;;
        -m|--method)
            TestMethod="$2"
            shift 2
        ;;
        -t|--test)
            Test=1
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "$1" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac 
done

# alreay test count
_TestCount=0
# alreay test files
_TestFiles=0
time_unix
start=$result
function test_method
{
    _TestCount=$((_TestCount+1))
    if [[ $TestSilent == 0 ]];then
        time_unix
        local start=$result
    fi
    if [[ $Test == 0 ]];then
        bash -c "#/bin/bash
set -e
source \"$1\"
set +e
$2
"
    fi
    if [[ $TestSilent == 0 ]];then
        time_since $start
        echo " - $2 ${result}s"
    fi
}
function test_file
{
    if [[ ! -f "$1" ]];then
        echo "file not exists: $1"
        exit 1
    fi
    _TestFiles=$((_TestFiles+1))

    local count=0
    if [[ $TestSilent == 0 ]];then
        echo "$1"
        time_unix
        local start=$result
    fi

    # find test functions
    local s
    local func
    while read -r s func _;do
        if [[ $s == function ]];then
            if [[ $func != test_* ]];then
                continue
            fi
        elif [[ $s == test_* ]];then
            if [[ $s != *\(* ]] && [[ $func != \(* ]];then
                continue
            fi
            func=$s
        else
            continue
        fi
        func=${func%%(*}
        count=$((count+1))
        test_method "$1" "$func"
    done < "$1"

    if [[ $TestSilent == 0 ]];then
        time_since $start
        echo " * $count passed, used ${result}s"
    fi
}

tested=0
for file in "$@";do
    tested=1
    test_file "$file"
done
if [[ $tested == 0 ]];then
    if [[ -d "$TestDir" ]];then
        for s in `find "$TestDir" -type f -iname '*_test.sh'`;do
            test_file "$s"
        done
    else
        echo "dir not exists: $TestDir" 
        exit 1
    fi
fi
time_since $start
echo "test $_TestFiles files, $_TestCount passed, used ${result}s"
