#!/usr/bin/env bash
# do_clustergen_mcep_sptk
set -euao pipefail -

# shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }
# Default is now deltas (and mlpg)
# $0 mcep_sptk_deltas $PROMPTFILE
vanilla=0
# neut_parl_s01_0001 MCEP with deltas (SPTK) 16000
# Cannot open file 2048!
# Cannot open file 24!
# neut_parl_s01_0001 COMBINE_COEFFS (f0,mcep_deltas,v)
# BUG si FRAMELEN est renseignée ..
#/$\ $ESTDIR/bin/ch_wave -otype raw < wav/$fname.wav < BUG
#/home/dop7/MyDevelop/theotherway/bin/do_clustergen_mcep_sptk.sh : ligne 114 : 3081407 Relais brisé (pipe)    $FRAME -l $FRAMELEN -p $FRAMESHIFT $TMP.sf
#     3081408 Erreur de segmentation  | $WINDOW -l $FRAMELEN -L $FFTLEN -w $WINDOWTYPE -n $NORMALIZE -n
#     3081409 Fini                    | $MCEP -a $FREQWARP -m $MCEPORDER -l $FFTLEN -e 1.0E-08 > mcep_sptk/$fname.mcep



# shellcheck disable=SC1091,SC2002,SC2003,SC2006,SC2034,SC2046,SC2086,SC2154,SC2162,SC2166
if [[ "$vanilla" == "0" ]] ; then
    # Extract MCEP using SPTK, but save them into mcep_deltas directory
    # so other parts of this script (sic : the vanilla do_clustergen) continue to work
    MCEPORDER=24
    WINDOWTYPE=1
    NORMALIZE=1
    FFTLEN=2048
    # shellcheck disable=SC2034
    LNGAIN=1

    X2X=$SPTKDIR/bin/x2x
    MCEP=$SPTKDIR/bin/mcep
    # shellcheck disable=SC2034
    LPC2LSP=$SPTKDIR/bin/lpc2lsp
    # shellcheck disable=SC2034
    MERGE=$SPTKDIR/bin/merge
    SOPR=$SPTKDIR/bin/sopr
    NAN=$SPTKDIR/bin/nan
    MINMAX=$SPTKDIR/bin/minmax
    # shellcheck disable=SC2034
    PITCH=$SPTKDIR/bin/pitch
    FRAME=$SPTKDIR/bin/frame
    WINDOW=$SPTKDIR/bin/window


    if [ ! -d mcep_sptk ]
    then
	mkdir mcep_sptk
    fi

    if [ ! -d mcep_deltas ]
    then
	mkdir mcep_deltas
    fi
    # shellcheck disable=SC2002 # useless cat
    cat "$PROMPTFILE" |
    awk '{print $2}' |
    while read -r i
    do
	fname=$i
SAMPFREQ=16000
FRAMELEN=$(echo | awk "{print int(0.025*$SAMPFREQ)}")
FRAMESHIFT=$(echo | awk "{print int(0.005*$SAMPFREQ)}")
FREQWARP=0.42
	if [ "$SAMPFREQ" = "" ]
	then
	    # Use the first wav file to determine sampling frequency
	    # SAMPFREQ=$($ESTDIR/bin/ch_wave -info wav/$fname.wav  | grep 'Sample rate' | cut -d ' ' -f 3)

		FRAMELEN=$(echo | awk "{print int(0.025*$SAMPFREQ)}")
		FRAMESHIFT=$(echo | awk "{print int(0.005*$SAMPFREQ)}")

		FWARP[8000]=0.312
		FWARP[11025]=0.357
		FWARP[16000]=0.42
		FWARP[22050]=0.455
		FWARP[32000]=0.504
		FWARP[44100]=0.544
		FWARP[48000]=0.554

		FREQWARP=${FWARP[$SAMPFREQ]}
		
		if [ "$FREQWARP" = "" ]
		then
			echo "mcep_sptk_deltas: Cannot handle sampling frequency $SAMPFREQ"
			exit 1
	    fi
	fi

	echo "$fname MCEP with deltas (SPTK) $SAMPFREQ"
	# echo "-a $FREQWARP -m $MCEPORDER -l $FFTLEN " -a 0.42 -m 24 -l 2048 
	TMP=mcep_sptk_tmp.$$
	# raw (little endian short-type format)
	# Save raw wave out
	# BUG ? < 
	ls -al  wav/"$fname".wav
	"$ESTDIR"/bin/ch_wave -otype raw wav/"$fname".wav > $TMP.raw
	"$X2X" +sf $TMP.raw > $TMP.sf
    # shellcheck disable=SC2002 # useless cat
	cat $TMP.sf | $MINMAX | $X2X +fa > $TMP.minmax
	min=$(head -n 1 $TMP.minmax)
	max=$(tail -n 1 $TMP.minmax)
	if [ -s $TMP.raw -a "$min" -gt -32768 -a "$max" -lt 32767 ]
	then
        # frame [ options ] [ infile ] > stdout
        #  window [ options ] [ infile ] > outfile
        #  mcep [ options ] [ infile ] > stdout
	    $FRAME -l "$FRAMELEN" -p "$FRAMESHIFT" $TMP.sf |
            $WINDOW -l "$FRAMELEN" -L $FFTLEN -w $WINDOWTYPE -n $NORMALIZE -n -> $TMP.a  #| \
        # pipe doesn't work stricter usage than window and frame
		$MCEP -a $FREQWARP -m $MCEPORDER -l $FFTLEN -e 1.0E-08 $TMP.a > mcep_sptk/"$fname".mcep
        if [ -n "$($NAN mcep_sptk/"$fname".mcep)" ]
	    then
		echo "Failed to process $fname"
	    else
		$SPTKDIR/bin/delta -m $MCEPORDER -d -0.5 0.0 0.5 < mcep_sptk/"$fname".mcep | \
		    $SPTKDIR/bin/x2x +fa$(expr 2 \* \( $MCEPORDER + 1 \)) | \
		    $ESTDIR/bin/ch_track -itype ascii -otype est_binary -s 0.005 -o mcep_deltas/"$fname".mcep
	    fi
	else
	    echo "Failed to process $fname"
	fi

	rm -rf $TMP.*
    done
    exit 0  
fi    
