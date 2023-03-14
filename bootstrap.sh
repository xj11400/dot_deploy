#!/bin/bash

# x_use 
# -----
# download from github
#
# args:
#   - $1: git url
#   - $2: target path (target parent dir)
#   - $3: name
function x_use(){
    if [[ ! -d "$2" ]]
    then
        print -P "%F{243}▓▒░ %F{249}Installing …%f"
        #command mkdir -p "$2/$3" #&& command chmod g-rwX "$2"
        command git clone "https://github.com/$1.git" "$2" --depth 1 && \
        print -P "%F{243}▓▒░ %F{67}Installation successful.%f" || \
        print -P "%F{124}▓▒░ The clone has failed.%f"
    fi
}

# colors
# ======
HINTC='\033[0;33m'
STEPC='\033[0;35m'
TITLEC='\033[4;34m▓▒░\033[0m '
OPTIONC='\033[0;92m'
ARGC='\033[0;95m'
NC='\033[0m' # No Color

# function hint(){
#     echo -e "${HINTC}$1${NC}"
# }

# [func] x_chk 
# -------------
# check if program exist
# 
# args:
#   - $1: program name

function x_chk(){
    if ! [ -x "$(command -v $1)" ]; then
        echo -e "${TITLEC}${HINTC}$1 not found${NC}"
        return 0
    else
        echo -e "${TITLEC}${HINTC}$1 found${NC}"
        return 1
    fi
}


# stow
# ----
if x_chk stow ;then
    echo "install stow"
    git clone https://git.savannah.gnu.org/git/stow.git --depth 1
    ./configure 
    sudo make install  
fi

# tpm
