#! /bin/env bash
# ./bin/make_dist.sh
# to be run in the VOX directory
# shellcheck source=/dev/null
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
export FESTIVALDIR PROMPTFILE HEAPSIZE


if [ ! -f etc/voice.defs ]
then
   "$FESTVOXDIR"/src/general/guess_voice_defs
fi
. ./etc/voice.defs
if [ ! -d versions ]
then
   mkdir versions
fi

OPTNAME=$2

# Voice distribution has festival/lib/voice/LANG/voicename as prefix
# for all files
if [ "$1" = "festvox" ]
then
    fvdir=festival/lib/voices/$FV_LANG/$FV_FULLVOICENAME
    if [ ! -f "$fvdir" ]
    then
        mkdir -p "$(dirname "$fvdir")"
      (cd "$(dirname "$fvdir")" || exit; ln -s ../../../.. "$FV_FULLVOICENAME")
    fi
    fvsigdir="$fvdir"/wav
    tar zcvf versions/festvox_"$FV_FULLVOICENAME""$OPTNAME".tar.gz \
         "$fvdir"/README \
         "$fvdir"/COPYING \
         "$fvdir"/festvox/*.scm \
         "$fvdir"/festival/clunits/"$FV_VOICENAME".catalogue \
         "$fvdir"/festival/trees/"$FV_VOICENAME".tree \
         "$fvdir"/mcep/*.mcep \
         "$fvsigdir"/* 
    # that symlink causes some people problesm in cp's 
    rm "$fvdir"
fi        
