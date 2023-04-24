#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source core.sh
source command.sh

test_flags(){
    assert_call_false command_flags -v abc

    assert_call_true command_begin root
    assert_call_true command_flags -v addr -l=addr -sa --type string '--describe=listen address'
}