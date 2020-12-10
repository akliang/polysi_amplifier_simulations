
% input is a simrun directory material (ex: CZT folder)
% TODO
% if indir is empty, try to find the most recent run
% NOTE: currently assuming a 70 kev simulated signal... how to detect exactly what it is supposed to be?

function [Tmat,m2bvals,m4bvals]=compute_noise(indir,rc,doplots)

more off

% octave-control variables
if (~exist('doplots','var'))
  doplots=false;     % false means no plotting, just computing noise values
end
usesubplot=false;  % false means use individual figure windows for each plot
usesubplot=true;  % false means use individual figure windows for each plot


% global variables
addpath('./octave_scripts/');
set(0,'DefaultTextInterpreter','none');  % turn off LaTeX formating


% user-control variables
sumallnoise=true;
detin_dir='detin_SWEEP';
ampin_dir='ampin_SWEEP';
tran_dir='TRAN_SWEEP';
%linearity_dirs='TRAN_SWEEP_*';
linearity_dir='TRAN_SWEEP';
linearity_key='Xcalib';
climlow=-3;
climhigh=0.5;
climlownoise=-2;
climhighnoise=0.5;
climlowSNR=10;
climhighSNR=50;
climlowfreq=3;
climhighfreq=8;
climlowgbp=3;
climhighgbp=8;

% low-gain setting
Gtarget_min=0.5;
% high-gain setting
%Gtarget_min=1.25;
% high-gain setting
Gtarget_min=1.25;
Gtarget_max=8;

FLK_NOISE_ONLY=true

cal_target=10;  % temporary patch to use 10 kev as calibration curve
% what is the simulated input signal?  assuming 70 kev...
siminval=70;
lin_dev=0.9;  % how much the signal is allowed to deviate from linearity
vratio_lim=0.25;    % how much the underswing is allowed to be compared to the signal

%bias_noise=10;    % in mV
bias_noise=0;   % in mV
m4bupclip=6;    % upper limit of m4b for plot clipping
GTflag='T';     % options:  G for using Gmat to calculate SNR and T for using Tmat to calculate SNR


% load the files
Nfiles={};
[xx tmp]=system(sprintf('ls -1d %s/*/scalednoise*.mat | sed -e "s/^/Nfiles{end+1}=''/" -e "s/$/'';/"',indir));  % for some reason double single quote adds a single quote
eval(tmp);
[xx tmp]=system(sprintf('ls -1d %s/%s/gainmap*.mat | sed -e "s/^/Gmat=load(''/" -e "s/$/'');/"',indir,detin_dir));
eval(tmp);
if (~exist('Gmat','var'))
  fid=fopen('adat.txt','a');
  fprintf(fid,'%s\terror\tGmat_not_found\n',indir);
  warning('%s\terror\tGmat_not_found\n',indir);
  fclose(fid);
  return
end
m2bvals=Gmat.m2bvals;
m3bvals=Gmat.m3bvals;
m4bvals=Gmat.m4bvals;
m2b_noise=Gmat.m2b_noise*bias_noise;
m4b_noise=Gmat.m4b_noise*bias_noise;
if (isfield(Gmat,'freq3dbR'))
  FmatR=Gmat.freq3dbR;
end
if (isfield(Gmat,'freq3dbL'))
  FmatL=Gmat.freq3dbL;
end
Gmat=Gmat.gainmax;
[xx tmp]=system(sprintf('ls -1d %s/%s/voutmax*.mat | sed -e "s/^/Tmat=load(''/" -e "s/$/'');/"',indir,tran_dir));
eval(tmp);
if (~exist('Tmat','var'))
  fid=fopen('adat.txt','a');
  fprintf(fid,'%s\terror\tTmat_not_found\n',indir);
  warning('%s\terror\tTmat_not_found\n',indir);
  fclose(fid);
  return
end
vout_base001=Tmat.vout_base001;
vout_base005=Tmat.vout_base005;
vout_tmax=Tmat.vout_tmax;
vout_tmin=Tmat.vout_tmin;
% check the direction of the pulse
% 2016-12-06 POTENTIAL IMPROVEMENT: instead of checking tmin and tmax, instead compare vmin and vmax
vout_tdiff=vout_tmin-vout_tmax;
vout_ratio=abs(Tmat.vout_min./Tmat.vout_max);
if (    sum(sum(vout_tdiff>0))  >  sum(sum(vout_tdiff<0))   )
  disp('Assuming amp-pulse is positive-edge');
  edgedir='pos';
  Tmat=Tmat.vout_max;
else
  disp('Assuming amp-pulse is negative-edge');
  edgedir='neg';
  Tmat=-1*Tmat.vout_min;
  vout_ratio=1./vout_ratio;
end
 
[xx tmp]=system(sprintf('ls -1d %s/%s/allbodes*.mat | sed -e "s/^/Bmat=load(''/" -e "s/$/'');/"',indir,detin_dir));
eval(tmp);
freq=Bmat.freq;
if (isfield(Bmat,'phasesave'));
  PHmat=Bmat.phasesave;
end
Bmat=Bmat.gainsave;
[xx tmp]=system(sprintf('ls -1d %s/%s/rundat*.mat | sed -e "s/^/Rmat=load(''/" -e "s/$/'');/"',indir,tran_dir));
eval(tmp);
s2=Rmat.s2;
Rmat=Rmat.rundat;


% do noise analysis
Nmat=[];
THMmat=[];
FLKmat=[];
for idx=1:numel(Nfiles)
  % if summing all noise files, then need to exclude ampin file (double-counting noise for M1)
  % otherwise, exclude all files except ampin file
  % note: detin and ISWEEP both produce scaled_noise matrix with all 0's, so no need to exclude them
  ampin_found=(numel(strfind(Nfiles{idx},ampin_dir))>0);
  if (  sumallnoise &&  ampin_found ); continue; end
  if ( ~sumallnoise && ~ampin_found ); continue; end

  disp(sprintf('loading %s',Nfiles{idx}));
  Ntmp=load(Nfiles{idx});
  THMtmp=Ntmp.thermal_noise;
  FLKtmp=Ntmp.flicker_noise;
  Ntmp=Ntmp.scaled_noise;
  if (numel(Nmat)==0)
    Nmat=Ntmp;
    THMmat=THMtmp;
    FLKmat=FLKtmp;
    Ndat=zeros([size(Ntmp) numel(Nfiles)]);
    THMdat=zeros([size(Ntmp) numel(Nfiles)]);
    FLKdat=zeros([size(Ntmp) numel(Nfiles)]);
  else
    Nmat=sqrt(Nmat.^2+Ntmp.^2);
    THMmat=sqrt(THMmat.^2+THMtmp.^2);
    FLKmat=sqrt(FLKmat.^2+FLKtmp.^2);
  end
  Ndat(:,:,idx)=Ntmp;
  THMdat(:,:,idx)=THMtmp;
  FLKdat(:,:,idx)=FLKtmp;
end
if FLK_NOISE_ONLY
  disp('NOTE! Only considering flicker noise... replacing Nmat with FLKmat')
  Nmat=FLKmat;
end
STmat=Tmat./Nmat;  % tran SNR
SGmat=Gmat./Nmat;  % bode SNR
% generate additional noise and SNR mat for analysis point picking
Nmat_ana=Nmat;
Nmat_ana=sqrt(Nmat_ana.^2+m2b_noise.^2);
Nmat_ana=sqrt(Nmat_ana.^2+m4b_noise.^2);
if (GTflag=='G')
  Smat_ana=Gmat./Nmat_ana;
else
  Smat_ana=Tmat./Nmat_ana;
end

% clip the data, if requested
if (exist('m4bupclip'))
  disp(sprintf('Clipping m4b to %f',m4bupclip));
  m4bvals=m4bvals(m4bvals<=m4bupclip);
  Gmat=Gmat(:,1:numel(m4bvals));
  Nmat=Nmat(:,1:numel(m4bvals));
  Tmat=Tmat(:,1:numel(m4bvals));
  STmat=STmat(:,1:numel(m4bvals));
  SGmat=SGmat(:,1:numel(m4bvals));
  Smat_ana=Smat_ana(:,1:numel(m4bvals));
  if (exist('FmatR','var'))
    FmatR=FmatR(:,1:numel(m4bvals));
  end
  if (exist('FmatL','var'))
    FmatL=FmatL(:,1:numel(m4bvals));
  end
  if (exist('vout_base001','var'))
    vout_base001=vout_base001(:,1:numel(m4bvals));
  end
  if (exist('vout_base005','var'))
    vout_base005=vout_base005(:,1:numel(m4bvals));
  end
  FLKmat=FLKmat(:,1:numel(m4bvals));
  THMmat=THMmat(:,1:numel(m4bvals));
  vout_ratio=vout_ratio(:,1:numel(m4bvals));
end

% find the best bias point
% find the index points that meet the Gtarget criteria
if (GTflag=='G')
  Amat=Gmat;
else
  Amat=Tmat;
end
Gidx1=(Amat>Gtarget_min);
Gidx2=(Amat<Gtarget_max);
Gidx=(Gidx1 .* Gidx2);  % range where gain falls within range
if (sum(sum(Gidx)) == 0) && (~exist('rc','var'))
  fid=fopen('adat.txt','a');
  fprintf(fid,'%s\terror\tGtarget_not_found\tmin:%e\tmax:%e\n',indir,min(min(Amat)),max(max(Amat)));
  warning('%s\terror\tGtarget_not_found\tmin:%e\tmax:%e\n',indir,min(min(Amat)),max(max(Amat)));
  fclose(fid);
  return
end
% find the index points that meet the linearity requirements
caldirs=dir([indir '/' linearity_dir '/' linearity_key '*.dat.bin']);
if (numel(caldirs)~=0)
  caldat={};
  caldatcf=[];
  for cf=1:numel(caldirs)
    cf_linearity_key=regexpi(caldirs(cf).name,[linearity_key '[0-9]*\.'],'match');
    cf_linearity_key=regexprep(cf_linearity_key,'\.','');
    cf_linearity_key=cf_linearity_key{1};
    caldirsvoutmax=[indir '/' linearity_dir '/' regexprep(caldirs(cf).name,'\.dat\.bin','_voutmax.mat')];
    if (~exist(caldirsvoutmax))
      fprintf(1,'Did not find %s, running analyze_amp3 to generate it\n',caldirsvoutmax);
      analyze_amp3([indir '/' linearity_dir '/' regexprep(caldirs(cf).name,'\.bin','')],'TRAN','','','',cf_linearity_key)
    end
    caldattmp=load(caldirsvoutmax);
    calinval=str2num(regexprep(cf_linearity_key,linearity_key,''));
    if (strcmp(edgedir,'pos'))
      caldat{calinval}=caldattmp.vout_max;
    else
      caldat{calinval}=-1*caldattmp.vout_min;
    end
    caldatcf(end+1)=calinval;
  end

  % find the initial slope from 0 keV to cal_target
  callinfac=caldat{cal_target};
  callinfac=callinfac(1:size(Amat,1),1:size(Amat,2));  % clip the matrix to be the same size as everything else

  % scale the linearity mat from the calib value up to the target simulated value
  callinfac_siminval=callinfac*(siminval/cal_target);

  % linearity factor 1: "large-signal" linearity
  % compare scaled-up 70 keV signal to actual-simulated 70 keV signal
  Lmat1=Amat./callinfac_siminval;

  % linearity factor 2: "small-signal" linearity
  % compare slope from 0-10 keV to slope from 69-71 keV
  callinfac_slope=callinfac./cal_target;
  % find the 2 calinvals that are closest to siminval
  caldatcfcp=caldatcf;
  caldatcfcp(caldatcfcp==siminval)=NaN;  % remove the actual keV inval
  [xx siminval_1]=min(abs(caldatcfcp-siminval));
  caldatcfcp(siminval_1)=NaN;
  [xx siminval_2]=min(abs(caldatcfcp-siminval));
  siminval_1=caldatcf(siminval_1);
  siminval_2=caldatcf(siminval_2);
  fprintf(1,'Getting calibration data from %d and %d keV...\n',siminval_1,siminval_2);
  prevdat=caldat{siminval_1};
  nextdat=caldat{siminval_2};
  Lmat2_tmp=abs(prevdat-nextdat)./abs(siminval_1-siminval_2);
  % truncase Lmat size
  Lmat2_tmp=Lmat2_tmp(1:size(Amat,1),1:size(Amat,2));
  % finally, take the ratio of the two slopes
  Lmat2=Lmat2_tmp./callinfac_slope;

  % linearity factor 3: mV/keV
  Lmat3=Lmat2_tmp*1000;  % times 1000 is because Lmat2_tmp is in volts

  % linearity factor 4: max-deviation between a given range (Razavi textbook)
  calidx1=20;  calidx2=100;
  nowcal1=caldat{calidx1};  nowcal2=caldat{calidx2};
  calslope=(nowcal2-nowcal1)/(calidx2-calidx1);
  Lmat4=zeros([size(nowcal1) 2]);
  for calidx=calidx1:calidx2
    nowcal=caldat{calidx};
    if (numel(nowcal)>0)
      Lmat4(:,:,calidx)=(  nowcal-  (calslope*(calidx-calidx1)+nowcal1)  ) ./ (nowcal2-nowcal1);
      % note: anything/0  =  Inf
      % note: -anything/0 = -Inf
      % note: 0/0 = NaN
    end
  end
  % replace Inf and -Inf with NaN so max() doesn't screw up
  Lmat4(abs(Lmat4)==Inf)=NaN;
  % note: Lmat4 is not sparse (has matrix of 0s wherever there isn't a valid calidx)
  % this shouldn't cause problems bc we're taking max, but in the future, making it sparse might solve some problems
  Lmat4=max(abs(Lmat4),[],3);
  % make Lmat4 the "same direction" as the other 3 Lmat matrices
  Lmat4=1-Lmat4;
  Lmat4(Lmat4<lin_dev)=NaN;



  % which linearity factor to continue with analysis?
  Lmat=Lmat4;
  Lmat=Lmat(1:size(Amat,1),1:size(Amat,2));  % clip the matrix to be the same size as everything else

  % a debug line
  Lmatpre=Lmat.*Gidx; Lmatpre(Lmatpre==0)=NaN; Amatpre=Amat.*Gidx; Amatpre(Amatpre==0)=NaN;

  % filter the linearity results by lin_dev
  Gidx1=Lmat>lin_dev;
  Gidx2=Lmat<=(2-lin_dev);  % e.g., 1.1 if lin_dev=0.9
  Gidx=Gidx.*Gidx1.*Gidx2;



end  % end of numel(caldirs)
if (sum(sum(Gidx)) == 0) && (~exist('rc','var'))
  fid=fopen('adat.txt','a');
  fprintf(fid,'%s\terror\tLinearity_not_found\tcal_target:%d\tsiminval:%d\tlin_dev:%f\tlin_min:%e\tlin_max:%e\n',indir,cal_target,siminval,lin_dev,min(min(Lmatpre)),max(max(Lmatpre)));
  warning('%s\terror\tLinearity_not_found\tcal_target:%d\tsiminval:%d\tlin_dev:%f\tlin_min:%e\tlin_max:%e\n',indir,cal_target,siminval,lin_dev,min(min(Lmatpre)),max(max(Lmatpre)));
  fclose(fid);
  return
end


% apply vout_ratio thresholding
while false;
  if (vratio_lim>1) && (~exist('rc','var'))
    fid=fopen('adat.txt','a');
    tmp=vout_ratio.*Gidx; tmp(tmp==0)=NaN;  % have to remove zeroes or else they show up as the min(min(tmp))
    fprintf(fid,'%s\terror\tVratio_not_found\tvratio_lim:%f\tvratio_min:%f\tvratio_max:%f\n',indir,vratio_lim,min(min(tmp)),max(max(tmp)));
    warning('%s\terror\tVratio_not_found\tvratio_lim:%f\tvratio_min:%f\tvratio_max:%f\n',indir,vratio_lim,min(min(tmp)),max(max(tmp)));
    fclose(fid);
    return
  end

  Gidx1=(vout_ratio<vratio_lim);
  if (sum(sum(Gidx.*Gidx1)) == 0)
    tmp=vout_ratio.*Gidx; tmp(tmp==0)=NaN;  % have to remove zeroes or else they show up as the min(min(tmp))
    warning('%s\terror\tVratio_not_found\tvratio_lim:%f\tvratio_min:%f\tvratio_max:%f\n',indir,vratio_lim,min(min(tmp)),max(max(tmp)));
    warning('Increasing vratio_lim and trying again...');
    vratio_lim=vratio_lim*1.5;
  else
    break;
  end
end
Gidx=Gidx.*Gidx1;

if (GTflag=='G') || (~exist('vout_base001','var'))
  disp('vout_base001 not found')
  vSmat=Smat_ana.*Gidx;
  [r c]=find2d( vSmat,'max');  % find the highest SNR where output voltage (Gmat) is sufficient
else
  disp('Using vout_base001 to compute r c...')
  vSmat=vout_base001.*Gidx;
  %vSmat=vout_base005.*Gidx;
  % having zeros in vSmat throws off the find2d min results
  vSmat(vSmat==0)=NaN;
  [r c]=find2d( vSmat,'min');  % find the fastest return to baseline (note: vSmat is idx numbers, but smallest idx number is also fastest return to baseline)
end
if ((numel(r)==0) || (numel(c)==0)) && (~exist('rc','var'))
  fid=fopen('adat.txt','a');
  fprintf(fid,'%s\terror\tr c not found (general error)\n',indir);
  warning('%s\terror\tr c not found (general error)\n',indir);
  fclose(fid);
  return
end
if (numel(r)>1)
  fprintf(1,'More than 1 r index returned (%d)... using the first one r=%d\n',numel(r),r(1))
  r=r(1);
end
if (numel(c)>1)
  fprintf(1,'More than 1 c index returned (%d)... using the first one c=%d\n',numel(c),c(1))
  c=c(1);
end
if (exist('rc','var') && (numel(rc)==2))
  r=rc(1);
  c=rc(2);
end
m2b=m2bvals(r);
m3b=m3bvals(r);  % WARNING: not currently computing m3b!
m4b=m4bvals(c);


if doplots;
% plot and save files (note: text() function takes in x,y coords which is col,row)
if usesubplot
  figure(1,'Position',[0 0 1800 1100]);
  subplot(4,4,1);
else
  figure(1)
end
imagesc(m4bvals,m2bvals,log10(Gmat)); caxis([climlow climhigh]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('Vout (plotted log10): %fV',Gmat(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');
if usesubplot
  % add the super-title
  text(0,max(m2bvals)+1,sprintf('%s: sumallnoise=%d; r=%d (%0.2fV); c=%d (%0.2fV) m3b=%.2fV',indir,sumallnoise,r,m2b,c,m4b,m3b));
end
disp(sprintf('%s: sumallnoise=%d; r=%d (%0.2fV); c=%d (%0.2fV) m3b=%.2fV',indir,sumallnoise,r,m2b,c,m4b,m3b))
% report the max value in this plot
disp(sprintf('Max value in subplot 1,1: %f\n',max(max(Gmat))));

if usesubplot
  subplot(4,4,2);
else
  figure(2)
end
imagesc(m4bvals,m2bvals,log10(Nmat)); caxis([climlownoise climhighnoise]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('Vrms noise (plotted log10): %fV',Nmat(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');
% report the max value in this plot
disp(sprintf('Max value in subplot 1,2: %f\n',max(max(Nmat))));

if usesubplot
  subplot(4,4,3);
else
  figure(3)
end
imagesc(m4bvals,m2bvals,log10(Tmat)); caxis([climlow climhigh]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('TRAN vout: %f',Tmat(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');
% report the max value in this plot
disp(sprintf('Max value in subplot 1,3: %f\n',max(max(Tmat))));


if usesubplot
  subplot(4,4,4);
else
  figure(4)
end
imagesc(m4bvals,m2bvals,log10(FLKmat)); caxis([climlownoise climhighnoise]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('Flicker noise (plotted log10): %fV',FLKmat(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');

if usesubplot
  subplot(4,4,5);
else
  figure(5)
end
TTT=Gmat./Nmat;
imagesc(m4bvals,m2bvals,TTT); caxis([climlowSNR climhighSNR]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('SNR: %f',TTT(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');
% report the max value in this plot
disp(sprintf('Max value in subplot 2,1: %f\n',max(max(TTT))));


%if (exist('FmatR','var'))
%  if usesubplot
%    subplot(4,4,6);
%  else
%    figure(6)
%  end
%  TTT=log10(FmatR.*Gmat./sqrt(2));
%  imagesc(m4bvals,m2bvals,TTT); caxis([climlowgbp climhighgbp]); text(m4b,m2b,'.'); colorbar;
%  set(gca,'YDir','normal')
%  title(sprintf('Gain-bandwidth product log10'));
%  xlabel('m4b (V)');
%  ylabel('m2b (V)');
%end

if usesubplot
  subplot(4,4,6);
else
  figure(6)
end
imagesc(m4bvals,m2bvals,Lmat); caxis([0.5 2]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('Linearity'));
xlabel('m4b (V)');
ylabel('m2b (V)');



if usesubplot
  subplot(4,4,7);
else
  figure(7)
end
imagesc(m4bvals,m2bvals,STmat); caxis([climlowSNR climhighSNR]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('TRAN SNR: %f',STmat(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');
% report the max value in this plot
disp(sprintf('Max value in subplot 2,3: %f\n',max(max(STmat))));


if usesubplot
  subplot(4,4,8);
else
  figure(8)
end
imagesc(m4bvals,m2bvals,log10(THMmat)); caxis([climlownoise climhighnoise]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('Thermal noise (plotted log10): %fV',THMmat(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');


% generate bode of specific point (both detin and TRAN)
if usesubplot
  subplot(4,4,9);
else
  figure(9)
end
plot(log10(freq),log10(Bmat{r,c}));
v=axis;
v(1)=3;
v(2)=9;
v(3)=-2;
v(4)=1;
%v(4)=1.2;
axis(v);
xlabel('Frequency');
ylabel('log10(Vout)');
title('Vout of detin');
if (exist('FmatL','var'))
  disp('Annotating bode curve...')
  hold on
  tmpidx=find(freq==FmatL(r,c));
  plot(log10(freq(tmpidx)),log10(Bmat{r,c}(tmpidx)),'ro')
  tmpidx=find(freq==FmatR(r,c));
  plot(log10(freq(tmpidx)),log10(Bmat{r,c}(tmpidx)),'ro')
  tmpidx=find(Bmat{r,c}==Gmat(r,c));
  plot(log10(freq(tmpidx)),log10(Bmat{r,c}(tmpidx)),'go')
  hold off
end
if (exist('PHmat','var'))
  disp('Adding phase information and annotating bode curve...');
  phasefac=180;
  phvec=PHmat{r,c}/phasefac;
  hold on
  plot(log10(freq),phvec,'r')
  ylabel('log10(Vout)/pi');
  % find all the points where phase flips signs
  Gtmp=(phvec>0); Gtmp=find(diff(Gtmp)==-1);
  text(log10(freq([Gtmp])),log10(Bmat{r,c}([Gtmp])),'x');
  hold off
end



if usesubplot
  subplot(4,4,10);
else
  figure(10)
end
imagesc(m4bvals,m2bvals,vout_ratio); caxis([0 0.5]); text(m4b,m2b,'.'); colorbar;
set(gca,'YDir','normal')
title(sprintf('Vout Ratio: %f',vout_ratio(r,c)));
xlabel('m4b (V)');
ylabel('m2b (V)');
% report the max value in this plot
disp(sprintf('Max value in subplot 3,2: %f\n',max(max(vout_ratio))));


if usesubplot
  subplot(4,4,11);
else
  figure(11)
end
Tidx=sub2ind(size(Tmat),r,c);
timevec=Rmat{Tidx}(:,s2.TIME);
datvec=Rmat{Tidx}(:,s2.V_OUT);
plot(timevec,datvec);
title(sprintf('TRAN run (Tidx=%d)',Tidx));
v=axis;
v
v2_orig = v(2);
if (exist('vout_base001','var'))
  %v(2)=timevec(vout_base001(r,c))*5; % round to nearest 10
  v(2)=vout_base001(r,c);
else
  v(2)=20e-6;
end
% 2020-01-06
% weird patch to fix v2 in case vout_base001 returns NaN
% i need to find and fix the bug causing vout_base001 to return Nan when the waveform is perfectly fine
if isnan(v(2))
  v(2)=v2_orig;
end
v(3)=0.5;
v(4)=3.5;
v(3)=0;
v(4)=8;
%v(3)=datvec(1)-Gtarget_max;
%v(4)=datvec(1)+Gtarget_max;
v
axis(v);
xlabel('time (s)');
ylabel('Vout');


if usesubplot
  subplot(4,4,12);
else
  figure(12)
end
% make the calibration curve at (r,c)
calib_curve=[];
for F=1:numel(caldat)
  if (numel(caldat{F})~=0)
    calib_curve(end+1,1)=F;
    calib_curve(end,2)=caldat{F}(r,c);
  end
end
plot(calib_curve(:,1),calib_curve(:,2))
hold on
% mark where the current run value is
tmp=find(calib_curve(:,1)==siminval);
plot(calib_curve(tmp,1),calib_curve(tmp,2),'ro')
% draw the straight-diagonal line
tmp=find(calib_curve(:,1)==cal_target);
tmp2=calib_curve(end,1)/cal_target;
plot([0 calib_curve(end,1)],[0 calib_curve(tmp,2)*tmp2],'k')
hold off
title(sprintf('Calibration curve (linearity=%f)',Lmat(r,c)))
xlabel('Input energy (keV)');
ylabel('Output (V)');



if (exist('FmatL','var'))
  if usesubplot
    subplot(4,4,13);
  else
    figure(13)
  end
  imagesc(m4bvals,m2bvals,log10(FmatL)); caxis([climlowfreq climhighfreq]); text(m4b,m2b,'.'); colorbar;
  set(gca,'YDir','normal')
  title(sprintf('3db frequency (FmatL) log10: %f',FmatL(r,c)));
  xlabel('m4b (V)');
  ylabel('m2b (V)');
  disp(sprintf('Max value in subplot 4,1: %f\n',max(max(FmatL))));
end


if (exist('FmatR','var'))
  if usesubplot
    subplot(4,4,14);
  else
    figure(14)
  end
  imagesc(m4bvals,m2bvals,log10(FmatR)); caxis([climlowfreq climhighfreq]); text(m4b,m2b,'.'); colorbar;
  set(gca,'YDir','normal')
  title(sprintf('3db frequency (FmatR) log10: %f',FmatR(r,c)));
  xlabel('m4b (V)');
  ylabel('m2b (V)');
  disp(sprintf('Max value in subplot 4,2: %f\n',max(max(FmatR))));
end


if (exist('vout_base001','var'))
  if usesubplot
    subplot(4,4,15);
  else
    figure(15)
  end
  %imagesc(m4bvals,m2bvals,vout_base001); caxis([1e-6 10e-6]); text(m4b,m2b,'.'); colorbar;
  imagesc(m4bvals,m2bvals,vout_base001);  text(m4b,m2b,'.'); colorbar;
  set(gca,'YDir','normal')
  title(sprintf('1-percent return to baseline (vout_base001): %e',vout_base001(r,c)));
  xlabel('m4b (V)');
  ylabel('m2b (V)');
  disp(sprintf('Min value in subplot 4,3: %e\n',min(min(vout_base001))));
end


if (exist('vout_base005','var'))
  if usesubplot
    subplot(4,4,16);
  else
    figure(16)
  end
  %imagesc(m4bvals,m2bvals,vout_base005); caxis([1e-6 10e-6]); text(m4b,m2b,'.'); colorbar;
  imagesc(m4bvals,m2bvals,vout_base005);  text(m4b,m2b,'.'); colorbar;
  set(gca,'YDir','normal')
  title(sprintf('5-percent return to baseline (vout_base005): %e',vout_base005(r,c)));
  xlabel('m4b (V)');
  ylabel('m2b (V)');
  disp(sprintf('Min value in subplot 4,4: %e\n',min(min(vout_base005))));
end



end  % end doplots if loop

% report the noise statistics for the chosen bias point
fprintf(1,'chosen point: m2b = %f (%d) ; m4b = %f (%d)\n',m2bvals(r),r,m4bvals(c),c);
tftnoisevals='';
for idx=1:numel(Nfiles)
  [resdir fname ext]=fileparts(Nfiles{idx});
  if (idx==1)
    fprintf(1,'Directory: %s\n',resdir);
    fprintf(1,'%-30s\tscaled_noise(V)\tthm_noise(V)\tflk_noise(V)\n','Node');
  end
  fprintf(1,'%-30s\t%e\t%e\t%e\n',fname,Ndat(r,c,idx),THMdat(r,c,idx),FLKdat(r,c,idx))
  tftnoisevals.(regexprep(fname,'-',''))=Ndat(r,c,idx);
end

% write results into a file
if (exist('FmatR','var'))
  fmatBWR=FmatR(r,c);
else
  fmatBWR=0;
end
if (exist('FmatL','var'))
  fmatBWL=FmatL(r,c);
else
  fmatBWL=0;
end
if (exist('vout_tmax','var'))
  tmax=vout_tmax(r,c);
else
  tmax=0;
end
if (exist('vout_base001','var'))
  base001=vout_base001(r,c);
else
  base001=0;
end
if (exist('vout_base005','var'))
  base005=vout_base005(r,c);
else
  base005=0;
end
if (exist('Lmat1','var'))
  Lval1=Lmat1(r,c);
else
  Lval1=0;
end
if (exist('Lmat2','var'))
  Lval2=Lmat2(r,c);
else
  Lval2=0;
end
if (exist('Lmat3','var'))
  Lval3=Lmat3(r,c);
else
  Lval3=0;
end
if (exist('Lmat4','var'))
  Lval4=Lmat4(r,c);
else
  Lval4=0;
end
fid=fopen('adat.txt','a');
if (isfield(tftnoisevals,'scalednoiseXFCASC1_N2OUT'))
  xf1n2out='scalednoiseXFCASC1_N2OUT';
else
  xf1n2out='scalednoiseXFCASC1N2OUT';
end
datstr=sprintf('%s\t%d\t%d\t%0.1f\t%0.1f\t%0.2f\t%0.3f\t%0.3f\t%0.2f\t%e\t%e\t%e\t%e\t%.0f\t%.0f\t%e\t%e\t%e\t%0.5f\t%0.5f\t%0.2f\t%0.5f\t%0.5f\n',indir,r,c,m2b,m3b,m4b,Amat(r,c),Nmat(r,c),Amat(r,c)/Nmat(r,c),tftnoisevals.(xf1n2out),tftnoisevals.scalednoiseST1M2BOUT, tftnoisevals.scalednoiseST1M3BOUT, tftnoisevals.scalednoiseST1M4BOUT,fmatBWR,fmatBWL,tmax,base001,base005,Lval1,Lval2,Lval3,Lval4,vout_ratio(r,c));
fprintf(fid,'%s',datstr);
fclose(fid);
fprintf(1,'%s',datstr);


% create a params file using the [r c] point found
[xx tranfile]=system(sprintf('ls -1d %s/%s/*.cir | head -n 1 | head -c -1',indir,tran_dir));
S=loadeldobin('',tranfile);
S.m2bval=m2b;
S.m3bval=m3b;
S.m4bval=m4b;
for ID=1:numel(caldat)
  if (~isempty(caldat{ID}))
    S.(sprintf('caldat%d',ID))=caldat{ID}(r,c);
  end
end



%[xx allparams]=system(sprintf('grep "\\.PARAM" %s',tranfile));
param_fname=strrep(indir,'/','');
param_fname=strrep(param_fname,'.','');
param_fname=sprintf('%s_Gmin_%f_Gmax_%f.txt',param_fname,Gtarget_min,Gtarget_max);
fid=fopen(param_fname,'w');
fprintf(fid,'#%s',datstr);
for FN=fieldnames(S)'
  fprintf(fid,'.PARAM %s=%.10g\n',FN{1},S.(FN{1}));
end
fclose(fid);


% save the variable space
%save(sprintf('%s/allvars_computenoise.mat',indir),'-v7');
