
function []=set_amp_bias(cirfile,datfile1,datfile2,datfile3,QVgain)
  resultsdir=[pwd '/sweeps_output'];

  %QVgain=1.5e-3;
  [m2b m4b]=analyze_amplifier2(datfile1,datfile2,datfile3,QVgain,resultsdir);

  system(sprintf('./cir_sed.sh %s ampDCm2b %.2f',cirfile,m2b));
  system(sprintf('./cir_sed.sh %s ampDCm4b %.2f',cirfile,m4b));

end

