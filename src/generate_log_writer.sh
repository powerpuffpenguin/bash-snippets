#!/bin/bash
set -e

Command=`basename $BASH_SOURCE`

# * $1 flag
# * $2 message
function print_flag
{
    printf "  %-20s %s\n" "$1" "$2"
}

Prefix="log_"
Output="log_writer.sh"
Test=0
function help
{
    echo "generate bash log writer code"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    print_flag "-p, --prefix" "function name prefix (default \"$Prefix\")"
    print_flag "-o, --output" "generate the output file of the code (default \"$Output\")"
    print_flag "-t, --test" "only output generated code to the stdout but don't actually write to the output file"
    print_flag "-h, --help" "help for $Command"
}

function create_file
{
    if [[ $Test == 1 ]];then
        echo "$1"
    else
        echo "$1" > "$Output"
    fi
}
function write_file
{
    if [[ $Test == 1 ]];then
        echo "$1"
    else
        echo "$1" >> "$Output"
    fi
}

ARGS=`getopt -o hp:o:t --long help,prefix:output:test -n "$Command" -- "$@"`
eval set -- "${ARGS}"

while true; do
    case "$1" in
        -h|--help)
            help
            exit 0
        ;;
        -p|--prefix)
            Prefix="$2"
            shift 2
        ;;
        -o|--output)
            Output="$2"
            shift 2
        ;;
        -t|--test)
            Test=1
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "$1" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac 
done

create_file "#/bin/bash
__${Prefix}name=''
__${Prefix}index=0
__${Prefix}ext=''
__${Prefix}count=''

# 0 end_with
# 1 start_with
# (s, sub, 1|0 ): 1|0
function __${Prefix}strings_with
{
    errno=0
    local sub=\"\$2\"
    if [ \"\$sub\" = '' ];then
        result=1
        return
    fi
    local n0=\${#sub}
    local s=\"\$1\"
    local n1=\${#s}
    if ((n1<n0));then
        result=0
        return
    elif ((n1>n0));then
        if [ \$3 == 0 ];then # end with
            local i=\$((n1-n0))
            s=\${s:i}
        else
            s=\${s:0:n0}
        fi
    fi
    if [ \"\$s\" == \"\$sub\" ];then
        result=1
    else
        result=0
    fi
}

# How many log files to store at most
${Prefix}file_backups=3
# The maximum size of a single log store
${Prefix}file_size=\$((10*1024*1024))
# If set will override the filename to write
${Prefix}file_name=''
# write log to file
function ${Prefix}write_file
{
    # get output filename
    local filename
    if [ \"\$${Prefix}file_name\" == '' ];then
        filename=\$${Prefix}file_name
    else
        filename=\$${Prefix}to_file
    fi

    # init and check exists log files
    if [ \"\$__${Prefix}count\" == '' ];then
        # log dir
        local dir=\`dirname \"\$filename\"\`
        if [ \"\$dir\" == '' ];then
            dir='.'
        fi
        local errno
        local result
        __${Prefix}strings_with \"\$dir\" \"/\" 0
        if [ \$result == 0 ];then
            dir=\"\$dir/\"
        fi
        # log name
        __${Prefix}index=0
        local name=\`basename \"\$filename\"\`
        if [ \"\$name\" == '' ];then
            __${Prefix}name=\"\$dir\"
            __${Prefix}ext=''
        else
        
        fi

        if [ -d \"\$dir\" ];then
            local s=\$IFS
            IFS=\"
\"
            local strs=(\`find \"\$dir\" -maxdepth 1 -type f\`)
            IFS=\$s
            for s in \"\${strs[@]}\";do
                s=\`basename \"\$s\"\`
            done
        else
            mkdir \"\$dir\" -p
            echo \"${Prefix}write_file: mkdir '\$dir' -p error\"
            return 0
        fi
        __${Prefix}count=0
    fi

    # write log to file
    filename=\"\$__${Prefix}name\$__${Prefix}index\$__${Prefix}ext\"
    echo \"\$@\" >> \"\$filename\"

    # Every 100 writes, check the log file size
    if ((__${Prefix}count<100));then
        __${Prefix}count=\$((__${Prefix}count+1))
        return
    fi
    __${Prefix}count=0
    for s in \`du -b \"\$filename\"\`; do
        if ((s>=${Prefix}file_size));then
            __${Prefix}index=\$((__${Prefix}index+1))
            # delete log
            local i=\$((__${Prefix}index-${Prefix}file_backups))
            if ((i>=0)); then
                filename=\"\$__${Prefix}name\$i\$__${Prefix}ext\"
                if [ -f \"\$filename\" ];then
                    rm \"\$filename\" -f
                fi
            fi
        fi
        break
    done
}"
