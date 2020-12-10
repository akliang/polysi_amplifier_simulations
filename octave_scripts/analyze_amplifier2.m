

function [m2b m4b]=analyze_amplifier2(infile1,infile2,infile3,QVgain,resultsdir)

colors={'r','g','b','k','c','m','y'};
colors=repmat(colors,[1 30]);
more off;

[s q01]=loadeldobin([infile1 '.bin']);
[s q02]=loadeldobin([infile2 '.bin']);
[s q03]=loadeldobin([infile3 '.bin']);


inidx=s.V_XPIXEL_IN_IDEAL;
pulseidx=s.V_XPIXEL_IN_SPIKE;
outidx=s.V_XPIXEL_AMP_OUT;
ampm2bidx=s.V_XPIXEL_AMP_M2B;
ampm4bidx=s.V_XPIXEL_AMP_M4B;
outidxst1=s.V_XPIXEL_AMP_OUTST1;
outidxst2=s.V_XPIXEL_AMP_OUTST2;
ivccaidx=s.I_RVCCA;
igndaidx=s.I_RGNDA;
trigoutidx=s.V_XPIXEL_TRIG_OUT;
trigvthidx=s.V_XPIXEL_TRIG_VTH;

d=[1 ampm2bidx ampm4bidx];
q1=doreshape_improved(q01,d);
q2=doreshape_improved(q02,d);
q3=doreshape_improved(q03,d);
time=squeeze(q1(:,1,1,1));



rsq=[];
delV=[];
QVgainout=[];
asum=[];
Vdrift=[];

fh=figure('visible','off');
for F=1:size(q1,3)
  for G=1:size(q1,2)
    %% detect the time window of the first pulse
    pvec_start=find_pulses(q1(:,G,F,inidx));
    if (isnan(pvec_start)); 
      disp(sprintf('Nan detected at F=%d and G=%d, skipping',F,G)); 
      QVgainout(F,G)=NaN;
      delV(F,G)=NaN;
      Darea(F,G)=NaN;
      continue; 
    end

    timevec=squeeze(q1(pvec_start(1):pvec_start(2),G,F,1));

    outvec{1}=squeeze(q1(pvec_start(1):pvec_start(2),G,F,outidx));
    outvec{2}=squeeze(q2(pvec_start(1):pvec_start(2),G,F,outidx));
    outvec{3}=squeeze(q3(pvec_start(1):pvec_start(2),G,F,outidx));
    invec{1}=squeeze(q1(pvec_start(1):pvec_start(2),G,F,inidx));
    invec{2}=squeeze(q2(pvec_start(1):pvec_start(2),G,F,inidx));
    invec{3}=squeeze(q3(pvec_start(1):pvec_start(2),G,F,inidx));

    % this is assuming the 1000e output is {2}!!
    plot(time(pvec_start(1):pvec_start(2)),outvec{2},colors{F});
    hold on



    [rsq(F,G) delV(F,G) QVgainout(F,G) asum(F,G) Vdrift(F,G)]=anaCurve(timevec,invec,outvec,QVgain);
  end
end

% convert metrics to be "closer to 0 is better"
rsq=rsq-1;


wfac=0.1;
scoremat=abs(delV)*wfac;
wfac=0.1;
scoremat=scoremat+abs(asum*wfac);
wfac=0.25;
scoremat=scoremat+abs(rsq*wfac);
wfac=0.5;
scoremat=scoremat+abs(Vdrift*wfac);


[c r]=findMinMax(scoremat,'min');

m2b=q2(1,r,c,ampm2bidx);
m4b=q2(1,r,c,ampm4bidx);
plot(time,q2(:,r,c,outidx),'rx');
hold off



QVgainout=QVgainout(c,r);
disp(sprintf('m2b= %.2f  ;  m4b = %.2f  ;  QVgain = %.2e ; rsq = %.2e ; asum = %.2e ; Vdrift = %.2e',m2b,m4b,QVgainout,rsq(c,r)+1,asum(c,r),Vdrift(c,r)));






% save the plot
figure(fh);
xlabel('time');
ylabel('volts');
title(sprintf('m2b=%.2f ; m4b=%.2f ; QVgainout=%.2e \n %s',m2b,m4b,QVgainout,resultsdir));
print(fh,sprintf('%s/amp.png',resultsdir));

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


% plot how linear the gain is
figure(fh);
clf(fh);
xlabel('time');
ylabel('volts');
plot(time,q1(:,r,c,outidx),'r');
hold on
plot(time,q2(:,r,c,outidx),'b');
plot(time,q3(:,r,c,outidx),'g');
plot(time,q2(:,r,c,trigoutidx),'kx--');
plot(time,q2(:,r,c,trigvthidx),'ko--');
hold off
legend('750e','1000e','1250e','trig_out','trig_vth');
title(sprintf('gain linearity'));
print(fh,sprintf('%s/amp_linearity.png',resultsdir));


% plot the current consumption
figure(fh);
clf(fh);
xlabel('time');
ylabel('current');
plot(time,q1(:,r,c,ivccaidx),'r');
hold on
plot(time,q2(:,r,c,ivccaidx),'b');
plot(time,q3(:,r,c,ivccaidx),'g');
hold off
legend('750e ivcca','1000e ivcca','1250e ivcca');
title(sprintf('current consumption'));
print(fh,sprintf('%s/amp_current.png',resultsdir));




end %function







function [rsq delV QVgainout asum Vdrift]=anaCurve(timevec,invec,outvec,QVgain)
  for F=1:numel(invec)
    in(F)=invec{F}(1)-min(invec{F});  % in volts
    out(F)=max(outvec{F})-outvec{F}(1);  % in volts
  end

  % linear regression
  p=polyfit(in,out,1);
  % calculate R-squared
  yfit=polyval(p,in);
  yresid=out-yfit;
  SSresid=sum(yresid.^2);
  SStotal=(length(out)-1)*var(out);
  rsq=1-SSresid/SStotal;


  % convert input into electrons, find the 1000e index number
  ine=in/1.609e-19;
  [xx yy]=min(abs(ine-1000));
  targetV=ine(yy)*QVgain;  % expected output in volts
  delV=(out(yy)-targetV)/targetV;  % percentage ratio of out volt versus expected volt
  QVgainout=out(yy)/ine(yy);


%  % calculate the "area" away from ideal in the last 1/3 of this signal
%  selrange=round(2/3*numel(outvec));
%  trange=timevec(end)-timevec(selrange);
%  npts=numel(outvec)-selrange;
%  %Darea=sum((outvec(selrange:end)-targetV(1)).^2)/trange;  % in units of V^2*t
%  Darea=sum((outvec(selrange:end)-outvec(1)).^2)/npts;  % in units of V^2*t
%  Darea=Darea/(100e-3)^2;  % normalized to 100mV^2*t

  % calculate the area "above" baseline (ringing in the bad direction) after the initial pulse crosses baseline
  zcross=find(diff(outvec{yy}>=outvec{yy}(1)));  % >= sets the first point to true as well
  [xx ymaxidx]=max(outvec{yy});  % find the index of the output max (and ignore anything to the left)
  zcrossidx=find(zcross>ymaxidx);
  if (isempty(zcrossidx))
    asum=0;
  else
    zcrossidx=zcross(zcrossidx(1))+1;  % the first index to "return" from above baseline is the end of the main signal (+1 because of diff offset)
    % sum up the area above baseline after zcrossidx
    aidx=find(outvec{yy}(zcrossidx:end)>outvec{yy}(1));
    if (isempty(aidx))
      asum=0;
    else
      asum=sum(    (outvec{yy}(aidx)-outvec{yy}(1)).^2        );
    end
  end


  % score how close it returned to baseline (in percent)
  Vdrift=abs((outvec{yy}(1)-outvec{yy}(end))/outvec{yy}(1));

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



