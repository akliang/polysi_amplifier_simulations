


addpath('./octave_scripts');
colors={'r','g','b','k','c','m','y'};
colors=repmat(colors,[1 30]);

if (~exist('atype','var'))
  atype='';
end

if (strcmp(atype,'tran') || strcmp(atype,'TRAN'))
in=1e-3;
infile='./amptest.dat';
gainthresh=0;  % amount of voltage drop for a line to be displayed in plot
gainmin=0.5;  % amount of voltage drop for a line to be displayed in plot
gainmax=1.5;  % amount of voltage drop for a line to be displayed in plot

% single stage
m2bidx=14;
m4bidx=15;
outr_idx=11;
outi_idx=0;
%outr_idx=21;
%outi_idx=22;

% three stage
m2bidx=14;
m4bidx=15;
outr_idx=11;
outi_idx=0;
%outr_idx=21;
%outi_idx=22;

q=load(infile);
d=[1 m2bidx m4bidx];
doreshape;

m2b=q2(1,:,1,m2bidx);
m4b=q2(1,1,:,m4bidx);

freq=q2(:,1,1,1);

figure;
maxgain=0;
Fsave=0;
Gsave=0;
for F=1:numel(m2b)
  for G=1:numel(m4b)

    % normalize DC offset
    output=q2(:,F,G,outr_idx);
    output=output-output(1);
    disp(sprintf('output swing: %f',abs(min(output)-output(1))))
    % determine if it is above gainthresh
    if (abs(min(output))>=gainthresh)
      plot(freq,output,colors{F})
      hold on
    end
  end
end






else
% single stage
m2bidx=17;
m4bidx=19;
outr_idx=13;
outi_idx=14;
%outr_idx=21;
%outi_idx=22;

% three stage
m2bidx=25;
m4bidx=27;
outr_idx=19;
outi_idx=20;
%outr_idx=21;
%outi_idx=22;
in=1e-3;

addpath('./octave_scripts');
infile='./amptest_ac.dat';
q=load(infile);
d=[1 m2bidx m4bidx];
doreshape;

m2b=q2(1,:,1,m2bidx);
m4b=q2(1,1,:,m4bidx);

freq=q2(:,1,1,1);
gain=[];
phase=[];

maxgain=0;
Fsave=0;
Gsave=0;
for F=1:numel(m2b)
  for G=1:numel(m4b)
    temp=sqrt(q2(:,F,G,outr_idx).^2+q2(:,F,G,outi_idx).^2)/in;
    if (max(temp)>maxgain);
      maxgain=[max(temp) maxgain];
      Fsave=[F Fsave];
      Gsave=[G Gsave];
      if (numel(maxgain)>5)
        maxgain=maxgain(1:5);
        Fsave=Fsave(1:5);
        Gsave=Gsave(1:5);
      end
    end
    gain=[gain temp];
%    temp=atan(q2(:,F,G,outi_idx)./q2(:,F,G,outr_idx))*180/pi; % in degrees
%    phase=[phase temp];
    z=[q2(:,F,G,outr_idx)+q2(:,F,G,outi_idx)*i];
    temp=angle(z)*180/pi;
    phase=[phase temp];

  end
end

gainmin=1e-4;
gainmax=1e6;
% ignore gain below gainmin
gain(gain<gainmin)=NaN;
% add the min-max for phase and gain
phase(end-1,1)=-200;
phase(end,1)=250;
gain(end-1,1)=1e-2;
gain(end,1)=1e5;

figure
[ax,h1,h2]=plotyy(freq,phase,freq,gain,'semilogx','loglog');
set(get(ax(1),'Ylabel'),'String','phase');
set(get(ax(2),'Ylabel'),'String','gain');
xlabel('time');


% plot a horiz line
hold on
plot([freq(1) freq(end)],[1 1])


% calculate the phase margin
for F=1:size(gain,2)
  nowgain=gain(:,F);
  [xx yy]=min(abs(nowgain-1));
  % hack/patch for bandpass double-unity
  gaintmp=nowgain;
  gaintmp(yy)=NaN;
  [xx yy2]=min(abs(gaintmp-1));
  if (freq(yy)<freq(yy2))
    yy=yy2;
  end
  disp(sprintf('Phase margin: %d',phase(yy,F)));
end



end  % end atype if statement
