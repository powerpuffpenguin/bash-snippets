#!/bin/bash

# Save all defined command ids
__command=(

)
__command_id=0

# begin define a command
# (name string) (id number)
command_begin(){
    result=$__command_id
}

# commit command to system
# () errno
command_commit(){
    local id=$__command_id


    __command_id=$((__command_id+1))
    local n=${#__command}
    __command[n]=$id
}

# (pid number, children ...number) errno
command_add(){
    local pid=$1
    shift 1
}

# (id number, arg...) errno
# Parse the parameters and execute the command callback function
command_execute(){
    local id=$1
    for s in "${__command[@]}";do
        echo "* '$s'"
    done
}