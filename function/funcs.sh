# check commands exist or not
check_command() {
    if ! [ -x "$(command -v $1)" ]; then
        show_error "command $1 not found"
    else
        show_success "command $1 found"
    fi
}
