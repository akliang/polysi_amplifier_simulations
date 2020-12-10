#!/bin/bash

# crontab: */5 * * * * /home/user/haseldonoise_sleeper_balancer.sh >>/mnt/SimRAID/Sims2010/Skynet/queues/haseldonoise_sleeper_balancer.log
# crontab: */5 * * * * /mnt/SimRAID/Sims2010/framework/spc_testbenches/pmb2016_countrate_paper/haseldonoise_sleeper_balancer.sh >>/mnt/SimRAID/Sims2010/Skynet/queues/haseldonoise_sleeper_balancer.log

set -o errexit

ABSPATH="/home/user"
ABSPATH="/mnt/SimRAID/Sims2010/framework/spc_testbenches/pmb2016_countrate_paper"
DTAG=$( date +%Y%m%dT%H%M%S )
TSTART=$( date +"%s" )
BNAME=$( basename "$0" )

SLEEP_PRIO='\-8999'
SLEEP_JOB="/bin/sleep"

# run xnodestats to refresh lastcql
/home/user/bin/xnodestats > /dev/null

XNCQL="/mnt/SimRAID/opt/tmp/lastcql.out"
LASTCQL="$( grep "HAS_ELDONOISE" $XNCQL )"

# figure out if there are any HAS_ELDONOISE jobs that aren't running
IDLEJOBS=$( echo "$LASTCQL" | grep -v '/bin/sleep' | gawk '$1 == 1' | wc -l )
if [ "$IDLEJOBS" -gt 0 ]; then
  echo "======= $BNAME ($DTAG) begin ======="
  echo "Found $IDLEJOBS jobs idling (non-sleeper, HAS_ELDONOISE tagged)"

  # figure out how mnay running sleeper jobs there are
  SLEEPRUNIDS=$( echo "$LASTCQL" | grep '/bin/sleep' | gawk '$1 == 2' | gawk 'BEGIN { OFS="." } { print $2,$3 }' )
  if [ "$SLEEPRUNIDS" == "" ]; then
    SLEEPRUNNUM=0
  else
    SLEEPRUNNUM=$( echo "$SLEEPRUNIDS" | wc -l )
  fi
  echo "Currently have $SLEEPRUNNUM running sleeper jobs"

  # _hold and _release sleeper jobs, if possible
  if [ "$SLEEPRUNNUM" -eq 0 ]; then
    echo "No sleeper jobs to release... doing nothing."
    HOLDNUM=0
  elif [ "$SLEEPRUNNUM" -ge "$IDLEJOBS" ]; then
    HOLDNUM="$IDLEJOBS"
  elif [ "$SLEEPRUNNUM" -lt "$IDLEJOBS" ]; then
    HOLDNUM="$SLEEPRUNNUM"
  else
    echo "Unknown error!"
    HOLDNUM=0
    exit
  fi

  if [ "$HOLDNUM" -gt 0 ]; then
    echo "Putting $HOLDNUM sleepers on hold..."
    condor_hold $( echo "$SLEEPRUNIDS" | head -n "$HOLDNUM" )
    echo "Waiting 5 seconds to re-queue sleepers..."
    sleep 5
    condor_release $( echo "$SLEEPRUNIDS" | head -n "$HOLDNUM" )
  else
    echo "HOLDNUM is zero!  Exiting..."
    exit
  fi

  TEND=$( date +"%s" )
  TLAP=$( echo $TEND $TSTART | gawk '{ print $1-$2 }' )
  echo "$BNAME done!  ... took $TLAP seconds"
  echo -e "\n\n"

else
  #echo "No idle jobs found... doing nothing."
  sleep 1
fi

# clean-up
#rm $ABSPATH/cirsim_sleepers_condorq.txt $ABSPATH/cirsim_sleepers_condorq_long.txt $ABSPATH/cirsim_sleepers_combined.txt


