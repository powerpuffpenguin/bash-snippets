#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source time.sh


test_duration(){
    local items=(
        0 0s
        $time_second 1s
        $time_minute 1m
        $time_hour 1h
        $time_day 1d

        $((time_day*2+time_hour*3+time_minute*4+time_second*5)) 2d3h4m5s
        $((time_day*2+time_minute*4+time_second*5)) 2d4m5s
        $((time_day*2+time_hour*3+time_second*5)) 2d3h5s
        $((time_hour*3+time_second*5)) 3h5s
    )
    
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+2));do
        assert_call_equal "${items[i+1]}" time_string "${items[i]}"
        assert_call_equal "${items[i]}" time_parse "$result"
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
        assert_call_false time_string "$s"
    done
    
    items=(
        1
    )
    for s in "${items[@]}";do
        assert_call_false time_parse "$s"
    done
}

