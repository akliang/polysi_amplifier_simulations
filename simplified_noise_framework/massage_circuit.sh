#!/bin/bash


# note: at the bottom, the two functions duplicate_mcards() and generate_rand_mcards()
# might error out in the future since they are HARD CODED to generate 350 TFTs


INFILE=$1
OUTFILE=$( basename $INFILE )
GCNT=1000
PCNT=1000
NCNT=1000
#TGTDIR="./simrun021_golden"
TGTDIR="$2"
SUBCKTSDIR="$3"
#RANDTFTS="$4"

if [ ! -e $TGTDIR ]; then
  echo "Directory $TGTDIR not found... creating"
  mkdir $TGTDIR
else
  echo "Directory exists!  Erroring out"
  exit
fi



find_subckt() {
  local OLINE=""
  while [ $# -gt 0 ]; do
    local SRCFILE="$1"
#    echo "SRCFILE=$SRCFILE"
#    echo "checkfile: $SUBCKTSDIR/$SRCFILE.subckt"
#    [ -e "$SUBCKTSDIR/$SRCFILE.subckt" ] && echo "hi"
    [ -e "$SUBCKTSDIR/$SRCFILE.subckt" ] && break
    OLINE="$OLINE	$1"
#    echo "OLINE=$OLINE"
    shift
  done
  local TGTFILE="$1_$GCNT"
  shift
  OLINE="$OLINE	$TGTFILE	$*"
  echo "$OLINE"
  cat "$SUBCKTSDIR/$SRCFILE.subckt" \
  | sed -r -e "s/(\\.SUBCKT|\\.ENDS)\s+$SRCFILE/\\1 $TGTFILE/g" \
  > "$TGTDIR/$TGTFILE.subckt.tmp"
  GCNT=$(( $GCNT+1 ))
  process_file "$TGTDIR/$TGTFILE.subckt.tmp" "$TGTDIR/$TGTFILE.subckt"
  rm "$TGTDIR/$TGTFILE.subckt.tmp"
}



find_tft() {
  local OLINE=""

  while [ $# -gt 0 ]; do
    if [ "$1" == "ntft" ]; then
      NCNT=$(( $NCNT+1 ))
      TFT="ntft$NCNT"
      break
    fi

    if [ "$1" == "ptft" ]; then
      PCNT=$(( $PCNT+1 ))
      TFT="ptft$PCNT"
      break
    fi
    OLINE="$OLINE       $1"
    shift
  done
  shift
  OLINE="$OLINE $TFT        $*"
  echo "$OLINE"
}


process_file() {
  local INFILE="$1"
  local OFILE="$2"
  #echo -n > "$OFILE"

  local LINE
  while read LINE; do
    if [[ "$LINE" =~ ^\s*[xX] ]]; then
      # detect if the line is a subcircuit instantiation
      find_subckt $LINE >> "$OFILE"
    elif [[ "$LINE" =~ ^\s*[mM] ]]; then
      # detect if the line is a model instantiation
      find_tft $LINE >> "$OFILE"
    else
      # otherwise, just print the line out normally
      echo "$LINE" >> "$OFILE"
    fi
  done < "$INFILE"
}


pickshift() {
  #echo "PS enter: $*" 1>&2
  shift  $(( $1 % ($#-1) ))
  #echo "PS shift: $*" 1>&2
  echo $2
}

duplicate_mcards() {
  echo -e > "$TGTDIR/modelcards.mc"

  for F in $NTFTCARD $PTFTCARD; do
    MCF="$( find mcards/ -name "$F.mc" )" 
    cp "$MCF" $TGTDIR/
    echo ".INCLUDE $F.mc" >> "$TGTDIR/modelcards.mc"
  done

  # add malias for cyclic or random variation
  CNT=1001
  while [[ ($CNT -le $NCNT) || ($CNT -le $PCNT) ]]; do
    NSHIFT=$CNT
    PSHIFT=$CNT
    if $RANDTFTS; then
       NSHIFT=$RANDOM
       PSHIFT=$RANDOM
    fi
    MN=$( pickshift $NSHIFT $NTFTCARD )
    MP=$( pickshift $PSHIFT $PTFTCARD )
    echo ".MALIAS $MN ntft$CNT" >> "$TGTDIR/modelcards.mc"
    echo ".MALIAS $MP ptft$CNT" >> "$TGTDIR/modelcards.mc"
    CNT=$(( $CNT+1 ))
  done
}

process_file $INFILE "$TGTDIR/$OUTFILE"
echo $GCNT


# pick whether to fully-randomize model card, or duplicate golden standard
duplicate_mcards


