
function [pvec_start]=find_pulses(invec)
% returns the indices of the start of every pulse
% returns the first index and the last index if only 1 pulse is detected

      if (sum(isnan(invec))>0)
        pvec_start=NaN;
        return;
      end

      % detect the time window of the first pulse
      pvec=invec;
      pvec2=diff(pvec);
      pvec3=diff((abs(pvec2)>1e-20));


      % find start of pulse and grab 4 points before it
      pvec4=find(pvec3==1);
      pvec_start=pvec4-1;  % diff adjustment
      pvec_start=pvec_start-4;

      %% find end of the pulse and grab 4 points after it
      %pvec4=find(pvec3==-1);
      %pvec_end=pvec4-1; % diff adjustment
      %pvec_end=pvec_end+4;


      % some fixes and adjustments
      if (numel(pvec_start)==0)
        pvec_start=0;
        return;
      end
      
      if (numel(pvec_start)==1);  % just a single input pulse
        pvec_start(2)=numel(pvec);
      end

      if (pvec_start(1)<1); pvec_start(1)=1; end
      %if (pvec_end(end)>numel(pvec)); pvec_end(end)=numel(pvec); end


end

