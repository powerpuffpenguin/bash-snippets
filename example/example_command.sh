#!/bin/bash
set -e

cd `dirname $BASH_SOURCE`

source ../dst/command.sh
source ../dst/core.sh

main(){
    core_call_default command_begin --name "`basename $BASH_SOURCE`" \
        --short 'Example for command.sh'

    core_call_default command_flags --type string '--describe=Listen address' \
        -v listen --long=listen -sl \
        --default=::
    core_call_default command_flags --type uint --describe 'Listen port' \
        -v port --long port --short p \
        --default 80
    core_call_default command_flags -t int '-d=Work threads, -1 number of CPUs' \
        -v thread -lthreads \
        -D-1 \
        --max 32 --min=-1
    core_call_default command_flags -t strings -d 'Time zone' \
        -v zone -l zone -s z \
        -V Taiwan -V Japan -V "T J" -V America \
        -D Taiwan -D Japan
    core_call_default command_flags -t strings -d 'Allowed upload file name' \
        -v upload -l upload -s u\
        -P '*.txt' -P '*.jpg'
    core_call_default command_flags -t strings -d 'Access token list' \
        -v tokens -l tokens \
        -R '^[a-zA-Z0-9]+$' -R 'king*'

    # __command_1_name=abc123
    # __command_2_name=def
    # __command_1_short='short abc'
    # __command_2_short='short def'
    # __command_children=(1 2)

    core_call_default command_commit
    # echo "$result"
    __command_0_help
}
main "$@"



