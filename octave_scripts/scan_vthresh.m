
function scan_vthresh(infile,pulsedir)
% scan through the data to find range to do finer sweep

if (nargin==1)
  pulsedir='';
end

more off;
[s q]=loadeldobin([infile '.bin']);


inidx=s.V_XPIXEL_IN_IDEAL;
pulseidx=s.V_XPIXEL_IN_SPIKE;
vthreshidx=s.V_XPIXEL_TRIG_VTH;
outidx=s.V_XPIXEL_TRIG_OUT;

d=[1 vthreshidx];
doreshape;

pcnt=[];
for F=[1:size(q2,2)]
  pvec_start=find_pulses(q2(:,F,inidx));

  out=q2(pvec_start(1):pvec_start(2),F,outidx);
  out2=(out>4);
  %out2=(out<4);

  pcnt(F)=scan_pulse(out2,pulsedir);
end

pcnt2=find(pcnt==1);
if ( (numel(pcnt2)==0) && (strcmp(pulsedir,'neg')==0) )
  scan_vthresh(infile,'neg');
else
  vlow=pcnt2(1);
  vhigh=pcnt2(end);

  vlow=q2(1,vlow,vthreshidx);
  vhigh=q2(1,vhigh,vthreshidx);

  disp(sprintf('VLOW=%.2f',vhigh-0.5));
  %disp(sprintf('VHIGH=%.2f',vhigh));
  disp(sprintf('VHIGH=%.2f',vhigh+0.5));
end


end

