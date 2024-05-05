#!/usr/bin/env bash
echo case "$1"
export general structure environ analyse
case "${1}" in
    general*) cfg="${general}" ;;
    structure*) cfg="${structure}" ;;
    environ*) cfg="${environ}" ;;
    analyse*) cfg="${analyse}" ;;
esac
ls -al "$cfg"

#if [[ ! "INCLUDED_${1}" == "1" ]]; then 
    printf 'start config %s ###################/\n' "$1"

    VAR="$(
        awk '/^[a-zA-Z0-9_]+=/ {
            split($0, a, /=/);
            print a[1]
        }' <"${cfg}"  |
            sort
    )"
    # shellcheck source=/dev/null
    source "$cfg"
    for VAR in $VAR; do
        echo "${VAR}"
        # SC2163 (warning): This does not export 'VAR'. Remove $/${} for that, or use ${var?} to quiet.
        export VAR
    done   
    printf "end config###################/\n"
    
    echo "$FIND"
 #fi
