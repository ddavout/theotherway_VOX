#!/bin/env bash
###########################################################################
##                                                                       ##
##                  Language Technologies Institute                      ##
##                     Carnegie Mellon University                        ##
##                      Copyright (c) 2002-2017                          ##
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
##  Build a flite voice from a festvox voice                             ##
##                                                                       ##
##  C files are built into ${flite_dir}/                                        ##
##                                                                       ##
###########################################################################
unset IFS
# tempo
ESTDIR=/home/getac/Develop/speech_tools
FESTVOXDIR=/home/getac/Develop/festvox
FLITEDIR=/home/getac/Develop/flite
export ESTDIR
export FESTVOXDIR
cd "${DIR_VOX}" || exit 
flite_dir=flite
mkdir -p "${flite_dir}"
FESTIVAL="$FESTIVALDIR"/bin/festival
FV_VOICENAME=INST_LANG_VOX
# For smaller (and quicker) voices you can build with a reduced order
# this seems to be ok for values down to 13 
RORDER=0  
if [ $# = 2 ]; then
  RORDER=$2
fi
export RORDER
echo cg_convert: finding parameter ranges
"$ESTDIR"/bin/ch_track -otype est_ascii festival/trees/"${FV_VOICENAME}"_mcep*.params |
sed '1,/EST_Header_End/d' |
awk 'BEGIN {nc=0;}
    {if (nc == 0) nc = NF;
    if (NF == nc )
    {
       for (i=3; i<=NF; i++)
       {
           if ((NR == 1) || ($i < min[i])) min[i] = $i;
           if ((NR == 1) || ($i > max[i])) max[i] = $i;
       }
       nc = NF;
    }
 } 
 END {for (i=3; i<=nc; i++)
      {
         printf("( %f %f )\n",min[i],max[i]-min[i]);
      }
     }' >festival/trees/"${FV_VOICENAME}"_min_range.scm

ls etc/
#shellcheck disable=SC2002     
echo flite_dir "$flite_dir"

cat etc/f0.params |
sed 's/=/ /' |
head -2 |
awk '{printf("(set! %s %s)\n",$1,$2)}' > "${flite_dir}"/f0_params.scm


"$FESTIVAL" --heap "$HEAPSIZE" -b \
         '(set! cg_reduced_order '"$RORDER"')' \
          "${flite_dir}"/f0_params.scm \
          "$FLITEDIR"/tools/make_cg.scm \
          "$FLITEDIR"/tools/make_cart.scm \
          "$FLITEDIR"/tools/make_vallist.scm \
         '(cg_convert 
                   "'$FV_VOICENAME'"
                   "."
                   '"$flite/"')'    
exit 0

# touch flite/"${FV_VOICENAME}"_voice_feats.c
if [ -f etc/voice.feats ];   then
  "${FLITEDIR}"/tools/make_flite_feats etc/voice.feats >flite/"${FV_VOICENAME}"_voice_feats.c
fi                   