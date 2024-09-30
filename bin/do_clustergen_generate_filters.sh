#!/usr/bin/env bash
# do_clustergen_cluster
set -euao pipefail -
# sans (set! cg:parallel_tree_build t) dans l'appel
# et même (set! cg:parallel_tree_build nil)

# shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
# needed if you use this file directly
# environ=/home/getac/MyDevelop/Voices/EXP2/config/env_festvox_settings0.cfg
# source $environ
#DIR_VOX=/home/getac/MyDevelop/Voices/EXP2/build/fr/scratch/INST_LANG_VOX_cg
#PROMPTFILE="etc/txt.done.data"
HEAPSIZE=2000000
export HEAPSIZE

export PROMPTFILE HEAPSIZE FESTIVALDIR DIR_VOX
export CLUSTERGENDIR="$DIR_VOX"/bin
cd "$DIR_VOX"

    MEF_ORDER=47
    LPF_ORDER=31

    FRVGEN="$CLUSTERGENDIR"/freq_response_vector_gen

    # Find sampling rate from first wavefile
    # shellcheck disable=SC2086 #SC1091,SC2002,SC2003,SC2006,SC2034,SC2046,SC2086,SC2154,SC2162,SC2166
    fname=$(head -1 $PROMPTFILE | awk '{print $2}')
    # TODO lourdingue cut !
    # shellcheck disable=SC2086
    SAMP_RATE=$($ESTDIR/bin/ch_wave -info wav/$fname.wav  | grep 'Sample rate' | cut -d ' ' -f 3)

    if [ ! -d filters ]
    then
	mkdir filters
    fi

    TMP=fil_$$

    # Generate MEF
        # shellcheck disable=SC2086
    $FRVGEN LPF $SAMP_RATE 500 > $TMP.h1.freq
            # shellcheck disable=SC2086
    $FRVGEN BPF $SAMP_RATE 900 1500 > $TMP.h2.freq
            # shellcheck disable=SC2086
    $FRVGEN BPF $SAMP_RATE 2000 3750 > $TMP.h3.freq
            # shellcheck disable=SC2086
    $FRVGEN BPF $SAMP_RATE 4000 6000 > $TMP.h4.freq
            # shellcheck disable=SC2086
    $FRVGEN BPF $SAMP_RATE 6250 7500 > $TMP.h5.freq
    for i in $(seq 1 5)
    do
            # shellcheck disable=SC2086
	$ESTDIR/bin/design_filter $TMP.h$i.freq -forder $MEF_ORDER -o $TMP.tmp
	        # shellcheck disable=SC2086
	sed '1,/End/ d' $TMP.tmp | sed 's/ /\n/g' > filters/h$i.txt
	        # shellcheck disable=SC2086
	sed '1,/End/ d' $TMP.tmp > $TMP.h$i
    done
            # shellcheck disable=SC2086
    cat $TMP.h1 $TMP.h2 $TMP.h3 $TMP.h4 $TMP.h5 | $ESTDIR/bin/ch_track -itype ascii -s 0.005 -otype est_binary -o festvox/mef.track

    # Generate LPF
            # shellcheck disable=SC2086
    $FRVGEN LPF $SAMP_RATE 6000 > $TMP.lpf.freq
            # shellcheck disable=SC2086
    $ESTDIR/bin/design_filter $TMP.lpf.freq -forder $LPF_ORDER -o $TMP.tmp
            # shellcheck disable=SC2086
    sed '1,/End/ d' $TMP.tmp | $ESTDIR/bin/ch_track -itype ascii -s 0.005 -otype est_binary -o festvox/lpf.track

    rm -rf $TMP.*
