#!/usr/bin/env bash
# bin/update_data.sh
# paramètre
unset IFS
set -eauo pipefail
declare -x -g FIND
export NEW data_file CHMOD x z PROMPTFILE FIND DIR_VOX sig_dir sig_ext GREP CP RM
ls -l "$PROMPTFILE"
echo data_file "${data_file}"
#shellcheck disable=SC2034
# si par exemple l'étape our_do_ehmm est conduit à l'élimination de prompts, il peut être demandé de redémarrer le build, le datafile réduit devra alors être adopté
# où reprendre sans avoir à tout refaire ? l'examen des dates des stamp_* fournira la réponse
if [[ ! -s "${PROMPTFILE}" ]] ; then { echo no proper promptfile, you have to add one ; exit 65 ;}; fi

( while IFS=' '; read -r x fname z; do
  [[ $x = \;* ]] && continue # do nothing
  printf '%s\n' "$fname"
  # PROMPTFILE réputé du précédent build si NEW=0 et si NEW=1 candidat proposé par l'utilisateur
done < "$PROMPTFILE"> "${data_file}_previous"
echo NEW "$NEW"
if [[ "$NEW" == "1" ]]; then cp "${data_file}_previous" "${data_file}"; fi
echo  1
# à chaque redémarrage, on réactualise full_list.txt, les wav disponibles un jour peuvent disparaitre TODO ? vérification integrité ou utilisation
# de rsync sur full_liste.txt
if [ "$1" = "start" ] ; then
"$FIND" -L "${DIR_VOX}"/"${sig_dir}"  -maxdepth 1 -type f -perm -o=r -name "*${sig_ext}" -print0 | while IFS="/" read -r -d '' a; do
    file="${a##*/}"; echo "${file%.*}";
    done | sort > "${DIR_VOX}"/full_list.txt
fi
)
echo  2
if [ "$1" = "acknowledge" ]; then
    # restriction du data_file_previous pour cause liste waves ?
    # dd la liste des seuls fname possibles vu les la liste des waves, d as in disponible
    "$GREP" -wF -f "${data_file}_previous"  "${DIR_VOX}"/full_list.txt >"${DIR_VOX}"/dd
    # "interactivité ? retrouver vos waves"
        "$GREP" -f "${data_file}" "${PROMPTFILE}" >"${DIR_VOX}"/tdd
        "$GREP" -f "${data_file}_previous" "${PROMPTFILE}" >"${DIR_VOX}"/tdd
        "$CP" -b "${DIR_VOX}"/tdd "${PROMPTFILE}"

    # mise à jour éventuelle pour cause de perte
    if [[ ${NEW} == "0" ]] ; then
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
        echo perte de prompts prise en compte \(grâce à date.file tenant compte de la situation\)
        cp -b  "$DIR_VOX"/data_file_filtre.txt "${data_file}";
        cp -b "$PROMPTFILE"   "$PROMPTFILE".bak
        wc -l "${data_file}"
        grep "$PROMPTFILE".bak -f "$DIR_VOX"/data_file_filtre.txt > "$PROMPTFILE"
        }
        rm -f dd
        # rm dd $dc "$DIR_VOX"/data_file_filtre.txt
    fi
    if [[ ${NEW} == "1" ]] ; then
        cp -b "${DIR_VOX}"/tdd  "$PROMPTFILE"
        cp -b "${DIR_VOX}"/dd "${data_file}"
        rm -f ss"${DIR_VOX}"/dd "${DIR_VOX}"/tdd
    fi
fi
