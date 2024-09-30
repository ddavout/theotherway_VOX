#!/usr/bin/env bash
# do_clustergen_cluster
set -euao pipefail -
# sans (set! cg:parallel_tree_build t) dans l'appel
# et même (set! cg:parallel_tree_build nil)

# shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
# needed if you use this file directly
# environ=/home/getac/MyDevelop/Voices/EXP2/config/env_festvox_settings0.cfg
# source $environ
#DIR_VOX=/home/getac/MyDevelop/Voices/EXP2/build/fr/scratch/INST_LANG_VOX_cg
#PROMPTFILE="etc/txt.done.data"
HEAPSIZE=2000000
export HEAPSIZE

export PROMPTFILE HEAPSIZE FESTIVALDIR DIR_VOX
cd "$DIR_VOX"
   ORDER=24
   dynwin=$FESTVOXDIR/src/vc/src/win/dyn.win
   CG_TMP=cg_tmp_$$

   if [ ! -d mcep_deltas ]
   then
      mkdir mcep_deltas
   fi
# shellcheck disable=SC2002
   cat "$PROMPTFILE" |
   awk '{print $2}' |
   while read -r i
   do
      fname=$i
      echo "$fname" MCEP with deltas
      "$FESTVOXDIR"/src/vc/src/analysis/analysis -nmsg -mcep -pow -order "$ORDER" -npowfile "$CG_TMP".npow wav/"$i".wav "$CG_TMP".mcep

      # get deltas
# shellcheck disable=SC2006
      ORDERP=`echo $ORDER | awk '{printf("%d",$1+1)}'`
      "$FESTVOXDIR"/src/vc/src/mlpg/delta -nmsg -jnt -dynwinf "$dynwin" -dim "$ORDERP" "$CG_TMP".mcep "$CG_TMP".mcepd

# TODO d2a.pl Convert binary to ascii
# shellcheck disable=SC2086,SC2002
      cat "$CG_TMP".mcepd |
      perl "$DIR_VOX"/bin/d2a.pl |
      awk '{printf("%s ",$1); if ((NR%(2*('$ORDER'+1))) == 0) printf("\n")}' |
      cat >"$CG_TMP".ascii.mcepd

      cat $CG_TMP.ascii.mcepd |
        "$ESTDIR"/bin/ch_track -itype ascii -otype est_binary -s 0.005 -o mcep_deltas/"$i".mcep

#      cat cg_tmp.npow |
#      perl $CLUSTERGENDIR/d2a.pl |
#      awk '{printf("%s\n",$1);}' |
#      $ESTDIR/bin/ch_track -itype ascii -otype est_binary -s 0.005 -o mcep/$i.npow
      rm -f "$CG_TMP".*
   done
