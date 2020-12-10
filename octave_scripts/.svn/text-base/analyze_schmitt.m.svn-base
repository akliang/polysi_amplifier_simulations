
function [vthresh]=analyze_schmitt(infile,resultsdir)


more off;
[s q]=loadeldobin([infile '.bin']);


%inidx=s.V_XPIXEL_XIN_IDEAL;
%pulseidx=s.V_XPIXEL_XIN_SPIKE;
%vthreshidx=s.V_XPIXEL_XSCHMITT_THRESH;
%outidx=s.V_XPIXEL_XSCHMITT_OUT;
inidx=s.V_XPIXEL_IN_IDEAL;
pulseidx=s.V_XPIXEL_IN_SPIKE;
vthreshidx=s.V_XPIXEL_TRIG_VTH;
outidx=s.V_XPIXEL_TRIG_OUT;


d=[1 vthreshidx];
doreshape;


% step through each thresh level and find best
hilodelta=[];
switchcnt=[];
vstart=[];
for F=[1:size(q2,2)]
  pvec_start=find_pulses(q2(:,F,inidx));


  out=q2(pvec_start(1):pvec_start(2),F,outidx);
  out2=(out>4);
  hi=max(out);
  lo=min(out);
  hilodelta(F)=abs(hi-lo);

  %swtmp=(out>4);
  %%swtmp=(out<4);
  %switchcnt(F)=sum(abs(diff(swtmp)));

  %vstart(F)=(out(1)<4);
  %%vstart(F)=(out(1)>4);

  pcnt(F)=scan_pulse(out2);
end

%swfilter=(switchcnt==2);
%[xx Fsave]=max(hilodelta);
%[xx Fsave]=max(hilodelta .* swfilter);  % retired/modified on 20130709
% which outputs trigger only twice and start high?
%possvth=swfilter.*vstart;
[xx Fsave]=max(hilodelta .* pcnt);

vthresh=q2(1,Fsave,vthreshidx);



% save png of output
fh=figure("visible","off");
plot(q2(pvec_start(1):pvec_start(2),1,1),squeeze(q2(pvec_start(1):pvec_start(2),:,outidx)));
hold on
plot(q2(:,1,1),q2(:,Fsave,outidx),'rx');
plot(q2(:,1,1),q2(:,Fsave,10),'gx');
title(sprintf('gx = input ; rx = output ; vthresh=%.2f \n %s',vthresh,resultsdir));
xlabel('time');
ylabel('volts');
hold off;
print(fh,sprintf('%s/vthresh.png',resultsdir));

