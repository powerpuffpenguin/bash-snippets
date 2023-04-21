#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source core.sh


test_getopt(){
    __core_getopt -fn0 1 2 3
    assert_equal n0 "$name" '__core_getopt -fn0 1 2 3'
    s="${args[@]}"
    assert_equal '1 2 3' "$s" '__core_getopt -fn0 1 2 3'

    assert_equal 0 "$is_trace" '__core_getopt -fn0 1 2 3'
    assert_equal 0 "$is_caller" '__core_getopt -fn0 1 2 3'


    __core_getopt -tf n2 a b c
    assert_equal n2 "$name" '__core_getopt -tf n2 a b c'
    s="${args[@]}"
    assert_equal 'a b c' "$s" '__core_getopt -tf n2 a b c'
    assert_equal 1 "$is_trace" '__core_getopt -tf n2 a b c'
    assert_equal 0 "$is_caller" '__core_getopt -tf n2 a b c'

    __core_getopt -tcfn2 a b c
    assert_equal n2 "$name" '__core_getopt -tf n2 a b c'
    s="${args[@]}"
    assert_equal 'a b c' "$s" '__core_getopt -tf n2 a b c'
    assert_equal 1 "$is_trace" '__core_getopt -tf n2 a b c'
    assert_equal 1 "$is_caller" '__core_getopt -tf n2 a b c'
}