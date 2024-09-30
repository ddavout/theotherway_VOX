#!/usr/bin/env bash
set -eauo pipefail -
# bin/install_SPTK.sh
# default
# TOP="$PWD" #/home/getac/MyDevelop/theotherway_VOX
echo TOP "$TOP"
# default
# SPTKDIR=/home/getac/Develop/SPTK
export SPTKDIR
export FESTVOX
echo SPTKDIR "$SPTKDIR"
# FESTIVAL="$FESTIVALDIR"/bin/festival
sptk=SPTK-3.6
sptktar="$sptk".tar.gz
{  
	cd "$TOP" || exit 1
    /usr/bin/tar xfv src/"$sptktar" || exit 1
    cd "$sptk" ; ./configure --prefix="$SPTKDIR" || exit 1 

    # patch -p NUM  --strip=NUM  Strip NUM leading components from file name
    # we are executing the command from $sptk . But the patch file contains all the filenames in absolute path format
    # ex : diff -rupN SPTK-3.6/bin/pitch/snack/jkGetF0.c new/SPTK-3.6/bin/pitch/snack/jkGetF0.c
	# -p1 tells the patch command to skip 1 leading slash from the filenames present in the patch file. 
	# until SPTK-3.6/ is ignored.

	patch -p 1 < "$FESTVOX"/src/clustergen/SPTK-3.6.patch || exit 1
	# patching file SPTK-3.6/bin/pitch/snack/jkGetF0.c
	# patching file SPTK-3.6/bin/psgr/psgr.c
	# patching file SPTK-3.6/bin/psgr/psgr.h
	make || exit 1
	make install || exit 1
	rm -rf  ./"$sptk"
 }



 