

% 1 = SPC1-Amp1
% 2 = SPC1-Amp2
% 3 = New-amp-a
% 4 = New-amp-b
design=4;

% not used, just for reference
indir='C5simruns/20161221_FINAL/20161221T170348_three_stage_amp_fcasc2_compinload_m1_50u5u_m2_10u10u_m3_20u10u_m4_20u10u_rfb_15MEG_rdet_10MEG_cpar_100f_m3b3.0_PITCH250e-6/CZT';
r=35;
c=7;

cox=3.45306e-4;  % F/m
k=1.38e-23;
T=298;

kfn=4.4872e-25;  % C^2/m^2
kfp=7.5739e-25;  % C^2/m^2


W=[
50 10 20 20
50 10 20 20
50 10 20 20
50 10 20 20
]*1e-6;

L=[
10 10 10 10
10 10 10 10
5 10 10 10
5 10 10 10
]*1e-6;

gm=[
1.75  1.06  1.30  1.79
16.4  1.47  1.12  10.3
39.7  2.18  2.79  10.3
52.9  3.57  4.72  12.1
]*1e-6;

kf=[
kfn kfn kfp kfp
kfn kfn kfp kfp
kfn kfn kfp kfp
kfn kfn kfp kfp
];

f1=[
0.63  0.71  0.71  0.71
2.00  2.24  2.24  2.24
31.6  35.5  35.5  31.6
35.5  39.8  39.8  39.8
]*1e4;

f2=[
6.31  6.31  6.31  6.31
7.94  7.94  7.94  7.94
224   224   224   224
282   316   316   316
]*1e4;

gain=[
89.74  109.6  26.44  149.2
484.0  121.1  36.42  510.4
216.0  81.05  82.66  74.39
74.27  43.55  47.16  26.73
];

r3=[
0
200e6
15e6
15e6
];



results=[];
for idx=1:size(gm,2)
  thermal=   8/3 * k * T * gm(design,idx) * (f2(design,idx)-f1(design,idx));
  flicker=   kf(design,idx) / (cox^2*W(design,idx)*L(design,idx)) * log(f2(design,idx)/f1(design,idx)) * gm(design,idx)^2;
  flicker_v= flicker / gm(design,idx)^2;
  fc=        kf(design,idx) / (cox^2*W(design,idx)*L(design,idx)) * gm(design,idx) * 3/(8*k*T);

  thermal=  sqrt(thermal);
  flicker=  sqrt(flicker);
  flicker_v=sqrt(flicker_v);
  flicker_v_scaled=flicker_v*gain(design,idx);


  fprintf(1,'   idx(%d)  thermal(I): %0.3e   flicker(I): %0.3e   flicker(V): %0.3e   flicker(V_gain): %0.3e  fc: %0.2e\n',idx,thermal,flicker,flicker_v,flicker_v_scaled,fc);

  % save into a var for excel-friendly printing
  if (numel(results)==0)
    results=[thermal flicker flicker_v_scaled fc];
  else
    results(end+1,:)=[thermal flicker flicker_v_scaled fc];
  end
end

% calculate the resistor thermal noise
disp('Resistor thermal noise (I)')
fprintf(1,'F2 is %d\n',min(f2(design,:)))
fprintf(1,'F1 is %d\n',max(f1(design,:)))
resistor_thermal_amps = 4 * k * T * (min(f2(design,:))-max(f1(design,:))) / r3(design);
fprintf(1,'Resistor thermal noise (I) is %0.3e\n\n',resistor_thermal_amps)



% excel printout
for idx=1:size(results,1)
  fprintf(1,'%0.3e\t%0.3e\t%0.3e\t%0.2e\n',results(idx,:))
end



%{

sv=(kf)/(cox^2*W*L);
svt=8/3*kb*T/q2(1,F,G,igm);
[scaled_noise(F,G) GBWP(F,G) thermal_noise(F,G) flicker_noise(F,G)]=conv_bode(sv,svt,freq,gain);  % in volts


function [scaled_noise GBWP thermal_noise flicker_noise]=conv_bode(sv,svt,freq,fcurve)
% step through the freq sweep and scale the noise by the gain

  scaled_noise=[];
  GBWP=[];
  thermal_noise=[];
  flicker_noise=[];
  for fidx=2:numel(freq)
    Fhi=freq(fidx);
    Flo=freq(fidx-1);
    fnoise2=sv*log(Fhi/Flo);  % 2016-02-08 note: this is correct (natural log) because the integral of 1/x is ln(x) 
    tnoise2=svt*(Fhi-Flo);
    gain2=((fcurve(fidx-1)+fcurve(fidx))/2)^2;
    GBWP(end+1)=sqrt(gain2)*(Fhi-Flo);
    flicker_noise(end+1)=gain2*fnoise2;
    thermal_noise(end+1)=gain2*tnoise2;
    %scaled_noise(end+1)=gain2*noise2;
    scaled_noise(end+1)=flicker_noise(end)+thermal_noise(end);
  end
  flicker_noise=sqrt(sum(flicker_noise));
  thermal_noise=sqrt(sum(thermal_noise));
  scaled_noise=sqrt(sum(scaled_noise));
  %scaled_noise=sqrt(scaled_noise);
  GBWP=sum(GBWP)/100e3;  % GBWP at 100kHz

end



%}
