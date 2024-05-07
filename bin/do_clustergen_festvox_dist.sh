#! /bin/env bash
# ./bin
# to be run in the VOX directory
# shellcheck source=/dev/null
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
# shellcheck disable=SC2034
FV_INST=INST
# shellcheck disable=SC2034
FV_LANG=LANG
# shellcheck disable=SC2034
FV_NAME=VOX
# shellcheck disable=SC2034
FV_TYPE=cg
## shellcheck disable=SC2034
#FV_VOICENAME=$FV_INST"_"LANG"_"$FV_NAME
FV_FULLVOICENAME=INST_LANG_VOX_cg   
export FV_FULLVOICENAME
OPTNAME=$2


if [ ! -f "$fvdir" ]
then
    mkdir -p "$(dirname "$fvdir")" || exit 66
    (cd "$(dirname "$fvdir")" || exit; ln -s ../../../.. INST_LANG_VOX_cg)
fi
touch "$fvdir"/README "$fvdir"/COPYING
fvsigdir="$fvdir"/wav
tar zcvf versions/festvox_INST_LANG_VOX_cg"$OPTNAME".tar.gz \
     "$fvdir"/README \
     "$fvdir"/COPYING \
     "$fvdir"/festvox/*.scm \
     "$fvdir"/festival/clunits/INST_LANG_VOX.catalogue \
     "$fvdir"/festival/trees/INST_LANG_VOX.tree \
     "$fvdir"/mcep/*.mcep \
     "$fvsigdir"/* 
# that symlink causes some people problesm in cp's 
#rm "$fvdir"

# Voice distribution has festival/lib/voice/LANG/voicename as prefix
# for all files
echov 'Make festvox voice distribution'
fvdir=festival/lib/voices/LANG/INST_LANG_VOX_cg
if [ ! -f "$fvdir" ]; then  mkdir -p fvdir || exit 66; fi
(cd "$fvdir"  || exit 66 ; ln -s ../../../.. INST_LANG_VOX_cg)
# to be filled later if missing
touch "$fvdir"/README "$fvdir"/COPYING
# for a simple cg the model_files would be
# festival/lib/voices/LANG/INST_LANG_VOX_cg/festival/trees/INST_LANG_VOX_f0.tree
# festival/lib/voices/LANG/INST_LANG_VOX_cg/festival/trees/INST_LANG_VOX_mcep.tree
# festival/lib/voices/LANG/INST_LANG_VOX_cg/festival/trees/INST_LANG_VOX_mcep.params
# "$FESTIVALDIR"/bin/festival --heap "$HEAPSIZE"  -b festvox/clustergen_build.scm festvox/INST_LANG_VOX_cg.scm '(begin (voice_INST_LANG_VOX_cg) (INST_LANG_VOX::cg_dump_model_filenames "model_files") )'

tar zcvf festvox_INST_LANG_VOX_cg.tar.gz \
     "$(cat model_files)" \
     "$fvdir"/festvox \
     "$fvdir"/README \
     "$fvdir"/COPYING
    #rm -rf festival/lib
