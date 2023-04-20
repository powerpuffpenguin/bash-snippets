#!/bin/bash
function __assert_join_args 
{
    s=''
    local n=${#@}
    local i=0
    for ((;i<n;i++));do
        if [[ $i == 0 ]];then
            s="$1"
        else
            s="$s, $1"
        fi
        shift
    done
}
function __assert_print
{
    local field="$1"
    shift
    printf "      %20s %s\n" "$field" "$@"
}
function __assert_error
{
    local line
    local sub
    local file
    read line sub file < <(caller 1)

    local name=`basename "$file"`
    echo "--- FAIL: $sub"
    echo "    $name:$line:"
    __assert_print "Error Trace:" "$file:$line"
    __assert_print "Error:" "$1"
    __assert_print "" "expected: $2"
    __assert_print "" "actual  : $3"

    shift 3
    local msg="$@"
    if [[ $msg != '' ]];then
        __assert_print "Message:" "$msg"
    fi

    __assert_print "Test:" "$sub"
    exit 1
}

# (expect, actual, msg...)
function assert_equal
{
    if [[ $1 == $2 ]];then
        return 0
    fi

    local expect="$1"
    local actual="$2"
    shift 2
    __assert_error "Not equal:" "$expect" "$actual" "$@"
}

# assert actual == '' or 'false' or 'FALSE' or 0
# (actual, msg...)
function assert_false
{
    if [[ $1 == '' ]] || [[ $1 == false ]] || [[ $1 == FALSE ]] || [[ $1 == 0 ]];then
        return 0
    fi

    local actual="$1"
    shift 1
    __assert_error "Should be false" "'' or false or FALSE or 0" "$actual" "$@"
}

# assert actual != ('' or 'false' or 'FALSE' or 0)
# (actual, msg...)
function assert_true
{
    if [[ $1 == '' ]] || [[ $1 == false ]] || [[ $1 == FALSE ]] || [[ $1 == 0 ]];then
        local actual="$1"
        shift 1
        __assert_error "Should be true" "!= ('' or false or FALSE or 0)" "$actual" "$@"
    fi
}
# assert f(args...) == expect
# (expect, f, args...)
function assert_call_equal
{
    local expect=$1
    local f=$2
    shift 2
    local s
    __assert_join_args "$@"
    local msg="$f($s)"

    if ! "$f" "$@";then
        if [[ $result_errno != '' ]];then
            msg="$msg => $result_errno"
        fi
        __assert_error "Function '$f' should be return true" true false "$msg"
        return $?
    fi
    if [[ $expect != $result ]];then
        __assert_error "Function '$f' return not equal:" "$expect" "$result" "$msg"
    fi
}

# assert f(args) bash return 0
# (f, args...)
function assert_call_true
{
    local f=$1
    shift 1
    local s
    __assert_join_args "$@"
    local msg="$f($s)"

    if ! "$f" "$@";then
        if [[ $result_errno != '' ]];then
            msg="$msg => $result_errno"
        fi
        __assert_error "Function '$f' should be return true" true false "$msg"
    fi
}
# assert f(args) bash return != 0
# (f, args...)
function assert_call_false
{
    local f=$1
    shift 1
    local s
    __assert_join_args "$@"
    local msg="$f($s)"

    if "$f" "$@";then
        if [[ $result_errno != '' ]];then
            msg="$msg => $result_errno"
        fi
        __assert_error "Function '$f' should be return false" false true "$msg"
    fi
}