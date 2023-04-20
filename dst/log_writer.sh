#/bin/bash
if [[ -v $log_writer_version ]] && [[ $log_writer_version =~ ^[0-9]$ ]] && ((log_writer_version>1));then
    return
fi
log_writer_version=1

__log_name=''
__log_index=0
__log_ext=''
__log_count=''

# How many log files to store at most
log_file_backups=3
# The maximum size of a single log store
log_file_size=$((1*1024*1024))
# If set will override the filename to write
log_file_name=''
# How many times to check log size whenever write
log_file_check_times=100
# write log to file
function log_write_file
{
    local filename
    # not init,do it
    if [[ $__log_count == '' ]];then
        # set log filename
        if [[ $log_file_name == '' ]];then
            filename=$log_to_file
        else
            filename=$log_file_name
        fi

        # dir and name
        local n=${#filename}
        if [[ $n == 0 ]];then
            local dir='./'
            local name=''
        elif [[ ${filename:n-1} == '/' ]];then
            local dir="$filename"
            local name=''
        else
            local dir=`dirname "$filename"`
            n=${#dir}
            if [[ ${dir:n-1} != '/' ]];then
                dir="$dir/"
            fi
            local name=`basename "$filename"`
            if [[ $name == '.' ]];then
                name=''
            fi
        fi

        # name and ext
        __log_index=0
        local ext=''
        if [[ $name == '' ]];then
            __log_name=$dir
            __log_ext=''
        else
            __log_name="$dir$name"
            __log_ext=''
            local i=${#name}
            local c
            for ((i=i-1;i>=0;i--));do
                c=${name:i:1}
                if [[ $c == "." ]];then
                    __log_name="$dir${name:0:i}"
                    __log_ext="${name:i}"
                    ext="${name:i}"
                    name="${name:0:i}"
                    break
                fi
            done
        fi
        # find exists log files
        if [[ -d "$dir" ]];then
            local s=$IFS
            IFS="
"
            local strs=(`find "$dir" -maxdepth 1 -type f`)
            IFS=$s
            local name_len=${#name}
            local ext_len=${#ext}  
            local i
            for s in "${strs[@]}";do
                s=`basename "$s"`
                if [[ "${s:0:name_len}" == "$name" ]];then
                    s=${s:name_len}
                else
                    continue
                fi
                i=$((${#s}-ext_len))
                if ((i>=0)) &&  [[ "${s:i}" == "$ext" ]];then
                    s=${s:0:i}
                else
                    continue
                fi
                if echo "$s" | egrep -vsq '^[0-9]+$'; then
                    continue
                fi
                if ((s>__log_index));then
                    __log_index=$s
                fi
            done
        else
            if ! mkdir "$dir" -p;then
                echo "log_write_file: mkdir '$dir' -p error"
                return 0
            fi
        fi
        __log_count=$log_file_check_times
    fi

    # current log filename
    filename="$__log_name$__log_index$__log_ext"
    
    # Every 100 writes, check the log file size
    if ((__log_count>=log_file_check_times));then
        __log_count=0
        if [[ -f "$filename" ]];then
            local s=`wc -c < "$filename"`
            if ((s>=log_file_size));then
                __log_index=$((__log_index+1))
                filename="$__log_name$__log_index$__log_ext"
                # delete log
                local i=$((__log_index-log_file_backups))
                if ((i>=0)); then
                    s="$__log_name$i$__log_ext"
                    if [[ -f "$s" ]];then
                        rm "$s" -f
                    fi
                fi
            fi
        fi
    fi

    # write log to file
    echo "$@" >> "$filename"
    __log_count=$((__log_count+1))
}
