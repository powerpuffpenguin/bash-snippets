#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source log_writer.sh

# (s, sub): 1|0
function strings_end_with
{
    __log_strings_with "$1" "$2" 0
}
# (s, sub): 1|0
function strings_start_with
{
    __log_strings_with "$1" "$2" 1
}

function test_start_with
{
    local items=(
        abc ""
        abc a
        "ab cd" "ab "
        "ab cd" "ab c"
        "ab cd" "a"
        "ab'\"" "ab'"
        "ab'\"" "ab'\""
    )

    local ec
    local ok
    local count=${#items[@]}
    local i
    v=0
    for ((i=0;i<count;i=i+2));do
        strings_start_with "${items[i]}" "${items[i+1]}"; ec=$errno; ok=$result;
        assert_equal 0 $ec
        assert_equal 1 "$ok" "strings_start_with(${items[i]}, ${items[i+1]})"
    done
}

function test_end_with
{
    local items=(
        abc ""
        abc c
        "ab cd" " cd"
        "ab cd" "b cd"
        "ab cd" "d"
        "ab'\"" "'\""
        "ab'\"" "ab'\""
    )

    local ec
    local ok
    local count=${#items[@]}
    local i
    v=0
    for ((i=0;i<count;i=i+2));do
        strings_end_with "${items[i]}" "${items[i+1]}"; ec=$errno; ok=$result;
        assert_equal 0 $ec
        assert_equal 1 "$ok" "strings_end_with(${items[i]}, ${items[i+1]})"
    done
}