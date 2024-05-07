#!/bin/env bash
# ./bin/do_ehmm_phseq.sh
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
##  Do EHMM labeling phseq                                               ##
##                                                                       ##
###########################################################################
# to be run in the VOX directory
set -euo pipefail -
    LANG=C; export LANG
    export ESTDIR FESTVOXDIR FESTIVALDIR
    EHMMDIR=$FESTVOXDIR/src/ehmm
    export EHMMDIR PROMPTFILE
    # shellcheck source=/dev/null
    source etc/voice.defs || { echo to be run in the VOX directory; exit 66; } 

    # impose structure ESTDIR FESTIVALDIR
    # aucune vérification cohérence de ph_list, pas d'alerte or il peut être question d'une liste obsolète de phonèmes
    # ou même d'un fichier vide. voir optimization clustergen find_nstates
    # hmm state number 5 est fixe
    # ni log ni traitement d'erreur, pas même une vérification finale génrération de txt.phseq.data

#at minima
if [[ ! -s "$PROMPTFILE" ]]; then { echo the ttd went missing; exit 66 ;} fi 

        echo "EHMM extract phone sequences and base hmm state numbers"
        # SC2086 (info): Double quote to prevent globbing and word splitting.
        #"$ESTDIR"/../festival/bin/festival -b "$EHMMDIR"/bin/phseq.scm '(phseq "'"$PROMPTFILE"'" "ehmm/etc/txt.phseq.data")'
        "$FESTIVALDIR"/bin/festival -b "$EHMMDIR"/bin/phseq.scm '(phseq "'"$PROMPTFILE"'" "ehmm/etc/txt.phseq.data")' || exit 66
        #;; warning: Cannot open file prompt-utt/neut_parl_s01_0074.utt as tokenstream
        #;; warning: load_utt: cant open utterance input file prompt-utt/neut_parl_s01_0074.utt
        #;; warning: utt.load: loading from "prompt-utt/neut_parl_s01_0074.utt" failed
        #;; warning: closing a file left open: ehmm/etc/txt.phseq.data

        # at minima
        if [[ -s 'etc/ph_list' ]]
        #if [ -f etc/ph_list ]
        then
           # Maybe there is an optimized hmm state number list available
           cp -pr etc/ph_list ehmm/etc/ph_list
        else
           # SC2086 (info): Double quote to prevent globbing and word splitting.
           perl "$EHMMDIR"/bin/phfromutt.pl ehmm/etc/txt.phseq.data ehmm/etc/ph_list 5
        fi
        awk 'END {printf("NoOfFiles: %d\n",NR)}' ehmm/etc/txt.phseq.data >ehmm/etc/mywavelist
        awk '{print $1}' ehmm/etc/txt.phseq.data >>ehmm/etc/mywavelist
