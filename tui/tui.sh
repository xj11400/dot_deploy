#!/bin/bash

tui() {
    local _source="${BASH_SOURCE[0]}"
    while [ -h "$_source" ]; do # resolve $_source until the file is no longer a symlink
        local _dir="$(cd -P "$(dirname "$_source")" && pwd)"
        _source="$(readlink "$_source")"
        [[ $_source != /* ]] && _source="$_dir/$_source" # if $_source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    local _source_dir="$(cd -P "$(dirname "$_source")" && pwd)"
    local _parent_dir=$(dirname "$_source_dir")

    # shellcheck disable=SC1091
    source "$_source_dir/prompts.sh"
    # shellcheck disable=SC1091
    source "$_source_dir/logging.sh"
    # shellcheck disable=SC1091

    source "$_source_dir/colors.sh"
    source "$_source_dir/inquirer.sh"
    source "$_source_dir/checkbox_input.sh"
    source "$_source_dir/list_input.sh"
    source "$_source_dir/text_input.sh"

    source "$_source_dir/progress_bar.sh"

    source "$_source_dir/message_show.sh"
    source "$_source_dir/platform_helpers.sh"

}

tui
