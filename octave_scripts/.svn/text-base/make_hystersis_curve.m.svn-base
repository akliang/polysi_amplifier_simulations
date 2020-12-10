
more off;
colors={'r','g','b','k','c','m','y','rx','gx','bx','kx','cx','mx','yx'};
colors=repmat(colors,[1 30]);


q=load('./data.dat');

inidx=2;
vthreshidx=3;
outidx=4;
rtimeidx=5;
%d=[1 vthreshidx];
sweepparam=rtimeidx;
d=[1 sweepparam];
doreshape;

in=q2(:,1,inidx);
in_pt=floor(size(in)/2);

% find/cut the in curve
in_up=in(1:in_pt);
in_dw=in(in_pt+1:end);

figure
legstr={};
for F=[1:size(q2,2)]
  plot(in_up,q2(1:in_pt,F,outidx),colors{F})
  hold on
  plot(in_dw,q2(in_pt+1:end,F,outidx),colors{F})
  legstr{end+1}=sprintf('Vthresh=%.1e',q2(1,F,sweepparam));
  legstr{end+1}=''; % because of back-forth plotting, there are 2 lines plotted for each Vthresh
end
hold off
legend(legstr)

