#!/bin/bash

function _assert_print
{
    local field="$1"
    shift
    printf "      %20s %s\n" "$field" "$@"
}
function _assert_error
{
    local line
    local sub
    local file
    read line sub file < <(caller 1)

    local name=`basename "$file"`
    echo "--- FAIL: $sub"
    echo "    $name:$line:"
    _assert_print "Error Trace:" "$file:$line"
    _assert_print "Error:" "$1"
    _assert_print "" "expected: $2"
    _assert_print "" "actual  : $3"

    shift 3
    if [[ "$@" != '' ]];then
        _assert_print "Message:" "$@"
    fi

    _assert_print "Test:" "$sub"
    exit 1
}
# (msg...)
function assert_message
{
    local line
    local sub
    local file
    read line sub file < <(caller 0)

    local name=`basename "$file"`
    echo "--- FAIL: $sub"
    echo "    $name:$line:"
    _assert_print "Error Trace:" "$file:$line"
    if [[ "$@" != '' ]];then
        _assert_print "Message:" "$@"
    fi
    _assert_print "Test:" "$sub"
    exit 1
}
# (title, expect, actual, msg...)
function assert_error
{
    local line
    local sub
    local file
    read line sub file < <(caller 0)

    local name=`basename "$file"`
    echo "--- FAIL: $sub"
    echo "    $name:$line:"
    _assert_print "Error Trace:" "$file:$line"
    _assert_print "Error:" "$1"
    _assert_print "" "expected: $2"
    _assert_print "" "actual  : $3"

    shift 3
    if [[ "$@" != '' ]];then
        _assert_print "Message:" "$@"
    fi

    _assert_print "Test:" "$sub"
    exit 1
}
# (expect, actual, msg...)
function assert_equal
{
    if [ "$1" == "$2" ];then
        return 0
    fi

    local expect="$1"
    local actual="$2"
    shift 2
    _assert_error "Not equal:" "$expect" "$actual" "$@"
}

# assert actual == '' or 'false' or 'FALSE' or 0
# (actual, msg...)
function assert_false
{
    if [ "$1" == '' ] || [ "$1" == false ] || [ "$1" == FALSE ] || [ "$1" == 0 ];then
        return 0
    fi

    local actual="$1"
    shift 1
    _assert_error "Should be false" "'' or false or FALSE or 0" "$actual" "$@"
}

# assert actual != ('' or 'false' or 'FALSE' or 0)
# (actual, msg...)
function assert_true
{
    if [ "$1" == '' ] || [ "$1" == false ] || [ "$1" == FALSE ] || [ "$1" == 0 ];then
        local actual="$1"
        shift 1
        _assert_error "Should be true" "!= ('' or false or FALSE or 0)" "$actual" "$@"
    fi
}
