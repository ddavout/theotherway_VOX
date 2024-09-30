#!/bin/env bash
#####################################################-*-mode:shell-script-*-
##                                                                       ##
##                   Carnegie Mellon University and                      ##
##                   Alan W Black and Kevin A. Lenzo                     ##
##                      Copyright (c) 1998-2000                          ##
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
###                                                                       ##
###  Generate LPC coefficients and residual for diphones (or otherwise)   ##
###                                                                       ##
############################################################################
ESTDIR=/home/getac/Develop/speech_tools
FESTVOXDIR=/home/getac/Develop/festvox
export ESTDIR
export FESTVOXDIR
cd "${DIR_VOX}" || exit 
CH_TRACK="${ESTDIR}"/bin/ch_track
LANG=C; export LANG
# unset IFS
# important
IFS=$'\n\t'
   echo "Finding LPC min, max and range"
   # make lpc.params file
   # shellcheck disable=SC2002
   cat "$PROMPTFILE" |
   awk '{print $2}' |
   while read -r i
   do
      "${CH_TRACK}" -otype est_ascii lpc/"$i".lpc | 
       
      sed '1,/EST_Header_End/d'
   done |
   awk 'BEGIN {min=0; max=0;}
        {for (i=4; i<=NF; i++)
        {
            if ($i < min) min = $i;
            if ($i > max) max = $i;
        }
     } 
     END {printf("LPC_MIN=%f\n",min);
          printf("LPC_MAX=%f\n",max);
          printf("LPC_RANGE=%f\n",max-min);
         }' >lpc/lpc.params