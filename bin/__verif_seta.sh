#! /bin/env bash
# bin/__verif_seta
if [[ ! "$TEST" == "" ]]; then
    echov "$TEST=test"
else
    exit 77;
fi
