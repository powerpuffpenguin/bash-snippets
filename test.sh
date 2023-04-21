#!/bin/bash
set -e

Command=`basename $BASH_SOURCE`

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
function date_now
{
    echo `date +%s`.`date +%N`
}
function trim_start_0
{
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
function trim_end_0
{
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
function date_used
{
    local s=$1
    local s0=${s%%.*}
    local ns0=${s##*.}
    ns0=`trim_start_0 $ns0`
    s=`date_now`
    local s1=${s%%.*}
    local ns1=${s##*.}
    ns1=`trim_start_0 $ns1`
    if ((ns1>ns0));then
        s=$((s1-s0))
        local ns=$((ns1-ns0))
    else
        s=$((s1- s0-1))
        local ns=$((ns1+1000000000-ns0))
    fi
    ns=`printf '%09d' $ns`
    ns=`trim_end_0 $ns`
    if [[ $ns == 0 ]];then
        echo $s
    else
        echo $s.$ns
    fi
}
# alreay test count
_TestCount=0
# alreay test files
_TestFiles=0
start=`date_now`
function test_method
{
    _TestCount=$((_TestCount+1))
    if [[ $TestSilent == 0 ]];then
        local start=`date_now`
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
        echo " - $2 `date_used $start`s"
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
        local start=`date_now`
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
        echo " * $count passed, used `date_used $start`s"
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
echo "test $_TestFiles files, $_TestCount passed, used `date_used $start`s"
