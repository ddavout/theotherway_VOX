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
awk '{print $2}' "$PROMPTFILE" |
while read -r i
do
   fname="$i"
   echo "$fname" LPC

   # Potentially normalise the power (if powfact is there)
   if [ -f etc/powfacts ]
   then
       #powfact=`awk '{if ($1 == "'$fname'") print $2}' etc/powfacts`
      powfact=$(awk '{if ($1 == "'"$fname"'") print $2}' etc/powfacts)
       if [ ! "$powfact" ]
       then
           powfact=1.0
       fi
       # $ESTDIR/bin/ch_wave -scale "$powfact" wav/"$fname".wav -o /tmp/tmp$$.wav
       $ESTDIR/bin/ch_wave -scale "$powfact" wav/"$fname".wav -o tmp_"$fname"
   else
       # cat wav/"$fname".wav >/tmp/"tmp$$".wav    
       cat wav/"$fname".wav >tmp_"$fname"  
   fi
   # Change the overall volume too, of the normalised file
   # $ESTDIR/bin/ch_wave -scaleN 0.65 -o /tmp/tmp$$.wav /tmp/tmp$$.wav

   # and if you want to resample, now is the time (can be combine with above)
   #$ESTDIR/bin/ch_wave -F 11025 -o /tmp/tmp$$.wav /tmp/tmp$$.wav

   # Extract the LPC coefficients 
  # $ESTDIR/bin/sig2fv /tmp/"tmp$$".wav -o lpc/"$fname".lpc -otype est_binary -lpc_order 16 -coefs "lpc" -pm pm/"$fname".pm -preemph 0.95 -factor 3 -window_type hamming
  $ESTDIR/bin/sig2fv tmp_"$fname"  -o lpc/"$fname".lpc -otype est_binary -lpc_order 16 -coefs "lpc" -pm pm/"$fname".pm -preemph 0.95 -factor 3 -window_type hamming
   # Extract the residual
   # $ESTDIR/bin/sigfilter /tmp/"tmp$$".wav -o lpc/"$fname".res -otype riff -lpcfilter lpc/"$fname".lpc -inv_filter
   $ESTDIR/bin/sigfilter tmp_"$fname"  -o lpc/"$fname".res -otype riff -lpcfilter lpc/"$fname".lpc -inv_filter

   # rm /tmp/tmp$$.wav
   # rm tmp_"$fname"  


done
