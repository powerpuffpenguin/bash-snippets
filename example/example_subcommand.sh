#!/bin/bash
set -e

cd `dirname $BASH_SOURCE`

source ../dst/command.sh
source ../dst/core.sh

# define root command
on_main(){
    echo "--- on_main ---"
    echo "version=$version"
    echo "args[${#@}]=($@)"
}
core_call_default command_begin --name "`basename $BASH_SOURCE`" \
    --short 'Example of subcommand for command.sh' \
    --func on_main
root=$result

core_call_default command_flags -d "display version" \
    -v version --long version --short v


core_call_default command_commit

# execute root command parse
core_call_default command_execute "$root" "$@"