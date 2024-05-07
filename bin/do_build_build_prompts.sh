#! /bin/env bash
# ./bin/do_build_build_prompts.sh
# to be run in the VOX directory
# shellcheck source=/dev/null
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
export FESTIVALDIR PROMPTFILE HEAPSIZE
echo "$FESTIVALDIR"/bin/festival --heap "$HEAPSIZE" -b festvox/build_clunits.scm '(build_prompts "'"$PROMPTFILE"'")'
if [[ ! -s "$PROMPTFILE" ]]; then { echo the ttd went missing; exit 66 ;} fi 
"$FESTIVALDIR"/bin/festival --heap "$HEAPSIZE" -b festvox/build_clunits.scm '(build_prompts "'"$PROMPTFILE"'")'
