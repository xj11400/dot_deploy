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
check_command "git"
check_command "zsh"
check_command "npm"
check_command "xj"

#
# select dot folder
#

# get folder list array
# checkbox

#
# stow
#

# check directory exist
# stow

#
# user dotfile repo
#

# select folder
# stow

#
# git config
#

