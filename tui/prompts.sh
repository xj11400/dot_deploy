#!/bin/bash
# @name Prompts
# @brief Inquirer.js inspired prompts
# @brief fork from https://github.com/timo-reymann/bash-tui-toolkit
# @brief add reference and selected function

# colors
# ======
#_color_selected="\033[0m"
# readonly SELECTED="[x]"
# readonly UNSELECTED="[ ]"
# 
# readonly WHITE="\033[2K\033[37m"
# readonly BLUE="\033[2K\033[34m"
# readonly RED="\033[2K\033[31m"
# readonly GREEN="\033[2K\033[32m"


# sign
# ====
# _sign_arrow="$(echo -e '\xe2\x9d\xaf')"
# _sign_checked="$(echo -e '\xe2\x97\x89')"
# _sign_unchecked="$(echo -e '\xe2\x97\xaf')"

# functions
# =========

_get_cursor_row() {
    local IFS=';'
    # shellcheck disable=SC2162,SC2034
    read -sdR -p $'\E[6n' ROW COL;
    echo "${ROW#*[}";
}
_cursor_blink_on() { echo -en "\033[?25h" >&2; }
_cursor_blink_off() { echo -en "\033[?25l" >&2; }
_cursor_to() { echo -en "\033[$1;$2H" >&2; }

# key input helper
_key_input() {
    local ESC=$'\033'
    local IFS=''

    read -rsn1 a
    # is the first character ESC?
    if [[ "$ESC" == "$a" ]]; then
        read -rsn2 b
    fi

    local input="${a}${b}"
    # shellcheck disable=SC1087
    case "$input" in
        "$ESC[A") echo up ;;
        "$ESC[B") echo down ;;
        "$ESC[C") echo right ;;
        "$ESC[D") echo left ;;
        'h') echo left ;;
        'j') echo down ;;
        'k') echo up ;;
        'l') echo right ;;
        '') echo enter ;;
        ' ') echo space ;;
    esac
}

# print new line for empty element in array
# shellcheck disable=SC2231
_new_line_foreach_item() {
    count=0
    while [[ $count -lt $1  ]];
    do
        echo "" >&2
        ((count++))
    done
}

# display prompt text without linebreak
_prompt_text() {
    echo -en "\033[32m?\033[0m\033[1m ${1}\033[0m " >&2
}

# display hint text without linebreak
_hint_text() {
    if [ ! -z $1 ];then
        echo -en "\033[30m(${1})\033[0m" >&2
    fi
}

# display selected text without linebreak
_selected_text() {
    echo -en "  - \033[34m${1}\033[0m " >&2
}

# decrement counter $1, considering out of range for $2
_decrement_selected() {
    local selected=$1;
    ((selected--))
    if [ "${selected}" -lt 0 ]; then
        selected=$(($2 - 1));
    fi
    echo -n $selected
}

# increment counter $1, considering out of range for $2
_increment_selected() {
    local selected=$1;
    ((selected++));
    if [ "${selected}" -ge "${opts_count}" ]; then
        selected=0;
    fi
    echo -n $selected
}

# Assign variable one scope above the caller.
# Usage: local "$1" && upvar $1 value [value ...]
# Param: $1  Variable name to assign value to
# Param: $*  Value(s) to assign.  If multiple values, an array is
#            assigned, otherwise a single value is assigned.
# NOTE: For assigning multiple variables, use 'upvars'.  Do NOT
#       use multiple 'upvar' calls, since one 'upvar' call might
#       reassign a variable to be used by another 'upvar' call.
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        eval $1\=\(\)
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

# @description format list
# @arg $1 array List
# @stdout option1, option2, ...
join() {
    local IFS=$'\n'
    local _join_list
    eval _join_list=( '"${'${1}'[@]}"' )
    local first=true
    for item in ${_join_list[@]}; do
    if [ "$first" = true ]; then
        printf "%s" "$item"
        first=false
    else
        printf "${2-, }%s" "$item"
    fi
    done
}

# @description mapping options and checked index
# @arg $1 array List of options
# @arg $2 array List of checked index
# @stdout selected optionss
selected_idx_join() {
    local _options=$1[@]
    local opts; opts=( "${!_options}" )
    local _checked=$2[@]

    local _selected=()
    local IFS=$' \r'
    for i in ${!_checked}; do
        if [ ! -z "$i" ];then
            _selected+=( "${opts[$i]}" )
        fi
    done
    IFS="" echo -n "${_selected[@]}"
}

# @description Prompt for text
# @arg $1 string Phrase for prompting to text
# @stderr Instructions for user
# @stdout Text as provided by user
# @example
#   # Raw input without validation
#   text=$(input "Please enter something and confirm with enter")
# @example
#   # Input with validation
#   text=$(with_validate 'input "Please enter at least one character and confirm with enter"' validate_present)
input() {
    _prompt_text "$1"; echo -en "\033[36m\c" >&2
    read -r text
    echo -n "${text}"
}

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
    _prompt_text "$1 (y/N)"
    local result=""
    until [[ "$result" == "y" ]] || [[ "$result" == "n" ]] || [[ "$result" == "Y" ]] || [[ "$result" == "N" ]]
    do
        _read_char result

        if [ ${#result} -eq 0 ]; then
            # echo "Enter was hit" >&2
            result="n"
        fi
    done

    echo -en "\033[36m$result\033[0m" >&2
    case "$result" in
        y|Y) echo -n 1 ;;
        n|N) echo -n 0 ;;
    esac

    echo "" >&2
}

# @description Renders a text based list of options that can be selected by the
# user using up, down and enter keys and returns the chosen option.
# Inspired by https://unix.stackexchange.com/questions/146570/arrow-key-enter-menu/415155#415155
# @arg $1 string Phrase for promptint to text
# @arg $2 array List of options (max 256)
# @stdout selected index (0 for opt1, 1 for opt2 ...)
# @stderr Instructions for user
# @example
#   options=("one" "two" "three" "four")
#   option=$(list "Select one item" "${options[@]}")
#   echo "Your choice: ${options[$option]}"
list() {
    _prompt_text "$1 "
    _hint_text "$2"

    local _options=$3[@]
    local opts; opts=( "${!_options}" )
    local opts_count; opts_count=$((${#opts[@]}))
    _new_line_foreach_item "${#opts[@]}"

    # determine current screen position for overwriting the options
    local lastrow; lastrow=$(_get_cursor_row)
    local startrow; startrow=$((lastrow - opts_count + 1))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "_cursor_blink_on; stty echo; exit" 2
    _cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt in "${opts[@]}"; do
            _cursor_to $((startrow + idx))
            if [ $idx -eq $selected ]; then
                printf "\033[0m\033[36m❯\033[0m \033[36m%s\033[0m" "$opt" >&2
            else
                printf "  %s" "$opt" >&2
            fi
            ((idx++))
        done

        # user key control
        case $(_key_input) in
            enter) break; ;;
            up) selected=$(_decrement_selected "${selected}" "${opts_count}"); ;;
            down) selected=$(_increment_selected "${selected}" "${opts_count}"); ;;
        esac
    done

    echo -en "\n" >&2

    # cursor position back to normal
    # _cursor_to "${lastrow}"
    # _cursor_blink_on

    # clean options
    local idx=0
    for opt in "${opts[@]}"; do
        _cursor_to $((startrow + idx -1))
        n=$((${#opt}+3))
        n=$(eval echo {0..$n})
        printf '\r'; printf ' %0.s' $n >&2 # 10 expansions of the space character
        ((idx++))
    done

    # show selected
    _cursor_to $((startrow-1))
    _selected_text "${opts[$selected]}"

    _cursor_to $((startrow))
    _cursor_blink_on

    if [ ! -z "$4" ];then
        local "$4" && _upvar $4 "${opts[$selected]}"
    else
        echo -n "${selected}"
    fi

}

# @description Render a text based list of options, where multiple can be selected by the
# user using up, down and enter keys and returns the chosen option.
# Inspired by https://unix.stackexchange.com/questions/146570/arrow-key-enter-menu/415155#415155
# @arg $1 string Phrase for promptint to text
# @arg $2 array List of options (max 256)
# @stdout selected index (0 for opt1, 1 for opt2 ...)
# @stderr Instructions for user
# @example
#   options=("one" "two" "three" "four")
#   checked=$(checkbox "Select one or more items" "${options[@]}")
#   echo "Your choices: ${checked}"
checkbox() {
    local _options=$3[@]
    local _selected=$4[@]

    local checked=()

    # check selected
    local _idx=0;
    if [ ! -z "$_selected" ];then
        for op in "${!_options}"; do
            for se in "${!_selected}"; do
                if [ "$op" == "$se" ];then
                    checked+=("${_idx}")
                fi
            done
            ((_idx++))
        done
    fi

    _prompt_text "$1"
    _hint_text "$2"

    local opts; opts=( "${!_options}" )
    local opts_count; opts_count=$((${#opts[@]}))
    _new_line_foreach_item "${#opts[@]}"

    # determine current screen position for overwriting the options
    local lastrow; lastrow=$(_get_cursor_row)
    local startrow; startrow=$((lastrow - opts_count + 1))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "_cursor_blink_on; stty echo; exit" 2
    _cursor_blink_off

    local selected=0

    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt in "${opts[@]}"; do
            _cursor_to $((startrow + idx))
            local icon="◯"
            for item in "${checked[@]}"; do
                if [ "$item" == "$idx" ]; then
                    icon="◉"
                    break;
                fi
            done

            if [ $idx -eq $selected ]; then
                printf "❯%s \e[0m\e[36m\e[0m\e[36m%-50s\e[0m" "$icon" "$opt" >&2
            else
                printf " %s %-50s" "$icon" "$opt" >&2
            fi
            ((idx++))
        done

        # user key control
        case $(_key_input) in
            enter) break;;
            space)
                local found=0;
                for item in "${checked[@]}"; do
                    if [ "$item" == "$selected" ]; then
                        found=1
                        break;
                    fi
                done
                if [ $found -eq 1 ]; then
                    checked=( "${checked[@]/$selected}" )
                else
                    checked+=("${selected}")
                fi
                ;;
            up) selected=$(_decrement_selected "${selected}" "${opts_count}"); ;;
            down) selected=$(_increment_selected "${selected}" "${opts_count}"); ;;
        esac
    done

    # cursor position back to normal
    # _cursor_to "${lastrow}"
    # _cursor_blink_on

    # clean options
    local idx=0
    for opt in "${opts[@]}"; do
        _cursor_to $((startrow + idx))

        n=$((${#opt}+3))
        n=$(eval echo {0..$n})
        printf '\r'; printf ' %0.s' $n >&2 # 10 expansions of the space character
        ((idx++))
    done

    checked=($(printf '%s\n' "${checked[@]}"|sort))

    # show selected
    local _selected=()
    for item in "${checked[@]}"; do
        _selected+=("${opts[$item]}")
    done
    _cursor_to $((startrow))
    _selected_text "${_selected[*]}"

    _cursor_to $((startrow+1))
    _cursor_blink_on

    if [ ! -z "$4" ];then
        local "$4" && _upvar $4 "${_selected[@]}"
    else
        IFS="" echo -n "${checked[@]}"
    fi
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
    _prompt_text "$1"
    echo -en "\033[36m" >&2
    local password=''
    local IFS=
    while read -r -s -n1 char; do
        # ENTER pressed; output \n and break.
        [[ -z "${char}" ]] && { printf '\n' >&2; break; }
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

# @description Open default editor ($EDITOR) if none is set falls back to vi
# @arg $1 string Phrase for promptint to text
# @stdout Text as input by user in input
# @stderr Instructions for user
# @example
#   # Open default editor
#   text=$(editor "Please enter something in the editor")
#   echo -e "You wrote:\n${text}"
editor() {
    tmpfile=$(mktemp)
    _prompt_text "$1"
    echo "" >&2

    "${EDITOR:-vi}" "${tmpfile}" >/dev/tty
    echo -en "\033[36m" >&2
    # shellcheck disable=SC2002
    cat "${tmpfile}" | sed -e 's/^/  /' >&2
    echo -en "\033[0m" >&2

    cat "${tmpfile}"
}

# @description Evaluate prompt command with validation, this prompts the user for input till the validation function
# returns with 0
# @arg $1 string Prompt command to evaluate until validation is successful
# @arg #2 function validation callback (this is called once for exit code and once for status code)
# @stdout Value collected by evaluating prompt
# @stderr Instructions for user
# @example
#   # Using builtin is present validator
#   text=$(with_validate 'input "Please enter something and confirm with enter"' validate_present)
# @example
#   # Using custom validator e.g. for password
#   validate_password() { if [ ${#1} -lt 10 ];then echo "Password needs to be at least 10 characters"; exit 1; fi }
#   pass=$(with_validate 'password "Enter random password"' validate_password)
with_validate() {
    while true; do
        local val; val="$(eval "$1")"
        if ($2 "$val" >/dev/null); then
            echo "$val";
            break;
        else
            show_error "$($2 "$val")";
        fi
    done
}

# @description Validate a prompt returned any value
# @arg $1 value to validate
# @stdout error message for user
# @exitcode 0 String is at least 1 character long
# @exitcode 1 There was no input given
# @example
#   # text input with validation
#   text=$(with_validate 'input "Please enter something and confirm with enter"' validate_present)
validate_present() {
    if [ "$1" != "" ]; then return 0; else echo "Please specify the value"; return 1; fi
}
