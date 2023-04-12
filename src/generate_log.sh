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
Output="log.sh"
Test=0
function help
{
    echo "generate bash log code"
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
# if != '', print log to this file
${Prefix}to_file=''
# you can override how to write log to file
function ${Prefix}write_file
{
    echo \"\$@\" >> \"\$${Prefix}to_file\"
}
# call after log to stdout, you can override it
function ${Prefix}after_stdout
{
    return 0
}

# if != '', print log tag
${Prefix}flag_tag='[DEFAULT]'

# if != 0, print log line
${Prefix}flag_line=1

# if != 0, print log sub
${Prefix}flag_sub=1

# * 0, not print filename
# * 1, print log short filename
# * 2, print log long filename
${Prefix}flag_file=1

# log print level
# * 0 trace
# * 1 debug
# * 2 info
# * 3 warn
# * 4 error
# * 5 fatal
${Prefix}flag_level=0

# * 0 no color
# * 1 color level
# * 2 color metadata
# * 3 color message
# * 4 color metadata+message
${Prefix}color=1
# trace color
${Prefix}color_trace='97m'
# debug color
${Prefix}color_debug='93m'
# info color
${Prefix}color_info='92m'
# warn color
${Prefix}color_warn='95m'
# error color
${Prefix}color_error='91m'
# fatal color
${Prefix}color_fatal='31m'

function _${Prefix}print
{
    local s=\"\`date '+%F %H:%M:%S'\`\"
    if [ \"\$${Prefix}flag_tag\" != '' ];then
        s=\"\$${Prefix}flag_tag \$s\"
    fi
    local caller1=''
    if [ \"\$${Prefix}flag_line\" != 0 ] || [ \"\$${Prefix}flag_sub\" != 0 ] || [ \"\$${Prefix}flag_file\" != 0 ];then
        local line
        local sub
        local file
        read line sub file < <(caller 1)

        case \"\$${Prefix}flag_file\" in
            1)
                caller1=\`basename \"\$file\"\`
            ;;
            2)
                caller1=\"\$file\"
            ;;
        esac

        if [ \"\$${Prefix}flag_line\" != 0 ];then
            caller1=\"\$caller1:\$line\"
        fi
        if [ \"\$${Prefix}flag_sub\" != 0 ]; then
            if [ \"\$caller1\" == '' ];then
                caller1=\"\$sub\"
            else
                caller1=\"\$caller1 \$sub\"
            fi
        fi

        if [ \"\$caller1\" != '' ];then
            caller1=\"[\$caller1] \"
        fi
    fi

    if [ \"\$${Prefix}to_file\" != '' ];then
        ${Prefix}write_file \"\$s \$_${Prefix}tag \$caller1\$@\"
        return \$?
    fi

    case \"\$${Prefix}color\" in
        1)
            echo -n \"\$s\"
            echo -en \"\\e[\$_${Prefix}color\"
            echo -n \" \$_${Prefix}tag \"
            echo -en \"\\e[0m\"
            echo \"\$caller1\$@\"
        ;;
        2)
            echo -en \"\\e[\$_${Prefix}color\"
            echo -n \"\$s \$_${Prefix}tag \$caller1\"
            echo -en \"\\e[0m\"
            echo \"\$@\"
        ;;
        3)
            echo -en \"\\e[\$_${Prefix}color\"
            echo \"\$s \$_${Prefix}tag \$caller1\$@\"
            echo -en \"\\e[0m\"
        ;;
        *)
            echo \"\$s \$_${Prefix}tag \$caller1\$@\"
        ;;
    esac
    ${Prefix}after_stdout \"\$s \$_${Prefix}tag \$caller1\$@\"
}

# trace(... any)
function ${Prefix}trace
{
    if ((\$${Prefix}flag_level>0));then
        return 0
    fi

    _${Prefix}color=\"\$${Prefix}color_trace\"
    _${Prefix}tag=\"[trace]\"
    _${Prefix}print \"\$@\"
}
# debug(... any)
function ${Prefix}debug
{
    if ((\$${Prefix}flag_level>1));then
        return 1
    fi
    _${Prefix}color=\"\$${Prefix}color_debug\"
    _${Prefix}tag=\"[debug]\"
    _${Prefix}print \"\$@\"
}
# info(... any)
function ${Prefix}info
{
    if ((\$${Prefix}flag_level>2));then
        return 0
    fi
    _${Prefix}color=\"\$${Prefix}color_info\"
    _${Prefix}tag=\"[info]\"
    _${Prefix}print \"\$@\"
}
# warn(... any)
function ${Prefix}warn
{
    if ((\$${Prefix}flag_level>3));then
        return 0
    fi
    _${Prefix}color=\"\$${Prefix}color_warn\"
    _${Prefix}tag=\"[warn]\"
    _${Prefix}print \"\$@\"
}
# error(... any)
function ${Prefix}error
{
    if ((\$${Prefix}flag_level>4));then
        return 0
    fi
    _${Prefix}color=\"\$${Prefix}color_error\"
    _${Prefix}tag=\"[error]\"
    _${Prefix}print \"\$@\"
}
# fatal(... any) then exit 1
function ${Prefix}fatal
{
    _${Prefix}color=\"\$${Prefix}color_fatal\"
    _${Prefix}tag=\"[fatal]\"
    _${Prefix}print \"\$@\"
    exit 1
}"