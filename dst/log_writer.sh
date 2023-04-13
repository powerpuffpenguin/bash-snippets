#/bin/bash
__log_name=''
__log_index=0
__log_ext=''
__log_count=''

# 0 end_with
# 1 start_with
# (s, sub, 1|0 ): 1|0
function __log_strings_with
{
    errno=0
    local sub="$2"
    if [ "$sub" = '' ];then
        result=1
        return
    fi
    local n0=${#sub}
    local s="$1"
    local n1=${#s}
    if ((n1<n0));then
        result=0
        return
    elif ((n1>n0));then
        if [ $3 == 0 ];then # end with
            local i=$((n1-n0))
            s=${s:i}
        else
            s=${s:0:n0}
        fi
    fi
    if [ "$s" == "$sub" ];then
        result=1
    else
        result=0
    fi
}

# How many log files to store at most
log_file_backups=3
# The maximum size of a single log store
log_file_size=$((10*1024*1024))
# If set will override the filename to write
log_file_name=''
# write log to file
function log_write_file
{
    # get output filename
    local filename
    if [ "$log_file_name" == '' ];then
        filename=$log_file_name
    else
        filename=$log_to_file
    fi

    # init and check exists log files
    if [ "$__log_count" == '' ];then
        # log dir
        local dir=`dirname "$filename"`
        if [ "$dir" == '' ];then
            dir='.'
        fi
        local errno
        local result
        __log_strings_with "$dir" "/" 0
        if [ $result == 0 ];then
            dir="$dir/"
        fi
        # log name
        __log_index=0
        local name=`basename "$filename"`
        if [ "$name" == '' ];then
            __log_name="$dir"
            __log_ext=''
        fi

        if [ -d "$dir" ];then
            local s=$IFS
            IFS="
"
            local strs=(`find "$dir" -maxdepth 1 -type f`)
            IFS=$s
            for s in "${strs[@]}";do
                s=`basename "$s"`
            done
        else
            mkdir "$dir" -p
            echo "log_write_file: mkdir '$dir' -p error"
            return 0
        fi
        __log_count=0
    fi

    # write log to file
    filename="$__log_name$__log_index$__log_ext"
    echo "$@" >> "$filename"

    # Every 100 writes, check the log file size
    if ((__log_count<100));then
        __log_count=$((__log_count+1))
        return
    fi
    __log_count=0
    for s in `du -b "$filename"`; do
        if ((s>=log_file_size));then
            __log_index=$((__log_index+1))
            # delete log
            local i=$((__log_index-log_file_backups))
            if ((i>=0)); then
                filename="$__log_name$i$__log_ext"
                if [ -f "$filename" ];then
                    rm "$filename" -f
                fi
            fi
        fi
        break
    done
}
