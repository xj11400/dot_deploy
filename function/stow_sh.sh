#!/bin/bash

# fork: https://github.com/bashdot/bashdot

VERSION=4.1.7

#
# variables
#
STOW_DIR=$(pwd)
STOW_TARGET=$HOME
STOW_PROFILE=()
STOW_DELETE_PROFILE=()
STOW_RESTOW=false
STOW_DELETE=false
STOW_INSTALL=true

# ignored_files='^.$|^..$|^changelog|^contributing|^dockerfile|^icon|^license|^makefile|^readme|^.git'
#TODO
# ignore_xdg='.local/share|.local/state|.config|.cache'
# current_working_dir=$(pwd)
# bashdot_config_file=$HOME/.cache/stow/.bashdot

LOGGER_FMT=${LOGGER_FMT:="%Y-%m-%d"}
LOGGER_LVL=${LOGGER_LVL:="info"}

if [ -n "$BASHDOT_LOG_LEVEL" ]; then
    LOGGER_LVL=$BASHDOT_LOG_LEVEL
fi

usage() {
    case "$1" in
    commands)
        echo "Usage: bashdot [dir|install|links|profiles|uninstall|version] OPTIONS"
        ;;
    install)
        echo "Usage: bashdot install PROFILE1 PROFILE2 ... PROFILEN"
        ;;
    uninstall)
        echo "Usage: bashdot uninstall PROFILE_DIRECTORY PROFILE"
        ;;
    esac
}

###### verify

exit_if_profile_directories_contain_invalid_characters() {
    profile_dir=$1
    if [ ! -d $profile_dir ]; then
        log error "Directory '$profile_dir' not exist."
        exit 1
    fi

    if ls "$profile_dir" | grep -E '[[:space:]:,/\]'; then
        log error "Files in '$profile_dir' contain invalid characters."
        exit 1
    fi
    # log info "[profile_directories_contain_invalid_characters] '$1' verified!!"
}

exit_if_invalid_directory_name() {
    dir=$1
    if ! echo "$dir" | grep "^[/.a-zA-Z0-9_-]*$" >/dev/null; then
        log error "Current working directory '$dir' has an invalid character. The directory you are in when you install a profile must have alpha numeric characters, with only dashes, dots or underscores."
        exit 1
    fi
    # log info "[invalid_directory_name] '$1' verified!!"
}

exit_if_invalid_profile_name() {
    profile=$1
    if ! echo "$profile" | grep "^[a-zA-Z0-9_-]*$" >/dev/null; then
        log error "Invalid profile name '$profile'. Profiles must be alpha numeric with only dashes or underscores."
        exit 1
    fi
    # log info "[invalid_profile_name] '$1' verified!!"
}

check_valid_profile_name() {
    profile=$1
    if ! echo "$profile" | grep "^[a-zA-Z0-9_-]*$" | grep -v "^$\|^--restow$\|^--delete$\|^--stow$" >/dev/null; then
        IFS=''
        echo -en "false"
    else
        IFS=''
        echo -en "true"
    fi
}
## logger

log() {
    action=$1 && shift

    case "$action" in
    debug) [[ "$LOGGER_LVL" =~ debug ]] && echo "$(date "+${LOGGER_FMT}") - DEBUG - $@" 1>&2 ;;
    info) [[ "$LOGGER_LVL" =~ debug|info ]] && echo "$(date "+${LOGGER_FMT}") - INFO - $@" 1>&2 ;;
    warn) [[ "$LOGGER_LVL" =~ debug|info|warn ]] && echo "$(date "+${LOGGER_FMT}") - WARN - $@" 1>&2 ;;
    error) [[ ! "$LOGGER_LVL" =~ none ]] && echo "$(date "+${LOGGER_FMT}") - ERROR - $@" 1>&2 ;;
    esac

    true
}

####

link_dotfile() {
    source_file=$1
    target_file=$2

    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        existing=$(readlink "$target_file")
        log debug "Evaluating if '$target_file' which links to '$existing' matches desired target '$source_file'."

        if [ "$existing" == "$source_file" ]; then
            log info "File '$target_file' already links to '$source_file', continuing."
            return
        fi
        return

        log error "File '$_file' already exists, exiting."
    fi

    log debug "'$target_file' does not link to desired target '$source_file'."
    log info "Linking '$source_file' to '$target_file'."

    _target_dir_name="$(dirname "$target_file")"
    echo "target dir: $_target_dir_name"

    if [ ! -d "${_target_dir_name}" ]; then
        echo "mkdir -p $_target_dir_name"
        mkdir -p $_target_dir_name
    fi

    ln -s "$source_file" "$target_file"
}

#TODO don't reverify
install_no_folding() {
    _files=()
    profile=$1
    profile_dir="$STOW_DIR/$profile"

    # exit_if_profile_directories_contain_invalid_characters "$profile_dir"

    # Pipe separated regex (parsed by egrep, case insensitive)
    # that will not be symlinked by bashdot
    ignored_files='^.$|^..$|^changelog|^contributing|^dockerfile|^icon|^license|^makefile|^readme|^.git'

    if [ ! -d "$profile_dir" ]; then
        log error "Profile '$profile' directory does not exist."
        exit 1
    fi

    log info "Adding dotfiles profile '$profile'."
    for _f in $(find $profile_dir -type f); do
        echo "[$_f]"
        _rel_path="${_f/$profile_dir\//}"
        if $(echo "${_rel_path}" | grep -E -i "$ignored_files" >/dev/null 2>&1); then
            echo -- $_f
            continue
        fi

        _filename="${_f##*/}"
        if $(echo "${_filename}" | grep -E -i "$ignored_files" >/dev/null 2>&1); then
            echo -- $_f
            continue
        fi

        _file="${_f/$profile_dir/$STOW_TARGET}"
        echo ">>>>   $_file"

        # _source_file="$_f"
        # if [ -e "$_file" ] || [ -L "$_file" ]; then
        #     echo "exist!!!"
        #     existing=$(readlink "$_file")

        #     # Skip files which already link to the same location
        #     if [ "$existing" == "$source_file" ]; then
        #         continue
        #     fi

        #     log error "File '$_file' already exists, exiting."
        #     continue
        # fi

        _files+=("${_rel_path}")
    done

    log info "Installing dotfiles from '$profile_dir'."

    for _f in ${_files[@]}; do
        echo "ln -s $STOW_DIR/$_f $STOW_TARGET/$_f"
        # ln -s $STOW_DIR/$_f $STOW_TARGET/$_f
        link_dotfile $STOW_DIR/$_f $STOW_TARGET/$_f
    done

    echo "install no folding done!!!"
}


_get_dir(){
    if [ -f $profile_dir/$_file ];then
        echo "is a file">&2
        IFS=''
        echo $_file
    elif [ -d $profile_dir/$_file ];then
        echo "is a directory">&2
        # while $(ls -a $profile_dir | grep -E -iv "$ignored_files");do
        # done
    fi
}

install() {
    profile=$1
    profile_dir="$STOW_DIR/$profile"
    _files=()

    exit_if_profile_directories_contain_invalid_characters "$profile_dir"

    # Pipe separated regex (parsed by egrep, case insensitive)
    # that will not be symlinked by bashdot
    #TODO:: .git?
    ignored_files='^.$|^..$|^changelog|^contributing|^dockerfile|^icon|^license|^makefile|^readme|^.git'

    if [ ! -d "$profile_dir" ]; then
        log error "Profile '$profile' directory does not exist."
        exit 1
    fi

    log info "Adding dotfiles profile '$profile'."

    log debug "Checking for exiting conflicting dotfiles."
    for _file in $(ls -a $profile_dir | grep -E -iv "$ignored_files"); do
        echo "--$_file"

        # _ret
        if [ -f $profile_dir/$_file ];then
            echo "is a file"
            _files+=("${_ret}")
            return
        elif [ -d $profile_dir/$_file ];then
            echo "is a directory"

            # while $(ls -a $profile_dir | grep -E -iv "$ignored_files");do
            # done
        fi

        _target_file="$STOW_TARGET/$_file/$profile"
        echo "--$_target_file"
        source_file="$profile_dir/$_file"
        if [ -e "$_target_file" ]; then
            existing=$(readlink "$_target_file")

            # Skip files which already link to the same location
            if [ "$existing" == "$source_file" ]; then
                continue
            fi

            log error "File '$_target_file' already exists, exiting."
            # exit 1
        fi



    done
    exit
    # log debug "Found no conflicting dotfiles in home, proceeding to link dotfile."
    # if [ -f "$bashdot_config_file" ]; then
    #     if ! grep -E "^$STOW_DIR$" "$bashdot_config_file" >/dev/null; then
    #         log info "Appending '$STOW_DIR' to bashdot config file '$bashdot_config_file'"
    #         echo "$STOW_DIR" >>"$bashdot_config_file"
    #     fi
    # else
    #     log info "Creating bashdot config file '$bashdot_config_file' with '$STOW_DIR'."
    #     echo "$STOW_DIR" >"$bashdot_config_file"
    # fi

    ## TODO don't remove all prepended dot
    # for skipped_file in $(ls -ad .*); do
    #     if [ "$skipped_file" != ".." ] && [ "$skipped_file" != "." ]; then
    #         log warn "Skipping file with dot prepended '$skipped_file'. Remove dot if file should be linked."
    #     fi
    # done

    # For each template, we will source it, and write the output to dev null. But send
    # error to std out.  This will ensure that all variables are set prior running or
    # exit with an error on the unset variable.
    for template in $(ls | grep -E '.*\.template$'); do
        source_file="$profile_dir/$template"
        log info "Ensuring all variables in template '$source_file' are set."

        # Eval in current environment with 'set -u' to error on unset variables
        # For some reason both 'set -u' below are required in my testing, I'm
        # not sure why.
        set -u
        eval set -u "cat <<EOF
$(<"$source_file")
EOF" >/dev/null
    done
    set +u
    log info "All variables used in templates are set."
    exit

    log info "Installing dotfiles from '$profile_dir'."
    for file in $(ls | grep -E -iv "$ignored_files"); do
        source_file="$profile_dir/$file"

        if [[ "$source_file" == *.template ]]; then
            rendered_file_name=$(echo "$file" | sed -e 's/^\(.*\)\.template/\1.rendered/')
            rendered_file_path="$profile_dir/$rendered_file_name"

            log info "'$source_file' is a template, rendering to '$rendered_file_path'."
            dotfile_name=$(echo "$file" | sed -e 's/^\(.*\)\.template/\1/')
            dotfile=~/."$dotfile_name"

            # Eval in current environment to replace variables with current environment
            eval "cat <<EOF
$(<"$source_file")
EOF" >"$rendered_file_path" 2>/dev/null

            # Linking dotfile to rendered file path
            link_dotfile "$dotfile" "$rendered_file_path"
        else
            dotfile=~/."$file"
            link_dotfile "$dotfile" "$source_file"
        fi

    done

    log info "Completed adding dotfiles profile '$profile'."
}

# list_links() {
#     for file in $(ls -a ~); do

#         # Only evaluate symlinks
#         if [[ -L ~/"$file" ]]; then

#             # Only include if it points to the dotfiles directory
#             while IFS= read -r bashdot_dir; do
#                 expected_target_file_name=$(basename "$file" | cut -c 2-)
#                 if readlink ~/"$file" | grep -E "^$bashdot_dir/[a-zA-Z0-9_-]*/$expected_target_file_name(\.rendered)?$" >/dev/null; then
#                     echo "$file"
#                 fi
#             done <"$bashdot_config_file"
#         fi
#     done
# }

# list_profiles() {
#     if [ ! -f "$bashdot_config_file" ]; then
#         log info "No dotfiles installed by bashdot."
#     else
#         while IFS= read -r dir; do
#             for link in $(list_links); do
#                 expected_target_file_name=$(basename "$link" | cut -c 2-)
#                 if readlink ~/"$link" | grep -E "^$dir/[.a-zA-Z0-9_-]*/$expected_target_file_name(\.rendered)?$" >/dev/null; then
#                     profile=$(readlink ~/"$link" | sed -e "s/^.*\/[.a-zA-Z0-9_-]*\/\(.*\)\/.*$/\1/")
#                     echo "$dir $profile"
#                 fi
#             done
#         done <"$bashdot_config_file" | sort | uniq
#     fi
# }

# show_links() {
#     for link in $(list_links); do
#         dest=$(readlink ~/"$link")
#         chomped_link="${link%\\n}"
#         echo "~/$chomped_link -> $dest"
#     done
# }

# dir() {
#     if [ ! -f "$bashdot_config_file" ]; then
#         log info "No dotfiles installed by bashdot."
#     else
#         sort "$bashdot_config_file"
#     fi
# }

uninstall() {
    dir=$1
    profile=$2

    if [ ! -f "$bashdot_config_file" ]; then
        log error "Config file '$bashdot_config_file' not found."
        log error "No dotfiles installed by bashdot."
        exit 1
    fi

    # Don't proceed with uninstall if profiles not available in given directory
    if ! list_profiles | grep "^$dir $profile$" >/dev/null; then
        log error "Profile '$profile' not installed from '$dir'."
        exit 1
    fi

    # Loop through each file and only remove if they are a symlink
    # and point to a file in this profile in the target dir
    for link in $(list_links); do
        log debug "Evaluating '$link' for removal."
        target=$(readlink ~/"$link")

        # Check if link target is part of this bashdot profile
        expected_target_file_name=$(basename "$link" | cut -c 2-)
        if echo "$target" | grep -E "^$dir/$profile/${expected_target_file_name}(\.rendered)?$" >/dev/null; then
            # If a link target was rendered from a template, remove
            # the rendered file on uninstall
            if echo "$target" | grep -E '\.rendered$' >/dev/null; then
                log info "Removing rendered file '$target'."
                \rm "$target"
            fi

            log info "Removing '$link'."
            \rm ~/"$link"
        fi
    done
    log debug "All links for profile '$profile' removed."

    # If no more profiles point to this directory, remove it
    log debug "Updating bashdot config file '$bashdot_config_file'."
    dir_empty=true
    for link in $(list_links); do
        log debug "Evaluating if '$link' is part of a bashdot profile in dir '$dir'."
        expected_target_file_name=$(basename "$link" | cut -c 2-)
        if readlink ~/"$link" | grep -E "^$dir/[a-zA-Z0-9_-]*/${expected_target_file_name}(\.rendered)?$" >/dev/null; then
            log debug "'$link' is part of a bashdot profile in '$dir', not removing '$dir' from '$bashdot_config_file'."
            dir_empty=false
            break
        fi
    done

    if [ "$dir_empty" = true ]; then
        log info "Removing '$dir' from '$bashdot_config_file'."
        mv "$bashdot_config_file" "${bashdot_config_file}".backup
        grep -v "^$dir$" <"${bashdot_config_file}".backup >"$bashdot_config_file"
    fi

    # If there are no more bashdot profiles, remove .bashdot and backup
    if [ ! -s "$bashdot_config_file" ]; then
        log info "No more bashdot profiles installed, removing '$bashdot_config_file'."
        \rm -f "$bashdot_config_file" "${bashdot_config_file}".backup
    fi
}

###
# case "$action" in
#     dir)
#         dir
#         ;;
#     install)
#         if [ $# -lt 2 ]; then
#             usage install
#             exit 1
#         fi

#         exit_if_invalid_directory_name "$current_working_dir"

#         while true; do
#             shift

#             if [ -z "$1" ];then
#                 break
#             fi

#             exit_if_invalid_profile_name "$1"
#             install "$1"
#         done

#         log info "Completed installation of all profiles successfully."
#         ;;
#     links)
#         show_links
#         ;;
#     profiles)
#         list_profiles
#         ;;
#     uninstall)
#         if [ $# -ne 3 ]; then
#             usage uninstall
#             exit 1
#         fi
#         uninstall "$2" "$3"
#         log info "Completed uninstallation successfully."
#         ;;
#     version)
#         echo "$VERSION"
#         ;;
# esac

#
# parse args
#

while [[ $# -gt 0 ]]; do
    case $1 in
    # Set stow dir to DIR (default is current dir)
    -d)
        STOW_DIR="$2"
        shift # past argument
        shift # past value
        ;;
    --dir=*)
        __sp=(${1//=/ })
        STOW_DIR=${__sp[1]}
        shift # past argument
        ;;
    # Set target to DIR (default is parent of stow dir)
    -t)
        STOW_TARGET="$2"
        shift # past argument
        shift # past value
        ;;
        # Stow the package names that follow this option
    --target=*)
        __sp=(${1//=/ })
        STOW_TARGET=${__sp[1]}
        shift # past argument
        ;;
    -S | --stow)
        # Stow the package names that follow this option
        STOW_INSTALL=true
        shift # past argument

        while $(check_valid_profile_name $1) && [[ $# -gt 0 ]]; do
            STOW_PROFILE+=("$1")
            shift # past value
        done
        ;;
    -D | --delete)
        # Unstow the package names that follow this option
        STOW_DELETE=true
        shift # past argument

        while $(check_valid_profile_name $1) && [[ $# -gt 0 ]]; do
            STOW_DELETE_PROFILE+=("$1")
            shift # past value
        done
        ;;
    -R | --restow)
        # Restow (like stow -D followed by stow -S)
        STOW_RESTOW=true
        shift # past argument
        ;;
    -* | --*)
        usage commands
        exit 1
        ;;
    *)
        while $(check_valid_profile_name $1) && [[ $# -gt 0 ]]; do
            STOW_PROFILE+=("$1")
            shift # past value
        done
        # STOW_PROFILE+=("$1")
        # shift # past argument
        ;;
    esac
done

# set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
echo "--------------------------------------------------"

printf "stow dir         : %s\n" "${STOW_DIR}"
printf "stow target      : %s\n" "${STOW_TARGET}"
printf "stow profile     : %s\n" "${STOW_PROFILE[*]}"
printf "stow del profile : %s\n" "${STOW_DELETE_PROFILE[*]}"
printf "delete           : %s\n" "${STOW_DELETE}"
printf "install          : %s\n" "${STOW_INSTALL}"
printf "restow           : %s\n" "${STOW_RESTOW}"

echo "--------------------------------------------------"

exit_if_invalid_directory_name "${STOW_DIR}"

# for _p in ${STOW_PROFILE[@]}; do
#     exit_if_invalid_profile_name "${_p}"
# done

for _p in ${STOW_PROFILE[@]}; do
    exit_if_profile_directories_contain_invalid_characters "${STOW_DIR}/${_p}"
done

echo "--------------------------------------------------"

stow_delete() {
    if [ ! $# -gt 0 ]; then
        echo "error"
        return
    fi

    for _d in $@; do
        echo "delete $_d"
    done
}

stow_install() {
    if [ ! $# -gt 0 ]; then
        echo "error"
        return
    fi

    for _d in $@; do
        echo "install $_d"
        # install_no_folding $_d
        install $_d
    done
}

echo "[proc] stow del"
if $STOW_DELETE; then
    if [ ! -z ${STOW_DELETE_PROFILE} ]; then
        stow_delete ${STOW_DELETE_PROFILE[@]}
    else
        log warn "delete missing proifle"
    fi
fi

if $STOW_RESTOW; then
    if [ ! -z ${STOW_PROFILE} ]; then
        stow_delete ${STOW_PROFILE[@]}
    else
        log warn "delete missing proifle"
    fi
fi

echo "[proc] stow install"

if $STOW_INSTALL || $STOW_RESTOW; then
    if [ ! -z ${STOW_PROFILE} ]; then
        stow_install ${STOW_PROFILE[@]}
    else
        log warn "install missing proifle"
    fi
fi

# printf "restow  : %s" "${STOW_DELETE}"
