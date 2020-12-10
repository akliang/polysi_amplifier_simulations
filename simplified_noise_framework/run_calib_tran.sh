#!/bin/bash

# because this file outputs directly to a condor skysubmit list, any rogue error outputs can pollute the skycondor
set -o errexit

INDIR="$1"
#FNAME=$( basename "$INDIR" )
#FPATH=$( dirname  "$INDIR" )
# note: more intelligent way to find the cir file?  this will break if there is more than 1 cir file
#CIRFILE=$( ls -1d "${INDIR}/*.cir" )  # this doesn't work... why?
CIRFULL=$( find $INDIR -name '*.cir' )
CIRFILE=$( basename "$CIRFULL" )
INVAL="$2"

shift 2
while [ $# -gt 0 ]; do
  CALVAL="$1"
  NEWDIR="${INDIR}_${CALVAL}"

  # copy INDIR to the new directory
  cp -a "$INDIR" "$NEWDIR"

  # find the injelectrons value
  INJVAL=$( grep "\.PARAM\s*injelectrons" "$CIRFULL" | sed -e "s/.*injelectrons=\([0-9]*\).*/\1/" )

  # scale the CALVAL with INVAL
  RVAL=$( echo "$CALVAL $INVAL" | gawk '{ print $1/$2 }' )
  NEWINJVAL=$( echo "$INJVAL $RVAL" | gawk '{ print $1*$2 }' )

  # replace injelectrons in the new CALVAL folder
  sed -i -e "s/\(\.PARAM\s*injelectrons=\).*/\1$NEWINJVAL/" "${NEWDIR}/${CIRFILE}"

  # echo the condor submit line
  # this echo-line is caught by the amp.sh script and put into the condor submit list
  echo "${NEWDIR} launchme.condor"
  

  shift
done




