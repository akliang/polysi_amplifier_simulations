#!/bin/bash

DEBUG=true
# TODO: add gm calc back in

if [ "$1" == "" ]; then
  echo "Please specify an input cir file."
  exit
fi
INFILE="$1"
INFILEBASE=${INFILE%.*}
if [ "$2" != "" ]; then
  RUNTAG="_$2"
fi
if [ "$3" != "" ]; then
  PITCH="$3"
else
  PITCH="1000e-6"
fi
if [ "$4" != "" ]; then
  RUNTIME="$4"
else
  RUNTIME="50u"
fi
if [ "$5" != "" ]; then
  INKEV="$5"
else
  INKEV="70"
fi
if [ "$6" != "" ]; then
  CZTSIZE="$6"
else
  CZTSIZE="500e-6"
fi
RUNTAG="${RUNTAG}_PITCH$3_CZT$6"
# read in the file for eval later, exclude asterisk (commented-out SPICE) lines but preserves *#
INCIR="$( cat header.cir $INFILE | grep -v '^\s*\*[^#\$]' | grep -v -e '\*#GREPDEL' )"

SWEEPALLNODES=true

# derived by plotting McWhorter using plotkf B1-6 tfts and picking reasonable value
#KFN="1e-25"
#KFP="5e-25"
# kf of n355 and p274 using Vds 1 and 5, and Vg 1 3 5
KFN="4.4872e-25"
KFP="7.5739e-25"
COX=$( echo "3.9 8.854e-12 1e-7" | gawk '{ print $1*$2/$3 }' )

DTAG=$( date +%Y%m%dT%H%M%S )
#RESPATH="/mnt/Cloud1/albert_data/spc_testbenches/pmb2016_countrate_paper/simplified_noise_framework/simruns/${DTAG}_${INFILEBASE}${RUNTAG}/"
#RESPATH="/mnt/Cloud4/MasdaXcloud/albert_data/spc_testbenches/pmb2016_countrate_paper/simplified_noise_framework/simruns/${DTAG}_${INFILEBASE}${RUNTAG}/"
#RESPATH="/mnt/Cloud5/albert_data/spc_testbenches/pmb2016_countrate_paper/simplified_noise_framework/simruns/${DTAG}_${INFILEBASE}${RUNTAG}/"
RESPATH="/mnt/Cloud6/albert_data/spc_testbenches/pmb2016_countrate_paper/simplified_noise_framework/simruns/${DTAG}_${INFILEBASE}${RUNTAG}/"
TMPPATH="tmp/$DTAG/"
mkdir -p $RESPATH
mkdir -p $TMPPATH

# copy files over for archiving
cp amp.sh $INFILE analyze_amp3.m $RESPATH
ln -s /mnt/SimRAID/Sims2010/framework/spc_testbenches/spie2016_presentation/simplified_noise_framework/octave_scripts $RESPATH/octave_scripts

#NTFTCARD="n127v1e2"  # version1 cards
#PTFTCARD="p203v1e2"  # version1 cards
NTFTCARD="n355v2e1"
PTFTCARD="p274v2e1"
export NTFTCARD
export PTFTCARD
COPYMC=false
COPYMCSRC="${TMPPATH}/modelcards.mc"

# detector inputs and parameters
#INKEV="70"
COULOMB="6.24e18"  # in electrons/coulomb
AMPOUTLEV="1"      # in volts (not used anymore?)
E0="8.854e-12"
#AMTAG[0]="CZT";  WEFF[0]=10;  THICK[0]="200e-6";  ECAP[0]="10";     DETL[0]=500e-6;  DETW[0]=${DETL[0]};   # CZT
AMTAG[0]="CZT";  WEFF[0]=4.6;  THICK[0]="$CZTSIZE";  ECAP[0]="10.9";     DETL[0]="$PITCH";  DETW[0]=${DETL[0]};   # CZT
#AMTAG[1]="ASE";  WEFF[1]=35;  THICK[1]="1000e-6"; ECAP[1]="6.5";    DETL[1]=500e-6;  DETW[1]=${DETL[1]};   # ASE
#AMTAG[2]="CSI";  WEFF[2]=35;  THICK[2]="2e-6";    ECAP[2]="11.68";  DETL[2]=100e-6;  DETW[2]=${DETL[2]};   # CSI-ASI

{ # this brace is for saving the output to log file
GAINFILE="${RESPATH}/gain"
{
for F in ${!WEFF[*]}; do
  INE0[$F]=$( echo "$INKEV ${WEFF[$F]}" | gawk '{ print $1*1000/$2 }' OFMT='%.0f' )
  echo "MTAG: ${AMTAG[$F]}
WEFF: ${WEFF[$F]}
INE0: ${INE0[$F]}
THICK: ${THICK[$F]}
ECAP: ${ECAP[$F]}
DETLW: ${DETL[$F]}"

  CAP[$F]=$( echo "$E0 ${ECAP[$F]} ${DETL[$F]} ${DETW[$F]} ${THICK[$F]}" | gawk '{ print $1*$2*$3*$4/$5 }' OFMT='%.2e' )
  echo "Cdet: ${CAP[$F]}"

  VIN[$F]=$( echo "${INE0[$F]} $COULOMB ${CAP[$F]}" | gawk '{ print $1/$2/$3 }' OFMT='%.2e' )
  echo "Vin: ${VIN[$F]}"
done
} > ${GAINFILE}


PRINTFILENODES=$( echo -en "\n+" )
PRINTFILENODESTRAN="$PRINTFILENODES"
# construct list of nodes of interest
NODES=$( echo "$INCIR" | grep probe_node | gawk '{ print $1 }' )
ACPROBENODES=$( echo "$INCIR" | grep probe_node | gawk '{ print $2 }' )
PNAC=$( echo "$INCIR" | grep '*#PRINTNODEAC' | gawk '{ print $2 }' )
ACPN=$( echo -e "$ACPROBENODES\n$PNAC" )
DCPROBENODES=$( echo "$INCIR" | grep probe_node | gawk '{ print $3 }' )
PNDC=$( echo "$INCIR" | grep '*#PRINTNODEDC' | gawk '{ print $2 }' )
DCPN=$( echo -e "$DCPROBENODES\n$PNDC" )
GMPN=$( echo "$INCIR" | grep '*#PRINTNODEGM' | gawk '{ print $2 }' )


# process the nodes into their respective necessary formats
for AC in $ACPN; do
  #PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vr(/" -e "s/$/)/"  )"
  #PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vi(/" -e "s/$/)/"  )"
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vm(/" -e "s/$/)/"  )"
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vp(/" -e "s/$/)/"  )"
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vr(/" -e "s/$/)/"  )"
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vi(/" -e "s/$/)/"  )"
  PRINTFILENODESTRAN="$PRINTFILENODESTRAN $( echo -e "$AC" | sed -e "s/^/v(/" -e "s/$/)/"  )"
done
for AC in $DCPN; do
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vm(/" -e "s/$/)/"  )"
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/vr(/" -e "s/$/)/"  )"
done
for AC in $GMPN; do
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/gm(/" -e "s/$/)/"  )"
  PRINTFILENODES="$PRINTFILENODES $( echo -e "$AC" | sed -e "s/^/gds(/" -e "s/$/)/"  )"
  #PRINTFILENODESTRAN="$PRINTFILENODESTRAN $( echo -e "$AC" | sed -e "s/^/gm(/" -e "s/$/)/"  )"
  #PRINTFILENODESTRAN="$PRINTFILENODESTRAN $( echo -e "$AC" | sed -e "s/^/gds(/" -e "s/$/)/"  )"
done
# find and add the sweep input node, construct SWEEPNODES list
SWEEPNODES="ISWEEP
$ACPROBENODES
TRAN"


for ARRIDX in ${!AMTAG[*]}; do
 MTAG=${AMTAG[$ARRIDX]}
 DETCAP=${CAP[$ARRIDX]}
 EINJ=${INE0[$ARRIDX]}
 VINJ=${VIN[$ARRIDX]}
 GPATH="${RESPATH}/${MTAG}"
 mkdir -p $GPATH

 for ACNODE in $SWEEPNODES; do  # sweep in twice to get bias settings first, then noise bode sweep second

  # PBLOCK needs to start with a newline
  PBLOCK="
  .PARAM m2bval=2
  .PARAM m4bval=4
  "
  SKIPSTEP=""
  SWEEPRUN=true
  SWEEPTAG="_SWEEP"
  
  ACPATH="${GPATH}/${ACNODE}${SWEEPTAG}"
  CIRTAG="run_${ACNODE}"
  DATFILE="${CIRTAG}.dat"
  CIRFILE="${CIRTAG}.cir"
  DEVFILE="${CIRTAG}.dev"
  CHIFILE="${CIRTAG}.chi"
  LOGFILE="${CIRTAG}.log"
  echo -e "\n---------- Currently running: ${CIRTAG} -------------"

  if [ "$ACNODE" == "ISWEEP" ]; then
    RUNTRAN="*"
    RUNAC=""
    CUSTOMSRC="
*.option TUNING=VHIGH
.option EPS=1e-9
.option UNBOUND
.option LVLTIM=2
.OPTION POST=2 PROBE
.option post_double
.option NUMDGT=18

.PARAM injelectrons=$EINJ
.PARAM pdelay=1u
.PARAM prise=20n
.PARAM plen=100n
.PARAM pwait=500u
.PARAM DClow=0
.PARAM DChigh=(injelectrons * 1.6022e-19 )

Iin  0  ampinL  DC=0  AC=DChigh
Visweep isweep 0  0
"
  elif [ "$ACNODE" == "TRAN" ]; then
    RUNTRAN=""
    RUNAC="*"
    CUSTOMSRC="
*.option TUNING=VHIGH
.option EPS=1e-9
.option UNBOUND
.option LVLTIM=2
.OPTION POST=2 PROBE
.option post_double
.option NUMDGT=18

.PARAM injelectrons=$EINJ
.PARAM pdelay=1u
.PARAM prise=20n
.PARAM plen=100n
.PARAM pwait=2000u
.PARAM DClow=0
.PARAM DChigh=(injelectrons * 1.6022e-19 / plen )

*Iin  detin  ampinL  PWL(
Iin  ampinL  detin  PWL(
+ 0              DClow
+ pdelay         DClow
+ (pdelay+prise) (2*DChigh)
+ (pdelay+plen)  DClow
+ pwait          DClow
+ R )
"
  else
    RUNTRAN="*"
    RUNAC=""
    CUSTOMSRC=""
  fi
  # terrible way to substitute all vars in the cir template (uses eval)
  eval "cat <<REPLACEVARS
$INCIR
REPLACEVARS
" > $TMPPATH/$CIRFILE
  # add ACval to the correct node
  if [ "$ACNODE" == "detin" ]; then
    sed -i -e "s/\(.*$ACNODE.*probe_node\)\(.*\)/\1 ACval=$VINJ \2/" $TMPPATH/$CIRFILE
  else
    sed -i -e "s/\(.*$ACNODE.*probe_node\)\(.*\)/\1 ACval=1m \2/" $TMPPATH/$CIRFILE
  fi



  # 2016-06-17 if TRAN, export CIRFILE to a subckt
  if [ "$ACNODE" == "TRAN" ]; then
    echo -e "\n.SUBCKT TRANCIR$DTAG$CLEV vcc gnd ampinref detinref" > $TMPPATH/TRANCIR$DTAG.subckt
    echo "Edetin  ampinL  detin  VCVS ampinref detinref  DSCALE" >> $TMPPATH/TRANCIR$DTAG.subckt
    # strip out the params because those take precendence of the global ones
    cat $INFILE | grep -i -v '\.param' >> $TMPPATH/TRANCIR$DTAG.subckt
    echo ".ENDS TRANCIR$DTAG" >> $TMPPATH/TRANCIR$DTAG.subckt
    ln -s ../$TMPPATH/TRANCIR$DTAG.subckt ./subckts/

    # spawn subckts to perform calibration pulses
    for CLEV in 1 5 10 20 30 40 50 60 69 70 71 80 90 100 110 120 130 140 150 160 170 180 190 200 70000; do
    #for CLEV in 1 2 5 10 20 40 60 65 75 80 150; do
      # figure out how much to change detin pulse by
      DSCALE=$( echo "$INKEV $CLEV" | gawk '{ print $2/$1 }' )
      # instantiate a subckt to simulate the kev pulse
      echo "Xcalib$CLEV vcc gnd ampin detin TRANCIR$DTAG DSCALE=$DSCALE" >> $TMPPATH/$CIRFILE
      # create a make-shift printfile
      echo -e ".PRINTFILE TRAN FILE=Xcalib$CLEV.dat\n+ v(Xcalib$CLEV.detin) v(Xcalib$CLEV.ampin) v(Xcalib$CLEV.out) v(Xcalib$CLEV.Xfcasc1n2) v(Xcalib$CLEV.Xfcasc2n2) v(Xcalib$CLEV.Xfcasc3n2) v(Xcalib$CLEV.Xfcasc1.out) v(Xcalib$CLEV.Xfcasc2.out) v(Xcalib$CLEV.Xfcasc3.out) v(st1m2b) v(st1m3b) v(st1m4b)" >> $TMPPATH/$CIRFILE
    done
    #exit
#  else
#    continue
  fi


  ./massage_circuit.sh ${TMPPATH}/${CIRFILE} ${ACPATH} ./subckts
  if $COPYMC; then
    if [ -e ${COPYMCSRC} ]; then 
     echo "COPYMCSRC exists -- copying $COPYMCSRC to $ACPATH"
     cp -a ${COPYMCSRC} ${ACPATH}/modelcards.mc
    else
     echo "COPYMCSRC does NOT exist -- sending $ACPATH/modelcards.mc to $COPYMCSRC"
     cp -a ${ACPATH}/modelcards.mc ${COPYMCSRC}
    fi
  fi


#  echo "Running Eldo..."
  (
  cd $ACPATH
  # gotta append the subckt INCLUDE at the beginning of the cir file
  # save the cir file first
  CFILE=$( cat $CIRFILE )
  {
  echo -e "\n"  # insert a newline at the beginning of the file since Eldo ignores the first line
  for F in $( ls -1d *.subckt ); do
   echo ".INCLUDE $F"
  done
  echo "$CFILE"
  } > $CIRFILE

#  eldobin "${CIRFILE}" > ${LOGFILE}  2>&1
#  $DEBUG && grep -n -A 2 -i 'error' ${LOGFILE}
#  $DEBUG && grep -n -A 2 -i 'warning' ${LOGFILE}
#  $DEBUG && grep -n -A 2 -i 'note' ${LOGFILE}
  )


 # create the condor shell script to run
 cat "launchme.sh" | sed \
  -e "s/^\s*eldobin.*/eldobin '$CIRFILE'/" \
  -e "s/KFN=.*/KFN='$KFN'/" \
  -e "s/KFP=.*/KFP='$KFP'/" \
  -e "s/COX=.*/COX='$COX'/" \
  -e "s/DETCAP=.*/DETCAP='$DETCAP'/" \
  -e "s/ACNODE=.*/ACNODE='$ACNODE'/" \
  -e "s/CIRFILE=.*/CIRFILE='$CIRFILE'/" \
  -e "s/DEVFILE=.*/DEVFILE='$DEVFILE'/" \
  -e "s/DATFILE=.*/DATFILE='$DATFILE'/" > $ACPATH/launchme.sh
  chmod +x $ACPATH/launchme.sh
  cp launchme.condor $ACPATH

# (
# cd $ACPATH
# SKYTAG="CirSim" sky_condor_submit launchme.condor
# )

  # create a list of jobs to launch in a batch
  echo "$ACPATH launchme.condor" >>  ${DTAG}_skycondorsubmit.list

#  if [ "$ACNODE" == "TRAN" ]; then
#    {
#    ./run_calib_tran.sh $ACPATH $INKEV 1 2 5 10 20 40 60 65 75 80 150
#    } >> ${DTAG}_skycondorsubmit.list
#  fi


 done  # end ACNODE wiggling sweep
done  # end AMTAG sweep

echo "Submitting jobs to sky_condor_submit..."
./launch_condor_jobs.sh ${DTAG}_skycondorsubmit.list


} 2>&1 | tee $RESPATH/runlog

#touch "$RESPATH/done"

