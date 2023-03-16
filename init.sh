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

#
# options variable
#
_custom_conf=$DIR/custom.conf
if [ ! -f "$_custom_conf" ];then
    echo "no $_custom_conf"
    cp "$DIR/default.conf" "$_custom_conf"
fi

source $_custom_conf

_user_repo=$custom_repo
# declare _user_repo
# if [ -z "$1" ];then
#     _user_repo="$_xj_custom_repo"
# else
#     _user_repo="$custom_repo"
# fi
#
# source files
#
source $DIR/tui/tui.sh
source $DIR/function/funcs.sh

#
# show info
#
printf "platform     : %s\n" "$(detect_os)"
printf ".dotfiles dir: %s\n" "$PARENT_DIR"
printf "repo         : %s\n" "$_user_repo"

#
# check commands
#
_chk_cmd=('git' 'stow' 'zsh' 'npm' 'xj')

for cmd in ${_chk_cmd[@]}; do
    check_command $cmd
done

#
# depoly .dotfiles
#

# get folder list array
list_of_dirs $PARENT_DIR _dir_list

# checkbox
_selected_conf=("${stow_dir[@]}")
checkbox_input "select config" "(x)" _dir_list _selected_conf

echo ${_selected_conf[*]}
stow_dot $PARENT_DIR _selected_conf

#
# write conf
#
echo "# last: $(date)" > $_custom_conf
echo "stow_dir=(${_selected_conf[*]})" >> $_custom_conf
echo "custom_repo=\"${_user_repo}\"" >> $_custom_conf

#
# user dotfiles
#

# - clone repo
_user_dir="$PARENT_DIR/_custom"
if [ -d "${_user_dir}" ]; then
    show_warning "${_user_dir} is already exist."
else
    git clone $_user_repo $_user_dir
fi

list_of_dirs $_user_dir _custom_dir_list
echo ${_custom_dir_list[*]}
stow_dot $_user_dir _custom_dir_list

#
# git config
#
exit
source $DIR/git.sh

##
exit
sudo chsh -s /bin/zsh
sudo sh -c "echo 'export SHELL=/bin/zsh' > /etc/zsh/zshrc"
