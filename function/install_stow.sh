#!/bin/bash

# x_use
# -----
# download from github
#
# args:
#   - $1: git url
#   - $2: target path (target parent dir)
#   - $3: name
function x_use() {
    if [[ ! -d "$2" ]]; then
        print -P "%F{243}▓▒░ %F{249}Installing …%f"
        #command mkdir -p "$2/$3" #&& command chmod g-rwX "$2"
        command git clone "https://github.com/$1.git" "$2" --depth 1 &&
            print -P "%F{243}▓▒░ %F{67}Installation successful.%f" ||
            print -P "%F{124}▓▒░ The clone has failed.%f"
    fi
}

# stow
# ----
check_stow() {
    if [ ! -x "$(command -v stow)" ]; then
        local current=$(pwd)
        echo -e "\033[4;34m▓▒░\033[0m install stow"
        git clone https://git.savannah.gnu.org/git/stow.git --depth 1 /tmp/stow
        cd /tmp/stow
        echo $(pwd)
        ./configure
        sudo make install
        cd $current
    fi
}
