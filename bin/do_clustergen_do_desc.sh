#!/usr/bin/env bash
unset IFS
set -eauf
export modele
export DIR_VOX
echo generating desc files with the modele "$modele"
cd "${DIR_VOX}"
cp -R -p "${modele}"/INST_LANG_VOX_cg/models models
catalogue_dir="${catalogue_dir:-festival/clunits}"

	ls -al "${DIR_VOX}"/etc/statenames
	st=$(cat "${DIR_VOX}"/"${catalogue_dir}"/statenames);
	ph=$(tr -d "\n" <"${DIR_VOX}"/"${catalogue_dir}"/phonenames); \
	echo ph "${ph}"
	posst=$(tr -d "\n" <"${DIR_VOX}"/"${catalogue_dir}"/posnames); \
    sed -e "s/state names/${st}/" -e "s/phone names/${ph}/" -e "s/___/ /g" -e "s/pos names/${posst}/" "${DIR_VOX}"/models/mcep.desc > festival/clunits/mcep.desc || exit 1
	sed -e "s/state names/${st}/" -e "s/phone names/${ph}/" -e "s/___/ /g" -e "s/pos names/${posst}/" "${DIR_VOX}"/models/all.desc > festival/clunits/all.desc || exit 1
	sed -e "s/state names/${st}/" -e "s/phone names/${ph}/" -e "s/___/ /g" -e "s/pos names/${posst}/" "${DIR_VOX}"/models/mceptraj.desc > festival/clunits/mceptraj.desc || exit 1






