#!/usr/bin/env bash
# do_clustergen_cluster
set -euao pipefail -
# sans (set! cg:parallel_tree_build t) dans l'appel 
# et même (set! cg:parallel_tree_build nil)

# shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
# needed if you use this file directly
# environ=/home/dop7/MyDevelop/Voices/EXP2/config/env_festvox_settings0.cfg
# source $environ
#DIR_VOX=/home/dop7/MyDevelop/Voices/EXP2/build/fr/scratch/INST_LANG_VOX_cg
#PROMPTFILE="etc/txt.done.data"
HEAPSIZE=2000000
export HEAPSIZE

export PROMPTFILE HEAPSIZE FESTIVALDIR DIR_VOX
cd "$DIR_VOX"

if [[ ! -s "$PROMPTFILE" ]]; then
    echo you don\'t have a proper ttd; exit 67
fi

if [[ ! -s "festival/clunits/mcep.desc" ]]; then
    echo missing desc file ;
    exit 58;
fi

if [[ ! -d "ccoefs" ]]; then
    echo the step combine_coeffs_v is compulsary, you shoud have a non empty folder ccoefs; exit 69
fi
rmdir --ignore-fail-on-non-empty ccoefs
if [[ ! -d "ccoefs" ]]; then
    echo the step combine_coeffs_v is compulsary, but your folder ccoefs was empty \(and deleted...\); exit 70
fi

if [[ ! -x "bin/cg_get_feats_all" ]]; then
    echo missing executable cg_get_feats_all, you will need it in festvox scm call  ;
    exit 58;
fi

# shellcheck disable=SC2037

#command="$FESTIVALDIR"/bin/festival --heap "$HEAPSIZE" -b festvox/clustergen_build.scm festvox/build_clunits.scm festvox/INST_LANG_VOX_cg.scm "'"\(begin \(set! cg:parallel_tree_build t\)"'" # (build_clustergen "'"$PROMPTFILE"'"))'
  
"$FESTIVALDIR"/bin/festival --heap "$HEAPSIZE" -b festvox/clustergen_build.scm festvox/build_clunits.scm festvox/INST_LANG_VOX_cg.scm '(begin (build_clustergen "'"$PROMPTFILE"'"))'

# shellcheck disable=SC2154
#echo we run "$command"
exit 0
