#!/bin/bash

cd `dirname $BASH_SOURCE`

source log.sh

# log to file
log_to_file="example.log"
log_trace this is trace message
log_debug this is debug message
log_info this is info message
log_warn this is warn message
log_error this is error message

# log to stdout
log_to_file=''
calls=0
function log_after_stdout
{
    calls=$((calls+1))

    # After output to stdout can output to file at the same time
    echo "$@" >> "example_after.log"
}
log_trace this is trace message
log_debug this is debug message
log_info this is info message
log_warn this is warn message
log_error this is error message
log_fatal this is fatal message "calls=$calls"
