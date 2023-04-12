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
# log_fatal this is fatal message "calls=$calls"

function a
{
    code="a1 $@"
}
function b
{
    code=b1
}
x=(
    1
    2
    "3 4"
)
# y=("${x[@]}")
# echo x.len=${#x[@]} y.len=${#y[@]}
# echo ${y[0]} ${y[1]} ${y[2]}
a=1;    value=("${x[@]}");
echo "a=$a"
echo "len=${#value[@]}"
i=0
for val in "${value[@]}";do
    echo "value[$i] = $val"
    i=$((i+1))
done