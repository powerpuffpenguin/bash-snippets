#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source log.sh
source log_writer.sh

log_file_check_times=10
log_file_size=100
log_file_backups=3
log_file_name="./log/writer.log"
function log_after_stdout
{
    log_write_file "$@"
}

for ((i=0;i<102;i++));do
    log_info "writer $i"
done