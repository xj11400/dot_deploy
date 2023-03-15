#!/usr/bin/env bash

# 0. check command
# 1. list folder
# 2. check exist
#    - fore : exist folder rename to exist_bk
#    - skip
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
# options variable
#
_user_repo="https://github.com/xj11400/dot_custom.git"

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
_chk_cmd=('git' 'zsh' 'npm' 'xj')

for cmd in ${_chk_cmd[@]}; do
    check_command $cmd
done

#
# depoly .dotfiles
#
# _config_path
depoly $PARENT_DIR
exit

#
# user dotfiles
#

# - clone repo
_user_dir="$PARENT_DIR/_custom"
if [ -d "${_user_dir}"]; then
    show_warning "${_user_dir} is already exist."
else
    git clone $_user_repo $_user_dir
    _depoly "$_user_dir"
fi

#
# git config
#
exit
source $DIR/git.sh
