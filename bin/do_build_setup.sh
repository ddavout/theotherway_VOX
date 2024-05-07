#!/bin/env bash
# ./bin/do_ehmm_setup.sh
#####################################################-*-mode:shell-script-*-
##                                                                       ##
##                     Carnegie Mellon University                        ##
##                        Copyright (c) 2005                             ##
##                        All Rights Reserved.                           ##
##                                                                       ##
##  Permission is hereby granted, free of charge, to use and distribute  ##
##  this software and its documentation without restriction, including   ##
##  without limitation the rights to use, copy, modify, merge, publish,  ##
##  distribute, sublicense, and/or sell copies of this work, and to      ##
##  permit persons to whom this work is furnished to do so, subject to   ##
##  the following conditions:                                            ##
##   1. The code must retain the above copyright notice, this list of    ##
##      conditions and the following disclaimer.                         ##
##   2. Any modifications must be clearly marked as such.                ##
##   3. Original authors' names are not deleted.                         ##
##   4. The authors' names are not used to endorse or promote products   ##
##      derived from this software without specific prior written        ##
##      permission.                                                      ##
##                                                                       ##
##  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         ##
##  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      ##
##  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   ##
##  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      ##
##  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    ##
##  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   ##
##  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          ##
##  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       ##
##  THIS SOFTWARE.                                                       ##
##                                                                       ##
###########################################################################
##                                                                       ##
##  Do EHMM labeling setup                                               ##
##                                                                       ##
###########################################################################
set -euo pipefail -

# to be run in the VOX directory
    LANG=C; export LANG
    export ESTDIR FESTVOXDIR
    EHMMDIR=$FESTVOXDIR/src/ehmm
    export EHMMDIR SAMPFREQ
    # shellcheck source=/dev/null
    source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }

    echo "EHMM setup"
    # -p pour éviter en cas de reprise mkdir: impossible de créer le répertoire « ehmm »: Le fichier existe
    mkdir -p ehmm/feat ehmm/etc ehmm/mod
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    # sample_wav_name=$(awk 'NR==1{print $2}' "$PROMPTFILE")
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    ## SAMPFREQ=$("$ESTDIR"/bin/ch_wave -info wav/"$sample_wav_name".wav  | grep 'Sample rate' | cut -d ' ' -f 3)
    FRAMELEN=$(echo | awk "{print int(0.01*$SAMPFREQ)}")
    FRAMESHIFT=$(echo | awk "{print int(0.005*$SAMPFREQ)}")
    ### fixe (what ever it is ...)
    ### FrameSize: 160
    ### FrameShift: 80
    ### Lporder: 12
    ### CepsNum: 16
    ### et 
    ### FeatDir: ./ehmm/feat
    # TODO 
    vanilla=1
if [[ "$vanilla" == "1" ]] ; then
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    # shellcheck disable=SC2002 # SC2002 (style): Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead.
    cat "$EHMMDIR"/etc/mysp_settings | \
	sed "s/^SamplingFreq:.*$/SamplingFreq: $SAMPFREQ/g" | \
	sed "s/^FrameSize:.*$/FrameSize: $FRAMELEN/g" | \
	sed "s/FrameShift:.*$/FrameShift: $FRAMESHIFT/g" > ehmm/etc/mysp_settings
fi
# at minima
# confirmé par cours_do_ehmm_setup
if [[ ! -s 'ehmm/etc/mysp_settings' ]] ; then
    echo "ehmm/etc/mysp_settings not generated"
    exit 66
fi
    exit 0 

