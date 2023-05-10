#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source ../dst/command.sh
source ../dst/core.sh

### subcommand web of root ###
on_web(){
    echo "--- on_web ---"
    echo "listen=$listen"
    echo "port=$port"
    echo "h2c=$h2c"
    echo "debug=$debug"
    echo "args[${#@}]=($@)"
}
# define web
command_begin --name web \
    --short 'Start a web server' \
    --func on_web
web=$result
# define flags of web
command_flags -t string -d "Listen address" \
    -v listen -l listen -s l \
    -D '::'
command_flags -t string -d "Listen port" \
    -v port -l port -s p \
    -D '80' --min 1 --max 65535
command_flags -t bool -d "Run as debug mode" \
    -v debug -l debug
command_flags -t bool -d "Enable h2c supported" \
    -v h2c -l h2c

# commit web
command_commit

### root ###
on_main(){
    echo "--- on_main ---"
    echo "version=$version"
    echo "tag=(${tag[@]})"
    echo "args[${#@}]=($@)"
}
# define root
command_begin --name "`basename $BASH_SOURCE`" \
    --short 'Example of subcommand for command.sh' \
    --func on_main
root=$result

# define flags of root
command_flags -d "display version" \
    -v version -l version -s v
command_flags -t strings -d "display tag" \
    -v tag -s t \
    -V t1 -V t2

# set subcommand 
command_children "$web"

# commit root
command_commit

# parse and execute
command_execute "$root" "$@"
