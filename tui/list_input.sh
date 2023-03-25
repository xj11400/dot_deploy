#
# list_input
#

on_list_input_up() {
    remove_list_instructions
    tput cub "$(tput cols)"

    printf "  ${_list_options[$_list_selected_index]}"
    tput el

    if [ $_list_selected_index = 0 ]; then
        _list_selected_index=$((${#_list_options[@]} - 1))
        tput cud $((${#_list_options[@]} - 1))
        tput cub "$(tput cols)"
    else
        _list_selected_index=$((_list_selected_index - 1))

        tput cuu1
        tput cub "$(tput cols)"
        tput el
    fi

    printf "${cyan}${arrow} %s ${normal}" "${_list_options[$_list_selected_index]}"
}

on_list_input_down() {
    remove_list_instructions
    tput cub "$(tput cols)"

    printf "  ${_list_options[$_list_selected_index]}"
    tput el

    if [ $_list_selected_index = $((${#_list_options[@]} - 1)) ]; then
        _list_selected_index=0
        tput cuu $((${#_list_options[@]} - 1))
        tput cub "$(tput cols)"
    else
        _list_selected_index=$((_list_selected_index + 1))
        tput cud1
        tput cub "$(tput cols)"
        tput el
    fi
    printf "${cyan}${arrow} %s ${normal}" "${_list_options[$_list_selected_index]}"
}

on_list_input_enter_space() {
    local OLD_IFS
    OLD_IFS=$IFS
    IFS=$'\n'

    tput cud $((${#_list_options[@]} - ${_list_selected_index}))
    tput cub "$(tput cols)"

    for i in $(seq $((${#_list_options[@]} + 1))); do
        tput el1
        tput el
        tput cuu1
    done
    tput cub "$(tput cols)"

    tput cuf $((${#prompt} + 3))
    printf "${cyan}${_list_options[$_list_selected_index]}${normal}"
    tput el

    tput cud1
    tput cub "$(tput cols)"
    tput el

    _break_keypress=true
    IFS=$OLD_IFS
}

remove_list_instructions() {
    if [ $_first_keystroke = true ]; then
        tput cuu $((${_list_selected_index} + 1))
        tput cub "$(tput cols)"
        tput cuf $((${#prompt} + 3))
        tput el
        tput cud $((${_list_selected_index} + 1))
        _first_keystroke=false
    fi
}

# Support VIM hjkl move
on_list_input_ascii() {
    key=$1
    if [[ $key == 'k' || $key == 'K' || $key == 'h' || $key == 'H' ]]; then
        on_list_input_up
    elif [[ $key == 'j' || $key == 'J' || $key == 'l' || $key == 'L' ]]; then
        on_list_input_down
    fi
}

_list_input() {
    local i
    local j
    prompt=$1
    hint=$2
    eval _list_options=( '"${'${3}'[@]}"' )

    _list_selected_index=0
    _first_keystroke=true

    trap control_c SIGINT EXIT

    stty -echo
    tput civis

    print "${normal}${green}?${normal} ${bold}${prompt}${normal} ${dim}${hint}${normal}"

    for i in $(gen_index ${#_list_options[@]}); do
        tput cub "$(tput cols)"
        if [ $i = 0 ]; then
            print "${cyan}${arrow} ${_list_options[$i]} ${normal}"
        else
            print "  ${_list_options[$i]}"
        fi
        tput el
    done

    for j in $(gen_index ${#_list_options[@]}); do
        tput cuu1
    done

    on_keypress on_list_input_up on_list_input_down on_list_input_enter_space on_list_input_enter_space on_list_input_up on_list_input_down on_list_input_ascii on_list_input_up

}

list_input() {
    _list_input "$1" "$2" "$3"
    local var_name=$4
    eval $var_name=\'"${_list_options[$_list_selected_index]}"\'
    unset _list_selected_index
    unset _list_options
    unset _break_keypress
    unset _first_keystroke

    cleanup
}

list_input_index() {
    _list_input "$1" "$2" "$3"
    local var_name=$4
    eval $var_name=\'"$_list_selected_index"\'
    unset _list_selected_index
    unset _list_options
    unset _break_keypress
    unset _first_keystroke

    cleanup
}
