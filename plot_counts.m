
more off;
set(0,'DefaultTextInterpreter','none');  % turn off LaTeX formating
addpath('./octave_scripts');

% NOTE: don't forget to set fgroup!
if ~exist('fgroup','var')
  disp('Oops!  Did not set fgroup yet.');
  return
else
  fprintf(1,'fgroup = %s\n',fgroup);
end



if (exist([fgroup '/datsave.mat']))
  disp('Found datsave file... loading that instead')
  load([fgroup '/datsave.mat']);
else
  disp('Running preprocess_join to create datsave...');
  preprocess_joindats
end




%%{
% plotvec columns: ( note: this column information is defined in preprocess.m )
% 1 = enlev
% 2 = nevents-in (kcps)
% 3 = nevents-out (kcps)
% 4 = nevents-filename
% 5 = kcps-filename
% 6 = thresh voltage
% 7 = timevec
% 8 = nevents-in  (count)
% 9 = nevents-out (count)
% plot it
doPlot=true;
doPlot && figure;
firstplot=true;
legstr={};
avgcolors={'r-o','b','g','k','c','m','r','b','g','k','c','m','r','b','g','k','c','m'};  cidx=0;
countdevsave=[];
%enlevrange=[10 20 30 40 50 60 70 80]
%enlevrange=[19.5];
%if (sum(enlevrange==19.5)==0); enlevrange=sort([enlevrange 19.5]); end  % make sure 19.5 kev is always there
enlevrange=[10];
for enlev=[enlevrange]
  cidx=cidx+1;
  nowvec=alldatavg(alldatavg(:,1)==enlev,:);
  % if nevents-out is less than 1% of the events-in, then set it to NaN or zero (interp1 cant handle NaN)
  nowvecNaN=nowvec; nowvecNaN(nowvec(:,9)<nowvec(:,4)*0.01,3)=NaN; nowvecNaN=nowvecNaN(~isnan(nowvecNaN(:,3)),:);
  nowvec0=nowvec;   nowvec0(nowvec(:,9)<nowvec(:,4)*0.01,3)=0;     nowvec0=nowvec0(nowvec0(:,3)~=0,:);

  % find the 10 and 30-percent deviation (walk from right-to-left)
  count_deviation=nowvec0(:,3)./nowvec0(:,2);
  %CR10=interp1(count_deviation,nowvec0(:,3),0.9);
  %CR30=interp1(count_deviation,nowvec0(:,3),0.7);
  CRidx=find(count_deviation>0.9);  CRidx=CRidx(end);
  CR10=interp1(count_deviation(CRidx-1:CRidx+1),nowvec0(CRidx-1:CRidx+1,3),0.9);
  CRidx=find(count_deviation>0.7);  CRidx=CRidx(end);
  CR30=interp1(count_deviation(CRidx-1:CRidx+1),nowvec0(CRidx-1:CRidx+1,3),0.7);
  % 2019-08-13 Very special hard-code to find correct FWHM using mono, but using the CR from spectrum
  assumed_CR = 270;
  DTL10 = interp1(nowvec0(:,3),count_deviation,assumed_CR);

  

  % plot the curve
  doPlot && loglog(nowvecNaN(:,5),nowvecNaN(:,3),avgcolors{cidx},'LineWidth',1);   % plotting filename-in vs counted-out
  legstr{end+1}=sprintf('%d kev dev (10/30/max): %4.1f/%4.1f/%4.1f',enlev,CR10,CR30,max(nowvecNaN(:,3)));

  % set hold-on after the first plot
  if (firstplot==true) && (doPlot); hold on; firstplot=false; end

  % save the max count rate if it's 19.5 kev
  if enlev==19.5 || enlev==10
    maxcountrate=max(nowvecNaN(:,3));
    countdevsave10=CR10;
    countdevsave30=CR30;
  end
end
if (doPlot)
% add the m=1 line
v=axis;
if (v(1)<v(3)); m1veclo=v(1); else; m1veclo=v(3); end
if (v(2)<v(4)); m1vechi=v(2); else; m1vechi=v(4); end
plot([m1veclo m1vechi],[m1veclo m1vechi],'k');
% final plotting stuff
hold off
title(sprintf('%s',fgroup))
legend(legstr);
v(3)=v(1);
axis(v);
xlabel('input counts')
ylabel('output counts')
end


% draw the energy distribution and S-curve
elev_thresh=10;  % dont plot counts below this... too noisy
usesubplot=false;
plotscurve=false;
plotenspec=true;
if (~exist('dofwhm'))
  dofwhm=false
end
fwhm_all=[];
for F=[1 5 10 20 50 100 200 206 250 500 800 1000 2000 5000]  % which count rates to visualize?
  pvec=alldatavg(alldatavg(:,5)==F,:);
  if (numel(pvec)==0)
    fprintf(1,'%d kcps not found, skipping...\n',F);
    continue
  end

  % s-curve
  if plotscurve
    if usesubplot
      figure
      subplot(1,2,1)
    else
      figure
    end
    plot(pvec(:,1),pvec(:,8))
    hold on
    plot(pvec(:,1),pvec(:,9),'r')
    hold off
    legend('in','out')
    title(sprintf('%d events / %0.2e sec (%d kcps)',pvec(1,4),pvec(1,7),F));
    v=axis;
    v(1)=elev_thresh;
    axis(v);
    xlabel('Energy level (keV)');
    ylabel('Num counts');
  end  % end plotscurve

  % remove the whole-number keV so the energy spectrum has to use 0.5-to-0.5 keV bins
  pvec2=[];
  for F2=1:numel(pvec(:,1))
    if (mod(pvec(F2,1),1) ~= 0)
      pvec2(end+1,:)=pvec(F2,:);
    end
  end

  % energy spectrum (line)
  if plotenspec
    if usesubplot
      figure
      subplot(1,2,2)
    else
      figure
    end
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
    plot(xvals,yvals);
    hold on


    yvals2=-1*diff(pvec2(:,9));
    yvals2(yvals2<0)=0;  % remove any negative numbers
    yvals2(xvals1<elev_thresh)=0;  % exclude counts below elev_thresh
    % duplicate the y-values so it looks like a square-wave histogram
    yvals=zeros([1 numel(yvals2)*2]);
    yvals(1:2:end)=yvals2;
    yvals(2:2:end)=yvals2;
    plot(xvals,yvals,'r');
    hold off
    legend(sprintf('in (%d pulses)',sum(yvals1)),sprintf('out (%d pulses)',sum(yvals2)))
    title(sprintf('%d events / %0.2e sec (%d kcps)',pvec(1,4),pvec(1,7),F));
    v=axis;
    v(1)=elev_thresh;
    axis(v);

    if dofwhm;
      % 2019-05-13 trying to get en res
      % interpolate yvals2 to 0.1 keV steps
      xvals1_interp = [xvals1(1):0.1:xvals1(end)];
      yvals2_interp = interp1(xvals1,yvals2,xvals1_interp);
      % find mean value (to know where to split left-right)
      yvals2_mean = (max(yvals2)-min(yvals2))/2;
      [xxx yvals2_idx] = max(yvals2_interp);
      % find the left and right half-value points
      xval_left  = interp1(yvals2_interp(1:yvals2_idx),xvals1_interp(1:yvals2_idx),yvals2_mean);
      xval_right = interp1(yvals2_interp(yvals2_idx+1:end),xvals1_interp(yvals2_idx+1:end),yvals2_mean);
      % delta of the two is FWHM
      fwhm3 = xval_right -  xval_left;
      % save this count rates FWHM for overall statistics later
      fwhm_all(end+1,1)=F;
      fwhm_all(end,2)=sum(yvals2)/sum(yvals1);
      fwhm_all(end,3)=fwhm3;
      fprintf(1,'FWHM for %d count rate (%d/%d counts) is %0.2f keV\n',F,sum(yvals2),sum(yvals1),fwhm3);
    end

  end  % end plotenspec
end  % end for-loop

if dofwhm;
  % 2019-05-13 final FWHM statistics
  fprintf(1,'\n');
  fprintf(1,'(mono) FWHM at 10-percent dead time loss is: %0.2f\n',interp1(fwhm_all(:,2),fwhm_all(:,3),0.9));
  fprintf(1,'(mono) FWHM at 30-percent dead time loss is: %0.2f\n',interp1(fwhm_all(:,2),fwhm_all(:,3),0.7));
  fprintf(1,'(spec) FWHM at 10-percent dead time loss is: %0.2f (hard-coded!! kcp=%d DTL=%f)\n',interp1(fwhm_all(:,2),fwhm_all(:,3),DTL10),assumed_CR,DTL10);

end



% append the max count into a dat file
%enlev=20;
fid=fopen('adat.txt','a');
%fprintf(fid,'%s\t%0.2f\t%0.2f\t%0.2f\n',fgroup,countdevsave(enlev,10),countdevsave(enlev,30),maxcountrate);
fprintf(fid,'%s\t%0.2f\t%0.2f\t%0.2f\n',fgroup,countdevsave10,countdevsave30,maxcountrate);
fclose(fid);


