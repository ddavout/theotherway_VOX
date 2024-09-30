#!/usr/bin/env bash
# do_clustergen_dur
set -eauo pipefail -

#shellcheck disable=SC1091
source etc/voice.defs || { echo to be run in the VOX directory; exit 66; }

# pour rappel
#shellcheck disable=SC2034
{ FV_VOICENAME=INST_LANG_VOX
FV_FULLVOICENAME=INST_LANG_VOX_cg
VOICENAME="(voice_INST_LANG_VOX_cg)"
VOICESCM=festvox/INST_LANG_VOX_cg.scm
NUM_CPUS=3 ;}

SIODHEAPSIZE="${SIODHEAPSIZE:-20000000}"
export SIODHEAPSIZE
export needtodoit
HEAPSIZE="$SIODHEAPSIZE"

# TODO message error 


# correspondant au vanilla make_dur_model_mcep
###########################################################################
##                                                                       ##
##  Build a duration model                                               ##
##                                                                       ##
##  Many parameterizations are possible and training techniques, many of ##
##  which will be better than what is here, but from experience this     ##
##  give a model that is substantially better than simply means durations##
##  with hand speicifed modification factors at the phrasal boundaries   ##
##                                                                       ##
##  Builds CART tree that predicts zscores of durations                  ##
##                                                                       ##
##  This is the *whole* thing, you probably want to actually do each     ##
##  stage by hand (the training itself can takes days)                   ##
##                                                                       ##
##  This is modified from make_dur_model, this version is for clustergen ##
##                                                                       ##
###########################################################################
# first cleaning
#SC2061 (warning): Quote the parameter to -name so the shell won't interpret it.
#SC2035 (info): Use ./*glob* or -- *glob* so names with dashes won't become options.

#find festival/dur/feats -name '*.feats' -exec rm {} \;

LANG=C; export LANG

SILENCENAME=pau
MODELNAME=INST_LANG_VOX

export PROMPTFILE
PREF=dur

# TODO
OMP="-omp_nthreads 3"
# TODO
STOP=25

DURMEANSTD=./bin/durmeanstd
DUMPFEATS=./bin/dumpfeats

WAGON=$ESTDIR/bin/wagon
WAGON_TEST=$ESTDIR/bin/wagon_test


PROMPTFILE="${PROMPTFILE:-"${1:-etc/txt.done.data}"}"
# needtodoit=
# if [ ! "$needtodoit" ]; then
##needtodoit\
# fi
#shellcheck disable=SC2002
cat "$PROMPTFILE" |
awk '{printf("festival/utts_hmm/%s.utt\n",$2)}' >utthmmfile



# move as and when needed and use needtodoit=false; export needtodit
needtodoit="${needtodoit:-true}"

## find the means and stddev for durations in database
echo ';;; Finding mean durations and standard deviation of each phone type'
$DURMEANSTD -relation HMMstate -output festival/dur/etc/durs.meanstd -from_file utthmmfile || exit 12

## extract the features
echo ';;; Extracting features from utterances'

#   -eval <ifile>
#             A scheme file to be loaded before dumping.  This may contain
#             dump specific features etc.  If filename starts with a left
#             parenthesis it it evaluated as lisp /!\ parenthis

$DUMPFEATS -relation HMMstate -eval "festvox/select_phoneset.scm" -eval "festvox/INST_LANG_VOX_cg.scm" -eval '(voice_INST_LANG_VOX_cg)' -feats festival/dur/etc/statedur.feats -output festival/dur/feats/%s.feats -eval festival/dur/etc/logdurn.scm -from_file utthmmfile || exit 13

## Save all features in one file removing silence phones
echo ';;; Collecting features in training and test data'
while read -r x
do
  fname="$(basename "$x" .utt)"
  #shellcheck disable=SC2002
  cat festival/dur/feats/"$fname".feats |
  awk '{if ($2 != "'$SILENCENAME'") print $0}'
done < utthmmfile  >festival/dur/data/dur.data

bin/traintest festival/dur/data/dur.data
bin/traintest festival/dur/data/dur.data.train

# Build description file
echo ';;; Build description file'
"$ESTDIR"/bin/make_wagon_desc festival/dur/data/dur.data festival/dur/etc/statedur.feats festival/dur/etc/dur.desc
(cp -b festival/dur/etc/dur.desc festival/dur/etc/dur.desc_bak)


echo ';;; fix it the heap of festvox/build_prosody.scm'
"$FESTIVALDIR"/bin/festival --heap "$HEAPSIZE" -b 'festvox/select_phoneset.scm' 'festvox/build_prosody.scm' '(begin (build_dur_feats_desc))'

# emacs festival/dur/etc/dur.desc



(
echo ';;; Build the duration model itself'
# shellcheck disable=SC2086 ## OMP to be splitted
"$WAGON" $OMP -data festival/dur/data/dur.data.train.train -desc festival/dur/etc/dur.desc -test festival/dur/data/dur.data.train.test -stop "$STOP" -output festival/dur/tree/"$PREF".S"$STOP".tree || exit 1

echo ";;; Test the duration model"
"${WAGON_TEST}" -heap "$HEAPSIZE" -data 'festival/dur/data/dur.data.test' -desc 'festival/dur/etc/dur.desc' -tree festival/dur/tree/"$PREF".S"$STOP".tree ) |
tee dur."$PREF".S"$STOP".out


echo ";;; Constructing the duration model as a loadable scheme file"
"$FESTIVALDIR"/bin/festival --heap "$HEAPSIZE" -b 'festvox/select_phoneset.scm' 'festvox/build_prosody.scm'  '(begin (finalize_dur_model "'"$MODELNAME"'" "'"$PREF.S$STOP.tree"'"))'

# the last part  of do_clustergen "dur"s
cp -b 'festvox/INST_LANG_VOX_dur.scm' 'festvox/INST_LANG_VOX_durdata_cg.scm'
exit 0
