
q=load('./amptest_opamp.dat');
%inp=sqrt(q(:,2).^2+q(:,3).^2);
%inn=sqrt(q(:,4).^2+q(:,5).^2);
%out=sqrt(q(:,6).^2+q(:,7).^2);
%freq=q(:,1);
%in=q(:,8);
%figure;
%semilogx(freq,out./in)
%
%% phase
%z=q(:,6)+q(:,7)*i;
%phase=angle(z)*180/pi;
%figure
%semilogx(freq,phase);

freq=q(:,1);
lo1_r=4;
lo1_i=5;
lo2_r=6;
lo2_i=7;
hi1_r=8;
hi1_i=9;
hi2_r=10;
hi2_i=11;
loin_r=12;
loin_i=13;
loa_r=14;
loa_i=15;
lob_r=16;
lob_i=17;
loc_r=18;
loc_i=19;
bloa_r=20;
bloa_i=21;
bao_r=22;
bao_i=23;
cloa_r=24;
cloa_i=25;
cao_r=26;
cao_i=27;
vvvout_r=28;
vvvout_i=29;
vvvao_r=30;
vvvao_i=31;
Bvvvout_r=32;
Bvvvout_i=33;
Bvvvao_r=34;
Bvvvao_i=35;

mag = @(x,y) sqrt(x.^2+y.^2);
phase = @(x,y) angle(x+y*i)*180/pi;

lo1_mag=mag(q(:,lo1_r),q(:,lo1_i));
lo1_phs=phase(q(:,lo1_r),q(:,lo1_i));
hi1_mag=mag(q(:,hi1_r),q(:,hi1_i));
hi1_phs=phase(q(:,hi1_r),q(:,hi1_i));

lo2_mag=mag(q(:,lo2_r),q(:,lo2_i));
lo2_phs=phase(q(:,lo2_r),q(:,lo2_i));
hi2_mag=mag(q(:,hi2_r),q(:,hi2_i));
hi2_phs=phase(q(:,hi2_r),q(:,hi2_i));

loa_mag=mag(q(:,loa_r),q(:,loa_i));
loa_phs=phase(q(:,loa_r),q(:,loa_i));
loa_phs=smooth_phase(loa_phs);
lob_mag=mag(q(:,lob_r),q(:,lob_i));
lob_phs=phase(q(:,lob_r),q(:,lob_i));
lob_phs=smooth_phase(lob_phs);
loc_mag=mag(q(:,loc_r),q(:,loc_i));
loc_phs=phase(q(:,loc_r),q(:,loc_i));
loc_phs=smooth_phase(loc_phs);
bloa_mag=mag(q(:,bloa_r),q(:,bloa_i));
bloa_phs=phase(q(:,bloa_r),q(:,bloa_i));
bloa_phs=smooth_phase(bloa_phs);
bao_mag=mag(q(:,bao_r),q(:,bao_i));
bao_phs=phase(q(:,bao_r),q(:,bao_i));
bao_phs=smooth_phase(bao_phs);
cloa_mag=mag(q(:,cloa_r),q(:,cloa_i));
cloa_phs=phase(q(:,cloa_r),q(:,cloa_i));
cloa_phs=smooth_phase(cloa_phs);
cao_mag=mag(q(:,cao_r),q(:,cao_i));
cao_phs=phase(q(:,cao_r),q(:,cao_i));
cao_phs=smooth_phase(cao_phs);

vvvout_mag=mag(q(:,vvvout_r),q(:,vvvout_i));
vvvout_phs=phase(q(:,vvvout_r),q(:,vvvout_i));
vvvout_phs=smooth_phase(vvvout_phs);
vvvao_mag=mag(q(:,vvvao_r),q(:,vvvao_i));
vvvao_phs=phase(q(:,vvvao_r),q(:,vvvao_i));
vvvao_phs=smooth_phase(vvvao_phs);
Bvvvout_mag=mag(q(:,Bvvvout_r),q(:,Bvvvout_i));
Bvvvout_phs=phase(q(:,Bvvvout_r),q(:,Bvvvout_i));
Bvvvout_phs=smooth_phase(Bvvvout_phs);
Bvvvao_mag=mag(q(:,Bvvvao_r),q(:,Bvvvao_i));
Bvvvao_phs=phase(q(:,Bvvvao_r),q(:,Bvvvao_i));
Bvvvao_phs=smooth_phase(Bvvvao_phs);

figure;
%loglog(freq,lo1_mag);
%hold on
%plot(freq,hi1_mag);
%plot(freq,lo2_mag,'g');
%plot(freq,hi2_mag,'g');
%plot(freq,loa_mag,'r');
%plot(freq,hia_mag,'r');
loglog(freq,loa_mag,'k');
hold on
%loglog(freq,lob_mag,'g');
%loglog(freq,loc_mag,'r');
loglog(freq,bao_mag,'r');
%loglog(freq,bao_mag,'g');
loglog(freq,cao_mag,'g');
loglog(freq,vvvao_mag,'c');
loglog(freq,Bvvvao_mag,'m');
hold off;
legend('low-pass w 500f AC couple','10/190','10/30');

%figure;
%semilogx(freq,lo1_phs);
%hold on
%plot(freq,lo2_phs,'o');
%plot(freq,hi1_phs,'g');
%plot(freq,hi2_phs,'go');
%plot(freq,loa_phs,'r');
%plot(freq,hia_phs,'ro');
%hold off



figure
plotyy(freq,loc_mag,freq,loc_phs,'loglog','semilogx');
title('loc mag and phs');

figure
semilogx(freq,loa_phs,'k');
hold on
plot(freq,bao_phs,'r');
plot(freq,cao_phs,'g');
plot(freq,vvvao_phs,'c');
plot(freq,Bvvvao_phs,'m');
hold off
legend('low-pass w 500f AC couple','10/190','10/30');




% tran analysis
q=load('./amptest_opamp_tran.dat');
time=q(:,1);
in=q(:,2);
loa=8;
bloa=11;
bao=12;

figure
plot(time,q(:,loa),'o');
hold on
plot(time,q(:,bloa),'r');
plot(time,q(:,bao),'g');
plot(time,in,'k');
hold off
legend('loa','bloa','bao','in');
