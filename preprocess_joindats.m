
%fgroup='./C4simruns/20160902T123010_three_stage_amp_fcasc2_compinload_';
fdirs=dir([fgroup '/launchtemp*']);

for F=1:numel(fdirs)
  ff=dir([fgroup '/' fdirs(F).name '/*.mat']);

  if (numel(ff)==0)
    error('Oops... did you forget to create the .mat files first using preprocess_condor_create.sh?');
    return
  end

  for G=1:numel(ff)
    q=load([fgroup '/' fdirs(F).name '/' ff(G).name]);
    if (G==1)
      plotvec=q.plotvec;
    else
      plotvec=[plotvec ; q.plotvec];
    end
  end
  plotvec=sortrows(plotvec,[1 5]);


  if (F==1)
    alldat=plotvec;
  else
    alldat(:,:,end+1)=plotvec;
  end


end


% average all the runs
alldatavg=mean(alldat,3);
% linearize all the runs (basically, concat the runs into a single vector)
alldatlin=sum(alldat,3);
save([fgroup '/datsave.mat'],'-v7');

