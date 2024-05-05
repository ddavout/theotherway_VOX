#! /bin/env bash
set -a
# bin/__verif_update_verif_datas
# dataS à la fois ttd et data_file.txt
# usage: export NEW=0; ./build __verif_functions

# shellcheck disable=SC2034 # not yet finished
export TOP
echo "$TOP"
prg="$TOP"/bin/update_datas.sh

# pour rappel (mais non mis à jour)
# shellcheck disable=SC2154,SC2034
 # car hors contexte
# NEW data_file CHMOD x z PROMPTFILE FIND DIR_VOX sig_dir sig_ext GREP CP RM echov 
export FIND DIR_VOX
if false ; then
    if [[ ! -s "${data_file}" ]] ; then echo are you sure of NEW, there is no "${data_file}" ; exit 66 ; fi
    if [[ -s "${data_file}" ]] && { [[ ! -r "${data_file}" ]] || [[ ! -w "${data_file}" ]] ;} ; then chmod -c +rw "${data_file}" ; fi
    echo some damages may have occurred since last process
    dc="${DIR_VOX}"/dc # données corrigées ou non = correctes vu les waves
    if [[ -f "${DIR_VOX}"/dd ]]; then
        grep -wF -f "${data_file}_previous" "${DIR_VOX}"/dd > "$dc" ;
        grep -wF -f "${data_file}" "$dc" > "$DIR_VOX"/data_file_filtre.txt
    else
        grep -wF -f "${data_file}_previous" "${data_file}" > "$DIR_VOX"/data_file_filtre.txt
    fi
    grep -q "${data_file}"  "$DIR_VOX"/data_file_filtre.txt || {
    echo perte de prompts prise en compte
    cp -b  "$DIR_VOX"/data_file_filtre.txt "${data_file}";
    cp -b "$PROMPTFILE"   "$PROMPTFILE".bak
    wc -l "${data_file}"
    grep "$PROMPTFILE".bak -f "$DIR_VOX"/data_file_filtre.txt > "$PROMPTFILE"
     }
    rm -f dd 
    # rm dd $dc "$DIR_VOX"/data_file_filtre.txt
fi

full_data_file="$TOP"/tests_functions/full_data.list
full_PROMPTFILE="$TOP"/tests_functions/full_txt.done.data
empty_data_file="$TOP"/tests_functions/empty.list.txt
partial_data_file="$TOP"/tests_functions/partial_data_file.txt
cat /dev/null > "$empty_data_file"
test_no=0
# TODO 1 seule fonction
expected_success(){
local sortie
sortie="";
# "$prg"  || { printf -v sortie "%s" "$?" ; echo what "$v" > /dev/stderr; exit 0 ;}
{ "$prg" &&  printf -v sortie "%s" "$?" ; printf '%s' "$sortie" ; if [[ ! "$sortie" == "0" ]] ; then { echo "this test fails"; exit 1 ;}; fi };
}
export -f expected_success
expected_failure(){
local sortie
sortie="";
# "$prg"  || { printf -v sortie "%s" "$?" ; echo what "$v" > /dev/stderr; exit 0 ;}
{ "$prg" &&  printf -v sortie "%s" "$?" ; printf '%s' "$sortie" ; if [[  "$sortie" == "0" ]] ; then { echo "this test fails"; exit 1 ;}; fi };
}
export -f expected_failure

test_no=$(( test_no + 1 ))

echo "test n° ${test_no}"
data_file="${empty_data_file}"
PROMPTFILE=${full_PROMPTFILE}
if [[ "$NEW" = "0" ]]; then
    expected_failure
else
    expected_success
fi

echo "test n° ${test_no}"
data_file="${full_data_file}"
PROMPTFILE="${full_PROMPTFILE}"
expected_success

echo "test n° ${test_no}"
PROMPTFILE="${full_data_file}"
data_file="${partial_data_file}"
expected_failure
