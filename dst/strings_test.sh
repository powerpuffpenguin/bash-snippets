#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source strings.sh

 test_start_with(  )
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

    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+2));do
        assert_call_true strings_start_with "${items[i]}" "${items[i+1]}"
    done

    items=(
        ab abab
        ab 123
        "" a
        ab "ab*"
    )
    count=${#items[@]}
    for ((i=0;i<count;i=i+2));do
        assert_call_false strings_start_with "${items[i]}" "${items[i+1]}"
    done
}
test_end_with(){
    local items=(
        abc ""
        abc c
        "ab cd" " cd"
        "ab cd" "b cd"
        "ab cd" "d"
        "ab'\"" "'\""
        "ab'\"" "ab'\""
    )

    local count=${#items[@]}
    local i
    v=0
    for ((i=0;i<count;i=i+2));do
        assert_call_true strings_end_with "${items[i]}" "${items[i+1]}"
    done

    items=(
        ab abab
        ab 123
        "" a
        ab "ab*"
    )
    count=${#items[@]}
    for ((i=0;i<count;i=i+2));do
        assert_call_false strings_end_with "${items[i]}" "${items[i+1]}"
    done
}
 test_index_ofchar ( )
{
    local items=(
        "12345" "a" -1
        "12345" "3" 2
        "12345" "a3" 2
        "12345" "3b" 2
        "12345" "5" 4
        "1234\"" "5\"" 4
        "1234'x1" "'x" 4
        "1234'x1" "x'" 4
    )
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+3));do
        assert_call_equal  "${items[i+2]}" \
            strings_index_ofchar "${items[i]}" "${items[i+1]}"
    done
}
function test_last_ofchar
{
    local items=(
        "12345" "a" -1
        "12345" "3" 2
        "12345" "a3" 2
        "12345" "3b" 2
        "12345" "5" 4
        "1234\"" "5\"" 4
        "1234'x1" "'x" 5
        "1234'x1" "x'" 5
    )
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+3));do
        assert_call_equal "${items[i+2]}" \
            strings_last_ofchar "${items[i]}" "${items[i+1]}"
    done
}
function test_split
{
    local items=(
        "a , b,c.d,e,f" ",." "a  bcdef" 6
        "1 2   3 4.5, 6 8 ,9" " .," "12345689" 8
    )
    local ec
    local strs
    local count=${#items[@]}
    local s
    for ((i=0;i<count;i=i+4));do
        assert_call_true strings_split \
            "${items[i]}" "${items[i+1]}"
        assert_equal "${items[i+3]}" "${#result[@]}" "strings_split(${items[i]}, ${items[i+1]})"

        assert_call_equal "${items[i+2]}" \
            strings_join "${result[@]}"
    done    
}
function test_join_with
{
    assert_call_equal  a \
        strings_join_with , a
    assert_call_equal "b 1,c" \
        strings_join_with , 'b 1' c
    assert_call_equal "b 1_x_c_x_d" \
        strings_join_with "_x_" 'b 1' c d
    assert_call_equal 1234 \
        strings_join_with "" 1 2 3 4
}