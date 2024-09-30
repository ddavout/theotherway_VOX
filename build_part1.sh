#!/usr/bin/env bash
unset IFS
# tempo
ESTDIR=/home/getac/Develop/speech_tools
FESTVOXDIR=/home/getac/Develop/festvox
export ESTDIR
export FESTVOXDIR

PROMPTFILE=etc/txt.done.data
# set -f  Désactive la génération de nom de fichier (globbing)
# set -o pipefail     the return value of a pipeline is the status of
#                     the last command to exit with a non-zero status,
#                     or zero if no command exited with a non-zero status
# set -u Treat unset variables as an error when substituting.
# Ces indicateurs peuvent être désactivés en utilisant « + » plutôt que « - Ils peuvent être utilisés lors de l'appel au shell. Le jeu d'indicateurs actuel peut être trouvé dans « $-
# set -e  Exit immediately if a command exits with a non-zero status.
#TODO doc /!\ a "single command", not a compound ?
# set -a: -a  Marque pour l'export toutes les variables qui sont modifiées ou créées.
# Variables that are marked for export will be inherited by any child process. Variables inherited in this way are called Environment Variables.
set -eauo pipefail -
trap '_=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $_' ERR
IFS=$'\n\t'

    F0MIN=50
    F0MAX=200
    F0MEAN=110
    F0_ARGS=`echo $F0MIN $F0MAX $F0MEAN | awk '{printf("-min %f -max %f -def %f",1.0/$2,1.0/$1,1.0/$3)}'`
    PM_ARGS='-wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0'

    # echo "$F0_ARGS"
    # -min 0.005000 -max 0.020000 -def 0.009091


awk '{print $2}' $PROMPTFILE |
while read i
do
  fname=$i
  echo $fname F0_PM
  PM_ARGS='-wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0'
    $ESTDIR/bin/ch_wave -scaleN 0.9 wav/$fname.wav -F 16000 | 
    "$ESTDIR"/bin/pitchmark -o pm_unfilled/$fname.pm -otype est -wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0 -min 0.005000 -max 0.020000 -def 0.009091 ;#}
    #$ESTDIR/bin/pitchmark -o pm_unfilled/$fname.pm -otype est -wave_end -lx_lf 140 -lx_lo 111 -lx_hf 80 -lx_ho 51 -med_o 0  -min 0.005000 -max 0.020000 -def 0.009091 ;}
  # $FESTVOXDIR/src/general/smooth_f0 -o f0/$fname.f0 -pm_input -pm_min_f0 $F0MIN -otype ssff pm_unfilled/$fname.pm -lab lab/$fname.lab -silences $SILENCE -interpolate -postsmooth -postwindow 0.025
done