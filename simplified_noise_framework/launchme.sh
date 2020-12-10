#!/bin/bash

# this is the script that the condor job calls
# it runs eldo on the created cir file
# and then runs analysis

# NOTE: this file is only a template
# It gets sed'd heavily by amp.sh when the jobs are being created

touch condor_start

{

eldobin amp.cir

DEBUG=true
KFN="4.4872e-25"
KFP="7.5739e-25"
COX="$COX"
DETCAP="$DETCAP"
ACNODE="st1m2b"
TMPPATH="."
CIRFILE="G0.0538326_st1m2b.cir"
DEVFILE="G0.0538326_st1m2b.dev"
ACPATH="."
DATFILE="run_ISWEEP.dat"

  # find the inode (TFTNOISEGATE)
  TFTNOISEGATE=$( grep "${ACNODE}.*TFTNOISEGATE" $TMPPATH/$CIRFILE | sed -e "s/.*TFTNOISEGATE //" )
  TFTNOISEGATE="$ACNODE $TFTNOISEGATE"
  TFTNOISEGATE=${TFTNOISEGATE^^}   # Eldo converts everything to uppercase
  $DEBUG && echo "TFTNOISEGATE: $TFTNOISEGATE"


for TFTNG in $TFTNOISEGATE; do
  ANAINODE=$( echo "$TFTNG" | sed -e "s/\./_/g" )

  # parse DEVFILE to gather necessary parameters for octave analysis
  #TLINE=$( grep " $TFTNG " $ACPATH/$DEVFILE | grep -v ' PWL $' | grep '^[ \t]*X.*\.M' )  # grep for a subckt that uses this node, also check that its the third node (tft gate)
  #$DEBUG && echo "TLINE: $TLINE"
  TLINE=$( grep " $TFTNG " $ACPATH/$DEVFILE | grep -v ' PWL $' | grep '^[ \t]*X.*\.M' | gawk '{ print $1,$3 }' | grep $TFTNG | gawk '{ print $1 }' )  # grep for a subckt that uses this node, also check that its the third node (tft gate)
  $DEBUG && echo "TLINE: $TLINE"
  TLINE=$( grep "^[ \t]*$TLINE " $ACPATH/$DEVFILE )
  $DEBUG && echo "TLINE: $TLINE"
  if [ "$TLINE" == "" ]; then
    echo "$ANAINODE not found in circuit, not valid for noise analysis, but will calculate gain..."
    L=-1
    W=-1
    KF="$KFN"
    if [ "$ANAINODE" == "AMPIN" ]; then
      echo "Exception case: assigning m1b TFT size and calculating noise anyway..."
      #W="50e-6"
      #L="10e-6"
      TLINE="XFCASC1.M1"
      L=$( grep -A 2 "$TLINE" $ACPATH/$DEVFILE | grep '^+L' | sed -e "s/\+L=//" )
      W=$( grep -A 2 "$TLINE" $ACPATH/$DEVFILE | grep '^+W' | sed -e "s/\+W=//" )
      KF="$KFN"
    fi
  else
    L=$( grep -A 2 "$TLINE" $ACPATH/$DEVFILE | grep '^+L' | sed -e "s/\+L=//" )
    W=$( grep -A 2 "$TLINE" $ACPATH/$DEVFILE | grep '^+W' | sed -e "s/\+W=//" )
    TTYPE=$( echo "$TLINE" | gawk '{ print $NF }' | head -c 1 )
    if [ "$TTYPE" == "P" ]; then KF="$KFP"; else KF="$KFN"; fi
  fi

  echo "Running octave..."
  TFTCONST="
    tcon.kf=$KF;
    tcon.cox=$COX;
    tcon.W=$W;
    tcon.L=$L;
    tcon.detcap=$DETCAP;
  "
  $DEBUG && echo "$TFTCONST analyze_amp3('$ACPATH/$DATFILE','$ANAINODE','OUT','',tcon,'');"
  PBLOCK=$( echo "$TFTCONST addpath('../../');addpath('../../octave_scripts');analyze_amp3('$ACPATH/$DATFILE','$ANAINODE','OUT','',tcon,'');" | octave -qH | grep -v "loadeldobin" )
done  # end multi-TFTNOISGATE for loop

echo "Removing dat files: "
ls -1d *.dat
rm *.dat
rm run_TRAN.dat.TRAN

} > launchme.log

touch condor_done

