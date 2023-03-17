#!/bin/bash
GIT_CONFIG_PATH="$HOME/.config/git"
GIT_CONFIG_FILE="$GIT_CONFIG_PATH/config"

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
    local _git_user_name=$(eval echo \$$1)
    local _git_user_email=$(eval echo \$$2)

    echo " >>> user.name = $_git_user_name"
    git config --global user.name "$_git_user_name"

    echo " >>> user.email = $_git_user_email"
    git config --global user.email "$_git_user_email"
}

git_write_conf_path() {
    if [ -z "$(grep "path = conf/config" $GIT_CONFIG_FILE)" ]; then
        echo "[include]" >>$GIT_CONFIG_FILE
        echo "    path = conf/config" >>$GIT_CONFIG_FILE
        show_success "write include config path..."
    else
        show_warning "already setting config path..."
    fi
}

git_check_config() {
    local _user_name=$(eval echo \$$1)
    local _user_email=$(eval echo \$$2)

    if [ ! -f $GIT_CONFIG_FILE ]; then
        show_warning " >>> not found git config file..."
        echo " >>> touch $GIT_CONFIG_FILE ..."
        mkdir -p $GIT_CONFIG_PATH
        touch $GIT_CONFIG_FILE

        # setting user.name and user.email
        if [ -z $_user_name ] || [ -z $_user_email ]; then
            show_error "missing git user.name or user.email"
            git_config_input _user_name _user_email
        else
            git_config _user_name _user_email
        fi
    else
        show_success "found git config file..."
        _user_name="$(git config --global user.name)"
        _user_email="$(git config --global user.email)"
    fi

    local "$1" && _upvar $1 $_user_name
    local "$2" && _upvar $2 $_user_email
}

#
# git_check_config $@
# git_write_conf_path
