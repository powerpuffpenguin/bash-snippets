#!/bin/bash

# current command id
__command_id=0

# (id: number) errno
__command_checkid()
{
    if ! eval "__command(){
        if [[ ! \$1 =~ ^[0-9]+\$ ]];then
            result_errno=\"id invalid: \$1\"
            return 1
        elif [[ \$__command_${1}_name == '' ]];then
            result_errno=\"command id not defined: \$1\"
            return 1
        fi
    }";then
        result_errno="command_subcommand eval error"
        if [[ $- == *e* ]];then
            echo "$result_errno"
        fi
        return 1
    fi
    __command "$1" "$2"
}

# (... -x var, ...id: number) (... var)  
# __command_get -name names -short shorts 1 2
# -name names
# -func funcs
# -short shorts
# -long longs
__command_get()
{
    local ids=()
    local flags=(
        name ''
        func ''
        short ''
        long ''
    )
    local flags_n=${#flags[@]}
    local s
    local found
    local n=${#@}
    local i
    while ((n>0)); do
        if [[ $1 == -* ]];then
            s=${1:1}
            found=0
            for ((i=0;i<flags_n;i=i+2));do
                if [[ ${flags[i]} == $s ]];then
                    flags[i+1]=$2
                    shift 2
                    found=1
                fi
            done
            if [[ $found == 1 ]];then
                continue
            fi
            result_errno="[__command_get] unknow flag: $1"
            return 1
        elif [[ ! $1 =~ ^[0-9]+$ ]];then
            result_errno="id invalid: $1"
            return 1
        else
            ids+=($1)
            shift
        fi
        n=${#@}
    done
    s="__command_get_eval(){"
    
    local id
    for id in "${ids[@]}";do
        s="$s
    if [[ \$__command_${id}_name == '' ]];then
        result_errno=\"command id not defined: $id\"
        return 1
    fi"
    done

    local name
    n=${#flags[@]}
    for ((i=0;i<n;i=i+2));do
        flag=${flags[i]}
        name=${flags[i+1]}
        if [[ $name == '' ]];then
            continue
        fi
        s="$s
    $name=("
        for id in "${ids[@]}";do
            s="$s
        \"\$__command_${id}_${flag}\""
        done
    s="$s
    )"
    done

    s="$s
    return 0
}"

    if ! eval "$s";then
        result_errno="eval __command_get_eval error"
        return 1
    elif __command_get_eval;then
        return 0
    else
        return $?
    fi
}
__command_get1()
{
    local n=${#@}
    local ids=()
    local name
    local short
    local long
    local func
    while ((n>0)); do
        case "$1" in
            -name)
                name=$2
                shift 2
            ;;
            -short)
                short=$2
                shift 2
            ;;
            -long)
                long=$2
                shift 2
            ;;
            -func)
                func=$2
                shift 2
            ;;
            *)
                if [[ $1 == -* ]];then
                    result_errno="[__command_get] unknow flag: $1"
                    return 1
                elif [[ ! $1 =~ ^[0-9]+$ ]];then
                    result_errno="id invalid: $1"
                    return 1
                fi
                ids+=($1)
                shift
            ;;
        esac
        n=${#@}
    done
    local s="__command_get_eval(){"
    local id
    for id in "${ids[@]}";do
        s="$s
    if [[ \$__command_${id}_name == '' ]];then
        result_errno=\"command id not defined: \$id\"
        return 1
    fi"
    done
    

    if [[ $name != '' ]];then
        s="$s
    $name=("
        for id in "${ids[@]}";do
            s="$s
        \"\$__command_${id}_name\""
        done
    s="$s
    )"
    fi
    if [[ $short != '' ]];then
        s="$s
    $short=("
        for id in "${ids[@]}";do
            s="$s
        \"\$__command_${id}_short\""
        done
    s="$s
    )"
    fi
    if [[ $long != '' ]];then
        s="$s
    $long=("
        for id in "${ids[@]}";do
            s="$s
        \"\$__command_${id}_long\""
        done
    s="$s
    )"
    fi
    if [[ $func != '' ]];then
        s="$s
    $func=("
        for id in "${ids[@]}";do
            s="$s
        \"\$__command_${id}_func\""
        done
    s="$s
    )"
    fi

    s="${s}
    return
}"
    echo "$s "   
}
# new a command
# (name: string, func: string,short_describe = '', long_describe = '') (id number, errno)
command_new(){
    if [[ $1 == '' ]];then
        result_errno="not a valid command name: $1"
        if [[ $- == *e* ]];then
            echo "$result_errno"
        fi
        return 1
    fi
    local id=$__command_id
    eval "__command_${id}_name=\$1
__command_${id}_func=$2
__command_${id}_short=\$3
__command_${id}_long=\$4
__command_${id}_children=()
__command_${id}_var=()
__command_${id}_flags=()
__command_${id}_type=()
__command_${id}_default=()
__command_${id}_values=()
"
    result=$__command_id
    __command_id=$((__command_id+1))
}

# (pid: number, ...children: number) errno
command_subcommands(){
    local pid=$1
    shift 1
    local checked=0
    local id
    local val
    for id in "$@";do
        local s="__command(){
    if [[ \$checked == 0 ]];then
        if [[ ! \$pid =~ ^[0-9]+\$ ]];then
            result_errno=\"id invalid: \$pid\"
            return 1
        elif [[ \$__command_${pid}_name == '' ]];then
            result_errno=\"command id not defined: \$pid\"
            return 1
        fi
        checked=1
    fi
    if [[ ! \$id =~ ^[0-9]+\$ ]];then
            result_errno=\"id invalid: \$id\"
            return 1
    elif [[ \$__command_${id}_name == '' ]];then
        result_errno='command id not defined: $id'
        return 1
    fi
    local s
    for s in \"\${__command_${pid}_children[@]}\";do
        if [[ \$s == $id ]];then
            return
        fi
    done
    __command_${pid}_children+=($id)
}"
        # echo "$s";exit 1;
        if ! eval "$s";then
            result_errno="eval command_subcommand error"
            if [[ $- == *e* ]];then
                echo "$result_errno"
            fi
            return 1
        elif __command;then
            continue
        else
            val=$?
            if [[ $- == *e* ]];then
                echo "$result_errno"
            fi
            return $val
        fi
    done
}
# (command: string, arg...) errno
command_help(){
    local errno=0
    local command=$1
    shift
    if __command_checkid "$1";then
        local s0="__command(){
    local padding
    local s
    local n

    local name=\$__command_${1}_name
    local short=\$__command_${1}_short
    local long=\$__command_${1}_long
    local children=(\"\${__command_${1}_children[@]}\")
    local flags=(\"\${__command_${1}_flags[@]}\")
    local type=(\"\${__command_${1}_type[@]}\")
    local default=(\"\${__command_${1}_default[@]}\")
    local values=(\"\${__command_${1}_values[@]}\")
    local func=(\"\${__command_${1}_func[@]}\")
    
    if [[ \$command == '' ]];then
        command=\$name
    else
        command=\"\$command \$name\"
    fi

    if [[ \$long != '' ]];then
        echo \"\$long
\"
    elif [[ \$short != '' ]];then
        echo \"\$short
\"
    fi
    echo \"Usage:
  \$command [flags]\"
    local children_n=\${#children[@]}
    if [[ \$children_n != 0 ]];then
        echo \"  \$command [command]

Available Commands:\"
        padding=10
        for s in \"\${children[@]}\";do
            n=\${#s}
            if ((n>padding));then
                padding=\$n
            fi
        done
        for s in \"\${children[@]}\";do
            printf \"  %-\${padding}s   %s\n\" \$s \$s
        done
    fi

    echo \"
Flags:\"
    padding=10
    local flag

    printf \"%5s --%-\${padding}s   %s\\n\" -h, help \"help for \$name\"

    if [[ \$children_n != 0 ]];then
        echo \"
Use \\\"\$command [command] --help\\\" for more information about a command.\"
    fi
"
        # echo "$s0}"; #exit 1;
        if ! eval "$s0}";then
            result_errno="eval command_execute error"
            errno=1
        else
            shift
            if __command;then
                errno=0
            else
                errno=$?
            fi
        fi
    else
        errno=$?
    fi
    if [[ $errno != 0 ]] && [[ $- == *e* ]];then
        echo "$result_errno"
    fi
    return $errno
}
# (id: number, arg...) errno
# Parse the parameters and execute the command callback function
__command_execute(){
    local errno=0
    if __command_checkid "$1";then
        local s0="__command(){
    local name=\$__command_${1}_name
    local short=\$__command_${1}_short
    local long=\$__command_${1}_long
    local children=(\"\${__command_${1}_children[@]}\")
    local flags=(\"\${__command_${1}_flags[@]}\")
    local type=(\"\${__command_${1}_type[@]}\")
    local default=(\"\${__command_${1}_default[@]}\")
    local values=(\"\${__command_${1}_values[@]}\")
    local func=(\"\${__command_${1}_func[@]}\")

    local state=0
    local args=()
    local n=\${#@}
    local arg
    while ((n>0)); do
        arg=\$1
        if [[ \$state == 0 ]];then
            if [[ \$arg == -h ]] || [[ \$arg == --help ]];then
                command_help '' $1
                return 0
            fi
        fi

        shift
        n=\${#@}
    done
"
    # echo "$s0}"; exit 1;
        if ! eval "$s0}";then
            result_errno="eval command_execute error"
            errno=1
        else
            shift
            if __command "$@";then
                errno=0
            else
                errno=$?
            fi
        fi
    else
        errno=$?
    fi
    if [[ $errno != 0 ]] && [[ $- == *e* ]];then
        echo "$result_errno"
    fi
    return $errno
}
# (id: number, arg...) errno
# Parse the parameters and execute the command callback function
command_execute(){
    local command=''
    __command_execute "$@"
}