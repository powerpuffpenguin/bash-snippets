#!/bin/bash
set -e
cd `dirname $BASH_SOURCE`

source assert.sh
source path.sh

function test_split_name
{
    local items=(
        "path.go"   ".go"
        "path.pb.go"    ".go"
        "a.dir/b"   ""
        "a.dir/b.go"    ".go"
        "a.dir/"    ""
        "." "."
        ".." "."
        "/.abc" ".abc"
    )
    local count=${#items[@]}
    local i
    local name
    local ext
    for ((i=0;i<count;i=i+2));do
        name=${items[i]}
        ext=${items[i+1]}
        name=${name:0:${#name}-${#ext}}

        assert_call_equal "$ext" \
            path_ext "${items[i]}"

        assert_call_equal "$name" \
            path_name "${items[i]}"

        assert_call_true \
            path_split_name "${items[i]}"
        assert_equal 2 ${#result[@]} "path_split_name(${items[i]})"
    done
}
function test_clean
{
    local items=(
        # Already clean
        ""      "."
        "abc"       "abc"
        "abc/def"   "abc/def"
        "a/b/c"     "a/b/c"
        "."              "."
        ".."             ".."
        "../.."         "../.."
        "../../abc"  "../../abc"
        "/abc"  "/abc"
        "/"          "/"

        # Remove trailing slash
        "abc/"  "abc"
        "abc/def/"  "abc/def"
        "a/b/c/"    "a/b/c"
        "./"               "."
        "../"              ".."
        "../../"          "../.."
        "/abc/"       "/abc"

        # Remove doubled slash
	    "abc//def//ghi"     "abc/def/ghi"
	    "//abc"         "/abc"
	    "///abc"        "/abc"
	    "//abc//"       "/abc"
	    "abc//"           "abc"

        # Remove . elements
	    "abc/./def"     "abc/def"
	    "/./abc/def"    "/abc/def"
	    "abc/."             "abc"

        # Remove .. elements
        "abc/def/ghi/../jkl"          "abc/def/jkl"
        "abc/def/../ghi/../jkl"     "abc/jkl"
        "abc/def/.."                        "abc"
        "abc/def/../.."                    "."
        "/abc/def/../.."                   "/"
        "abc/def/../../.."                ".."
        "/abc/def/../../.."              "/"
        "abc/def/../../../ghi/jkl/../../../mno"         "../../mno"

        # Combinations
        "abc/./../def"       "def"
        "abc//./../def"      "def"
        "abc/../../././../def"       "../../def"
    )
    local count=${#items[@]}
    local i
    
    for ((i=0;i<count;i=i+2));do
        assert_call_equal "${items[i+1]}" \
            path_clean "${items[i]}"
    done
}
function test_split
{
    local items=(
        "a/b"      "a/"        "b"
        "a/b/"    "a/b/"    ""
        "a/"        "a/"         ""
        "a"          ""             "a"
        "/"           "/"           ""
    )
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+3));do
        assert_call_true path_split "${items[i]}"
        assert_equal 2 "${#result[@]}" "path_split(${items[i]}) of len"
        assert_equal "${items[i+1]}" "${result[0]}" "path_split(${items[i]}) of dir"
        assert_equal "${items[i+2]}" "${result[1]}" "path_split(${items[i]}) of file"
    done
}
function test_dir
{
    local items=(
        ""       "."
        "."       "."
        "/."       "/"
        "/"       "/"
        "////"       "/"
        "/foo"       "/"
        "x/"       "x"
        "abc"       "."
        "abc/def"       "abc"
        "abc////def"       "abc"
        "a/b/.x"       "a/b"
        "a/b/c."       "a/b"
        "a/b/c.x"       "a/b"
    )
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+2));do
        assert_call_equal "${items[i+1]}" path_dir "${items[i]}"
    done
}
function test_base
{
    local items=(
        # Already clean
        ""       "."
        "."       "."
        "/."       "."
        "/"       "/"
        "////"       "/"
        "x/"       "x"
        "abc"       "abc"
        "abc/def"       "def"
        "a/b/.x"       ".x"
        "a/b/c."       "c."
        "a/b/c.x"       "c.x"
    )
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+2));do
        assert_call_equal "${items[i+1]}" path_base "${items[i]}"
    done
}
function test_is_abs
{
    local items=(
        ""       false
        "/"       true
        "/usr/bin/gcc"       true
        ".."       false
        "/a/../bb"       true
        "."       false
        "./"       false
        "lala"       false
    )
    local count=${#items[@]}
    local i
    for ((i=0;i<count;i=i+2));do
        if [[ "${items[i+1]}" == true ]];then
            assert_call_true path_is_abs "${items[i]}"
        else
            assert_call_false path_is_abs "${items[i]}"
        fi
    done
}
function test_join
{
    # zero parameters
    assert_call_equal '' \
        path_join
    # one parameter
    assert_call_equal '' \
        path_join ''
    assert_call_equal a \
        path_join a
    # two parameters
    assert_call_equal 'a/b' \
        path_join a b
    assert_call_equal a \
        path_join a ''
    assert_call_equal b \
        path_join '' b
    assert_call_equal /a \
        path_join / a
    assert_call_equal / \
        path_join / ''
    assert_call_equal a/b \
        path_join a/ b
    assert_call_equal a \
        path_join a/ ''
    assert_call_equal '' \
        path_join '' ''
}