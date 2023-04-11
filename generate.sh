#/bin/bash
set -e

cd `dirname $BASH_SOURCE`

./src/generate_log.sh -o "src/log.sh"