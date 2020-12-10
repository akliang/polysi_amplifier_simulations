#!/bin/bash

## assume first line is header vars
#HVARS=$( head -n 1 WLtable | sed -e "s/#//g" )

if [ "$1" != "" ]; then
  WLTABLE="$1"
else
  WLTABLE="WLtable"
fi

#INFILE="one_stage_amp_fcasc2_compinload.cir"
#INFILE="two_stage_amp_fcasc2_compinload.cir"
#INFILE="three_stage_amp_fcasc2_compinload.cir"
#INFILE="three_stage_standard_dp_1bw.cir"
#INFILE="three_stage_standard_dp.cir"


while read LINE; do
  LINE=$( echo "$LINE" | sed "s/^#.*//" )
  if [[ "$LINE" == "" ]]; then continue; fi

  M1W=$( echo "$LINE" | gawk '{ print $1 }' )
  M1L=$( echo "$LINE" | gawk '{ print $2 }' )
  M2W=$( echo "$LINE" | gawk '{ print $3 }' )
  M2L=$( echo "$LINE" | gawk '{ print $4 }' )
  M3W=$( echo "$LINE" | gawk '{ print $5 }' )
  M3L=$( echo "$LINE" | gawk '{ print $6 }' )
  M4W=$( echo "$LINE" | gawk '{ print $7 }' )
  M4L=$( echo "$LINE" | gawk '{ print $8 }' )
  M3BVAL=$( echo "$LINE" | gawk '{ print $9 }' )
  CINVAL=$( echo "$LINE" | gawk '{ print $10 }' )
  RFBVAL=$( echo "$LINE" | gawk '{ print $11 }' )
  RDETVAL=$( echo "$LINE" | gawk '{ print $12 }' )
  CPARVAL=$( echo "$LINE" | gawk '{ print $13 }' )
  PITCH=$( echo "$LINE" | gawk '{ print $14 }' )
  RUNTIME=$( echo "$LINE" | gawk '{ print $15 }' )
  INKEV=$( echo "$LINE" | gawk '{ print $16 }' )
  CZTSIZE=$( echo "$LINE" | gawk '{ print $17 }' )
  INFILE=$( echo "$LINE" | gawk '{ print $18 }' )

  sed -i -r \
    -e "s/(PARAM.*m1w=).*/\1$M1W/" \
    -e "s/(PARAM.*m1l=).*/\1$M1L/" \
    -e "s/(PARAM.*m2w=).*/\1$M2W/" \
    -e "s/(PARAM.*m2l=).*/\1$M2L/" \
    -e "s/(PARAM.*m3w=).*/\1$M3W/" \
    -e "s/(PARAM.*m3l=).*/\1$M3L/" \
    -e "s/(PARAM.*m4w=).*/\1$M4W/" \
    -e "s/(PARAM.*m4l=).*/\1$M4L/" \
    -e "s/(PARAM.*m3bval=).*/\1$M3BVAL/" \
    -e "s/(PARAM.*cinval=).*/\1$CINVAL/" \
    -e "s/(PARAM.*rfbval=).*/\1$RFBVAL/" \
    -e "s/(PARAM.*rdetval=).*/\1$RDETVAL/" \
    -e "s/(PARAM.*cparval=).*/\1$CPARVAL/" "$INFILE"
  

  ./amp.sh  "$INFILE"  "m1_${M1W}${M1L}_m2_${M2W}${M2L}_m3_${M3W}${M3L}_m4_${M4W}${M4L}_rfb_${RFBVAL}_rdet_${RDETVAL}_cpar_${CPARVAL}_m3b${M3BVAL}" "$PITCH" "$RUNTIME" "$INKEV" "$CZTSIZE"

done < "$WLTABLE"


