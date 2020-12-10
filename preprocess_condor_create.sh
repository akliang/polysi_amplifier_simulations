#!/bin/bash

# 2016-10-28 NOTE: this script is obsolete since the preprocess.m analysis is run at the end of the count-rate simulations now
# but, keeping this script around in case re-analysis is needed
# warning: re-analysis is really inefficient because the RAID cannot deliver the data fast enough to condor and disk i/o is the rate-limiting step
# recommend not processing more than 50-80 jobs in parallel

FULLDIRPATH=$( pwd )

INDIR="$1"
if [ "$INDIR" == "" ]; then echo "Error: needs an input file"; exit; fi
INSTR="$( basename $INDIR | sed -e "s/\./_/g" -e "s/_$//" )"
TMPDIR="preprocess_$INSTR"
mkdir "$TMPDIR"



for F in $( find "$INDIR" -name '*.bin' ); do


  FBASE=$( basename "$F" )
  FULLPATH=$( readlink -f $F )
  TMPFILE=$( mktemp preprocess_data.XXXXXX )
  rm "$TMPFILE"  # just want the random string, delete the file that was created

# make the executable
{
cat <<CONDOR
#!/bin/bash

echo "addpath('/mnt/SimRAID/Sims2010/framework/spc_testbenches/pmb2016_countrate_paper');fname='$FULLPATH';preprocess" | /usr/bin/octave -qH
CONDOR
} > $TMPDIR/$TMPFILE.sh
chmod +x $TMPDIR/$TMPFILE.sh

# make the condor job
{
cat <<CONDOR
Executable = $FULLDIRPATH/$TMPDIR/$TMPFILE.sh
Universe = vanilla
Priority = -7777
Log = ./$TMPFILE.condor.log
output = ./$TMPFILE.output.txt
error = ./$TMPFILE.error.txt
environment = "PATH=$ENV(PATH):/home/user/bin"

Requirements = TARGET.FileSystemDomain == "hellboyraids" && \
               TARGET.UidDomain == "cirsims" && \
               TARGET.HAS_ELDONOISE =?= True

Queue

CONDOR
} > $TMPDIR/$TMPFILE.condor


done

# submit to condor
(
cd "$TMPDIR"

for F in $( find . -name '*.condor' ); do
  SKYTAG='CirSim' sky_condor_submit "$F"
  #sky_condor_submit "$F"
done
)

