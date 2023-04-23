#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source size.sh


function test_size
{
    local items=(
        0 0b
        $size_k 1k
        $size_m 1m
        $size_g 1g
        $size_t 1t

        $((size_t*2+size_g*3+size_m*4+size_k*5+size_b*6)) 2t3g4m5k6b
        $((size_t*2+size_g*3+size_m*4+size_k*5)) 2t3g4m5k
        $((size_t*2+size_m*4+size_k*5+size_b*6)) 2t4m5k6b
        $((size_m*4+size_b*6)) 4m6b
    )

    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+2));do
        assert_call_equal "${items[i+1]}" size_string "${items[i]}"
        assert_call_equal "${items[i]}" size_parse "$result"
    done

    assert_call_equal $((size_m*2+4)) size_parse "2m4b"
    assert_call_equal $((size_m*2+5+size_k*4)) size_parse "3b1m2b4k1m"
 
     items=(
        ''
        12.34
        a12
        12a
        1a2
    )
    local s
    for s in "${items[@]}";do
        assert_call_false size_string "$s"
    done

    items=(
        1
    )
    for s in "${items[@]}";do
        assert_call_false size_parse "$s"
    done
}
