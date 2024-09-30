#!/usr/bin/env bash
set -eauo pipefail -
# do_flite_f0
# shellcheck disable=SC1091
export PROMPTFILE
ls "$PROMPTFILE"

IFS=$'\n\t'
    # unused pb bash
    F0MIN=50
    # F0MAX=200
    # F0MEAN=110

    #F0_ARGS=`echo $F0MIN $F0MAX $F0MEAN | awk '{printf("-min %f -max %f -def %f",1.0/$2,1.0/$1,1.0/$3)}'`
    #PM_ARGS='-wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0'

    # echo "$F0_ARGS"
    # -min 0.005000 -max 0.020000 -def 0.009091

#  (set! silence (car (cadr (car (PhoneSet.description '(silences))))))
SILENCE=pau  
awk '{print $2}' "$PROMPTFILE" |
while read -r i
do
  fname=$i
  echo "$fname" F0_PM

     # pitchmark as a file name as input
    "$ESTDIR"/bin/ch_wave -scaleN 0.9 wav/"$fname".wav -F 16000 -o tmp_"$fname" 
    "$ESTDIR"/bin/pitchmark -o pm_unfilled/"$fname".pm -otype est -wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0 -min 0.005000 -max "0.020000" -def "0.009091" tmp_"$fname";#}
    #$ESTDIR/bin/pitchmark -o pm_unfilled/$fname.pm -otype est -wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0  -min 0.005000 -max 0.020000 -def 0.009091 ;}
    # $FESTVOXDIR/src/general/smooth_f0 -o f0/$fname.f0 -pm_input -pm_min_f0 $F0MIN -otype ssff pm_unfilled/$fname.pm -lab lab/$fname.lab -silences $SILENCE -interpolate -postsmooth -postwindow 0.025
    echo "smooth"
# lab f0
    # "$FESTVOXDIR"/src/general/smooth_f0 -o f0/"$fname".f0 -pm_input -pm_min_f0 "$F0MIN" -otype ssff pm_unfilled/"$fname".pm -lab lab/"$fname".lab -silences "$SILENCE" -interpolate -postsmooth -postwindow 0.025
    echo     "$FESTVOXDIR"/src/general/smooth_f0 -o f0/"$fname".f0 -pm_input -pm_min_f0 "$F0MIN" -otype ssff pm_unfilled/"$fname".pm -lab lab/"$fname".lab -silences "$SILENCE" -interpolate -postsmooth -postwindow 0.025
    # /home/getac/Develop/festvox/src/general/smooth_f0 -o f0/neut_parl_s01_0036.f0 -pm_input -pm_min_f0 50 -otype ssff pm_unfilled/neut_parl_s01_0036.pm -lab lab/neut_parl_s01_0036.lab -silences pau -interpolate -postsmooth -postwindow 0.025
    # 
    # -o <ofile>       Output filename, defaults to stdout
    "$FESTVOXDIR"/src/general/smooth_f0 -o f0/"$fname".f0 -pm_input -pm_min_f0 "$F0MIN" -otype ssff pm_unfilled/"$fname".pm -lab lab/"$fname".lab -silences "$SILENCE" -interpolate -postsmooth -postwindow 0.025

done
