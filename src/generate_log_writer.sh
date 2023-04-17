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
${Prefix}file_size=\$((1*1024*1024))
# If set will override the filename to write
${Prefix}file_name=''
# How many times to check log size whenever write
${Prefix}file_check_times=100
# write log to file
function ${Prefix}write_file
{
    local filename
    # not init,do it
    if [ \"\$__${Prefix}count\" == '' ];then
        # set log filename
        if [ \"\$${Prefix}file_name\" == '' ];then
            filename=\$${Prefix}to_file
        else
            filename=\$${Prefix}file_name
        fi

        # dir and name
        local n=\${#filename}
        if [[ \"\$n\" == 0 ]];then
            local dir='./'
            local name=''
        elif [[ \"\${filename:n-1}\" == '/' ]];then
            local dir=\"\$filename\"
            local name=''
        else
            local dir=\`dirname \"\$filename\"\`
            n=\${#dir}
            if [[ \"\${dir:n-1}\" != '/' ]];then
                dir=\"\$dir/\"
            fi
            local name=\`basename \"\$filename\"\`
            if [[ \"\$name\" == '.' ]];then
                name=''
            fi
        fi

        # name and ext
        __${Prefix}index=0
        local ext=''
        if [ \"\$name\" == '' ];then
            __${Prefix}name=\"\$dir\"
            __${Prefix}ext=''
        else
            __${Prefix}name=\"\$dir\$name\"
            __${Prefix}ext=''
            local i=\${#name}
            local c
            for ((i=i-1;i>=0;i--));do
                c=\${name:i:1}
                if [[ \"\$c\" == \".\" ]];then
                    __${Prefix}name=\"\$dir\${name:0:i}\"
                    __${Prefix}ext=\"\${name:i}\"
                    ext=\"\${name:i}\"
                    name=\"\${name:0:i}\"
                    break
                fi
            done
        fi
        # find exists log files
        if [ -d \"\$dir\" ];then
            local s=\$IFS
            IFS=\"
\"
            local strs=(\`find \"\$dir\" -maxdepth 1 -type f\`)
            IFS=\$s
            local name_len=\${#name}
            local ext_len=\${#ext}  
            local i
            for s in \"\${strs[@]}\";do
                s=\`basename \"\$s\"\`
                if [[ \"\${s:0:name_len}\" == \"\$name\" ]];then
                    s=\${s:name_len}
                else
                    continue
                fi
                i=\$((\${#s}-ext_len))
                if ((i>=0)) &&  [[ \"\${s:i}\" == \"\$ext\" ]];then
                    s=\${s:0:i}
                else
                    continue
                fi
                if echo \"\$s\" | egrep -vsq '^[0-9]+$'; then
                    continue
                fi
                if ((s>__${Prefix}index));then
                    __${Prefix}index=\$s
                fi
            done
        else
            mkdir \"\$dir\" -p
            if [[ \$? != 0 ]];then
                echo \"${Prefix}write_file: mkdir '\$dir' -p error\"
                return 0
            fi
        fi
        __${Prefix}count=\$${Prefix}file_check_times
    fi

    # current log filename
    filename=\"\$__${Prefix}name\$__${Prefix}index\$__${Prefix}ext\"
    
    # Every 100 writes, check the log file size
    if ((__${Prefix}count>=${Prefix}file_check_times));then
        __${Prefix}count=0
        if [[ -f \"\$filename\" ]];then
            local s=\`wc -c < \"\$filename\"\`
            if ((s>=${Prefix}file_size));then
                __${Prefix}index=\$((__${Prefix}index+1))
                filename=\"\$__${Prefix}name\$__${Prefix}index\$__${Prefix}ext\"
                # delete log
                local i=\$((__${Prefix}index-${Prefix}file_backups))
                if ((i>=0)); then
                    s=\"\$__${Prefix}name\$i\$__${Prefix}ext\"
                    if [[ -f \"\$s\" ]];then
                        rm \"\$s\" -f
                    fi
                fi
            fi
        fi
    fi

    # write log to file
    echo \"\$@\" >> \"\$filename\"
    __${Prefix}count=\$((__${Prefix}count+1))
}"
