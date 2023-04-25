#!/bin/bash
if [[ -v command_version ]] && [[ $command_version =~ ^[0-9]$ ]] && ((command_version>=1));then
    return
fi
command_version=1

__command_id=0
__command_name=''
__command_short=''
__command_long=''
__command_children=()
__command_flag=0
__command_flags=()

# (name: string, short_describe?: string, long_describe?: string) (id: number, errno)
# begin a new command
command_begin(){
    if [[ "$1" == '' ]];then
        result_errno="command name invalid: $1"
        return 1
    fi

    __command_name=$1
    __command_short=$2
    if [[ "$long_describe" == '' ]];then
        __command_long=$2
    else
        __command_long=$3
    fi
    __command_children=()
    __command_flags=()

    result=$__command_id
    __command_id=$((__command_id+1))
}
__command_join(){
    result=''
    local s
    for s in "${@}";do
        s=${s// /\\ }
        if [[ "$result" == '' ]];then
            result=$s
        else
            result="$result $s"
        fi
    done
}
# get flag describe
# out s
# in type
# in describe
# in max
# in min
# in value
# in pattern
# in regexp
# in default
__command_flags_describe(){
    local n
    local result
    s=$describe
    if [[ "$type" == *s ]];then
        n=${#default[@]}
        if ((n>0));then
            __command_join "${default[@]}"
            s="$s (default [$result])"
        fi
    elif [[ "$default" != '' ]];then
        s="$s (default $default)"
    fi
    case "$type" in
        int|uint|ints|uints)
            if [[ "$max" != '' ]] || [[ "$min" != '' ]];then
                if [[ "$min" == '' ]];then
                    s="$s (range x to"
                else
                    s="$s (range $min to"
                fi
                if [[ "$max" == '' ]];then
                    s="$s x)"
                else
                    s="$s $max)"
                fi
            fi
        ;;
    esac
    n=${#value}
    if ((n>0));then
        __command_join "${value[@]}"
        s="$s (option [$result])"
    fi
    n=${#pattern}
    if ((n>0));then
        __command_join "${pattern[@]}"
        s="$s (== $result})"
    fi
    n=${#regexp}
    if ((n>0));then
        __command_join "${regexp[@]}"
        s="$s (=~ $result})"
    fi
}

# (long: string, short:string, arg0: string, args1: string) (shift_val: string, shift_n: string) 
__command_flags(){
    if [[ "$3" == "--$1" ]];then
        shift_val=$4
        shift_n=2
        return
    fi
    local s="--$1="
    local n=${#s}
    if [[ "${3:0:n}" == "$s" ]];then
        shift_val=${3:n}
        shift_n=1
        return
    fi
    
    if [[ $2 == '' ]];then
        return 1
    elif [[ "$3" == "-$2" ]];then
        shift_val=$4
        shift_n=2
        return
    fi
    s="-$2="
    n=${#s}
    if [[ "${3:0:n}" == $s ]];then
        shift_val=${3:n}
        shift_n=1
        return
    fi
    s="-$2"
    n=${#s}
    if [[ "${3:0:n}" == $s ]];then
        shift_val=${3:n}
        shift_n=1
        return
    fi
    return 1
}
# (...): errno
# define a flag for current command
# -v, --var string(^[a-zA-Z_][a-zA-Z0-9_]*$)  Varname of this flag 
# -l, --long string   Long name of this flag
# -s, --short char   Short name of this flag 
# -t, --type string     Flag type (default bool) (value [string, strings, int, ints, uint, uints, bool, bools])
# -d, --describe string     How to use descriptive information
#   , --max number  Max value, only valid for type int
#   , --min number  Min value, only valid for type int
# -V, --value string   Lists of valid values are compared using == "$value[i]"
# -P, --pattern string Lists of valid values are compared using == $pattern[i]
# -R, --regexp string Lists of valid values are compared using =~ $pattern[i]
# -D, --default string  Default value when not specified
command_flags(){
    if [[ "$__command_name" == '' ]];then
        result_errno="please call command_begin to begin a new command"
        return 1
    fi

    local var
    local long
    local short
    local type=bool
    local describe
    local max
    local min
    local value=()
    local pattern=()
    local regexp=()
    local default=()
    # parse
    local n=${#@}

    local shift_val
    local shift_n
    while ((n>0)); do
        if __command_flags var v "$1" "$2";then
            var=$shift_val
            shift $shift_n
        elif __command_flags long l "$1" "$2";then
            long=$shift_val
            shift $shift_n
        elif __command_flags short s "$1" "$2";then
            short=$shift_val
            shift $shift_n
        elif __command_flags type t "$1" "$2";then
            type=$shift_val
            shift $shift_n
        elif __command_flags describe d "$1" "$2";then
            describe=$shift_val
            shift $shift_n
        elif __command_flags max '' "$1" "$2";then
            max=$shift_val
            shift $shift_n
        elif __command_flags min '' "$1" "$2";then
            min=$shift_val
            shift $shift_n
        elif __command_flags value V "$1" "$2";then
            value+=("$shift_val")
            shift $shift_n
        elif __command_flags pattern P "$1" "$2";then
            pattern+=("$shift_val")
            shift $shift_n
        elif __command_flags regexp R "$1" "$2";then
            regexp+=("$shift_val")
            shift $shift_n
        elif __command_flags default D "$1" "$2";then
            default+=("$shift_val")
            shift $shift_n
        else
            result_errno="[command_flags] unknow flags: $1"
            return 1
        fi
        n=${#@}
    done
    if [[ ! "$var" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]];then
        result_errno='--var must matched with =~ ^[a-zA-Z_][a-zA-Z0-9_]*$'
        return 1
    fi
    if [[ "$long" == '' ]];then
        result_errno='long flag must be specified'
        return 1
    elif [[ "$long" == help ]];then
        result_errno='--help cannot be specified, it is a reserved flag'
        return 1
    fi
    if [[ "$short" != '' ]];then
        if [[ "$short" == h ]];then
            result_errno='-h cannot be specified, it is a reserved flag'
            return 1
        elif [[ "$short" != ? ]];then
            result_errno='short flag must be a char'
            return 1
        fi
    fi

    local flag=$__command_flag
    local id=$((__command_id-1))
    local prefix="__command_${id}_flag_${flag}"
    local s_default
    case "$type" in
        string|int|uint|bool)
            s_default="${prefix}_default=\"\${default[0]}\""
        ;;
        strings|ints|uints|bools)
            s_default="${prefix}_default=(\"\${default[@]}\")"
        ;;
        *)
            result_errno="[command_flags] unknow type: $type"
            return 1
        ;;
    esac

    local s_val
    case "$type" in
        int|ints)
            if [[ "$max" != '' ]] && [[ ! "$max" =~ ^-?[0-9]+$ ]];then
                result_errno="--max must specify a valid int value"
                return 1
            fi
            if [[ "$min" != '' ]] && [[ ! "$min" =~ ^-?[0-9]+$ ]];then
                result_errno="--min must specify a valid int value"
                return 1
            fi
        ;;
        uint|uints)
            if [[ "$max" != '' ]] && [[ ! "$max" =~ ^[0-9]+$ ]];then
                result_errno="--max must specify a valid uint value"
                return 1
            fi
            if [[ "$min" != '' ]] && [[ ! "$min" =~ ^[0-9]+$ ]];then
                result_errno="--min must specify a valid uint value"
                return 1
            fi
        ;;
    esac
    local s="${prefix}_var=\$var
${prefix}_long=\$long
${prefix}_short=\$short
${prefix}_type=\$type
${prefix}_describe=\$describe
${prefix}_max=\$max
${prefix}_min=\$min
${prefix}_value=(\"\${value[@]}\")
${prefix}_pattern=(\"\${pattern[@]}\")
${prefix}_regexp=(\"\${regexp[@]}\")
$s_default
"
    # echo "$s"
    if eval "$s";then
        __command_flags+=("$flag")
        __command_flag=$((__command_flag+1))
    else
        local errno=$?
        result_errno="eval has error: $s"
        return $errno
    fi
}

__command_help(){
    s="$s
${prefix}_help(){
    local min=0
    local i
    local n
    local s
    local format
    if [[ \$__command_parent == '' ]];then
        local name=\$${prefix}_name
    else
        local name=\"\$__command_parent \$${prefix}_name\"
    fi
    printf '%s\n\nUsage:\n  %s [flags]\n' \"\$${prefix}_long\" \"\$name\"
"
    local n=${#__command_children[@]}
    # children command
    if ((n>0));then
        local i=0
        local names
        local shorts
        local child
        for child in "${__command_children[@]}";do
            if [[ $i == 0 ]];then
                names="(\"\$__command_${child}_name\""
                shorts="(\"\$__command_${child}_short\""
            else
                names="$names \"\$__command_${child}_name\""
                shorts="$shorts \"\$__command_${child}_short\""
            fi
            i=$((i+1))
        done
        s="$s    
    # children command
    printf '  %s [command]\n\nAvailable Commands:\n' \"\$name\"
    local names=$names)
    local shorts=$shorts)
    for s in \"\${names[@]}\";do
        n=\${#s}
        if ((min<n));then
            min=\$n
        fi
    done
    format=\"  %-\${min}s  %s  %s\n\"
    n=0
    for s in \"\${names[@]}\";do
        printf \"\$format\" \"\$s\" \"\${shorts[n]}\"
        n=\$((n+1))
    done
"
    fi

    # flags
    local flags_long
    local flags_short
    local flags_type
    local flag
    local i=0
    for flag in "${__command_flags[@]}";do
        if [[ $i == 0 ]];then
            flags_long="(\"\$${prefix}_flag_${flag}_long\""
            flags_short="(\"\$${prefix}_flag_${flag}_short\""
            flags_type="(\"\$${prefix}_flag_${flag}_type\""
        else
            flags_long="$flags_long \"\$${prefix}_flag_${flag}_long\""
            flags_short="$flags_short \"\$${prefix}_flag_${flag}_short\""
            flags_type="$flags_type \"\$${prefix}_flag_${flag}_type\""
        fi
        i=$((i+1))
    done
    if [[ "$flags_long" == '' ]];then
        flags_long="("
        flags_short="("
        flags_type="("
    fi
    s="$s
    # flags
    printf '\nAvailable Commands:\n'
    local flags_long=$flags_long)
    local flags_short=$flags_short)
    local flags_type=$flags_type)
    min=9
    i=0
    for s in \"\${flags_long[@]}\";do
        s=\"\$s \${flags_type[i]}\"
        n=\${#s}
        if ((min<n));then
            min=\$n
        fi
        i=\$((i+1))
    done
    format=\"  %3s --%-\${min}s   %s\n\"
    local short
    local type
    local describe
    local max
    local min
    local value
    local pattern
    local regexp
    local default
"
    local sf
    for flag in "${__command_flags[@]}";do
        sf="$sf    short=\$${prefix}_flag_${flag}_short
    if [[ \"\$short\" != '' ]];then
        short=\"-\$short,\"
    fi
    type=\$${prefix}_flag_${flag}_type
    describe=\$${prefix}_flag_${flag}_describe
    max=\$${prefix}_flag_${flag}_max
    min=\$${prefix}_flag_${flag}_min
    value=(\"\${${prefix}_flag_${flag}_value[@]}\")
    pattern=(\"\${${prefix}_flag_${flag}_pattern[@]}\")
    regexp=(\"\${${prefix}_flag_${flag}_regexp[@]}\")
    if [[ \"\$type\" == *s ]];then
        default=(\"\${${prefix}_flag_${flag}_default[@]}\")
    else
        default=\$${prefix}_flag_${flag}_default
    fi
    __command_flags_describe
    printf \"\$format\" \"\$short\" \"\$${prefix}_flag_${flag}_long \$${prefix}_flag_${flag}_type\" \"\$s\"
"
    done
    s="$s$sf    printf \"\$format\" \"-h,\" \"help bool\" \"Help for \$${prefix}_name\"
"
echo "$s"
    # children help
    n=${#__command_children[@]}
    if ((n>0));then
        s="$s    
    # children help
    printf '\nUse \"%s [command] --help\" for more information about a command.\n' \"\$name\"
}"
    else
        s="$s}"
    fi
}
# () (string, errno)
# get current command eval string
command_string(){
    if [[ "$__command_name" == '' ]];then
        result_errno="please call command_begin to begin a new command"
        return 1
    fi
    local id=$((__command_id-1))
    local prefix="__command_${id}"

    local s="${prefix}_id=$id
${prefix}_name=\$__command_name
${prefix}_short=\$__command_short
${prefix}_long=\$__command_long
"
    __command_help
    ### execute
    s="$s
${prefix}_execute(){
    return
}"
    result=$s
}

# () (errno)
# generate command code and load it with eval
command_commit(){
    if command_string ;then
        if eval "$result";then
            __command_name=''
            __command_flag=0
            return
        else
            result_errno="eval has error: $result"
            return $?
        fi
    else
        return $?
    fi
}