#
# checkbox_input
#

on_checkbox_input_up() {
    remove_checkbox_instructions
    tput cub "$(tput cols)"

    if [ "${_checkbox_selected[$_current_index]}" = true ]; then
        printf " ${green}${checked}${normal} ${_checkbox_list[$_current_index]} ${normal}"
    else
        printf " ${unchecked} ${_checkbox_list[$_current_index]} ${normal}"
    fi
    tput el

    if [ $_current_index = 0 ]; then
        _current_index=$((${#_checkbox_list[@]} - 1))
        tput cud $((${#_checkbox_list[@]} - 1))
        tput cub "$(tput cols)"
    else
        _current_index=$((_current_index - 1))

        tput cuu1
        tput cub "$(tput cols)"
        tput el
    fi

    if [ "${_checkbox_selected[$_current_index]}" = true ]; then
        printf "${cyan}${arrow}${green}${checked}${normal} ${_checkbox_list[$_current_index]} ${normal}"
    else
        printf "${cyan}${arrow}${normal}${unchecked} ${_checkbox_list[$_current_index]} ${normal}"
    fi
}

on_checkbox_input_down() {
    remove_checkbox_instructions
    tput cub "$(tput cols)"

    if [ "${_checkbox_selected[$_current_index]}" = true ]; then
        printf " ${green}${checked}${normal} ${_checkbox_list[$_current_index]} ${normal}"
    else
        printf " ${unchecked} ${_checkbox_list[$_current_index]} ${normal}"
    fi

    tput el

    if [ $_current_index = $((${#_checkbox_list[@]} - 1)) ]; then
        _current_index=0
        tput cuu $((${#_checkbox_list[@]} - 1))
        tput cub "$(tput cols)"
    else
        _current_index=$((_current_index + 1))
        tput cud1
        tput cub "$(tput cols)"
        tput el
    fi

    if [ "${_checkbox_selected[$_current_index]}" = true ]; then
        printf "${cyan}${arrow}${green}${checked}${normal} ${_checkbox_list[$_current_index]} ${normal}"
    else
        printf "${cyan}${arrow}${normal}${unchecked} ${_checkbox_list[$_current_index]} ${normal}"
    fi
}

on_checkbox_input_enter() {
    local OLD_IFS
    OLD_IFS=$IFS
    _checkbox_selected_indices=()
    _checkbox_selected_options=()
    IFS=$'\n'

    for i in $(gen_index ${#_checkbox_list[@]}); do
        if [ "${_checkbox_selected[$i]}" = true ]; then
            _checkbox_selected_indices+=($i)
            _checkbox_selected_options+=("${_checkbox_list[$i]}")
        fi
    done

    tput cud $((${#_checkbox_list[@]} - ${_current_index}))
    tput cub "$(tput cols)"

    for i in $(seq $((${#_checkbox_list[@]} + 1))); do
        tput el1
        tput el
        tput cuu1
    done
    tput cub "$(tput cols)"

    tput cuf $((${#prompt} + 3))
    printf "\n"
    printf "${cyan}$(join _checkbox_selected_options)${normal}"
    tput el

    tput cud1
    tput cub "$(tput cols)"
    tput el

    _break_keypress=true
    IFS=$OLD_IFS
}

on_checkbox_input_space() {
    remove_checkbox_instructions
    tput cub "$(tput cols)"
    tput el
    if [ "${_checkbox_selected[$_current_index]}" = true ]; then
        _checkbox_selected[$_current_index]=false
    else
        _checkbox_selected[$_current_index]=true
    fi

    if [ "${_checkbox_selected[$_current_index]}" = true ]; then
        printf "${cyan}${arrow}${green}${checked}${normal} ${_checkbox_list[$_current_index]} ${normal}"
    else
        printf "${cyan}${arrow}${normal}${unchecked} ${_checkbox_list[$_current_index]} ${normal}"
    fi
}

remove_checkbox_instructions() {
    if [ $_first_keystroke = true ]; then
        tput cuu $((${_current_index} + 1))
        tput cub "$(tput cols)"
        tput cuf $((${#prompt} + 3))
        tput el
        tput cud $((${_current_index} + 1))
        _first_keystroke=false
    fi
}

# for vim movements
on_checkbox_input_ascii() {
    local key=$1
    case $key in
    "j") on_checkbox_input_down ;;
    "k") on_checkbox_input_up ;;
    esac
}

_checkbox_input() {
    local i
    local j
    prompt=$1
    hint=$2
    eval _checkbox_list=( '"${'${3}'[@]}"' )
    _current_index=0
    _first_keystroke=true

    trap control_c SIGINT EXIT

    stty -echo
    tput civis

    print "${normal}${green}?${normal} ${bold}${prompt}${normal} ${dim}${hint}${normal}"

    for i in $(gen_index ${#_checkbox_list[@]}); do
        _checkbox_selected[$i]=false
    done

    if [ -n "$3" ]; then
        eval _selected_indices=( '"${'${4}'[@]}"' )

        for i in $(gen_index ${#_checkbox_list[@]}); do
            for se in "${_selected_indices[@]}"; do
                if [ "$se" == "${_checkbox_list[$i]}" ]; then
                    _checkbox_selected[$i]=true
                fi
            done
        done
    fi

    for i in $(gen_index ${#_checkbox_list[@]}); do
        tput cub "$(tput cols)"
        if [ $i = 0 ]; then
            if [ "${_checkbox_selected[$i]}" = true ]; then
                print "${cyan}${arrow}${green}${checked}${normal} ${_checkbox_list[$i]} ${normal}"
            else
                print "${cyan}${arrow}${normal}${unchecked} ${_checkbox_list[$i]} ${normal}"
            fi
        else
            if [ "${_checkbox_selected[$i]}" = true ]; then
                print " ${green}${checked}${normal} ${_checkbox_list[$i]} ${normal}"
            else
                print " ${unchecked} ${_checkbox_list[$i]} ${normal}"
            fi
        fi
        tput el
    done

    for j in $(gen_index ${#_checkbox_list[@]}); do
        tput cuu1
    done

    on_keypress on_checkbox_input_up on_checkbox_input_down on_checkbox_input_space on_checkbox_input_enter on_default on_default on_checkbox_input_ascii
}

checkbox_input() {
    _checkbox_input "$1" "$2" "$3" "$4"
    _checkbox_input_output_var_name=$4
    select_indices _checkbox_list _checkbox_selected_indices $_checkbox_input_output_var_name

    unset _checkbox_list
    unset _break_keypress
    unset _first_keystroke
    unset _current_index
    unset _checkbox_input_output_var_name
    unset _checkbox_selected_indices
    unset _checkbox_selected_options

    cleanup
}

checkbox_input_indices() {
    _checkbox_input "$1" "$2" "$3" "$4"
    _checkbox_input_output_var_name=$4

    eval $_checkbox_input_output_var_name\=\(\)
    for i in $(gen_index ${#_checkbox_selected_indices[@]}); do
        eval $_checkbox_input_output_var_name\+\=\(${_checkbox_selected_indices[$i]}\)
    done

    unset _checkbox_list
    unset _break_keypress
    unset _first_keystroke
    unset _current_index
    unset _checkbox_input_output_var_name
    unset _checkbox_selected_indices
    unset _checkbox_selected_options

    cleanup
}
