% new function that integrates entire Bode plot to calculate noise
% Note: most of the functions in this script are not used anymore (mainly used to generate gainmap and scalednoise files), but the algorithms can be useful later

function debug_analyze_amp3(infile,inode,onode,gtarget)
% commented out gm function
addpath('./octave_scripts');

    tcon.kf=4.4872e-25;
    tcon.cox=0.000345306;
    tcon.W=1.000000E-05;
    tcon.L=1.000000E-05;
    tcon.detcap=1.93e-13;
    outfile='';

qcoulomb=1.602e-19;
kb=1.38e-23;
T=298;
xmodelkey='xfcasc';

if (strcmp(inode,'TRAN')==1)
  warning('TRAN detected, executing anaTran');
  infile=regexprep(infile,'.dat','.dat.TRAN');
  if (exist('outfile','var') && regexpi(outfile,'xcalib'))
    infile=regexprep(infile,'\.TRAN','');
  end
  [resdir filename ext]=fileparts(infile);
  [s q]=loadeldobin([ infile '.bin']);
  vout_max=anaTran(s,q,resdir,outfile);
  return
end

[resdir filename ext]=fileparts(infile);
kf=tcon.kf;
cox=tcon.cox;
W=tcon.W;
L=tcon.L;
detcap=tcon.detcap;

[s q]=loadeldobin([ infile '.bin']);


ifreq=s.FREQ;
iin=s.(['VM_' inode]);
iout=s.(['VM_' onode]);
%igm=s.(['GM_' gmtft]);
iphase=s.(['VP_' onode]);

im2bdc=s.(['VR_' 'ST1M2BDC' ]);
im3bdc=s.(['VR_' 'ST1M3BDC' ]);
im4bdc=s.(['VR_' 'ST1M4BDC' ]);
im5bdc=s.(['VR_' 'ST1M5BDC' ]);

% parse inode to figure out which TFT is gm
dothermal=true;
if (regexpi(inode,'st[0-9]*'))
  % note: this assumes "ST1M2B' structure
  stagenum=regexpi(inode,'st[0-9]*','match');
  stagenum=stagenum{1};
  stagenum=regexprep(stagenum,'st','','ignorecase');
  tftnum=regexpi(inode,'m[0-9]*b','match');
  tftnum=tftnum{1};
  tftnum=regexprep(tftnum,'m','','ignorecase');
  tftnum=regexprep(tftnum,'b','','ignorecase');
elseif (regexpi(inode,[xmodelkey '[0-9]*']))
  % now the Xfcasc1.n2 structure (xmodelkey)
  %fprintf(1,'Did not find using st#m#b keyword, trying with %s instead\n',xmodelkey);
  matchstr=[xmodelkey '[0-9]*'];
  stagenum=regexpi(inode,matchstr,'match');
  stagenum=stagenum{1};
  stagenum=regexprep(stagenum,xmodelkey,'','ignorecase');
  % NOTE: hard-coded relationship of Xfcasc to M1
  tftnum='1';
else
  % detin, ampin, etc
  stagenum='0';
  tftnum='0';
end
% put together the node string
gmfield=['GM_' upper(xmodelkey) stagenum '_M' tftnum];
gdsfield=['GDS_' upper(xmodelkey) stagenum '_M' tftnum];
%fprintf(1,'Looking for gm field %s and gds field %s\n',gmfield,gdsfield);
if (isfield(s,gmfield))
  igm=s.(gmfield);
  igds=s.(gdsfield);
end



d=[1 im2bdc im4bdc];
%q2=doreshape_improved(q,d);  % BUGGY????  (NaN for last cols)
q2=doreshape(q,d);
freq=squeeze(q2(:,1,1,ifreq));
%gm=squeeze(q2(1,1,1,igm));
% index for 1e4 to 1e5 freq range
[xx F1e4]=min(abs(freq-1e4));
[xx F1e5]=min(abs(freq-1e5));

m2bvals=squeeze(q2(1,:,1,im2bdc));
m3bvals=squeeze(q2(1,:,1,im3bdc));  if (numel(m3bvals)==1); m3bvals=repmat(m3bvals,size(m2bvals)); end
m4bvals=squeeze(q2(1,1,:,im4bdc));

% calculate the noise, and scale it
%si=(kf*gm^2)/(cox^2*W*L);
sv=(kf)/(cox^2*W*L);
% only do noise analysis if valid W and L are provided
if (W==-1)
  sv=0;
end



gainsave={};
phasesave={};
insave={};
outsave={};
gainmax=[];
freqmax=[];
freq3dbR=[];
freq3dbL=[];
gainmedian=[];
gainmean=[];
scaled_noise=[];
GBWP=[];
thermal_noise=[];
flicker_noise=[];
for F=1:numel(m2bvals)
  for G=1:numel(m4bvals)
    % calculate out mag
    out=squeeze(q2(:,F,G,iout));
    outsave{F,G}=out;
    % calculate in mag
    in=squeeze(q2(:,F,G,iin));
    if (strcmp(inode,'ISWEEP')); in=freq.^-1; end
    if (strcmp(inode,'DETIN'));  in=1; end
    % have to hard-code M1 transistor in vector because using the value at Xfcasc is not accurate since it is a floating voltage source (both ends are connected in series to the circuit)
    if (strmatch('XFCASC',inode));  in=1e-3; end
    insave{F,G}=in;
    % calculate gain as a func of frequency
    gain=out./in;
    % save the gain vector (gainsave) and the max gain (gainmax)
    gainsave{F,G}=gain;
    phasesave{F,G}=squeeze(q2(:,F,G,iphase));
    [gainmax(F,G) gainmaxidx]=max(gain);
    %{
    % use first derivative to find first local-minima coming from the left
    gaindiff=diff(log10(gain));
    s0=gaindiff(1);
    gainmaxidx=NaN;
    for ST=2:numel(gaindiff)
      if (gaindiff(ST)<s0)
        s0=gaindiff(ST);
      else
        gainmaxidx=ST;
        break;
      end
    end
    if isnan(gainmaxidx)
      disp('No first local-minima found... looking for first-deriv=0 instead');
      [xx gainmaxidx]=min(abs(gaindiff));
    end
    % add one back to gainmaxidx because of the diff()
    gainmaxidx=gainmaxidx+1;
    %}
    gainmax(F,G)=gain(gainmaxidx);
    freqmax(F,G)=freq(gainmaxidx);

    % calculate the 3db frequency
    [xx freq3dbidx]=min(abs(   gain(gainmaxidx:end) - (gainmax(F,G)/sqrt(2))  ));
    freq3dbR(F,G)=freq(freq3dbidx+gainmaxidx-1);
    [xx freq3dbidx]=min(abs(   gain(1:gainmaxidx) - (gainmax(F,G)/sqrt(2))  ));
    freq3dbL(F,G)=freq(freq3dbidx);


    gainmedian(F,G)=median(gain(F1e4:F1e5));
    gainmean(F,G)=mean(gain(F1e4:F1e5));

    % calculate the thermal noise magnitude
    if (stagenum ~= '0')
      %svt=4*kb*T*(q2(1,F,G,igm)+q2(1,F,G,igds))/q2(1,F,G,igm)^2;
      svt=8/3*kb*T/q2(1,F,G,igm);
    else
      svt=0;
    end

    [scaled_noise(F,G) GBWP(F,G) thermal_noise(F,G) flicker_noise(F,G)]=conv_bode(sv,svt,freq,gain);  % in volts
    %fprintf(1,'F=%d (%f) ; G=%d (%f); gm=%e ; gds=%e ; svt=%e ; tn=%e ; fn=%e ; sn=%e\n',F,m2bvals(F),G,m4bvals(G),q2(1,F,G,igm),q2(1,F,G,igds),svt,thermal_noise(F,G),flicker_noise(F,G),scaled_noise(F,G));
  end  % end G for loop
end    % end F for loop

% replace gainmax with gainmedian for better search?
%gainmax=gainmean;



% 2015-12-10 legacy "gain searching" variables (possibly unneeded)
  Fbias=1;
  Gbias=1;


% gather the biases (2015-12-10 probably unneeded)
m2b=q2(1,Fbias,Gbias,im2bdc);
m3b=q2(1,Fbias,Gbias,im3bdc);
m4b=q2(1,Fbias,Gbias,im4bdc);
m5b=q2(1,Fbias,Gbias,im5bdc);



% compute gradient in m2b and m4b directions
if (strcmp(inode,'DETIN')==1)
  m2b_delta=m2bvals(2)-m2bvals(1);
  m4b_delta=m4bvals(2)-m4bvals(1);
  m2b_gradient=abs(diff(gainmax,1,1));
  m4b_gradient=abs(diff(gainmax,1,2));
  m2b_noise=m2b_gradient./m2b_delta*1e-3;
  m2b_noise(end+1,:)=m2b_noise(end,:);
  m4b_noise=m4b_gradient./m4b_delta*1e-3;
  m4b_noise(:,end+1)=m4b_noise(:,end);
else
  m2b_noise='';
  m4b_noise='';
end



% save PNGs
if true;
  fh=figure('visible','off');
  % 2d colormap plot (only generate the surf plot if its a bias sweep)
  if (numel(m2bvals)>1)
    % actual bias sweep
    imagesc(m4bvals,m2bvals,gainmax);
    colorbar;
    print(fh,sprintf('%s/%s-%s-2dgainmap.png',resdir,inode,onode));

    % save 3d mesh
    surf(m4bvals,m2bvals,gainmax);
    colorbar;
    print(fh,sprintf('%s/%s-%s-2dgainmap-surf.png',resdir,inode,onode));

    % plot the frequency heatmap
    imagesc(m4bvals,m2bvals,freqmax);
    colorbar;
    print(fh,sprintf('%s/%s-%s-interp-2dgainmap-frequency.png',resdir,inode,onode));

    % plot the gainmap for median gain between 1e4 and 1e5 Hz
    gainmedian(gainmedian>16)=16;
    imagesc(m4bvals,m2bvals,gainmedian);
    colorbar;
    print(fh,sprintf('%s/%s-%s-interp-2dgainmap-1e4to1e5.png',resdir,inode,onode));

    % plot all the bode curves
    for X=1:numel(gainsave)
      loglog(freq,gainsave{X});
      hold on
    end
    hold off
    print(fh,sprintf('%s/%s-%s-allbodes.png',resdir,inode,onode));
  end
end


% save the gainmap
%save(sprintf('%s/gainmap-%s-%s.mat',resdir,inode,onode),'gainmax','m2b_noise','m4b_noise','m2bvals','m3bvals','m4bvals','freq3dbR','freq3dbL','-v7');
% save bode data
%save(sprintf('%s/allbodes-%s-%s.mat',resdir,inode,onode),'freq','gainsave','phasesave','insave','outsave','-v7');
% save scaled_noise mat
%save(sprintf('%s/scalednoise-%s-%s.mat',resdir,inode,onode),'scaled_noise','thermal_noise','flicker_noise','m2bvals','m3bvals','m4bvals','-v7');


if (~strcmp(outfile,''))
  fh=fopen(outfile,'a');
  fprintf(fh,['\nNodes: %s to %s\n', ...
              'Max_gain: %.1f\n',...
              'sv: %0.2e\n', ...
              'GBWP: %0.2e\n', ...
              'sc_noiseuV: %.0f\n', ...
              'qnoise: %.2e\n', ...
              'qenoise: %.0f\n'],inode,onode,gain,sv,GBWP,scaled_noise*1e6,qnoise,qenoise);
  fclose(fh);
end


% 2015-12-10 this output probably not needed anymore since amp.sh doesnt need PBLOCK since we are always sweeping
fprintf(1,['.PARAM m2bval=%f\n', ...
          '.PARAM m3bval=%f\n', ...
          '.PARAM m4bval=%f\n', ...
          '.PARAM m5bval=%f\n'],m2b,m3b,m4b,m5b);



% save all variables for debugging
%save(sprintf('%s/%sallvars.mat',resdir,outfile),'-v7');

end  % end analyze_amp function




function [scaled_noise GBWP thermal_noise flicker_noise]=conv_bode(sv,svt,freq,fcurve)
% step through the freq sweep and scale the noise by the gain

  scaled_noise=[];
  GBWP=[];
  thermal_noise=[];
  flicker_noise=[];
  for fidx=2:numel(freq)
    Fhi=freq(fidx);
    Flo=freq(fidx-1);
    fnoise2=sv*log(Fhi/Flo);  % 2016-02-08 note: this is correct (natural log) because the integral of 1/x is ln(x) 
    tnoise2=svt*(Fhi-Flo);
    gain2=((fcurve(fidx-1)+fcurve(fidx))/2)^2;
    GBWP(end+1)=sqrt(gain2)*(Fhi-Flo);
    flicker_noise(end+1)=gain2*fnoise2;
    thermal_noise(end+1)=gain2*tnoise2;
    %scaled_noise(end+1)=gain2*noise2;
    scaled_noise(end+1)=flicker_noise(end)+thermal_noise(end);
  end
  flicker_noise=sqrt(sum(flicker_noise));
  thermal_noise=sqrt(sum(thermal_noise));
  scaled_noise=sqrt(sum(scaled_noise));
  %scaled_noise=sqrt(scaled_noise);
  GBWP=sum(GBWP)/100e3;  % GBWP at 100kHz

end


function vout_max=anaTran(s,q,resdir,outfile)

  cols={'TIME','V_OUT','V_AMPIN','V_ST1M2B','V_ST1M4B'};
  % find these fieldnames in the s-struct
  % if they dont exist, try to find the outfile-appended version of them
  % if the outfile-appended one exists, then map that column number to the cols name above
  for F=1:numel(cols)
    if (~isfield(s,cols{F}))
      nowcol=regexprep(cols{F},'V_',sprintf('V_%s_',upper(outfile)));
      if (isfield(s,nowcol))
        s.(cols{F})=s.(nowcol);
      else
        error(sprintf('Could not find column named %s or %s in s-struct.',cols{F},nowcol));
      end
    end
  end

  % note: 2016-06-22 - this old method only worked because rundat_cols was put in numerical order
  % it also highly depends on the fieldname order in the s-struct, which is not guaranteed to be sorted in numerical order
  % trying a new method that explicitly maps using cols{}, and also carefully reshaping rundat later on as well

  %snames=fieldnames(s);
  %rundat_cols=[s.TIME s.V_OUT s.V_AMPIN s.V_ST1M2B s.V_ST1M4B];
  %cnt=1;
  %for sidx=1:numel(rundat_cols)
  %  s2.(snames{rundat_cols(sidx)})=cnt;
  %  cnt=cnt+1;
  %end
  cnt=1;
  for F=1:numel(cols)
    s2.(cols{F})=cnt;
    cnt=cnt+1;
  end


  itime=s.TIME;
  im2b=s.V_ST1M2B;
  im4b=s.V_ST1M4B;
  iout=s.V_OUT;
  % custom re-shape the data (LVLTIM=3 causes uneven number of points in TIME column so doreshape doesnt work)
  rundat={};
  m2bvals=[];
  m4bvals=[];
  tranruns=find(q(:,s.TIME)==0);
  for ridx=2:numel(tranruns)
    rbegin=tranruns(ridx-1);
    rend=  tranruns(ridx)-1;
    % 2016-06-22: instead of relying on rundat_cols to select the columns (which depends on rundat_cols being sorted in numerical order in order to match up with s2)
    % going to use another for-loop to explicity build rundat using cols{}
    %rundat{end+1}=q(rbegin:rend,rundat_cols);
    tmp=[];
    for F=1:numel(cols)
      tmp=[tmp q(rbegin:rend,s.(cols{F}))];
    end
    rundat{end+1}=tmp;
    m2bvals(end+1)=q(rbegin,im2b);
    m4bvals(end+1)=q(rbegin,im4b);
  end
  % 2016-06-22: have to update this as well
  %rundat{end+1}=q(rend+1:end,rundat_cols);
  tmp=[];
  for F=1:numel(cols)
    tmp=[tmp q(rend+1:end,s.(cols{F}))];
  end
  rundat{end+1}=tmp;
  m2bvals=unique(m2bvals);
  m4bvals=unique(m4bvals);

  % redefine the index numbers for rundat
  itime=s2.TIME;
  im2b=s2.V_ST1M2B;
  im4b=s2.V_ST1M4B;
  iout=s2.V_OUT;
  vout_max=zeros([numel(m2bvals) numel(m4bvals)]);
  vout_min=zeros(size(vout_max));
  vout_tmax=zeros(size(vout_max));
  vout_tmin=zeros(size(vout_max));
  vout_beg=zeros(size(vout_max));
  vout_end=zeros(size(vout_max));
  vout_end_std=zeros(size(vout_max));
  vout_end_mean=zeros(size(vout_max));
  vout_base001=zeros(size(vout_max));
  vout_base001hi=zeros(size(vout_max));
  vout_base001lo=zeros(size(vout_max));
  vout_base005=zeros(size(vout_max));
  vout_base005hi=zeros(size(vout_max));
  vout_base005lo=zeros(size(vout_max));
  vout_base010=zeros(size(vout_max));
  vout_base010hi=zeros(size(vout_max));
  vout_base010lo=zeros(size(vout_max));
  % walk through the re-shaped data to compute Vmax-V0
  for ridx=1:numel(rundat)
    nowdat=rundat{ridx};
    timevec=nowdat(:,itime);
    Fm2b=find(m2bvals==nowdat(1,im2b));
    Gm4b=find(m4bvals==nowdat(1,im4b));
    [maxval maxidx]=max(nowdat(:,iout));
    [minval minidx]=min(nowdat(:,iout));
    vout_max(Fm2b,Gm4b)=maxval-nowdat(1,iout);
    vout_min(Fm2b,Gm4b)=minval-nowdat(1,iout);
    vout_tmax(Fm2b,Gm4b)=nowdat(maxidx,itime);
    vout_tmin(Fm2b,Gm4b)=nowdat(minidx,itime);
    vout_beg(Fm2b,Gm4b)=nowdat(1,iout);
    vout_end(Fm2b,Gm4b)=nowdat(end,iout);
    vout_end_std(Fm2b,Gm4b)=std(nowdat(end-10:end,iout));
    vout_end_mean(Fm2b,Gm4b)=mean(nowdat(end-10:end,iout));

    % walk from the right and find where the signal is within 1% of max magnitude
    vout_base001(Fm2b,Gm4b)=NaN;
    base001hi=nowdat(1,iout)+vout_max(Fm2b,Gm4b)*0.01;
    base001lo=nowdat(1,iout)-vout_max(Fm2b,Gm4b)*0.01;
    vout_base001hi(Fm2b,Gm4b)=base001hi;
    vout_base001lo(Fm2b,Gm4b)=base001lo;
    for nidx=size(nowdat,1):-1:maxidx
      if (    (nowdat(nidx,iout) <= base001hi) && (nowdat(nidx,iout) >= base001lo)   )
        vout_base001(Fm2b,Gm4b)=timevec(nidx);
      else
        break
      end
    end
    % walk from the right and find where the signal is within 5% of max magnitude
    vout_base005(Fm2b,Gm4b)=NaN;
    base005hi=nowdat(1,iout)+vout_max(Fm2b,Gm4b)*0.05;
    base005lo=nowdat(1,iout)-vout_max(Fm2b,Gm4b)*0.05;
    vout_base005hi(Fm2b,Gm4b)=base005hi;
    vout_base005lo(Fm2b,Gm4b)=base005lo;
    for nidx=size(nowdat,1):-1:maxidx
      if (    (nowdat(nidx,iout) <= base005hi) && (nowdat(nidx,iout) >= base005lo)   )
        vout_base005(Fm2b,Gm4b)=timevec(nidx);
      else
        break
      end
    end
    % walk from the right and find where the signal is within 10% of max magnitude
    vout_base010(Fm2b,Gm4b)=NaN;
    base010hi=nowdat(1,iout)+vout_max(Fm2b,Gm4b)*0.1;
    base010lo=nowdat(1,iout)-vout_max(Fm2b,Gm4b)*0.1;
    vout_base010hi(Fm2b,Gm4b)=base010hi;
    vout_base010lo(Fm2b,Gm4b)=base010lo;
    for nidx=size(nowdat,1):-1:maxidx
      if (    (nowdat(nidx,iout) <= base010hi) && (nowdat(nidx,iout) >= base010lo)   )
        vout_base010(Fm2b,Gm4b)=timevec(nidx);
      else
        break
      end
    end
  end

  % reshape rundat
  rundat2={};
  cnt=1;
  for G=1:numel(m4bvals)
    for F=1:numel(m2bvals)
      rundat2{F,G}=rundat{cnt};
      cnt=cnt+1;
    end
  end
  rundat=rundat2;
  
%  % save the mat file
%  if (exist('outfile','var') && ~strcmp(outfile,''))
%    outfile=[outfile '_'];  % append an underscore
%  end
%  save(sprintf('%s/%svoutmax.mat',resdir,outfile),'m2bvals','m4bvals','vout_max','vout_min','vout_tmax','vout_tmin','vout_beg','vout_end','vout_end_std','vout_end_mean','vout_base001','vout_base001hi','vout_base001lo','vout_base005','vout_base005hi','vout_base005lo','vout_base010','vout_base010hi','vout_base010lo','-v7');
%  save(sprintf('%s/%srundat.mat',resdir,outfile),'m2bvals','m4bvals','rundat','s2','-v7');


end
