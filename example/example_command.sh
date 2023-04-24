#!/bin/bash
set -e

cd `dirname $BASH_SOURCE`

source ../dst/command.sh
source ../dst/core.sh

main(){
    core_call_default command_begin "`basename $BASH_SOURCE`" "Example for command.sh"
    core_call_default command_flags -v addr -l=addr -sa --type string '--describe=listen address'
    core_call_default command_flags -v addr -l=addr -sa --type string '--describe=listen address'

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



