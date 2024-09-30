#!/usr/bin/env bash
set -eauo pipefail -
# do_clustergen_build_flite


IFS=$'\n\t'

flite_dir="flite"
# cg ?
FV_TYPE="clunits"
FV_FLITE_LANG=INST_LANG_LANG_lang # cmu_${FV_LANG_TYPE}_lang
FV_FLITE_LEX=INST_LANG_LANG_lex # cmu_${FV_LANG_TYPE}_lex
FV_FLITE_LEX_DIR=${FV_FLITE_LEX}
FV_VOICENAME=INST_LANG_VOX
mkdir -p "${flite_dir}"

if [ ! -s "${flite_dir}"/Makefile ]; then
	# shellcheck disable=SC2002
    cat "$FLITEDIR"/tools/Makefile.flite_my |
    # TODO  bug vanilla  "$i" ?
      sed 's%__FLITEDIR__%'"$FLITEDIR"'%'  |
      sed 's%__VOICETYPE__%'"$FV_TYPE"'%' |
      sed 's%__FLITELANG__%'"$FV_FLITE_LANG"'%' |
      sed 's%__FLITELEX__%'"$FV_FLITE_LEX_DIR"'%' |
      sed 's%__VOICETYPE__%'"$FV_TYPE"'%' |
      sed 's%__VOICENAME__%'"$FV_VOICENAME"'%' > "$flite_dir"/Makefile || exit 88
else
      echo we don\'t overwrite the existing "$flite_dir"/Makefile
fi 

ls -al "$flite_dir"/Makefile
