
%d=load('RF_72kVp_20mmAL.dat');  % used for MPH 2018 paper
%d=load('RF_72kVp_20mmAL_mono70keV.dat');  % used for MPH 2018 paper
%d=load('../../RQA9_42_8mmAlFiltration_11_5mmHVL.csv');  % used for SPIE 2019 talk
%d=load('../../RQA9_42_8mmAlFiltration_11_5mmHVL_AED.csv');  % use for SPIE 2019 talk

%d=load('../../RF_49kVp_AED.csv');  % used for PMB 2019 paper
%d=load('../../RF_120kVp_AED.csv');  % used for PMB 2019 paper
%d=load('../../RF_33keV_mono.csv');  % used for PMB 2019 paper
d=load('../../RF_69keV_mono.csv');  % used for PMB 2019 paper

% Improvements intended for new approach:
% X code events with single positive/negative value (keV?) at start
% X overlay "keV" triangles, do Weff conversion in SPICE?
%   re-think calibration	
%   variable run length as function of kcps


% Effects currently not considered:
% - Thickness and QE of Converter Material, Free Mean Path
% - Swank Noise
% - Spread between pixels
% - ... k-edges, escape photons, ...
% - Constant rise/fall time vs. constant rise/fall slope?
% - Mmore general pulse modeling approach:
%   - use a PWL shape to model pulse shap
%   - scale PWL by height (and/or length) so that integral under PWL equals energy
%   - length scaling could also be a function of interaction depth?
%   - e.g. define length scaling by depth of interaction, then do height scaling
%     - after accounting for swank noise?

ev=d(:,1)*1E6;
% Sum up probability
prob=cumsum(d(:,2));
% Make sure total probability is 1
prob=prob./prob(end);

%calib=[10 20 30 40 50 60 70 80 100 120]'*1e3;
calib=[10 20 40 60 90 120 150 180 210 240]'*1e3;

% Generate random points in time
% Texpo is now set by N and kcps
%Texpo=10000e-6; % Exposure Time in seconds
%Texpo=100e-6; % Exposure Time in seconds

% Physical Constants
ec=1.6022e-19; % Electron Charge in Culomb

% Converter Properties
% Work function - set to "1 eV" (unity) later to allow external Weff scaling?
Weff=4.6; % Weff [eV] of the converter material
% Pulse Shape (Triangular)
tr=20e-9; % Pulse Rise-Time [s]
tf=80e-9; % Pulse Fall-Time [s]

% Simulation parameters
Tquiet=5e-6; % "Quiet" Time at the beginning and end of Texpo, should be larger than tr and tf
% Would it make sense if the first event always starts EXACTLY at Tquiet? (via transpose or adding it?)

% Count rates in kcps for which to generate output files
%kcps=[ 1 3 10 33 100 333 1000 3333 10000 33333 ];
%kcps=[ 1 2 5 10 20 50 100 200 500 1000 2000 5000 10000 20000 50000 ];
kcps=[ 1 2 5 10 20 50 100 150 200 250 300 350 400 450 500 600 700 800 900 1000 2000 3000 4000 5000 10000 20000 50000];
N=1000; % Generate 1000 events at each rate

% Generate N events of random energies E [keV], based on input spectrum, at random times T [s]
%for N=[ 0 1 2 3 4 5 6 7 8 9 10 20 30 40 50 75 100 200 300 400 500 750 1000 2000 3000 4000 5000 10000 33000 100000];
%for N=[ 0 1 ];
%for N=[ 1000 ];
for eventrate=kcps;
  Texpo=N*(1e-3/eventrate);
  if N==0; % Calibration events, known energies, equally spaced
    E=calib;
    T=[0.5:numel(calib)]' .* (Texpo/(numel(calib)));
  else % random events
    E=interp1(prob,ev,rand(N,1),'linear');
    T=rand(N,1)*(Texpo)+Tquiet;
  end
% Sort events by time
T=sort(T);
fprintf(1,'Created Pulses: %d\n', numel(E));


fprintf(1,'Avoid events within hmin of each other...\n');
pm=0; % number of pulses currently moved to avoid inputs piling up within hmin...
hmin=10e-15; % Minimum time elements can be spaced apart, default in eldo: 1ps
for id=1:size(T)-1;
  if T(id+1)-T(id)<hmin;
   if (pm<3) % Move overlapping pulse
    T(id+1)=T(id)+(hmin)*1.1;
    pm=pm+1;
    fprintf(1,'.');
   else % Delete if too many pulses had to be tmin-spaced
    %E(id)=0; % Do not delete for now, to guarantee number of pulses
    fprintf(1,'X');
   end
  else
   pm=0;
  end
end
% Filtering "unified" pulses
T=T(E>0);
E=E(E>0);
fprintf(1,'After Filtering: %d\n', numel(E));


% Codify energy of events in sequencially alternating way (odd events positive, even events negative)
Ealt=E; Ealt(2:2:end)=-Ealt(2:2:end);
%ECV=E/ec; % eV * C/e = CV (Energy of the event in Coulomb-Volt)
% Energy column in current file should avoid extreme values - we re-code energy into units of keV
Ealt=Ealt*1e-3;
% Convert E [eV] to Peak-Current [A] (consider using unity Weff for external Weff scaling)
Ipk=(E/Weff)*ec * 2/(tr+tf); 
% Slope of Current Pulse
dIr=Ipk * (+1/tr); % dI/dt for rising  pulse
dIf=Ipk * (-1/tf); % dI/dt for falling pulse

% Time vs. change-in-current-slope [A/s] and Actual alternating Energy [eV] Matrix
TE=[ 0 0 0 ; T-tr  dIr 0*E;  T [-dIr+dIf]  Ealt ; T+tf [-dIf]  0*E; Texpo+2*Tquiet 0 0 ];
TE=sortrows(TE); % Sort resulting points by time


% cumulative sum of change-in-current-slope at each time point results in
% actual current slopes [A/s] for each time point until the next timepoint
TED=[ TE(:,1) cumsum(TE(:,2)) TE(:,3) ];
% Duplicate each data point as the beginning of the next time point,
% so that the derivatives are represented as proper square wave
DIDX=floor( (1:0.5:size(TED,1))     ); % Data indexes
TIDX=floor( (1:0.5:size(TED,1)) +0.5); % Time indexes
TEY=[ TED(TIDX,1) TED(DIDX,2) TED(DIDX,3) ]; 

% Integrate derivates to form actual current pulses
TEI=[ TEY(:,1) cumtrapz( TEY(:,1), TEY(:,2) ) TEY(:,3) ];
% And remove unecessary duplicate points
TEI=TEI(1:2:end,:);

%FNAME=sprintf('input_%devents_%dkcps_%eruntime.pwl',N,eventrate,TEI(end,1))
FNAME=sprintf('input_%devents_%dkcps_%.1eTquiet.pwl',N,eventrate,Tquiet)
save('-ascii', FNAME, 'TEI');


% Example code of how to use COL3 to get time and height of input pulses
if true; 
% using actual COL3 (usually not what eldo will write out)
COL3=TEI(:,3);
% same with blindly interpolated data... 
COL3=interp1(TEI(:,1),TEI(:,3),1e-11*[1:99999])';
% and again, interpolated including the actual peaks (as LVTIM=2 should produce it)...
COL3=interp1(TEI(:,1),TEI(:,3),sort( [ 1e-11*[1:99999] TEI(:,1)' ]) )';

SD=sign(diff(COL3)); % Find where the diff changes signs
TIDX=find(SD~=0); % consider only those indexes were sign was not 0
SD(TIDX)=diff(SD([TIDX;TIDX(end)])); % Find where the diff really changes signs
TIDX=find(SD~=0)+1; % +1 to take care of the offset caused by diff

% The actual array of pulse energies...
PHD=abs(COL3(TIDX));
% hist(PHD,20)  % Plot the histogram
% sum(PHD>50e3) % Count number of events above 50 keV
end

% Example for loading and plotting data:
% TEI=load('input_1000events_20kcps_5.0e-06Tquiet.pwl')
% plot(TEI(:,1),TEI(:,2))
% hold on; plot(TEI(:,1),abs(TEI(:,3))*ec/Weff/100e-9*1e3*2,'rx'); hold off

end

