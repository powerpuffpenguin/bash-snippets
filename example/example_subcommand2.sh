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
core_call_default command_begin --name web \
    --short 'Start a web server' \
    --func on_web
web=$result
# define flags of web
core_call_default command_flags -t string -d "Listen address" \
    -v listen -l listen -s l \
    -D '::'
core_call_default command_flags -t string -d "Listen port" \
    -v port -l port -s p \
    -D '80' --min 1 --max 65535
core_call_default command_flags -t bool -d "Run as debug mode" \
    -v debug -l debug
core_call_default command_flags -t bool -d "Enable h2c supported" \
    -v h2c -l h2c

# commit web
core_call_default command_commit

### subcommand grpc of root.client ###
on_grpc(){
    echo "--- on_grpc ---"
    echo "url=$url"
    echo "debug=$debug"
    echo "args[${#@}]=($@)"
}
core_call_default command_begin --name grpc \
    --short 'A grpc client' \
    --func on_grpc
grpc=$result
core_call_default command_flags -t string -d "Connect Address" \
    -v url -l url -s u \
    -D 'http://127.0.0.1'
core_call_default command_flags -t bool -d "Run as debug mode" \
    -v debug -l debug -s d

core_call_default command_commit

### subcommand client of root ###
on_client(){
    echo "--- on_client ---"
    echo "url=$url"
    echo "debug=$debug"
    echo "args[${#@}]=($@)"
}
core_call_default command_begin --name client \
    --short 'A http client' \
    --func on_client
client=$result
core_call_default command_flags -t string -d "Connect URL" \
    -v url -l url -s u \
    -D 'http://127.0.0.1'
core_call_default command_flags -t bool -d "Run as debug mode" \
    -v debug -l debug

core_call_default command_children "$web" "$grpc"
core_call_default command_commit

### root ###
on_main(){
    echo "--- on_main ---"
    echo "version=$version"
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

# set subcommand 
command_children "$web" "$client"

# commit root
command_commit

# parse and execute
command_execute "$root" "$@"