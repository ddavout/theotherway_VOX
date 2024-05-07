#! /bin/env bash
# ./bin/do_clustergen_festvox_dist.sh
# to be run in the VOX directory
# shellcheck source=/dev/null
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }

# Voice distribution has festival/lib/voice/LANG/voicename as prefix
# for all files
echo 'Make festvox voice distribution' for "${DIR_VOX}"
fvdir="${DIR_VOX}"/festival/lib/voices
if [ ! -f "$fvdir" ]; then  mkdir -p "$fvdir" || exit 66; fi

# The owner and group of a symlink are not significant to file access performed through the link, but do have
# implications on deleting a symbolic link from a directory with the restricted deletion bit set.

#  many users prefer to first change directories to the location
# where the relative symlink will be created, so that tab-completion or
# other file resolution will find the same target as what will be placed in the symlink.

#‘--no-dereference’
#     Do not treat the last operand specially when it is a symbolic link
#     to a directory.  Instead, treat it as if it were a normal file.
# (The  default is to treat a destination that is a symlink to a directory just like a directory.)


(cd "$fvdir" || exit 66 ; ln -s -n -b ../../../.. INST_LANG_VOX_cg)
# to be filled later if missing
#touch "$fvdir"/README "$fvdir"/COPYING
touch README COPYING;
# TODO works but raise find: Boucle détectée dans le système de fichiers ; « ‘./festival/lib/voices/INST_LANG_VOX_cg/INST_LANG_VOX_cg’ » est dans la même boucle que ‘./’.

set +e
tar -zcvf festvox_INST_LANG_VOX_cg.tar.gz \
    README \
    COPYING \
    festival/trees/INST_LANG_VOX_f0.tree \
    festival/trees/INST_LANG_VOX_mcep.tree \
    festival/trees/INST_LANG_VOX_mcep.params \
    festvox || true
    #rm -rf festival/lib
exit 0
