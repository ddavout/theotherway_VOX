#!/usr/bin/env bash
set -eauo pipefail -
# do_clustergen_f0
# shellcheck disable=SC1091
ESTDIR=/home/getac/Develop/speech_tools
# FESTVOXDIR=/home/getac/Develop/festvox
export ESTDIR
# export FESTVOXDIR
PROMPTFILE=etc/txt.done.data
export PROMPTFILE
ls "$PROMPTFILE"

IFS=$'\n\t'
#!/usr/bin/env bash
set -eauo pipefail -
# do_clustergen_f0
# shellcheck disable=SC1091
export PROMPTFILE
ls "$PROMPTFILE"
PROMPTFILE=etc/txt.done.data
if [ $# = 1 ]
then
   PROMPTFILE=$1
fi
#PM_ARGS='-wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0'

awk '{print $2}' "$PROMPTFILE" |
while read -r i
do
   fname=$i
   echo "$i" PM_WAVE
   "$ESTDIR"/bin/ch_wave -scaleN 0.9 wav/"$i".wav -F 16000 -o tmp_"$fname"
   # You may (or may not) require -inv and many of the parameters here
   # may be worth modifying, see the section on Extracting pitchmarks from
   # waveforms in the document

# -fill Insert and remove pitchmarks according to min, max
#     and def period values. Often it is desirable to place limits
#     on the values of the pitchmarks. This option enforces a 
#     minimum and maximum pitch period (specified by -man and -max).
#     If the maximum pitch setting is low enough, this will 
#     esnure that unvoiced regions have evenly spaced pitchmarks 

# -min <float>  Minimum allowed pitch period, in seconds
    #F0_ARGS=`echo $F0MIN $F0MAX $F0MEAN | awk '{printf("-min %f -max %f -def %f",1.0/$2,1.0/$1,1.0/$3)}'`
    #PM_ARGS='-wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0'

    # echo "$F0_ARGS"
    # -min 0.005000 -max 0.020000 -def 0.009091 
# -min 0.005000 -max 0.020000 -def 0.009091
# $ESTDIR/bin/pitchmark tmp$$.wav -o pm/$fname.pm -otype est $PM_ARGS -fill 
   echo "$ESTDIR"/bin/pitchmark -o pm/"$fname".pm -otype est -wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0 -fill tmp_"$fname";#}
  "$ESTDIR"/bin/pitchmark -o pm/"$fname".pm -otype est -wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0 -fill tmp_"$fname";#}
   #rm -f tmp$$.wav
done 