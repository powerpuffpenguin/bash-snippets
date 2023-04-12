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

# How many log files to store at most
${Prefix}file_backups=3
# The maximum size of a single log store
${Prefix}file_size=10
# If set will override the filename to write
${Prefix}file_name=''
# write log to file
function log_write_file
{
    local filename
    if [ \"\$${Prefix}file_name\" == '' ];then
        filename=\$${Prefix}file_name
    else
        filename=\$${Prefix}to_file
    fi
  
    local s=\`printf \"%010d\" \"\$__${Prefix}index\"\`
    filename=\"\$__${Prefix}name\$s\$__${Prefix}ext\"
    echo \"\$@\" >> \"\$filename\"

    if ((__${Prefix}count<100));then
        __${Prefix}count=((__${Prefix}count+1))
        return
    fi
    __${Prefix}count=0
    
}"