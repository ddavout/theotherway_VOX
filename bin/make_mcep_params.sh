#!/usr/bin/env bash
set -eauo pipefail -
# make_mcep_params
export ESTDIR
# shellcheck disable=SC1091
export PROMPTFILE
ls "$PROMPTFILE"

IFS=$'\n\t'
   echo "Finding MCEP min max and range"
   # shellcheck disable=SC2002
   cat "$PROMPTFILE" |
   awk '{print $2}' |
   while read -r i ; do
       # TODO
      "$ESTDIR"/ch_track -otype est_ascii mcep/"$i".mcep |
      sed '1,/EST_Header_End/d'
   done |
       awk 'BEGIN {min=0; max=0;}
        {for (i=4; i<=NF; i++)
            {
                if ($i < min) min = $i;
                if ($i > max) max = $i;
            }
         } 
     END {printf("(set! mcep_min %f)\n",min);
          printf("(set! mcep_max %f)\n",max);
          printf("(set! mcep_range %f)\n",max-min);
         }' >mcep/mcep.params.scm
   echo "Finding MCEP min max and range ended"
   ls -al mcep/mcep.params.scm
