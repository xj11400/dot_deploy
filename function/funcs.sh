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
    if unset -v "$1"; then # Unset & validate varname
        eval $1\=\(\)
        if (($# == 2)); then
            eval $1=\"\$2\" # Return single value
        else
            eval $1=\(\"\${@:2}\"\) # Return array
        fi
    fi
}

# check commands exist or not
check_command() {
    if ! [ -x "$(command -v $1)" ]; then
        show_error "command $1 not found"
    else
        show_success "command $1 found"
    fi
}

# list folder
list_of_dirs() {

    local -a _dir_options

    local _dir=$1
    local _dirs=$(ls $_dir)
    for _d in ${_dirs}; do

        # filter file
        if [ -f $_dir/$_d ]; then
            continue
        fi

        # filter prefix _
        if [ "${_d:0:1}" == "_" ]; then
            continue
        fi

        # filter prefix .
        if [ "${_d:0:1}" == "." ]; then
            continue
        fi

        # echo "-$_d-"
        _dir_options+=("${_d}")

    done

    if [ ! -z "$2" ]; then
        local "$2" && _upvar $2 "${_dir_options[@]}"
    else
        IFS="" echo -n "${_dir_options[@]}"
    fi
}

stow_dot() {
    local _dir=$1
    local _list=$2[@]
    for _d in ${!_list}; do
        echo "${_dir}/$_d"
        stow -d $_dir -t $HOME $_d --no-folding
        # prograss bar
        # [=======         ] 35% $_d
    done
}

restow_dot() {
    local _dir=$1
    local _list=$2[@]
    for _d in ${!_list}; do
        echo "${_dir}/$_d"
        stow -d $_dir -t $HOME $_d --no-folding --restow
        # prograss bar
        # [=======         ] 35% $_d
    done
}
