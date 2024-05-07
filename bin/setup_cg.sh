#!/usr/bin/env bash
unset IFS
set -euf
export BUILD VARIANTE FESTVOXDIR
cd "$BUILD"
mkdir -p "${VARIANTE}"/INST_LANG_VOX_cg
cd "${VARIANTE}"/INST_LANG_VOX_cg

"$FESTVOXDIR"/src/clustergen/setup_cg INST LANG VOX
