#!/bin/env bash
# ./bin/do_ehmm_align.sh
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
##  Do EHMM labeling align                                               ##
##                                                                       ##
###########################################################################
# to be run in the VOX directory
set -euo pipefail -
    LANG=C; export LANG
    export FESTVOXDIR FESTIVALDIR
    EHMMDIR="$FESTVOXDIR"/src/ehmm
    export EHMMDIR
    vanilla=1
    # num_cpus encore recalculé, envisager changement de bin/find_num_available_cpu
    # fixés 
    # perl présupposé dans le PATH
    # pas de traitement d'erreurs, de vérification sanity
    echo "EHMM align"
# at minima
if [[ ! -s 'ehmm/etc/mysp_settings' ]] ; then
    echo 'files missing, normally generated during the ehmm'"'"'s first step: do_ehmm_setup'
    exit 66
fi
if [[ ! -s 'ehmm/etc/ph_list.int' ]] || [[ ! -s 'ehmm/etc/txt.phseq.data.int' ]] || [[ ! -s 'ehmm/etc/ph_list.int_log' ]] ; then
    echo "files missing, ehmm/etc/ph_list.int_log: normally generated with do_ehmm_bw, ehmm/etc/ph_list.int by do_ehmm_feats"
    #exit 66
fi
if [[ ! -s 'ehmm/mod/model101.txt' ]] || [[ ! -s 'ehmm/etc/txt.phseq.data.int' ]] || [[ ! -s 'ehmm/etc/ph_list.int_log' ]] ; then
    echo "ehmm/mod/model101.txt missing, normally generated with do_ehmm_bw ?"
    #exit 66
fi
if [[ "$vanilla" == "1" ]]; then
    num_cpus=$(./bin/find_num_available_cpu); 
    num_cpus=$(( num_cpus -1 ))

    #$EHMMDIR/bin/edec ehmm/etc/ph_list.int ehmm/etc/txt.phseq.data.int 1 ehmm/feat ft ehmm/etc/mysp_settings ehmm/mod 0 lab
    #SC2086 (info): Double quote to prevent globbing and word splitting.
    echo inside the VOX directory we will run  "$EHMMDIR"/bin/edec ehmm/etc/ph_list.int ehmm/etc/txt.phseq.data.int 1 ehmm/binfeat scaledft ehmm/etc/mysp_settings ehmm/mod 0 lab "${num_cpus}"
    echo PWD "${PWD}"
    NEW=1; export NEW ; "$EHMMDIR"/bin/edec ehmm/etc/ph_list.int ehmm/etc/txt.phseq.data.int 1 ehmm/binfeat scaledft ehmm/etc/mysp_settings ehmm/mod 0 lab 1 # "${num_cpus}"
           # scaledft: use binary feature files
           # (1): Sequential Flag..
	       # (0): nde flag if 1 uses Viterbi_NDE
           # (1): Number of Threads
    #SC2086 (info): Double quote to prevent globbing and word splitting.
    perl "$EHMMDIR"/bin/sym2nm.pl lab ehmm/etc/ph_list.int  #Earlier it was .map
    ###perl $EHMMDIR/bin/check_lab.pl lab ehmm/etc/txt.phseq.data  #commented due to use of short pause..
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    if [ ! -f etc/silence ]
    then
    # "$ESTDIR"/../festival/bin/festival -b festvox/build_clunits.scm "(find_silence_name)"
       "$FESTIVALDIR"/bin/festival -b festvox/build_clunits.scm "(find_silence_name)"
    fi
    # SC2006 (style): Use $(...) notation instead of legacy backticks `...`.
    SILENCE=$(awk '{print $1}' etc/silence)
    # shellcheck disable=SC2002 # useless cat
    cat ehmm/etc/ph_list.int_log |
    awk '{if (NF > 1)
          {
             printf("%s ",$1);
             for (i=4; i<(4+$2-2); i++)
                printf("%s_%s ",$1,$i);
             printf("\n");
          }}' |
   # SC2086 (info): Double quote to prevent globbing and word splitting
    sed 's/ ssil/ '"$SILENCE"'/g' >etc/statenames

# at minima
if [[ ! -s ehmm/mod/model101.txt ]] ; then
    echo "no proper ehmm/mod/model101.txt needed by  ou pas"
    #exit 66
fi
if [[ ! -s 'etc/statenames.ehmm' ]] ; then
    echo "etc/statenames.ehmm not generated, needed by do_ehmm_standardize ornot ?"
    ls -al etc/statenames.ehmm
    #exit 66
fi
fi
exit 0
