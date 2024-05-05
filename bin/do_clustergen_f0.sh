#!/usr/bin/env bash
set -eauo pipefail -
# do_clustergen_f0
# shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
export PROMPTFILE

# unlike vanilla, we don't allow empty file
if [[ ! -s etc/f0.params ]]
then
    echov 'without f0.params, we run find_f0_stats'
   ./bin/find_f0_stats "$PROMPTFILE" || exit 67
else
    echov "quicker"
    ./bin/make_f0_pm "$PROMPTFILE" || exit 68
fi
exit
