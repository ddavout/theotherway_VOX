#!/usr/bin/env bash
# do_clustergen_combine_coeffs.sh

set -eauo pipefail -

# shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
vanilla=0
echo "$PWD"
# TODO -s 0.005
# awk awk '{if (l==0) l not defined 
# shellcheck disable=SC1091,SC2002,SC2003,SC2006,SC2034,SC2046,SC2086,SC2154,SC2162,SC2166
if [[ "$vanilla" == "1" ]] ; then
   if [ ! -d ccoefs ]
   then
      mkdir -p ccoefs 
   fi
   CG_TMP=cg_tmp_$$

   cat $PROMPTFILE |
   awk '{print $2}' |
   while read -r i
   do
      fname=$i
      echo $fname "COMBINE_COEFFS (f0,mcep_deltas,v)"
      if [[ ! -f f0/$fname.f0 ]] || [[ ! -f mcep_deltas/$fname.mcep ]] || [[ ! -f v/$fname.v ]]   ; then
          exit 66
      fi
      # pis aller ??? enddur neut_parl_s01_0009 2.350 versus enddur neut_parl_s01_0009 2.365    
      if true; then
          if [ -f festival/utts/$fname.utt ]
          then
             $FESTIVALDIR/examples/dumpfeats -relation Segment -eval festvox/safeload.scm -feats '(end)' festival/utts/$fname.utt || exit
             enddur=`$FESTIVALDIR/examples/dumpfeats -relation Segment -eval festvox/safeload.scm -feats '(end)' festival/utts/$fname.utt | tail -1 | awk '{printf("%0.3f",$1+0.0005)}'`
             echov "enddur $fname $enddur"
          fi
      fi
    if false; then      
      enddur=`$ESTDIR/bin/ch_track -otype est_ascii mcep_deltas/$fname.mcep | awk '{time=$1} END {printf("%0.3f",time)}'`
      echov "enddur $fname $enddur" 
    fi

      $ESTDIR/bin/ch_track -otype ascii f0/$fname.f0 |  awk '{if (NR == 1) { print $1;} print $1}' >$CG_TMP.f0
#echov ok1
      $ESTDIR/bin/ch_track -otype ascii mcep_deltas/$fname.mcep |
      sed '1d' |
      awk '{if (NR == -1) { print $0; } print $0}' >$CG_TMP.mcep
#echov ok2
      cat v/$fname.v | awk '{print 10*$1}' |
      awk '{if (NR == 1) { print $1;} print $1}' >$CG_TMP.v
#echov ok3
      paste $CG_TMP.f0 $CG_TMP.mcep $CG_TMP.v |
      awk '{if (l==0) 
              l=NF;
            if (l == NF)
              print $0}' |
      $ESTDIR/bin/ch_track -itype ascii -otype est_binary -s 0.005 -end $enddur -o ccoefs/$fname.mcep
#echov ok4      
      #rm -f $CG_TMP.*
   done
fi
if [[ "$vanilla" == "0" ]] ; then
   mkdir -p ccoefs 
   CG_TMP=cg_tmp_"$$"
    #shellcheck disable=SC2002
   cat "$PROMPTFILE" |
   awk '{print $2}' |
   while read -r i
    do
        fname="$i"
        echo "$fname" "COMBINE_COEFFS (f0,mcep_deltas,v)"
        if [[ ! -f f0/"$fname".f0 ]] || [[ ! -f mcep_deltas/"$fname".mcep ]] || [[ ! -f v/"$fname".v ]]   ; then
          exit 66
        fi
        # pis aller ??? enddur neut_parl_s01_0009 2.350 versus enddur neut_parl_s01_0009 2.365    
        if false; then
          if [ -f festival/utts/"$fname".utt ];
            then
                "$FESTIVALDIR"/examples/dumpfeats -relation Segment -eval festvox/safeload.scm -feats '(end)' festival/utts/"$fname".utt || exit
                enddur="$("$FESTIVALDIR"/examples/dumpfeats -relation Segment -eval festvox/safeload.scm -feats '(end)' festival/utts/"$fname".utt | tail -1 | awk '{printf("%0.3f",$1+0.0005)}')"
                echov "enddur $fname $enddur"
        fi
        fi
        # without any festival/utts
        if true; then
            enddur="$("$ESTDIR"/bin/ch_track -otype est_ascii mcep_deltas/"$fname".mcep | awk '{time=$1} END {printf("%0.3f",time)}')"
            echov "enddur $fname $enddur" 
        fi

        "$ESTDIR"/bin/ch_track -otype ascii f0/"$fname".f0 |  awk '{if (NR == 1) { print $1;} print $1}' >"${CG_TMP}".f0
        #echov ok1
        "$ESTDIR"/bin/ch_track -otype ascii mcep_deltas/"$fname".mcep |
        sed '1d' |
        awk '{if (NR == -1) { print $0; } print $0}' >"${CG_TMP}".mcep
        #echov ok2
        #shellcheck disable=SC2002
        cat v/"$fname".v | awk '{print 10*$1}' |
        awk '{if (NR == 1) { print $1;} print $1}' >"${CG_TMP}".v
        #echov ok3
        paste "${CG_TMP}".f0 "${CG_TMP}".mcep "${CG_TMP}".v | awk '{if (l==0) 
              l=NF;
            if (l == NF)
              print $0}' | "$ESTDIR"/bin/ch_track -itype ascii -otype est_binary -s 0.005 -end "$enddur" -o ccoefs/"$fname".mcep
        #echov ok4
        #rm -f "${CG_TMP}".*
   done
fi
