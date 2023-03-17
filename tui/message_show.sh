#!/bin/bash
# @name User-Feedback
# @brief Provides useful colored outputs for user feedback on actions

# @description Display error message in stderr, prefixed by check emoji
# @arg $1 string Error message to display
# @example
#   show_error "Oh snap, that went horribly wrong"
show_error() {
    echo -e "${red}✘ $1${normal}" >&2
}

# @description Display success message in stderr, prefixed by cross emoji
# @arg $1 string Success message to display
# @example
#   show_success "There it is! World peace."
show_success() {
    echo -e "${green}✔ $1${normal}" >&2
}

# @description Display warning message in stderr, prefixed by cross emoji
# @arg $1 string warning message to display
# @example
#   show_warning "There it is! World peace."
show_warning() {
    echo -e "${yellow}❢ $1${normal}" >&2
}

# @description Display Hint message in stderr, prefixed by cross emoji
# @arg $1 string Hint message to display
# @example
#   show_hint "There it is! World peace."
show_hint() {
    echo -e "${gray}✱ $1${normal}" >&2
}

show_question() {
    echo -e "${green}? $1${normal}" >&2
}

show_step() {
    echo -e "${blue}✱ $1${normal}" >&2
}

show_msg() {
    echo -e "$1" >&2
}