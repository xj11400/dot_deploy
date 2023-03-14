#!/bin/bash
GIT_CONFIG_FILE="$HOME/.config/git/config"

function config(){
    GIT_USER_NAME="XJ Hsu"
    GIT_USER_EMAIL="xj11400@gmail.com"

    echo ""
    # set user name
    read -p "enter user name($GIT_USER_NAME): " gitUserName

    if [ -z $gitUserName ];then
        echo " >>> user.name = $GIT_USER_NAME"
    else
        echo " >>> user.name = $gitUserName"
        GIT_USER_NAME=$gitUserName
    fi

    git config --global user.name "$GIT_USER_NAME"

    echo ""
    # set user email
    read -p "enter user email($GIT_USER_EMAIL): " gitUserEmail

    if [ -z $gitUserEmail ];then
        echo " >>> user.email = $GIT_USER_EMAIL"
    else
        echo " >>> user.email = $gitUserEmail"
        GIT_USER_EMAIL=$gitUserEmail
    fi

    git config --global user.email "$GIT_USER_EMAIL"

    echo ""
}

if ! [[ -f $GIT_CONFIG_FILE ]];then
    echo " >>> not found git config file..."
    echo " >>> touch $GIT_CONFIG_FILE ..."
    touch $GIT_CONFIG_FILE
    config
else
    echo " >>> found git config file..."
fi

echo " >>> write include config path..."
echo "[include]" >> $GIT_CONFIG_FILE
echo "    path = conf/config" >> $GIT_CONFIG_FILE
