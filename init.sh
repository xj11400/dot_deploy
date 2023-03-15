#!/usr/bin/env bash

# 0. check command
# 1. list folder
# 2. check exist
#    - fore : exist folder rename to exist_bk
#    - ignore
#    - exit
# 3.

set -e

#
# basic variable
#
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
PARENT_DIR=$(dirname "$DIR")
TARGET_DIR=$HOME

printf ".dotfiles dir: %s\n" "$PARENT_DIR"

#
# source files
#
source $DIR/deploy.sh

#
# show device info
#
printf "platform    : %s\n" "$(detect_os)"

#
# check commands
#
_chk_cmd=( 'git' 'zsh' 'npm' 'xj' )

for cmd in ${_chk_cmd[@]};do
    check_command $cmd
done

#
# select dot folder
#

# get folder list array
list_of_dirs $PARENT_DIR _dir_list

# checkbox
_selected_conf=( 'zsh' 'vim' 'tmux' 'nvim' 'git' 'utils' )
checkbox "select config" "" _dir_list _selected_conf
# list "select config" "_" _dir_list _selected_conf

echo ${_selected_conf[*]}
exit

#
# stow
#

# check directory exist
for _d in "${_selected_conf[@]}";do
    if [ -d $TARGET_DIR/.config/$_d ];then
        show_warning "folder exist : $TARGET_DIR/$_d"
        _confirmed=$(confirm "force replace?")
    fi
done


# stow
# stow $PARENT_DIR $HOME

#
# user dotfile repo
#

# select folder
# stow

#
# git config
#

