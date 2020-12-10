
addpath('/mnt/SimRAID/Sims2010/framework/spc_testbenches/pmb2016_countrate_paper/octave_scripts');
[fpath fstr fext]=fileparts(fname);

  maxcal=200;  % maximum cal value considered, in keV

  [s q S]=loadeldobin(fname);
  % determine the analysis node
%  if (~exist('anaNode','var'))
%    if (isfield(s,'V_XFCASC3_OUT'))
%      anaNode='V_XFCASC3_OUT';
%    elseif (isfield(s,'V_XFCASC2_OUT'))
%      anaNode='V_XFCASC2_OUT';
%    else
%      anaNode='V_XFCASC1_OUT';
%    end
%  end
  anaNode='V_OUT';
  timevec=q(:,1);
  % adjust timevec by Tquiet
  timevec=timevec(end,1);
  timevec=timevec-2*S.TQUIET;
  out=q(:,s.(anaNode));
  vin=q(:,s.V_INREF);

  % generate calib vector, if it doesn't exist
  if (~exist('cal','var'))
    % read the data from the S param
    ARRNAME='caldat';
    cal=[0 0];
    for fnc=fieldnames(S)';
      fn=fnc{1};
      arrstr=regexp(fn, [ '^' ARRNAME '([0-9]*)$' ],'tokens','once');
      if ~isempty(arrstr); cal(end+1,:)=[ str2double(arrstr{1}) S.(fn) ]; end;
    end

    % truncate cal
    [xx maxcalidx]=min(abs(cal(:,1)-maxcal));
    cal=cal(1:maxcalidx,:)

    % linearly interpolate cal to have all kev levels (in 0.5V steps)
    newcalxvals=[0:0.5:cal(end,1)];
    newcal=interp1(cal(:,1),cal(:,2),newcalxvals);
    cal=[newcalxvals' newcal'];
  end

  neventsfn=regexp(fname,'[0-9]*events','match');
  temp=regexprep(neventsfn,'events','');
  neventsfn=str2num(temp{1});
  kcpsfn=regexp(fname,'[0-9]*kcps','match');
  temp=regexprep(kcpsfn,'kcps','');
  kcpsfn=str2num(temp{1});
  %ms=regexp(fname,'[0-9]*ms','match');
  %ms=str2num(regexprep(ms,'ms',''){1});

  plotvec=[];
  % step through all the keV levels available in cal and count the number of pulses
  for G=1:size(cal,1)
    % number of in-pulses
    SD=sign(diff(vin)); % Find where the diff changes signs
    TIDX=find(SD~=0); % consider only those indexes were sign was not 0
    SD(TIDX)=diff(SD([TIDX;TIDX(end)])); % Find where the diff really changes signs
    TIDX=find(SD~=0)+1; % +1 to take care of the offset caused by diff
    inval=abs(vin(TIDX));

    %nevents=numel(find(  diff(  iin > (cal(G,3)+iin(1))  )==1  ));
    nevents=sum(inval>cal(G,1));
    thresh=cal(G,2);
    outb=(out>=thresh+out(1));
    outL=find(diff(outb)==1);
    outL=numel(outL);
%    % exclude count-rates that resolved less than 1-percent of neventsfn
%    if (outL < neventsfn*0.01 )
%      outL=NaN;
%    end

    plotvec(end+1,1)=cal(G,1);
    plotvec(end,2)=nevents/timevec/1000;  % in units of kcps
    plotvec(end,3)=outL/timevec/1000;   % in units of kcps
    plotvec(end,4)=neventsfn;
    plotvec(end,5)=kcpsfn;
    plotvec(end,6)=thresh+out(1);
    plotvec(end,7)=timevec;
    plotvec(end,8)=nevents;  % absolute counts
    plotvec(end,9)=outL;     % absolute counts
    %plotvec(end,8)=cal(G,3)+iin(1);
  end  % for G=1:size(cal,1)

plotvec=sortrows(plotvec,[1 6]);

save([fpath '/' fstr '.mat'],'-v7');


