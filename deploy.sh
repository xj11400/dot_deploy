#!/usr/bin/env bash

# select dots
# stow selected


#
# depoly
#
depoly() {
    #
    # [select dot folder]
    #
    if [ ! -d "$1" ]; then
        show_error "$1 not exist!!!"
        exit
    fi

    # get folder list array
    list_of_dirs $1 _dir_list

    # checkbox
    _selected_conf=('zsh' 'vim' 'tmux' 'nvim' 'git' 'utils')
    checkbox "select config" "" _dir_list _selected_conf
    # list "select config" "_" _dir_list _selected_conf

    echo ${_selected_conf[*]}

    #
    # [stow]
    #

    # stow
    for _d in "${_selected_conf[@]}"; do
        stow -d $PARENT_DIR -t $HOME $_d
    done
}

# init deploy
#
init_deploy(){
    local _source="${BASH_SOURCE[0]}"
    while [ -h "$_source" ]; do # resolve $_source until the file is no longer a symlink
        local _dir="$(cd -P "$(dirname "$_source")" && pwd)"
        _source="$(readlink "$_source")"
        [[ $_source != /* ]] && _source="$_dir/$_source" # if $_source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    local _source_dir="$(cd -P "$(dirname "$_source")" && pwd)"
    local _parent_dir=$(dirname "$_source_dir")

    source $_source_dir/tui/tui.sh
    source $_source_dir/function/funcs.sh
}

init_deploy