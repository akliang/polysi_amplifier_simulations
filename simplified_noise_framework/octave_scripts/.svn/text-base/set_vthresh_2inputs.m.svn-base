
function []=set_vthresh_2inputs(cirfile,datfile1,datfile2,swflag)
  % datfile1 is the "target" level you WANT to trigger on
  % datfile2 is the reference level you DONT want to trigger on


  resultsdir=[pwd '/sweeps_output'];
%  mkdir(resultsdir);
  
  [vthresh]=analyze_schmitt_2inputs(datfile1,datfile2,resultsdir,swflag);

  system(sprintf('./cir_sed.sh %s schthreshV %.2f',cirfile,vthresh));

end


