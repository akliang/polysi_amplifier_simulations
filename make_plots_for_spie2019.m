
function make_paper_plots()
% note: only runs with matlab (only works on hellboy bc of path issues)

global fdata;
global width height;

iptsetpref('ImshowBorder','loose');
iptsetpref('ImshowAxesVisible','on');
close all;



% used for SPIE2019 presentation
fgroupid{1}='Improved-300um-49kVp';
fgroupid{2}='Improved-500um-120kVp';
fgroupid{3}='Improved-300um-30keV';
fgroupid{4}='Improved-500um-68keV';
fgroupc{1}='C4simruns/20190301_300um_49kVp/20190301T110556_C4simruns20190226T105501_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b35_PITCH300e-6CZT_Gmin_1.250000_Gmax_8.000000';
fgroupc{2}='C4simruns/20190210_500um_120kVp/20190210T154735_C4simruns20190208T110255_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b30_PITCH500e-6CZT_Gmin_1.250000_Gmax_8.000000';
fgroupc{3}='C4simruns/20190301_300um_30keV/20190301T110613_C4simruns20190226T105501_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b35_PITCH300e-6CZT_Gmin_1.250000_Gmax_8.000000';
fgroupc{4}='C4simruns/20190210_500um_68keV/20190210T154910_C4simruns20190208T110255_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b30_PITCH500e-6CZT_Gmin_1.250000_Gmax_8.000000';

ngroup{1}='simplified_noise_framework/C4simruns/20190226T105501_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b3.5_PITCH300e-6/CZT';        ngroupr(1)=30; ngroupc(1)=13;
ngroup{2}='simplified_noise_framework/C4simruns/20190208T110255_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b3.0_PITCH500e-6_SELECT/CZT'; ngroupr(2)=34; ngroupc(2)=10;

if (~iscell(fdata))
  % run plot_counts to grab the alldatavg for each one
  % NOTE: this is very dangerous due to variable cross-polluting between scripts
  fdata={};
  for fgroupidx=1:numel(fgroupc)
    fgroup=fgroupc{fgroupidx};
    plot_counts; close all;
    fdata{fgroupidx}=alldatavg;
  end
else
  disp('Found fdata variable, loading that instead...');
end

% pretty plot settings (source: https://dgleich.github.io/hq-matlab-figs/)
width = 4;
height = 4;
alw = 1.5;    % AxesLineWidth
fsz = 72;      % Fontsize
lw = 1;      % LineWidth
msz = 8;       % MarkerSize
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultAxesFontName','Times New Roman')
set(0,'defaultAxesFontSize',fsz);
set(0,'defaultTextFontName','Times New Roman')
set(0,'defaultTextFontSize',fsz);
% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width height]);
set(0,'defaultFigurePosition', [0 0 width height]);
% Set the defaults for saving/printing to a file
set(0,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(0,'defaultFigurePaperUnits','inches'); % This is the default anyway
%defsize = get(gcf, 'PaperSize');
%left = (defsize(1)- width)/2;
%bottom = (defsize(2)- height)/2;
%defsize = [left, bottom, width, height];
defsize = [0 0 width height];
set(0, 'defaultFigurePaperPosition', defsize);

plotFigure2()  % visualize 500um and 330um spectrum count rates
plotScurve(3,1,2)  % visualize the spectrums
plotScurve(4,3,4)  % visualize the monoenergetic pulses
plotTbase001(ngroup,ngroupr,ngroupc,1)
plotTbase001(ngroup,ngroupr,ngroupc,2)

% copy the figures over to bongo
system('cp ./paper_figures/* /mnt/bongo/Albert/Conferences/2019SPIE_proceeding/paper_figures');

end % end-function-header



function plotFigure2()
global fdata;
global width height;

cvec={'k-s','k-d','k-x','k-o'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 2
% plot all of their count rates on a single plot
firstplot=true; cidx=0; legstr={};
% variable for saving the plotted data
savedat=nan([100 1]);  % prealloc to make concatting varying length vectors possible

enlev=10;
for fgroupidx=[1 2]
  cidx=cidx+1;
  alldatavg=fdata{fgroupidx};
  nowvec=alldatavg(alldatavg(:,1)==enlev,:);
  nowvecNaN=nowvec; nowvecNaN(nowvec(:,9)<nowvec(:,4)*0.05,3)=NaN; nowvecNaN=nowvecNaN(~isnan(nowvecNaN(:,3)),:);
  nowvec0=nowvec;   nowvec0(nowvec(:,9)<nowvec(:,4)*0.05,3)=0;     nowvec0=nowvec0(nowvec0(:,3)~=0,:);

  % plot the curve
  loglog(nowvecNaN(:,5),nowvecNaN(:,3),cvec{cidx});   % plotting filename-in vs counted-out
  savedat(1:numel(nowvecNaN(:,5)),end+1)=nowvecNaN(:,5)';
  savedat(1:numel(nowvecNaN(:,3)),end+1)=nowvecNaN(:,3)';

  % set hold-on after the first plot
  if firstplot==true; hold on; firstplot=false; end
end
%legend(legstr,'Location','SouthEast');
%xlabel('Input count rate (kcps)');
%ylabel('Output count rate (kcps)');
v=axis;
v(3)=1e0;
v(4)=1e4;
axis(v);
% add the m=1 line based on axis
plot([1e0 min([v(2) v(4)])],[1e0 min([v(2) v(4)])],'k--')
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTick',[1 10 100 1000 10000],'YTick',[1 10 100 1000 10000])
set(gca,'XTickLabel',[],'YTickLabel',[]);
hold off



% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
savefname=sprintf('figure2_thresh%dkeV',enlev);
print(sprintf('./paper_figures/%s.pdf',savefname),'-dpdf','-r300');
% save the plotted data
csvwrite(sprintf('./paper_figures/%s.csv',savefname),savedat);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % end-plotFigure2-function-header


function plotScurve(figNum,fgroupidxstart,fgroupidxend)
global fdata;
global width height;
akey='a':'z'; cidx=1;  % needed to append a, b, c... to the figure name
elev_thresh=10;  % dont plot counts below this... too noisy
save_plot_data=[];

% hard-code the Ylim depending on figure
if (figNum==3)
  XlimL=elev_thresh;
  XlimR=120;
  Xtickval=[20 40 60 80 100 120];
  Ylim=50;
  Ytickval=[10 20 30 40 50];  % note this is the avg, true-counts is 10x
  Fcount_rate=[10 200 500 2000];
elseif (figNum==4)
  XlimL=elev_thresh;
  XlimR=120;
  Xtickval=[20 40 60 80 100 120];
  Ylim=1000;
  Ytickval=[200 400 600 800 1000]; % note this is avg, true-count is 10x
  Fcount_rate=[10 200 500 2000];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 3 and 4
% draw the energy distribution and S-curve
for fgroupidx=fgroupidxstart:fgroupidxend
  alldatavg=fdata{fgroupidx};
  %for F=[10 100 200 1000]  % which count rates to visualize?
  for F=[Fcount_rate]
    pvec=alldatavg(alldatavg(:,5)==F,:);

    % remove the whole-number keV so the energy spectrum has to use 0.5-to-0.5 keV bins
    pvec2=[];
    for F2=1:numel(pvec(:,1))
      if (mod(pvec(F2,1),1) ~= 0)
        pvec2(end+1,:)=pvec(F2,:);
      end
    end

    % energy spectrum (line)
    xvals1=pvec2(1:end-1,1);  % x is in 0.5 keV increments already (i.e. 0.5 keV)
    yvals1=-1*diff(pvec2(:,8));
    yvals1(xvals1<elev_thresh)=0;  % exclude counts below elev_thresh
    % duplicate the x- and y-values so it looks like a square-wave histogram
    xvals=zeros([1 numel(xvals1)*2]);
    xvals(1:2:end)=xvals1;
    xvals(2:2:end)=xvals1;
    xvals=xvals(2:end);  % drop the first time index
    xvals(end+1)=xvals(end)+(xvals1(end)-xvals1(end-1));  % add the last point (incremented by the default increment of xvals1)
    yvals=zeros([1 numel(yvals1)*2]);
    yvals(1:2:end)=yvals1;
    yvals(2:2:end)=yvals1;
    % plot the input spectrum
    plot(xvals,yvals,'Color',[0.5 0.5 0.5]);  % shift x-label by 0.5 (i.e., 1.5 becomes 2 keV)
    if (isempty(save_plot_data))
      save_plot_data = [xvals' yvals'];
    else
      save_plot_data(:,end+1)=xvals';
      save_plot_data(:,end+1)=yvals';
    end
    hold on

% temporary variable for reporting deadtime loss
yvalsave=yvals;

    yvals2=-1*diff(pvec2(:,9));
    yvals2(yvals2<0)=0;  % remove any negative numbers
    yvals2(xvals1<elev_thresh)=0;  % exclude counts below elev_thresh
    % duplicate the y-values so it looks like a square-wave histogram
    yvals=zeros([1 numel(yvals2)*2]);
    yvals(1:2:end)=yvals2;
    yvals(2:2:end)=yvals2;
    plot(xvals,yvals,'Color',[0 0 0]);
    save_plot_data(:,end+1)=xvals';
    save_plot_data(:,end+1)=yvals';
    hold off
    %legend(sprintf('in (%d pulses)',sum(yvals1)),sprintf('out (%d pulses)',sum(yvals2)))
    %title(sprintf('%d events / %0.2e sec (%d kcps)',pvec(1,4),pvec(1,7),F));
    v=axis;
    v(1)=XlimL;
    v(2)=XlimR;
    v(4)=Ylim;
    axis(v);

% temporary, report deadtime loss at each count rate
sum(yvals)/sum(yvalsave)

 
    % set ticks
    set(gca,'XMinorTick','off','YMinorTick','off')
    set(gca,'XTick',Xtickval,'YTick',Ytickval)
    set(gca,'XTickLabel',[],'YTickLabel',[]);

    % save the figures
    width=1.5; height=1.5;
    set(gcf,'PaperSize',[width height]);
    set(gcf, 'PaperPosition',[-0.15 -0.15 width+0.2 height+0.2]);
    print(sprintf('./paper_figures/figure%d%s.pdf',figNum,akey(cidx)),'-dpdf','-r300');
    cidx=cidx+1;
    % save the plot data points
  end  % end F for-loop
end  % end fgroupidx for-loop
% save the plot data
csvwrite(sprintf('./paper_figures/figure%d.csv',figNum),save_plot_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % end-plotScurve-function-header



function plotTbase001(ngroup,ngroupr,ngroupc,idx)
  global width height;

  ptb=load(sprintf('%s/TRAN_SWEEP/rundat.mat',ngroup{idx}));
  ptbq=ptb.rundat{ngroupr(idx),ngroupc(idx)};

  % adjust the DC level so it aligns with a tick mark
  plot(ptbq(:,1),ptbq(:,2)-ptbq(1,2)+2,'k')
  v=axis;
  v(1)=0;
  v(2)=6e-6;
  v(3)=0;
  v(4)=5;
  axis(v)
  set(gca,'XMinorTick','off','YMinorTick','off')
  set(gca,'XTick',[0 1e-6 2e-6 3e-6 4e-6 5e-6 6e-6],'YTick',[0 1 2 3 4 5])
  set(gca,'XTickLabel',[],'YTickLabel',[]);
  pbaspect([1 1 1]);

  % save the figures
  width=4; height=4;
  set(gcf,'PaperSize',[width height]);
  set(gcf,'PaperPosition',[0.5 0.5 width-0.5 height-0.5]);
  print(sprintf('./paper_figures/tbase001_ngroupidx%d.pdf',idx),'-dpdf','-r300');
end % end-plotTbase001-header


