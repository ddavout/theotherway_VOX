#!/usr/bin/env bash
###  Generate LPC coefficients and residual for diphones (or otherwise)   ##

ESTDIR=/home/getac/Develop/speech_tools
FESTVOXDIR=/home/getac/Develop/festvox
export ESTDIR
export FESTVOXDIR
cd "${DIR_VOX}" || exit 
FIND_STS="$FLITEDIR"/bin/find_sts # ELF
FESTIVAL="$FESTIVALDIR"/bin/festival
LANG=C; export LANG

PROMPTFILE=etc/txt.done.data

echo "Finding STS files"
if [ ! -d sts ]
then
   mkdir -p sts
fi
. ./lpc/lpc.params

CODEC=ulaw
if [ "$#" = "2" ]
then
   CODEC=$3
fi
   cat $PROMPTFILE |
   awk '{print $2}' |
   while read i
   do
      fname=$i
      echo $fname STS
      if [ $CODEC = "g721vuv" -o $CODEC = "vuv" ]      
      then
         $ESTDIR/bin/ch_track -itype ascii -otype est_binary -s 0.005 -o v.v v/$fname.v
         $FIND_STS -lpcmin $LPC_MIN -lpcrange $LPC_RANGE -lpc lpc/$fname.lpc -wave wav/$fname.wav -o sts/$fname.sts -codec $CODEC -vuv v.v
      else
         $FIND_STS -lpcmin $LPC_MIN -lpcrange $LPC_RANGE -lpc lpc/$fname.lpc -wave wav/$fname.wav -o sts/$fname.sts -codec $CODEC
      fi
   done
   echo $CODEC >flite/codec

exit 0