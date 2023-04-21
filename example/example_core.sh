#!/bin/bash

cd `dirname $BASH_SOURCE`

source ../dst/core.sh

error() {
    local errno=${#@}
    if [[ $errno == 0 ]];then
        result_errno="default error"
        errno=-1
    else
        result_errno="$@"
    fi
    return $errno
}

core_call -f date +%s

# error not do any things
core_call -f error test

core_call -tf error test print trace on error

core_call -tcf error test print trace caller on error