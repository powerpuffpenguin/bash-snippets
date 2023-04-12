#/bin/bash
__log_name=''
__log_index=0
__log_ext=''
__log_count=''

# How many log files to store at most
log_file_backups=3
# The maximum size of a single log store
log_file_size=10
# If set will override the filename to write
log_file_name=''
# write log to file
function log_write_file
{
    local filename
    if [ "$log_file_name" == '' ];then
        filename=$log_file_name
    else
        filename=$log_to_file
    fi
  
    local s=`printf "%010d" "$__log_index"`
    filename="$__log_name$s$__log_ext"
    echo "$@" >> "$filename"

    # if ((__log_count))
    # __log_count=((__log_count+1))
}
