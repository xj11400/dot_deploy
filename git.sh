#!/bin/bash
GIT_CONFIG_FILE="$HOME/.config/git/config"

git_config_input() {
    GIT_USER_NAME="XJ Hsu"
    GIT_USER_EMAIL="xj11400@gmail.com"

    echo ""
    # set user name
    read -p "enter user name($GIT_USER_NAME): " gitUserName

    if [ -z $gitUserName ]; then
        echo " >>> user.name = $GIT_USER_NAME"
    else
        echo " >>> user.name = $gitUserName"
        GIT_USER_NAME=$gitUserName
    fi

    git config --global user.name "$GIT_USER_NAME"

    echo ""
    # set user email
    read -p "enter user email($GIT_USER_EMAIL): " gitUserEmail

    if [ -z $gitUserEmail ]; then
        echo " >>> user.email = $GIT_USER_EMAIL"
    else
        echo " >>> user.email = $gitUserEmail"
        GIT_USER_EMAIL=$gitUserEmail
    fi

    git config --global user.email "$GIT_USER_EMAIL"

    echo ""
}

git_config() {
    local gitUserName=$1
    local gitUserEmail=$2

    echo " >>> user.name = $gitUserName"
    git config --global user.name "$gitUserName"

    echo " >>> user.email = $gitUserEmail"
    git config --global user.email "$gitUserEmail"
}

git_write_conf_path() {
    if [ -z "$(grep "path = conf/config" $GIT_CONFIG_FILE)" ]; then
        echo " >>> write include config path..."
        echo "[include]" >>$GIT_CONFIG_FILE
        echo "    path = conf/config" >>$GIT_CONFIG_FILE
    else
        echo " >>> already setting config path..."
    fi
}

git_check_config() {
    if [ ! -f $GIT_CONFIG_FILE ]; then
        echo " >>> not found git config file..."
        echo " >>> touch $GIT_CONFIG_FILE ..."
        touch $GIT_CONFIG_FILE

        # setting user.name and user.email
        if [ -z $1 ] || [ -z $2 ]; then
            echo "missing arg"
            git_config_input
        else
            git_config $1 $2
        fi
    else
        echo " >>> found git config file..."
    fi
}

#
git_check_config $@
git_write_conf_path
