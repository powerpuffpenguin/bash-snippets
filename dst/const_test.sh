#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source const.sh

function test_bool
{
    local test_true=(
        1
        2
        true
        TRUE
        fALSE
    )
    local item
    local ec
    local v
    for item in "${test_true[@]}";do
        assert_true "$item"

        assert_call_equal true bool_string "$item"
        assert_call_true  bool_true "$item"
        assert_call_false bool_false "$item"
    done

    local test_false=(
        0
        false
        FALSE
    )
    for v in "${test_false[@]}";do
        assert_false "$v"

        assert_call_equal false bool_string "$v"
        assert_call_false bool_true "$v"
        assert_call_true bool_false "$v"
    done
}


function test_duration
{
    local items=(
        0 0s
        $duration_second 1s
        $duration_minute 1m
        $duration_hour 1h
        $duration_day 1d

        $((duration_day*2+duration_hour*3+duration_minute*4+duration_second*5)) 2d3h4m5s
        $((duration_day*2+duration_minute*4+duration_second*5)) 2d4m5s
        $((duration_day*2+duration_hour*3+duration_second*5)) 2d3h5s
        $((duration_hour*3+duration_second*5)) 3h5s
    )
    
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+2));do
        assert_call_equal "${items[i+1]}" duration_string "${items[i]}"
        assert_call_equal "${items[i]}" duration_parse "$result"
    done
    
    items=(
        ''
        12.34
        a12
        12a
        1a2
    )
    local s
    for s in "${items[@]}";do
        assert_call_false duration_string "$s"
    done
    
    items=(
        1
    )
    for s in "${items[@]}";do
        assert_call_false duration_parse "$s"
    done
}


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
