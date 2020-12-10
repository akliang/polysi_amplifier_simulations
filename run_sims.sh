#!/bin/bash

#set -o errexit
#set -o nounset
DTAG=$( date +%Y%m%dT%H%M%S )
BASEDIR="$( pwd )"
#SIMDIR="/mnt/SimRAID/Sims2010/framework/spc_testbenches/pmb2016_countrate_paper/simruns/"
#SIMDIR="/mnt/Cloud1/albert_data/spc_testbenches/pmb2016_countrate_paper/simruns/"
#SIMDIR="/mnt/Cloud3/albert_data/spc_testbenches/pmb2016_countrate_paper/simruns/"
#SIMDIR="/mnt/Cloud4/MasdaXcloud/albert_data/spc_testbenches/pmb2016_countrate_paper/simruns/"
#SIMDIR="/mnt/Cloud5/albert_data/spc_testbenches/pmb2016_countrate_paper/simruns/"
SIMDIR="/mnt/Cloud6/albert_data/spc_testbenches/pmb2016_countrate_paper/simruns/"

TQUIET="5.0e-06"
#PDIR="inpulses_20160831_n1000x10"  # this was used for MPH 2018 paper
#PDIR="inpulses_20161021_mono70kev_n1000x10"  # this was used for MPH 2018 paper

#PDIR="inpulses_20181019_120kVp_AED_n1000x10"  # used for SPIE 2019 talk
#PDIR="inpulses_20181212_mono90keV_n1000x10"  # used for SPIE 2019 talk
#PDIR="inpulses_20190124_49kVp_n1000x10"  # used for SPIE 2019 talk
#PDIR="inpulses_20181212_mono30keV_n1000x10"  # used for SPIE 2019 talk

#PDIR="inpulses_20181019_120kVp_nonAED_n1000x10"  # used for SPIE 2019 proceeding
#PDIR="inpulses_20181019_mono68keV_n1000x10"  # used for SPIE 2019 proceeding
#PDIR="inpulses_20190124_49kVp_nonAED_n1000x10"  # used for SPIE 2019 proceeding
#PDIR="inpulses_20190124_mono30keV_n1000x10"  # used for SPIE 2019 proceeding

#PDIR="inpulses_20190522_49kVp_AED_n1000x10_finersteps"  # finer count rate steps near 10-percent DTL
#PDIR="inpulses_20190522_mono33keV_n1000x10_finersteps"  # finer count rate steps near 10-percent DTL
#PDIR="inpulses_20190522_120kVp_AED_n1000x10_finersteps" # finer count rate steps near 10-percent DTL
PDIR="inpulses_20190522_mono69keV_n1000x10_finersteps"  # finer count rate steps near 10-percent DTL

PULSEDIR=$( ls -1d $PDIR/inpulses_{001..010} )  # note: bash-ism

# note: obsolete now that the param files are directly providing detval
#PITCH="250u"
#PITCH="1000u"


INCSUBCKTS=$( ls -1d ./subckts/* | sed -e "s/^/.INCLUDE /" )
HEADERFILE="./header_common.cir"
if [ "$1" == "" ]; then
  echo "No param file specified... using the one defined in the script"
  #PARAMFILE="simplified_noise_framework/one_stage_amp_fcasc2_compinload_params008_1mm_001.txt"

  # set of param files reported in MPH 2018 paper
  #PARAMFILE="simplified_noise_framework/param_files/paperdata_20170320_thermalnoise/C5simruns20161221_FINAL20161221T165736_three_stage_standard_dp_1bw_m1_50u10u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_10MEG_rdet_100MEG_cpar_100f_m3b45_PITCH1000e-6CZT_Gmin_1.250000_Gmax_8.000000.txt"
  #PARAMFILE="simplified_noise_framework/param_files/paperdata_20170320_thermalnoise/C5simruns20161221_FINAL20161221T165859_three_stage_standard_dp_m1_50u10u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_10MEG_rdet_100MEG_cpar_100f_m3b10_PITCH1000e-6CZT_Gmin_1.250000_Gmax_8.000000.txt"
  #PARAMFILE="simplified_noise_framework/param_files/paperdata_20170320_thermalnoise/C5simruns20161221_FINAL20161221T170149_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b35_PITCH1000e-6CZT_Gmin_1.250000_Gmax_8.000000.txt"
  #PARAMFILE="simplified_noise_framework/param_files/paperdata_20170320_thermalnoise/C5simruns20161221_FINAL20161221T170348_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b30_PITCH250e-6CZT_Gmin_1.250000_Gmax_8.000000.txt"

  # param files for 300um and 500um of hypothetical amplifier for SPIE2019 proceeding
  #PARAMFILE="simplified_noise_framework/param_files/paperdata_20190210_330um_30keV_500um_68keV/C4simruns20190208T110255_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b30_PITCH500e-6CZT_Gmin_1.250000_Gmax_8.000000.txt" # note: run with 120 kVp or 68 keV
  #PARAMFILE="simplified_noise_framework/param_files/paperdata_20190226_300um_30keV/C4simruns20190226T105501_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b35_PITCH300e-6CZT_Gmin_1.250000_Gmax_8.000000.txt" # note: run with 49 kVp or 30 keV

  # PMB2019: param files for 330um pitch (500um CZT) and 400um pitch (1000um CZT) with R1 resistor to 2MEG
  #PARAMFILE="simplified_noise_framework/param_files/paperdata_20190529_330um_500umCZT_400um_1000umCZT_R1_2MEG/C6simruns20190528T154959_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_2MEG_cpar_100f_m3b35_PITCH330e-6_CZT500e-6CZT_Gmin_1.250000_Gmax_8.000000.txt"  # note: run with 49 kVp or 33 keV
  PARAMFILE="simplified_noise_framework/param_files/paperdata_20190529_330um_500umCZT_400um_1000umCZT_R1_2MEG/C6simruns20190528T144644_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_2MEG_cpar_100f_m3b30_PITCH400e-6_CZT1000e-6CZT_Gmin_1.250000_Gmax_8.000000.txt"  # note: run with 120 kVp or 69 keV


else
  PARAMFILE="$1"
fi
echo "Param file: $PARAMFILE"
#INFILE="simplified_noise_framework/one_stage_amp_fcasc2_compinload.cir"
#INFILE="simplified_noise_framework/three_stage_amp_fcasc2_compinload.cir"
#INFILE="simplified_noise_framework/three_stage_standard_dp.cir"
#INFILE="simplified_noise_framework/three_stage_standard_dp_1bw.cir"

# try to auto-detect what the infile should be
INFILES="three_stage_amp_fcasc2_compinload three_stage_standard_dp_1bw three_stage_standard_dp"
for IFQ in $INFILES; do
  if [ "$( echo "$PARAMFILE" | grep "$IFQ" )" != "" ]; then
    INFILE=$( echo "$IFQ" | sed -e "s/$/.cir/" )
    INFILE="simplified_noise_framework/$INFILE"
    DIRNAMETMP=$( basename "$PARAMFILE" )
    DIRNAME=$( echo "$DIRNAMETMP" | sed -e "s/\.txt//" )
    break
  fi
done
if [ "$INFILE" == "" ]; then echo "Error!  INFILE not found via auto-detection!"; exit; fi

NODEFILE="simplified_noise_framework/printnodes_common.cir"
INCIR="$( echo -e "\n$INCSUBCKTS" | cat - "$HEADERFILE" "$INFILE" "$NODEFILE" )"
BNAME="$( basename "$INFILE" | cut -d. -f1 )"

# SANITY CHECK
if false; then
  echo "Sanity check before running simulation:"
  echo "Simdir is $SIMDIR"
  while true; do read -rs -n1 KEY; if [[ "$KEY" == "" ]]; then echo -e "\n"; break; else echo "Press ENTER or ctrl-C to continue"; fi; done
  #echo "Pitch is $PITCH"
  #while true; do read -rs -n1 KEY; if [[ "$KEY" == "" ]]; then echo -e "\n"; break; else echo "Press ENTER or ctrl-C to continue"; fi; done
  echo "PDIR is $PDIR"
  SANCH1=$( echo "$PULSEDIR" | head -n 1)
  SANCH2=$( echo "$PULSEDIR" | tail -n 1)
  echo "PULSEDIR ranges from $SANCH1 to $SANCH2"
  while true; do read -rs -n1 KEY; if [[ "$KEY" == "" ]]; then echo -e "\n"; break; else echo "Press ENTER or ctrl-C to continue"; fi; done
  echo "INFILE is $INFILE and"
  echo "PARAM file is $PARAMFILE"
  head -n 1 $PARAMFILE
  while true; do read -rs -n1 KEY; if [[ "$KEY" == "" ]]; then echo -e "\n"; break; else echo "Press ENTER or ctrl-C to continue"; fi; done
fi

if [ "$PARAMFILE" != "" ]; then
#  # quick sanity-check that the param file matches the INFILE
#  STRCHECK=$( echo "$PARAMFILE" | grep "$BNAME" )
#  if [ "$STRCHECK" == "" ]; then
#    echo -e "*** Error!\nINFILE ($INFILE) does not match PARAMFILE ($PARAMFILE)"
#    echo "(Note: this check is not exhaustive and can miss cases where filenames partially match)"
#    exit
#  fi

  echo "Updating settings with $PARAMFILE"
  FSTR=""
  while read LINE; do
    # this line can sed out the keyword without depending on number of columns
    #KWORD=$( echo "$LINE" | sed -r -e "s/.*PARAM\s*([^=]*)=.*/\1/" )

    # current method (simpler)
    # split into tag, keyword, and value
    NLINE=$( echo "$LINE" | sed -e "s/=/ /" )
    TAG=$( echo "$NLINE" | gawk '{ print $1 }' )
    KEY=$( echo "$NLINE" | gawk '{ print $2 }' )
    VAL=$( echo "$NLINE" | gawk '{ print $3 }' )
    #FSTR="${FSTR}_${KEY}_${VAL}"

    # find the TAG and KEY pair in the cir file, and replace the VAL
    FLINE=$( echo "$INCIR" | grep -n "$TAG" | grep "\s$KEY=" )
    if [ "$FLINE" == "" ]; then
      echo "$TAG $KEY $VAL not found... appending it!"
      INCIR=$( echo -e "$INCIR\n$TAG $KEY=$VAL" )
    else
      INCIRTMP=$( echo "$INCIR" | sed -r "s/$TAG\s+$KEY=.*/$TAG $KEY=$VAL/" )
      INCIR=$INCIRTMP
    fi
  done <<< "$( grep -v -e '^\s*#' -e '^$' "$PARAMFILE" )"
fi

# appending Tquiet to the param list
INCIR=$( echo -e "$INCIR\n.PARAM TQUIET=$TQUIET" )


for PD in $PULSEDIR; do
  #BASEF="${SIMDIR}/${DTAG}_${BNAME}_${FSTR}"
  BASEF="${SIMDIR}/${DTAG}_${DIRNAME}"
  [ ! -e "$BASEF" ] && mkdir "$BASEF"
  PDBASE=$( basename "$PD" )
  LAUNCHF="$BASEF/launchtemp_${PDBASE}"
  mkdir "$LAUNCHF"
  ln -s $BASEDIR/subckts $LAUNCHF/
  ln -s $BASEDIR/modelcards.mc $LAUNCHF/
  ln -s $BASEDIR/mcards $LAUNCHF/
  #ln -s $BASEDIR/$PDBASE $LAUNCHF/
  ln -s $BASEDIR/$PDIR $LAUNCHF/
  ln -s $BASEDIR/amp_fcasc2_cutoff.subckt $LAUNCHF/
  ln -s $BASEDIR/amp_fcasc2_fc.subckt $LAUNCHF/



  #for F in $( ls -1d $PD/*.pwl ); do
  for F in $( ls -1d $PDIR/$PDBASE/*${TQUIET}Tquiet*.pwl ); do
    PULSEFILENAME="$( basename "$F" | sed -e "s/\.pwl//" )"
    RUNTIME=$( tail -n 25 "$F" | grep -v '^$' | tail -n 1 | gawk '{ print $1 }' )  # tail last 25 lines, remove empty lines (in case there are any at end of file), then take the time col of last line

    FN="$LAUNCHF/launchtemp_${PULSEFILENAME}.cir"

    echo "$INCIR" | 
      sed -e "s%PWL(FILE=\".*\.pwl\"%PWL(FILE=\"$F\"%g" | 
      sed -e "s/runtime=.*/runtime=$RUNTIME/" | 
      #sed -e "s%detL=.*%detL=$PITCH%" |
      #sed -e "s%detW=.*%detW=$PITCH%" |
      sed -e "s%\.PRINTFILE TRAN FILE=\".*dat\"%.PRINTFILE TRAN FILE=\"${BNAME}_${PULSEFILENAME}.dat\"%" | 
      cat > "$FN"

    #echo -e "#!/bin/bash\n\neldobin $LAUNCHF/launchtemp_${PULSEFILENAME}.cir" > $LAUNCHF/launchme_${PULSEFILENAME}.sh
{
cat <<HEREDOC
#!/bin/bash

eldobin "$LAUNCHF/launchtemp_${PULSEFILENAME}.cir"

echo "Executing rm..."
rm "$LAUNCHF/$( grep PRINTFILE "$LAUNCHF/launchtemp_${PULSEFILENAME}.cir" | grep TRAN | sed -e "s/.*=//" -e 's/"//g' )"

echo "Executing preprocess.m..."
echo "addpath('/mnt/SimRAID/Sims2010/framework/spc_testbenches/pmb2016_countrate_paper');fname='$LAUNCHF/$( grep PRINTFILE "$LAUNCHF/launchtemp_${PULSEFILENAME}.cir" | grep TRAN | sed -e "s/.*=//" -e 's/"//g' )';preprocess" | octave -qH
HEREDOC
} > $LAUNCHF/launchme_${PULSEFILENAME}.sh

    chmod +x $LAUNCHF/launchme_${PULSEFILENAME}.sh
    cat launchme.condor | sed \
       -e "s%Executable\s*=.*%Executable = ./launchme_${PULSEFILENAME}.sh%" \
       -e "s%Log\s*=.*%Log = ./condor_${PULSEFILENAME}.log%" \
       -e "s%output\s*=.*%output = ./condor_${PULSEFILENAME}.output%" \
       -e "s%error\s*=.*%error = ./condor_${PULSEFILENAME}.error%" > $LAUNCHF/launchme_${PULSEFILENAME}.condor
    echo "$LAUNCHF launchme_${PULSEFILENAME}.condor" >> ${DTAG}_run_sim_condor_submit.list
  done  # end for-loop for $F
done  # end for-loop for $PD

if [ -e "${DTAG}_run_sim_condor_submit.list" ]; then
  echo "Submitting jobs to sky_condor_submit..."
  ./simplified_noise_framework/launch_condor_jobs.sh ${DTAG}_run_sim_condor_submit.list
else
  echo "Error... ${DTAG}_run_sim_condor_submit.list not found... doing nothing."
fi



