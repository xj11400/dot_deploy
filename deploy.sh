#!/usr/bin/env bash

# select dots
# stow selected


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