

function [m2b m4b]=analyze_amplifier(infile,dim,QVgain,resultsdir)

colors={'r','g','b','k','c','m','y'};
colors=repmat(colors,[1 30]);

more off;
[s q]=loadeldobin([infile '.bin']);


%inidx=s.V_XPIXEL_XIN_IDEAL;
%pulseidx=s.V_XPIXEL_XIN_SPIKE;
%outidx=s.V_XPIXEL_XAMP_OUT;
%ampm2bidx=s.V_XPIXEL_XAMP_M2B;
%ampm4bidx=s.V_XPIXEL_XAMP_M4B;
inidx=s.V_XPIXEL_IN_IDEAL;
pulseidx=s.V_XPIXEL_IN_SPIKE;
outidx=s.V_XPIXEL_AMP_OUT;
ampm2bidx=s.V_XPIXEL_AMP_M2B;
ampm4bidx=s.V_XPIXEL_AMP_M4B;
outidxst1=s.V_XPIXEL_AMP_OUTST1;
outidxst2=s.V_XPIXEL_AMP_OUTST2;




delV=[];
Darea=[];
QVgainout=[];

if (dim==1)
  error('Deprecated dimension sweep type.');
elseif (dim==2)


  d=[1 ampm2bidx ampm4bidx];
  q2=doreshape_improved(q,d);

  time=squeeze(q2(:,1,1,1));

  fh=figure('visible','off');
  for F=1:size(q2,3)
    for G=1:size(q2,2)
      %% detect the time window of the first pulse
      pvec_start=find_pulses(q2(:,G,F,inidx));
      if (isnan(pvec_start)); 
        disp(sprintf('Nan detected at F=%d and G=%d, skipping',F,G)); 
        QVgainout(F,G)=NaN;
        delV(F,G)=NaN;
        Darea(F,G)=NaN;
        continue; 
      end


      outvec=squeeze(q2(pvec_start(1):pvec_start(2),G,F,outidx));
      invec=squeeze(q2(pvec_start(1):pvec_start(2),G,F,inidx));
      timevec=squeeze(q2(pvec_start(1):pvec_start(2),G,F,1));
      plot(time(pvec_start(1):pvec_start(2)),outvec,colors{F});
      %plot(time(pvec_start(1):pvec_start(2)),outvec,colors{G});
      hold on



      [QVgainout(F,G) delV(F,G) Darea(F,G)]=anaCurve(timevec,invec,outvec,QVgain);
    end
  end

  scoremat=abs(delV);
  %wfac=0.1;  % 1 unit of Darea is 10% of gain?
  wfac=0.02;  % 1 unit of Darea is 10% of gain?
  scoremat=scoremat+abs(Darea*wfac);


  [c r]=findMinMax(scoremat,'min');

  m2b=q2(1,r,c,ampm2bidx);
  m4b=q2(1,r,c,ampm4bidx);
  plot(time,q2(:,r,c,outidx),'rx');
  hold off



  QVgainout=QVgainout(c,r);
  disp(sprintf('m2b= %.2f  ;  m4b = %.2f  ;  QVgain = %.2e',m2b,m4b,QVgainout));

end




% save the plot
figure(fh);
%title(sprintf('amp out - input was %.2f electrons, targetV was %.2f volts (rx is chosen output, delV=%.2e) - m2b=%.2f  m4b=%.2f',in,targetV,outgain,m2b,m4b));
xlabel('time');
ylabel('volts');
title(sprintf('m2b=%.2f ; m4b=%.2f ; QVgainout=%.2e \n %s',m2b,m4b,QVgainout,resultsdir));
print(fh,sprintf('%s/amp.png',resultsdir));
% save a copy of the data.dat file
%copyfile(infile,[resultsdir '/ampsweep.dat']);
%copyfile([infile '.bin'],[resultsdir '/ampsweep.dat.bin']);
%copyfile([infile '.meta'],[resultsdir '/ampsweep.dat.meta']);

% plot the 3 stages of the selected bias
figure(fh);
clf(fh);
xlabel('time');
ylabel('volts');
% scale the first 2 signals up (so you can see it)
% but first take away baseline so you dont amplify baseline also!
plot(time,(q2(:,r,c,outidxst1)-q2(1,r,c,outidxst1))*100+q2(1,r,c,outidxst1));
hold on
plot(time,(q2(:,r,c,outidxst2)-q2(1,r,c,outidxst2))*10+q2(1,r,c,outidxst2),'g');
plot(time,q2(:,r,c,outidx),'r');
hold off
legend('stage1 x100','stage2 x10','stage3');
title(sprintf('m2b=%.2f ; m4b=%.2f ; QVgainout=%.2e \n %s',m2b,m4b,QVgainout,resultsdir));
print(fh,sprintf('%s/amp_3stages.png',resultsdir));



end %function







function [QVgainout delV Darea]=anaCurve(timevec,invec,outvec,QVgain)
  in=invec(1)-min(invec);  % in coulombs
  in=in/1.609e-19  % in electrons      %targetV=in*QVgain;  % in volts
  %out=outvec(1)-min(outvec);  % in volts
  out=max(outvec)-outvec(1);  % in volts
  targetV=in*QVgain;  % in volts
  delV=(out-targetV)/targetV;  % in percent
  QVgainout=out/in;

  % calculate the "area" away from ideal in the last 1/3 of this signal
  selrange=round(2/3*numel(outvec));
  trange=timevec(end)-timevec(selrange);
  npts=numel(outvec)-selrange;
  %Darea=sum((outvec(selrange:end)-targetV(1)).^2)/trange;  % in units of V^2*t
  Darea=sum((outvec(selrange:end)-outvec(1)).^2)/npts;  % in units of V^2*t
  Darea=Darea/(100e-3)^2;  % normalized to 100mV^2*t

%  % calculate the area "above" baseline (ringing in the bad direction) in the last 1/3 of the signal
%  selrange=round(2/3*numel(outvec));
%  trange=timevec(end)-timevec(selrange);
%  npts=numel(outvec)-selrange;
%  badringidx=find(outvec>outvec(1));
%
%figure
%plot(outvec)
%hold on
%%plot(selrange,outvec(selrange),'go');
%plot(badringidx,outvec(badringidx),'rx');
%hold off
%pause
%
%  Darea=sum(outvec(badringidx).^2)/npts;  % in units of V^2*t
%  Darea=Darea/(100e-3)^2;  % normalized to 100mV^2*t


end


function [idx]=minsort2D(in,numret)
  [vals inds]=sort(abs(in(:)));
  if ( ~exist('numret','var') ); numret='end'; end
  idx=inds(1:numret);
end

function [scoremat]=tallyScore(scoremat,idx,weight)
  smax=numel(idx);
  for F=1:smax
    scoremat(idx(F))=scoremat(idx(F))+(smax-F);
  end
end

function [r c val]=findMinMax(vec2d,type)
  if (type=='min')
    [x c]=min(min(vec2d));
    [val r]=min(vec2d(:,c));
  elseif (type=='max')
    [x c]=max(max(vec2d));
    [val r]=max(vec2d(:,c));
  else
    error('Please specific min or max analysis type');
  end
end



