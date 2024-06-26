#!/bin/env bash
# ./bin/do_ehmm_feats.sh
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
##  Do EHMM labeling feats                                               ##
##                                                                       ##
###########################################################################
# to be run in the VOX directory
set -eauo pipefail -
# shopt -s extglob
    LANG=C; export LANGs
    export ESTDIR FESTVOXDIR
    EHMMDIR=$FESTVOXDIR/src/ehmm
    export EHMMDIR SAMPFREQ
    # shellcheck source=/dev/null
    source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
    vanilla=0
    # /!\ perl supposé dans le PATH
    # grâce à la mise à jour automatique des datas, on évite le cas des waves perdus entre do_ehmm_setup et do_ehmm_feats
    # /$\ un fichier *.txt dans ehmm/mfcc correspondant à un wav disparu peut aller jusqu'à saturer le disque dur sans la moindre alerte
    # laisser num_cpus au choix de l'utilisateur 
    # sont fixés
    # gaussains=2          #[2]   # No.Gau: $ngau de seqloc
    # num_connections=2    # [2] # No.Con: $noc de seqloc
    # feature_dimension=13 # [13] ?? # DIM de seqloc
    # scaling_factor=4     #scaling-factor default festvox
    # pas de choix du nombre de parts, pas de rapport avec la taille 
    # aucun traitement d'erreurs ex si part vide 
    # utilisation de xargs au lieu de parallel, désordre dans les messages et logs
    # pas répertoire tmpdir dédié
# at minima
if [[ ! -s ehmm/etc/mysp_settings ]] || [[ ! -s ehmm/etc/mywavelist ]] || [[ ! -s ehmm/etc/txt.phseq.data ]]; then
    echo "we need a  correct ehmm/etc/mysp_settings and mywavelist and ehmm/etc/txt.phseq.data, generated by do_ehmm_setup or do_ehmm_phseq"
    exit 66
fi
vanilla=1
# xargs: warning: options --max-args and --replace/-I/-i are mutually exclusive, ignoring previous --max-args value
# -P, --max-procs=PROC-MAX
#  -I R                         identique à --replace=R
#  -i, --replace[=R]            replace R in INITIAL-ARGS with names read
#                                 from standard input, split at newlines;
#                                 if R is unspecified, assume {}
# tandis que -n, --max-args=ARG-MAX      utiliser au plus ARG-MAX par ligne de commande
if [[ "$vanilla" == "1" ]]; then
    echo "EHMM Feature extraction and normalization with new code"
    # Split mywavelist into $num_cpu parts
    num_cpus=$(./bin/find_num_available_cpu)
    # SC2006 (style): Use $(...) notation instead of legacy backticks `...`
    nc=$(echo "$num_cpus" | awk '{print $1-1}')
    #SC2086 (info): Double quote to prevent globbing and word splitting.
    for i in $(seq 0 "$nc")
    do
    #SC2086 (info): Double quote to prevent globbing and word splitting.
    # shellcheck disable=SC2002
	cat ehmm/etc/mywavelist | awk -v part="$i" '((NR>1) && (NR%'"$num_cpus"'==part)){print $0}' > ehmm/etc/mywavelist.part-"$i".tmp
    #SC2086 (info): Double quote to prevent globbing and word splitting.
    lines=$(wc -l ehmm/etc/mywavelist.part-"$i".tmp | awk '{print $1}')
    #SC2086 (info): Double quote to prevent globbing and word splitting.
	echo "NoOfFiles: $lines" > ehmm/etc/mywavelist.part-"$i"
	#SC2086 (info): Double quote to prevent globbing and word splitting.
	cat ehmm/etc/mywavelist.part-"$i".tmp >> ehmm/etc/mywavelist.part-"$i"
	#SC2086 (info): Double quote to prevent globbing and word splitting.
	rm -f ehmm/etc/mywavelist.part-"$i".tmp
    done
    # Run Feature Extraction
    #/!\ 
    #     seq 0 $nc | xargs -n1 -P $num_cpus -I{} $EHMMDIR/bin/FeatureExtraction ehmm/etc/mysp_settings ehmm/etc/mywavelist.part-{}
    seq 0 "$nc" | xargs -P "$num_cpus" -I{} "$EHMMDIR"/bin/FeatureExtraction ehmm/etc/mysp_settings ehmm/etc/mywavelist.part-{}
    # Convert Features to Binary
    # doit autoriser une reprise
    mkdir -p ehmm/binfeat
     echov ah
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    # /!\ et non pas xargs -0 -n1 -I {} basename {} .mfcc
    # Usage: /home/dop7/Develop/festvox/src/ehmm/bin/ConvertFeatsFileToBinaryFormat input_feat_file output_feat_file
    #find ehmm/feat -name '*.mfcc' -print0 | xargs -0 -n1 basename -s '.mfcc' 
    mkdir -p ehmm/binfeat
    find ehmm/feat -name '*.mfcc' -print0 | \
        xargs -0 -I{}  basename {} .mfcc | \
        xargs -P "$num_cpus" -I {} "$EHMMDIR"/bin/ConvertFeatsFileToBinaryFormat ehmm/feat/{}.mfcc ehmm/binfeat/{}.ft 


    # Normalize and Scale the feats
    #SC2086 (info): Double quote to prevent globbing and word splitting.
    "$EHMMDIR"/bin/ScaleBinaryFeats ehmm/etc/mywavelist 4 "$num_cpus"
    # 4 => Scaling Factor
    # Last => Number of threads to spawn
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    perl "$EHMMDIR"/bin/seqproc.pl ehmm/etc/txt.phseq.data ehmm/etc/ph_list 2 2 13
          #Last params: no.gaussains, no. of connections, feature_dimension
fi
#at minima
#if [[ ! -s 'etc/txt.phseq.data.int' ]]; then ( echo no proper etc/txt.phseq.data.int; exit 66 ); fi
#if [[ ! -s 'etc/ph_list.int' ]]; then ( echo no proper etc/ph_list.int needed by do_ehmm_bw; exit 66 ); fi

    exit 0
