
%function calc_msmv_width(infile)

%infile='./sweeps_output/outdiag.dag';
%infile='./simruns/msmv03_001/sweeps_output/outdiag.dat';
infile='./simruns/msmv_sfac2_001/sweeps_output/outdiag.dat';
infile='./simruns/msmv_sfac1_001/sweeps_output/outdiag.dat';
addpath('./octave_scripts');

more off;
set(0,'DefaultTextInterpreter','none');
[s q]=loadeldobin([infile '.bin']);

timeidx=s.TIME;
inidx=s.V_XPIXEL_MSMV_IN;
phi1idx=s.V_XPIXEL_MSMV_PHI1;
phi2idx=s.V_XPIXEL_MSMV_PHI2;

time=q(:,timeidx);
phi1=q(:,phi1idx);
phi2=q(:,phi2idx);

% calculate the middle of min-max voltage
vmax=max(phi1);
vmin=min(phi1);
vavg=(vmax+vmin)/2;

% digitally square out the wave
phi1=(phi1>vavg);
phi2=(phi2>vavg);



phi1times=[];
pdiff=diff(phi1);
idx1=find(pdiff==-1);
idx2=find(pdiff==1);
idx=sort([idx1;idx2]);
for F=1:numel(idx)
  if (F==1)
    id2=idx(F);
    phi1times(F)=time(id2)-time(1);
  else
    id2=idx(F);
    id1=idx(F-1);
    phi1times(F)=time(id2)-time(id1);
  end
end
if (phi1(1)==1)
  for F=1:numel(phi1times)
    if (mod(F,2)==1)
      disp(sprintf('phi1 high for %6.2f us',phi1times(F)*1e6));
    else
      disp(sprintf('phi1 low  for %6.2f us',phi1times(F)*1e6));
    end
  end
else
  for F=1:numel(phi1times)
    if (mod(F,2)==1)
      disp(sprintf('phi1 low  for %6.2f us',phi1times(F)*1e6));
    else
      disp(sprintf('phi1 high for %6.2f us',phi1times(F)*1e6));
    end
  end
end
%phi1hi=[]; phi1lo=[];
%if (phi(1)==1)
%  for F=1:numel(phi1times)
%    if (mod(F,2)==1)
%      phi1hi(end+1)=phi1times(F);
%    else
%      phi1lo(end+1)=phi1times(F);
%    end
%  end
%else
%  for F=1:numel(phi1times)
%    if (mod(F,2)==1)
%      phi1lo(end+1)=phi1times(F);
%    else
%      phi1hi(end+1)=phi1times(F);
%    end
%  end
%end


disp('');

phi2times=[];
pdiff=diff(phi2);
idx1=find(pdiff==-1);
idx2=find(pdiff==1);
idx=sort([idx1;idx2]);
for F=1:numel(idx)
  if (F==1)
    id2=idx(F);
    phi2times(F)=time(id2)-time(1);
  else
    id2=idx(F);
    id1=idx(F-1);
    phi2times(F)=time(id2)-time(id1);
  end
end
if (phi2(1)==1)
  for F=1:numel(phi2times)
    if (mod(F,2)==1)
      disp(sprintf('phi2 high for %6.2f us',phi2times(F)*1e6));
    else
      disp(sprintf('phi2 low  for %6.2f us',phi2times(F)*1e6));
    end
  end
else
  for F=1:numel(phi2times)
    if (mod(F,2)==1)
      disp(sprintf('phi2 low  for %6.2f us',phi2times(F)*1e6));
    else
      disp(sprintf('phi2 high for %6.2f us',phi2times(F)*1e6));
    end
  end
end


