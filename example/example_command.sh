#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`
source ../dst/command.sh

# define a command as root command
command_new "$BASH_SOURCE" '' 'Example for command.sh'
root=$result


# define a command as a subcommand
define_version(){
    command_new version execute_version "version info"


    # add to parent
    command_subcommands $root $result
}
define_version
execute_version(){ # callbackup for command version
    echo version
}

# define a command as a subcommand
define_start(){
    command_new start execute_start "start the service"

    # add to parent
    command_subcommands $root $result
}
define_start
execute_start(){ # callbackup for command help
    echo help
}




# execute root command
command_execute "$root" "$@"