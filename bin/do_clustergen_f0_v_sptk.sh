#!/usr/bin/env bash
# do_clustergen_f0_v_sptk
# shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
export PROMPTFILE

if [ ! -f etc/f0.params ]    
then
   ./bin/find_f0_stats "$PROMPTFILE" || exit 67
fi
./bin/make_f0_v_sptk "$PROMPTFILE" || exit 68
exit 0
