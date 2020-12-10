
function []=set_vthresh(cirfile,datfile)
  resultsdir=[pwd '/sweeps_output'];
%  mkdir(resultsdir);
  
  [vthresh]=analyze_schmitt(datfile,resultsdir);

  system(sprintf('./cir_sed.sh %s schthreshV %.2f',cirfile,vthresh));

end


