#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source strings.sh

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

    strings_end_with "ab" "abab"; ec=$errno; ok=$result;
    assert_equal 0 $ec
    assert_equal 0 "$ok" "strings_end_with(ab,abab)"
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

    strings_end_with "ab" "abab"; ec=$errno; ok=$result;
    assert_equal 0 $ec
    assert_equal 0 "$ok" "strings_end_with(ab,abab)"
}
function test_index_ofchar
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
    local ec
    local ok
    local count=${#items[@]}
    local i
    v=0
    for ((i=0;i<count;i=i+3));do
        strings_index_ofchar "${items[i]}" "${items[i+1]}"
        assert_equal 0 $errno
        assert_equal "${items[i+2]}" $result "strings_index_ofchar(${items[i]}, ${items[i+1]})"
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
    local ec
    local ok
    local count=${#items[@]}
    local i
    v=0
    for ((i=0;i<count;i=i+3));do
        strings_last_ofchar "${items[i]}" "${items[i+1]}"
        assert_equal 0 $errno
        assert_equal "${items[i+2]}" $result "strings_last_ofchar(${items[i]}, ${items[i+1]})"
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
        strings_split "${items[i]}" "${items[i+1]}"; ec=$errno; strs=$result;
        assert_equal 0 $ec "s=${items[i]} sep=${items[i+1]} join=${items[i+2]} n=join=${items[i+3]}"
        assert_equal "${items[i+3]}" "${#result[@]}" "s=${items[i]} sep=${items[i+1]} join=${items[i+2]} n=join=${items[i+3]}"

        strings_join "${result[@]}"; ec=$errno; s=$result;
        assert_equal 0 $ec "s=${items[i]} sep=${items[i+1]} join=${items[i+2]} n=join=${items[i+3]}"
        assert_equal "${items[i+2]}" "$s" "s=${items[i]} sep=${items[i+1]} join=${items[i+2]} n=join=${items[i+3]}"
    done

    
}
function test_join_with
{
    strings_join_with , a
    assert_equal 0 $errno
    assert_equal "a" "$result"

    strings_join_with , 'b 1' c
    assert_equal 0 $errno
    assert_equal "b 1,c" "$result"

    strings_join_with "_x_" 'b 1' c d
    assert_equal 0 $errno
    assert_equal "b 1_x_c_x_d" "$result"

    strings_join_with "" 1 2 3 4
    assert_equal 0 $errno
    assert_equal "1234" "$result"
}