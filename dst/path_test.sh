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