#!/usr/bin/env bash

_compare() {
    local value_l="$1" operator="$2" value_r="$3"

    awk -vv1="$value_l" -vv2="$value_r" 'BEGIN {
        split(v1, a, /\./); split(v2, b, /\./);
        if (a[1] == b[1]) {
            exit (a[2] '$operator' b[2]) ? 0 : 1
        }
        else {
            exit (a[1] '$operator' b[1]) ? 0 : 1
        }
    }'
}

# _compare() {
#     if [ "$(echo "$1 $2 $3" | bc)" == 0 ];then
#         echo false
#     else
#         echo true
#     fi
# }

_norm_precentage() {
    local percentage=$1

    if [ ! -z "$2" ]; then
        percentage=$(echo "($1*100)/$2" | bc)
    fi

    if $(_compare 0 ">" $percentage); then
        percentage=0
    elif $(_compare 0 "==" $percentage); then
        percentage=$1
    elif $(_compare 0 "<" $percentage) && $(_compare 1 ">" $percentage); then
        percentage=$(echo $percentage*100/1 | bc)
    elif $(_compare 0 "<" $percentage) && $(_compare 100 ">=" $percentage); then
        percentage=$(echo $percentage/1 | bc)
    elif $(_compare 100 "<" $percentage); then
        percentage=100
    fi

    IFS=''
    echo $percentage
}

progress_bar() {
    local percentage=$(_norm_precentage $2 $3)
    local width=$1
    local numFilled=$((percentage * width / 100))
    local numEmpty=$((width - numFilled))

    tput civis

    printf "["
    printf "%${numFilled}s" | tr ' ' '='
    printf "%${numEmpty}s" | tr ' ' ' '
    printf "] %d%%\r" $percentage

    if [[ $percentage -eq 100 ]]; then
        printf "\n"
        tput cnorm
    fi
}

progress_bar_full() {
    progress_bar 100 $1 $2
}

progress_bar_medium() {
    progress_bar 50 $1 $2
}

progress_bar_small() {
    progress_bar 10 $1 $2
}

progress_bar_print() {
    local percentage=$2

    if [ ! -z "$3" ]; then
        percentage=$(echo "($2*100)/$3" | bc)
    fi

    progress_bar $1 $percentage

    if [ $(echo "$percentage >= 100" | bc) == 0 ]; then
        printf "\n"
    fi
}

progress_bar_print_full() {
    progress_bar_print 100 $1 $2
}

progress_bar_print_medium() {
    progress_bar_print 50 $1 $2
}

progress_bar_print_small() {
    progress_bar_print 10 $1 $2
}
