
function output_diagram(infile,resultsdir)


colors={'r','g','b','k','c','m','y'};
colors=repmat(colors,[1 30]);

more off;
set(0,'DefaultTextInterpreter','none');
[s q]=loadeldobin([infile '.bin']);


nodepre='XPIXEL';
outfiletag='outdiag';
if (~isfield(s,['V_' nodepre '_IN_IDEAL']))
  disp('XPIXEL not found, trying XPIXEL2');
  nodepre='XPIXEL2';
  outfiletag='outdiag2pix';
end

inidx=s.(['V_' nodepre '_IN_IDEAL']);
pulseidx=s.(['V_' nodepre '_IN_SPIKE']);
incap=0.1e-12;
ampinidx=s.(['V_' nodepre '_AMP_IN']);
ampinidx2=s.(['V_' nodepre '_AMP_IN2']);
ampoutidx=s.(['V_' nodepre '_AMP_OUT']);
schinidx=s.(['V_' nodepre '_TRIG_IN']);
vthreshidx=s.(['V_' nodepre '_TRIG_VTH']);
schoutidx=s.(['V_' nodepre '_TRIG_OUT']);
msmvphi1idx=s.(['V_' nodepre '_MSMV_PHI1']);
msmvphi2idx=s.(['V_' nodepre '_MSMV_PHI2']);
lfsroutidx=s.(['V_' nodepre '_LFSR_OUT']);
datalineidx=s.(['V_' nodepre '_DATALINE']);
ivccaidx=s.I_RVCCA;
ivccdidx=s.I_RVCCD;
vccdidx=s.V_VCCD;


time=q(:,1);
pvec_start=find_pulses(q(:,inidx));
if (pvec_start==0)  % did not find any pulses, use whole vector
  pvec_start(1)=1;
  pvec_start(2)=numel(time);
end


fh=figure("visible","off");
%fh=figure();

% plot it once to save the raw file in case analysis fails
fh=figure("visible","off");
subplot(9,1,1)
line1=q(:,pulseidx);
v=plotline(time,line1);
ylabel('ispike')
text(v(1),v(3),sprintf('  %.2e',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %.2e',v(4)),'Color','b')
vsave{1}=v;

subplot(9,1,2)
line1=q(:,inidx);
v=plotline(time,line1);
ylabel('vin')
text(v(1),v(3),sprintf('  %.2e',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %.2e',v(4)),'Color','b')
vsave{2}=v;


subplot(9,1,3)
line1=q(:,ampinidx);
line2=q(:,ampinidx2);
v=plotline(time,line1-line1(1)+line2(1),'r');
hold on
v=plotline(time,line2,'g');
hold off
ylabel('amp_in')
text(v(1),v(3),sprintf('  %.2e',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %.2e',v(4)),'Color','b')
vsave{3}=v;


subplot(9,1,4)
line1=q(:,ampoutidx);
line2=q(:,schinidx);
line3=q(:,vthreshidx);
v=plotline(time,line1);
hold on
v=plotline(time,line2,'g');
v=plotline(time,line3,'r');
hold off
ylabel('amp_out')
text(v(1),v(3),sprintf('  %.2e',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %.2e',v(4)),'Color','b')
vsave{4}=v;


subplot(9,1,5)
line1=q(:,schoutidx);
v=plotline(time,line1);
v(3)=0;
v(4)=8;
axis(v);
ylabel('schmitt')
text(v(1),v(3),sprintf('  %d',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %d',v(4)),'Color','b')
vsave{5}=v;


subplot(9,1,6)
line1=q(:,msmvphi1idx);
v=plotline(time,line1,'r');
v(3)=0;
v(4)=8;
axis(v);
hold on
line2=q(:,msmvphi2idx);
v=plotline(time,line2,'g');
ylabel('msmv')
text(v(1),v(3),sprintf('  %d',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %d',v(4)),'Color','b')
vsave{6}=v;


subplot(9,1,7)
line1=q(:,lfsroutidx);
v=plotline(time,line1);
v(3)=0;
v(4)=8;
axis(v);
hold on
line2=q(:,datalineidx);
v=plotline(time,line2,'g');
ylabel('cnt_out')
text(v(1),v(3),sprintf('  %d',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %d',v(4)),'Color','b')
vsave{7}=v;


subplot(9,1,8)
line1=q(:,ivccaidx);
v=plotline(time,line1);
ylabel('ivcca')
text(v(1),v(3),sprintf('  %.2e',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %.2e',v(4)),'Color','b')
vsave{8}=v;


subplot(9,1,9)
line1=q(:,ivccdidx);
v=plotline(time,line1);
ylabel('ivccd')
text(v(1),v(3),sprintf('  %.2e',v(3)),'Color','r')
text(v(1),v(4),sprintf('  %.2e',v(4)),'Color','b')
vsave{9}=v;

% save the master plot
print(fh,sprintf('%s/%s_raw.png',resultsdir,outfiletag));




% now go through the plot and try to append as much info as possible before failing
subplot(9,1,1)
line1=q(:,pulseidx);
v=vsave{1};
% analysis
twidth=findpulsewidth(time,line1);
text(v(2),v(4),sprintf('  %.2fnA\n  %dns',max(line1)/1e-9,twidth/1e-9))
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,2)
line1=q(:,inidx);
v=vsave{2};
% analysis
vdelta=(max(line1(pvec_start(1):pvec_start(2)))-min(line1(pvec_start(1):pvec_start(2))))/incap / 1e-3;  % in mV
text(v(2),(v(3)+v(4))/2,sprintf('  %.2fmV',vdelta))
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,3)
line1=q(:,ampinidx);
line2=q(:,ampinidx2);
v=vsave{3};
% analysis
vdelta=(max(line1(pvec_start(1):pvec_start(2)))-min(line1(pvec_start(1):pvec_start(2)))) / 1e-3;  % in mV
text(v(2),(v(3)+v(4))/2,sprintf('  %.2fmV',vdelta))
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,4)
line1=q(:,ampoutidx);
v=vsave{4};
% analysis
vdelta=(max(line1(pvec_start(1):pvec_start(2)))-min(line1(pvec_start(1):pvec_start(2))));  % in V
text(v(2),(v(3)+v(4))/2,sprintf('  %.2fV',vdelta))
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,5)
line1=q(:,schoutidx);
v=vsave{5};
% analysis
twidth=findpulsewidth(time,line1);
text(v(2),(v(3)+v(4))/2,sprintf('  %.2fus',twidth/1e-6))
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,6)
line1=q(:,msmvphi1idx);
v=vsave{6};
% analysis
twidth1=findpulsewidth(time,line1,'neg')/1e-6;  % in us
twidth2=findpulsewidth(time,line2)/1e-6;  % in us
text(v(2),v(4),sprintf('  phi1 %.1fus\n  phi2 %.1fus',twidth1,twidth2))
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,7)
line1=q(:,lfsroutidx);
v=vsave{7};
% analysis
clk=q(:,msmvphi1idx);
[counter_out]=cntlfsr(clk,line1,mean(q(:,vccdidx)));
out=better_mat2str(counter_out);
text(v(2)/2,(v(3)+v(4))/2,sprintf(' %s',out))
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,8)
line1=q(:,ivccaidx);
v=vsave{8};
% analysis
text(v(2),(v(3)+v(4))/2,sprintf(' %.1fu\n +-%.2f',abs(mean(line1))/1e-6,std(line1)/1e-6));
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));

subplot(9,1,9)
line1=q(:,ivccdidx);
v=vsave{9};
% analysis
text(v(2),(v(3)+v(4))/2,sprintf(' %.1fu\n +-%.1f',abs(mean(line1))/1e-6,std(line1)/1e-6));
print(fh,sprintf('%s/%s_labelled.png',resultsdir,outfiletag));




% check to see if the output of the counter is correct
numbits=9;
tap=5;
counter_init=[1 1 1 1 1 1 1 1 1];
[r r2 truth]=check_counter_output(counter_out,numbits,tap);
if (r==1)
  fh=fopen(sprintf('%s/%s_lfsrsim_OK',resultsdir,outfiletag),'w');
  fprintf(fh,'Detected output: %s\n',better_mat2str(counter_out));
  fclose(fh);
else
  fh=fopen(sprintf('%s/%s_lfsrsim_FAIL',resultsdir,outfiletag),'w');
  fprintf(fh,'Expected output: %s\n',better_mat2str(truth));
  fprintf(fh,'Detected output: %s\n',better_mat2str(counter_out));
  fprintf(fh,'Counter statistics: bits(%d) - tap(%d) - counter_init(%s)',numbits,tap,better_mat2str(counter_init));
  fprintf(fh,'\n');
  fclose(fh);
end
if (r2==1)
  fh=fopen(sprintf('%s/%s_truthtable_OK',resultsdir,outfiletag),'w');
  fclose(fh);
else
  fh=fopen(sprintf('%s/%s_truthtable_FAIL',resultsdir,outfiletag),'w');
  fclose(fh);
end


end  % end of output_diagram function




function [ v ]=plotline(xaxis,yaxis,color)
  if (~exist('color','var')); color='b'; end
  plot(xaxis,yaxis,color)
  set(gca,'ytick',[])
  set(gca,'xtick',[])
  v=axis;
end


function [ twidth ]=findpulsewidth(time,line1,neg)
  if (exist('neg','var'))
    if (strcmp(neg,'neg')==1)
      line1=-line1;
    else
      error('Invalid pos/neg selection in findpulsewidth');
    end
  end

  twidth=(line1>mean(line1));
  twidth=diff(twidth);
  tmp1=find(twidth==1);
  tmp2=find(twidth==-1);
  if ((numel(tmp1)==0) || (numel(tmp2)==0)); 
    twidth=NaN;
  else
    twidth=time(tmp2(1))-time(tmp1(1));
  end
end

function [ t ]=swindow(n,in)
  t=in;
  t_filt=filter(ones([n 1]),1,t);
  t=t_filt(n:end);
end

function [ out ]=cntlfsr(clk,data,vcc)
  t=clk>(vcc/2);
  t2=diff(t);
  t3=find(t2==-1);  % find the falling edge (transition from phi1-high to phi1-low)
  t4=t3-5;  % take the reading 5 points before the edge

  out=data(t4)>(vcc/2);
  out=out';  % makes row-vector
end






function [ r r2 truth ]=check_counter_output(counter_out,numbits,tap)
  % determine how many bits to simulate/check against
  len=numel(counter_out);
  % generate the init sequence by running first 9 bits of output through LFSR (two-way hash like algorithm)
  init=lfsr_sim(numbits,tap,counter_out(1:numbits),numbits);
  % generate the expected outcome
  truth=lfsr_sim(numbits,tap,init,len);

  if (isequal(counter_out,truth))
    r=1;
  else
    r=0;
  end

  % check the counter output againts a full-list truth table
  [a b]=system(sprintf('cat 9bitlfsr_out.txt | grep %s',better_mat2str(counter_out)));
  if (~isempty(b))
    r2=1;
  else
    r2=0;
  end
end


function [ str ]=better_mat2str(mat)
% note: only 2d?
  out=mat2str(mat);  % returns [1,1,1,1,1,0,0,0]
  out=regexprep(out,'\[','');  % clean off the unnecessary symbols
  out=regexprep(out,'\]','');
  out=regexprep(out,',','');
  str=out;
end

