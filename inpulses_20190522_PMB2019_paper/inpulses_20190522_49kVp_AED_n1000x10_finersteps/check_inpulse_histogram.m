

%q=load('./input_1000events_10000kcps_5.0e-06Tquiet.pwl');
%q=load('./input_1000events_5kcps_5.0e-06Tquiet.pwl');

cbar={'r','b','g','k','c','m','y','r.','b.','g.','k.','c.','m.','y.'};
kcps=[5 50 100 200 300 400 500 5000 50000];
for k=1:numel(kcps)
  cline=cbar{k};
  kn=kcps(k);

  for F=1:10
    qtmp=load(sprintf('./inpulses_%03d/input_1000events_%dkcps_5.0e-06Tquiet.pwl',F,kn));
    if F==1
      q=qtmp;
    else
      q=[q; qtmp];
    end
  end

  inpulses=q(:,2);

  minp=min(inpulses);
  maxp=max(inpulses);
  nsteps=100;
  pstep=(maxp-minp)/nsteps;

  thresh=minp;

  cnts=zeros([2 nsteps]);

  for F=1:nsteps
    if F==1
      thresh=minp;
    else
      thresh=thresh+pstep;
    end
    tmp=(inpulses>=thresh);
    cnts(1,F)=thresh;
    cnts(2,F)=sum(diff(tmp)==1);
  end

  %plot(cnts(1,:),cnts(2,:))

  % find the max point (and only use the points to the right)
  [xx idx]=max(cnts(2,:));
  cnts=cnts(:,idx:end);
  hhist=-1*diff(cnts(2,:));
  plot(cnts(1,1:end-1),hhist,cline)
  hold on


end
hold off

