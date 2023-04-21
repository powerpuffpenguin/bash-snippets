#!/bin/bash

cd `dirname $BASH_SOURCE`

source ./example_core.sh

a(){
    error "test on" a
}

result_error=0
echo $result_error
core_call -tce abc -f a
echo "result_error=$result_error abc=$abc"

core_call_assert a
echo never