#!/bin/bash

# @description The stty raw mode prevents ctrl-c from working
#              and can get you stuck in an input loop with no
#              way out. Also the man page says stty -raw is not
#              guaranteed to return your terminal to the same state.
# @arg $1 reference set received char
# https://stackoverflow.com/a/30022297
_read_char() {
    stty -icanon -echo
    eval "$1=\$(dd bs=1 count=1 2>/dev/null)"
    stty icanon echo
}

# @description Show confirm dialog for yes/no
# @arg $1 string Phrase for promptint to text
# @stdout 0 for no, 1 for yes
# @stderr Instructions for user
# @example
#   confirmed=$(confirm "Should it be?")
#   if [ "$confirmed" = "0" ]; then echo "No?"; else echo "Yes!"; fi
confirm() {
    show_question "$1 (y/N)"
    local result=""
    until [[ "$result" == "y" ]] || [[ "$result" == "n" ]] || [[ "$result" == "Y" ]] || [[ "$result" == "N" ]]; do
        _read_char result

        if [ ${#result} -eq 0 ]; then
            # echo "Enter was hit" >&2
            result="n"
        fi
    done

    echo -en "\033[36m$result\033[0m" >&2
    case "$result" in
    y | Y) echo -n 1 ;;
    n | N) echo -n 0 ;;
    esac

    echo "" >&2
}

# @description Show password prompt displaying stars for each password character letter typed
# it also allows deleting input
# @arg $1 string Phrase for promptint to text
# @stdout password as written by user
# @stderr Instructions for user
# @example
#   # Password prompt with custom validation
#   validate_password() { if [ ${#1} -lt 10 ];then echo "Password needs to be at least 10 characters"; exit 1; fi }
#   pass=$(with_validate 'password "Enter random password"' validate_password)
# @example
#   # Password ith no validation
#   pass=$(password "Enter password to use")
password() {
    show_question "$1"
    echo -en "\033[36m" >&2
    local password=''
    local IFS=
    while read -r -s -n1 char; do
        # ENTER pressed; output \n and break.
        [[ -z "${char}" ]] && {
            printf '\n' >&2
            break
        }
        # BACKSPACE pressed; remove last character
        if [ "${char}" == $'\x7f' ]; then
            if [ "${#password}" -gt 0 ]; then
                password="${password%?}"
                echo -en '\b \b' >&2
            fi
        else
            password+=$char
            echo -en '*' >&2
        fi
    done
    echo -en "\e[0m" >&2
    echo -n "${password}"
}
