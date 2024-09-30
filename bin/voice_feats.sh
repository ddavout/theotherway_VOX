#!/bin/env bash
unset IFS
IFS=$'\n\t'
# tempo
ESTDIR=/home/getac/Develop/speech_tools
FESTVOXDIR=/home/getac/Develop/festvox
FLITEDIR=/home/getac/Develop/flite
export ESTDIR
export FESTVOXDIR
cd "${DIR_VOX}" || exit 
flite_dir=flite
mkdir -p "${flite_dir}"
FESTIVAL="$FESTIVALDIR"/bin/festival
FV_VOICENAME=INST_LANG_VOX
# For smaller (and quicker) voices you can build with a reduced order
# this seems to be ok for values down to 13 
# TODO même RORDER que dans f0_params
RORDER=0  
if [ $# = 2 ]; then
  RORDER=$2
fi
export RORDER

# cg_convert: converting F0 trees
# cg_convert: converting single spectral trees
# cg_convert:    converting model_01 quantized spectral params
# cg_convert: converting single duration model
# cg_convert:    converting 01 duration model
# cg_convert: converting phone to state map
#ok
   # "$FESTIVAL" --heap "$HEAPSIZE" -b \
   #          '(set! cg_reduced_order '"$RORDER"')' \
   #           "${flite_dir}"/f0_params.scm \
   #           "$FLITEDIR"/tools/make_cg.scm \
   #           "$FLITEDIR"/tools/make_cart.scm \
   #           "$FLITEDIR"/tools/make_vallist.scm \
   #          '(cg_convert 
   #                    "'$FV_VOICENAME'"
   #                    "."
   #                    "'"${flite_dir}"'")'   

echo "${FLITEDIR}/tools/make_flite_feats etc/voice.feats >flite/${FV_VOICENAME}_voice_feats.c"
# touch flite/${FV_VOICENAME}_voice_feats.c
# if [ -f etc/voice.feats ]
# then
   "${FLITEDIR}"/tools/make_flite_feats "${DIR_VOX}"/etc/voice.feats >flite/${FV_VOICENAME}_voice_feats.c
# fi