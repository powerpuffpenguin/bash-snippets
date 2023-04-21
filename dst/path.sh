#/bin/bash
if [[ -v path_version ]] && [[ $path_version =~ ^[0-9]$ ]] && ((path_version>=1));then
    return
fi
path_version=1

# (filepath: string) (name: string, ext: string)
# returns the name without the extension
function path_split_name
{
    result=(
        "$1"
        ''
    )
    local i=${#1}
    local c
    for ((i=i-1;i>=0;i--));do
        c=${1:i:1}
        if [[ $c == / ]];then
            break
        elif [[ $c == . ]];then
            result=(
                "${1:0:i}"
                "${1:i}"
            )
            break
        fi
    done
}

# (filepath: string): string
# returns the name without the extension
function path_name
{
    path_split_name "$1"
    result="${result[0]}"
}
# (filepath: string): string
# return extension name
function path_ext
{
    path_split_name "$1"
    result="${result[1]}"
}
# (path: string): string
# Clean returns the shortest path name equivalent to path
# by purely lexical processing. It applies the following rules
# iteratively until no further processing can be done:
#
#  1. Replace multiple slashes with a single slash.
#  2. Eliminate each . path name element (the current directory).
#  3. Eliminate each inner .. path name element (the parent directory)
#     along with the non-.. element that precedes it.
#  4. Eliminate .. elements that begin a rooted path:
#     that is, replace "/.." by "/" at the beginning of a path.
#
# The returned path ends in a slash only if it is the root "/".
#
# If the result of this process is an empty string, Clean
# returns the string ".".
#
# See also Rob Pike, “Lexical File Names in Plan 9 or
# Getting Dot-Dot Right,”
# https://9p.io/sys/doc/lexnames.html
function path_clean
{
    if [[ $1 == '' ]];then
        result=.
		return
	fi
    result=''

	local n=${#1}
    # 
    local r=0
    local dotdot=0
	if [[ "${1:0:1}" == / ]];then
        local rooted=1
        result=/
        r=1
        dotdot=1
    else
        local rooted=0
    fi
    local c0
    local r1
    local r2
    local w
    while ((r<n));do
        c0=${1:r:1}
        if [[ $c0 == / ]];then
            # empty path element
            r=$((r+1))
            continue
        fi
        if [[ $c0 == . ]];then
            r1=$((r+1))
            if [[ $r1 == $n ]] || [[ "${1:r1:1}" == / ]];then
                # . element
                r=$((r+1))
                continue
            elif [[ "${1:r1:1}" == . ]];then
                r2=$((r+2))
                if [[ $r2 == $n ]] || [[ "${1:r2:1}" == / ]];then
                    #  .. element: remove to last /
                    r=$r2
                    w=${#result}
                    if ((w>dotdot));then
                        w=$((w-1))
                        while ((w>dotdot)) && [[ "${result:w:1}" != / ]]; do
                          w=$((w-1))
                        done
                        result=${result:0:w}
                    elif [[ $rooted == 0 ]];then
                        if [[ $result == '' ]];then
                            result=..
                        else
                            result="$result/.."
                        fi
                        dotdot=${#result}
                    fi
                    continue
                fi
            fi
        fi
                    
        # real path element.
        # add slash if needed
        w=${#result}
        if [[ $rooted == 1 ]];then
            if [[ $w != 1 ]];then
                result="$result/"
            fi
        elif [[ $w != 0 ]];then
            result="$result/"
        fi
        while ((r<n)); do
            c0=${1:r:1}
            if [[ $c0 == / ]];then
                break
            fi
            result="$result$c0"
            r=$((r+1))
        done
	done

	# Turn empty string into "."
	if [[ $result == '' ]];then
		result=.
	fi
}

# (path: string) (dir: string, name: string)
function path_split
{
    result=(
        ''
        "$1"
    )
    local i=${#1}
    local c
    for ((i=i-1;i>=0;i--));do
        c=${1:i:1}
        if [[ $c == / ]];then
            result=(
                "${1:0:i+1}"
                "${1:i+1}"
            )
            break
        fi
    done
}
# (path: string): string
function path_dir
{
    path_split "$1"
    path_clean "${result[0]}"
}

# (path: string): string
# Returns the last element of path.
# Trailing slashes are removed before extracting the last element.
# If the path is empty, path_base returns ".".
# If the path consists entirely of slashes, path_base returns "/".
function path_base
{
    if [[ $1 == '' ]];then
        result=.
        return
    fi
    result=$1
    local n
    while true; do
        n=${#result}
        if ((n>0)) && [[ "${result:n-1}" == / ]];then
            result=${result:0:n-1}
            continue
        fi
        break
    done
    # Find the last element
    path_split "$result"
    result=${result[1]}
    if [[ $result == '' ]];then
        result=/
    fi
}
# (path: string): errno
function path_is_abs
{
    if [[ "${1:0:1 }" != / ]];then
        result_errno="not an abs path: $1"
        return 1
    fi
}
# (...elem: []string): string
function path_join
{
    result=''
    local s
    local size=0
    for s in "$@";do
        size=$((size+${#s}))
    done
    if [[ $size == 0 ]];then
        return
    fi

    for s in "$@";do
        if [[ $result == '' ]];then
            result=$s
        else
            result="$result/$s"
        fi
    done
    path_clean "$result"
}