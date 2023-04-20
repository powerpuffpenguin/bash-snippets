#!/bin/bash
cd `dirname $BASH_SOURCE`

source assert.sh
source command.sh

unset_e(){
    if [[ $- == *e* ]];then
        __command_test_set_e=1
        set +e
    fi
}
set_e(){
    if [[ $__command_test_set_e == 1 ]];then
        __command_test_set_e=0
        set -e
    fi
}

 test_subcommands(){
    unset_e
    assert_call_false command_subcommands abc 1
    assert_equal "id invalid: abc" "$result_errno" "command_subcommands(abc, 1)"
    local id=$__command_id
    assert_call_false command_subcommands $id 1
    assert_equal "command id not defined: $id" "$result_errno" "command_subcommands($id, 1)"

    assert_call_true command_new 'root'
    local root=$result

    assert_call_true command_subcommands $root

    assert_call_false command_subcommands $root abc
    assert_equal "id invalid: abc" "$result_errno" "command_subcommands($root, abc)"
    id=$((root+1))
    assert_call_false command_subcommands $root $id
    assert_equal "command id not defined: $id" "$result_errno" "command_subcommands($root, $id)"

    set_e
}

 test_get(){
    assert_call_true command_new root froot sroot lroot
    local root=$result
    assert_call_true command_new c0 fc0 sc0 lc0
    local c0=$result
    assert_call_true command_new c1 fc1 sc1 lc1
    local c1=$result
    assert_call_true command_new c2 fc2 sc2 lc2
    local c2=$result

    local names
    local funcs
    local shorts
    local longs
    local s

    local call=(
        __command_get -name names -func funcs $root $c0
    )
    assert_call_true "${call[@]}"
    s="${names[@]}"
    assert_equal "root c0" "$s" "${call[@]}"
    s="${funcs[@]}"
    assert_equal "froot fc0" "$s" "${call[@]}"
    s="${shorts[@]}"
    assert_equal "" "$s" "${call[@]}"
    s="${longs[@]}"
    assert_equal "" "$s" "${call[@]}"

    call=(
        __command_get -short shorts -long longs $c1 $c2
    )
    assert_call_true "${call[@]}"

    s="${names[@]}"
    assert_equal "root c0" "$s" "${call[@]}"
    s="${funcs[@]}"
    assert_equal "froot fc0" "$s" "${call[@]}"
    s="${shorts[@]}"
    assert_equal "sc1 sc2" "$s" "${call[@]}"
    s="${longs[@]}"
    assert_equal "lc1 lc2" "$s" "${call[@]}"
 }