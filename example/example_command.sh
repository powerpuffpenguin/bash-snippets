#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`
source ../dst/command.sh

# define a command as root command
command_new "$BASH_SOURCE" 'Example for command.sh'
root=$result


# define a command as a subcommand
define_version(){
    command_new version


    # add to parent
    command_subcommands $root $result
}
define_version
execute_version(){ # callbackup for command version
    echo version
}

# define a command as a subcommand
define_help(){
    command_new help

    # add to parent
    command_subcommands $root $result
}
define_help
execute_help(){ # callbackup for command help
    echo help
}




# execute root command
command_execute "$root" "$@"