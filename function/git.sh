#!/bin/bash
GIT_CONFIG_FILE="$HOME/.config/git/config"

git_config_input() {
    GIT_USER_NAME="XJ Hsu"
    GIT_USER_EMAIL="xj11400@gmail.com"

    local _git_user_name=$(eval echo \$$1)
    local _git_user_email=$(eval echo \$$2)

    echo ""
    # set user name
    read -p "enter user name($GIT_USER_NAME): " _git_user_name

    if [ -z $_git_user_name ]; then
        _git_user_name=$GIT_USER_NAME
    fi

    echo " >>> user.name = $_git_user_name"

    git config --global user.name "$_git_user_name"

    echo ""
    # set user email
    read -p "enter user email($GIT_USER_EMAIL): " _git_user_email

    if [ -z $_git_user_email ]; then
        _git_user_email=$GIT_USER_EMAIL
    fi

    echo " >>> user.email = $_git_user_email"

    git config --global user.email "$_git_user_email"

    echo ""

    local "$1" && _upvar $1 "${_git_user_name}"
    local "$2" && _upvar $2 "${_git_user_email}"
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
    local _user_name=$(eval echo \$$1)
    local _user_email=$(eval echo \$$2)

    if [ ! -f $GIT_CONFIG_FILE ]; then
        echo " >>> not found git config file..."
        echo " >>> touch $GIT_CONFIG_FILE ..."
        touch $GIT_CONFIG_FILE

        # setting user.name and user.email
        if [ -z $_user_name ] || [ -z $_user_email ]; then
            echo "missing arg"
            git_config_input _user_name _user_email
        else
            git_config _user_name _user_email
        fi
    else
        echo " >>> found git config file..."
        _user_name="$(git config --global user.name)"
        _user_email="$(git config --global user.email)"
    fi

    local "$1" && _upvar $1 $_user_name
    local "$2" && _upvar $2 $_user_email
}

#
# git_check_config $@
# git_write_conf_path
