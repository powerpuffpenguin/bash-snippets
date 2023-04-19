#!/bin/bash

cd `dirname $BASH_SOURCE`

source ../dst/command.sh

# define a command as root command
command_begin
root=$result
command_commit


# define a command as a subcommand
define_version(){
    command_begin
    local cmd=$result
    command_commit
}
define_version
execute_version(){
    echo version
}

# Add subcommands to parent command

# execute root command
command_execute "$root" "$@"