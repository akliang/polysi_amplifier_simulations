
function [vthresh]=analyze_schmitt_2inputs(datfile1,datfile2,resultsdir,swflag)



colors={'r','g','b','k','c','m','y'};
colors=repmat(colors,[1 30]);

more off;
[s in1]=loadeldobin([datfile1 '.bin']);
[s in2]=loadeldobin([datfile2 '.bin']);


inidx=s.V_XPIXEL_IN_IDEAL;
pulseidx=s.V_XPIXEL_IN_SPIKE;
vthreshidx=s.V_XPIXEL_TRIG_VTH;
if (swflag==1)
  outidx=s.V_XPIXEL_TRIG_OUT2;
else
  outidx=s.V_XPIXEL_TRIG_OUT;
end


d=[1 vthreshidx];

q=in1;
doreshape;
in1=q2;

q=in2;
doreshape;
in2=q2;


% find the first threshold that triggers 1000e and 900e
% then take the vthresh level in between the two of them
v1000=[];
v900=[];
for F=[1:size(in1,2)]
  pvec_start=find_pulses(in1(:,F,inidx));

  out1=in1(pvec_start(1):pvec_start(2),F,outidx);
  out2=in2(pvec_start(1):pvec_start(2),F,outidx);
  out1=(out1>4);
  out2=(out2>4);

  v1000(F)=scan_pulse(out1);
  v900(F)=scan_pulse(out2);

end


% take the mean of the two, rounded to the nearest hundredth volt
v1000=find(v1000==1);
v900=find(v900==1);
v1000=v1000(end);
v900=v900(end);
v1000idx=v1000;
v900idx=v900;
v1000=q2(1,v1000,vthreshidx)
v900=q2(1,v900,vthreshidx)
vthresh=round((v1000+v900)/2*100)/100;
disp(sprintf('Vthresh for 1000e = %.2f ; Vthresh for 900e = %.2f ; Set Vthresh to %.2f',v1000,v900,vthresh));




%  % save png of output
  fh=figure("visible","off");
  time=in1(pvec_start(1):pvec_start(2),1,1);
  plot(time,in1(pvec_start(1):pvec_start(2),v1000idx,outidx),'r');
  hold on
  plot(time,in1(pvec_start(1):pvec_start(2),v900idx,outidx),'b');
  plot(time,in2(pvec_start(1):pvec_start(2),v1000idx,outidx),'g');
  plot(time,in2(pvec_start(1):pvec_start(2),v900idx,outidx),'k');
  title(sprintf('v1000=%.2f ; v900=%.2f',v1000,v900));
  legend('1000e input at v1000','1000e input at v900','900e input at v1000','900e input at v900');
  xlabel('time');
  ylabel('volts');
  hold off;
  print(fh,sprintf('%s/vthresh_900e_1000e.png',resultsdir));



%  fh=figure("visible","off");
%  plot(in1(pvec_start(1):pvec_start(2),1,1),in1(pvec_start(1):pvec_start(2),Fsave,outidx),'r');
%  hold on
%  plot(in2(:,1,1),in2(:,Fsave,outidx),'b');
%  hold off
%  legend('1000e','900e');
%  xlabel('time');ylabel('volts');title(sprintf('Comparison of selected 1000e and 900e response - Vthresh=%.2f',vthresh));
%  print(fh,sprintf('%s/vthresh_1000e_900e_comp.png',resultsdir));


end



