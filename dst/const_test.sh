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
        assert_true "$item";

        bool_string "$item"; ec=$errno; v=$result;
        assert_equal 0 "$ec"
        assert_equal true "$v"

        bool_true "$item"; ec=$errno; v=$result;
        assert_equal 0 "$ec"
        assert_equal 1 "$v"

        bool_false "$item"; ec=$errno; v=$result;
        assert_equal 0 "$ec"
        assert_equal 0 "$v"
    done

    local test_false=(
        0
        false
        FALSE
    )
    for v in "${test_false[@]}";do
        assert_false "$v"

        bool_string "$v"; ec=$errno; v=$result;
        assert_equal 0 "$ec"
        assert_equal false "$v"

        bool_true "$v"; ec=$errno; v=$result;
        assert_equal 0 "$ec"
        assert_equal 0 "$v"

        bool_false "$v"; ec=$errno; v=$result;
        assert_equal 0 "$ec"
        assert_equal 1 "$v"
    done
}
test_bool

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
    local ec
    local s
    local count=${#items[@]}
    local i
    v=0
    for ((i=0;i<count;i=i+2));do
        duration_string "${items[i]}"; ec=$errno; s=$result;
        assert_equal 0 $ec
        assert_equal "${items[i+1]}" "$s" "${items[i+1]}"

        duration_parse "$s"; ec=$errno; s=$result;
        assert_equal 0 $ec
        assert_equal "${items[i]}" "$s" "${items[i+1]}"
    done
    
    duration_string 12.34; ec=$errno;
    assert_equal 1 $ec
    
    duration_parse "1"; ec=$errno;
    assert_equal 1 $ec
}
test_duration

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
    local ec
    local s
    local count=${#items[@]}
    local i
    v=0
    for ((i=0;i<count;i=i+2));do
        size_string "${items[i]}"; ec=$errno; s=$result;
        assert_equal 0 $ec
        assert_equal "${items[i+1]}" "$s" "${items[i+1]}"

        size_parse "$s"; ec=$errno; s=$result;
        assert_equal 0 $ec
        assert_equal "${items[i]}" "$s" "${items[i+1]}"
    done
    
    size_string 12.34; ec=$errno;
    assert_equal 1 $ec
    
    size_parse "1"; ec=$errno;
    assert_equal 1 $ec
}
test_size