#!/usr/bin/env bash
set -eauo pipefail -
# do_flite_cg
FESTIVAL="$FESTIVALDIR"/bin/festival
# shellcheck disable=SC1091
export PROMPTFILE
ls "$PROMPTFILE"
FV_VOICENAME=INST_LANG_VOX
cd "${DIR_VOX}" || exit 
flite_dir=flite

IFS=$'\n\t'

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
#shellcheck disable=SC2002     
cat etc/f0.params |
sed 's/=/ /' |
head -2 |
awk '{printf("(set! %s %s)\n",$1,$2)}' >flite/f0_params.scm

#      '(set! cg_reduced_order "'"$RORDER"'")' \

"$FESTIVAL" --heap "$HEAPSIZE" -b \
         '(set! cg_reduced_order '"$RORDER"')' \
          "${flite_dir}"/f0_params.scm \
          "$FLITEDIR"/tools/make_cg.scm \
          "$FLITEDIR"/tools/make_cart.scm \
          "$FLITEDIR"/tools/make_vallist.scm \
         '(cg_convert 
                   "'$FV_VOICENAME'"
                   "."
                   "flite/")'    

touch flite/"${FV_VOICENAME}"_voice_feats.c
if [ -f etc/voice.feats ];   then
  "${FLITEDIR}"/tools/make_flite_feats etc/voice.feats >flite/"${FV_VOICENAME}"_voice_feats.c
fi

# If Grapheme-based it has its own phoneset
if [ -f festvox/"${FV_VOICENAME}"_char_phone_map.scm ];  then
   echo "flite_feat_set_int(vox->features,\"grapheme\",1);" >>flite/"${FV_VOICENAME}"_voice_feats.c
   echo cg_convert: converting phoneset table
   echo "CG_GRAPHEME=true" >>flite/paramfiles.mak
  $FESTIVAL -b "$FLITEDIR"/tools/make_phoneset.scm \
  '(phonesettoC "'"${FV_VOICENAME}"'" (car (load "festvox/"'"${FV_VOICENAME}"'"_phoneset.scm" t)) "pau" "flite")'
fi
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_f0_trees.c': Aucun fichier ou dossier de ce type
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_mcep_trees.c': Aucun fichier ou dossier de ce type
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_params.c': Aucun fichier ou dossier de ce type
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_durmodel.c': Aucun fichier ou dossier de ce type
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_f0_trees.c': Aucun fichier ou dossier de ce type
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_mcep_trees.c': Aucun fichier ou dossier de ce type
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_params.c': Aucun fichier ou dossier de ce type
# ls: impossible d'accéder à 'INST_LANG_VOX_cg_*_durmodel.c': Aucun fichier ou dossier de ce type
Makefile:63: paramfiles.mak: Aucun fichier ou dossier de ce type


echo "flite_build cg complete.  You can compile the generated voice by"
echo "   cd flite; make"