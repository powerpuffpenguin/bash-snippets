#/bin/bash
set -e

cd `dirname $BASH_SOURCE`

./src/generate_log.sh -o "dst/log.sh"
./src/generate_log_writer.sh -o "dst/log_writer.sh"