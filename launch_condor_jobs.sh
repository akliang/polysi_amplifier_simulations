#!/bin/bash

if [ "$1" == "" ]; then
  echo "Please supply an input list."
  exit
fi
INFILE="$1"

while read LINE; do

  (
  cd $( echo $LINE | gawk '{ print $1 }' )
  SKYTAG='CirSim' sky_condor_submit $( echo $LINE | gawk '{ print $2 }' )
  )


done <$INFILE

mv $INFILE ${INFILE}.submitted

