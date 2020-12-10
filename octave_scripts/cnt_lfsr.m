
more off;

failcnt=0;
goodcnt=0;
nconv=0;


numbits=9;
tap=5;
clkind=51;
outind=47;
vcc=8;


for F=[1:100]
  testq=sprintf('./simruns/500ns/sramsr_clkODfixed3_%03d/allnodes.dat',F);
  system(['cat ' testq ' | grep -v -e "^#" | grep -e "^.*$" > loadme2.dat']);
  q=load('./loadme2.dat');
  %system('head allnodes.dat -n 8 | grep ^# | tail -n 1 | sed -e "s/# //" -e "s/ /\n/g" | grep -n ^ ')

  t=q(:,clkind)>(vcc/2);

  t2=swindow(5,t);
  t=t2;

  ind=find(t==max(t));
  ind2=diff(ind);
  ind3=find(ind2>1);
  ind4=ind(ind3);  % ind4 are all the indices to readout values of the LFSR

  %plot(q(:,3));
  %hold on;
  %plot(ind4,q(ind4,3),'ro');
  %hold off;

  outbits=q(ind4,outind)>(vcc/2);
  outbits=outbits';  % makes row-vector


  % generate the entire max-length sequence for this numbit
  output=lfsr_sim(numbits,tap,ones([numbits 1]),2^numbits*2);
  outstr=mat2str(output);
  outstr=outstr(2:end-1);  % strip off the extra [ and ] that mat2str appends
  outstr=regexprep(outstr, ','  , '');  % take out the commas added by mat2str

  % find/match where the data sequence matches with the max-length output
  instr=mat2str(outbits);
  instr=instr(2:end-1);  % strip off the extra [ and ] that mat2str appends
  instr=regexprep(instr, ','  ,'');  % take out the commas added by mat2str
  tmp=strfind(outstr,instr);

  if isempty(tmp)
    disp(sprintf('Output pattern not found in %s!',testq));
    failcnt=failcnt+1;
  else
    if (numel(tmp)==2)
      if (tmp(2)-tmp(1)==2^numbits-1)
        disp('Output pattern found in locations:');  tmp
        goodcnt=goodcnt+1;
      else
        disp(sprintf('Bitlength correct.  Expected %d, found %d in %s',2^numbits-1,tmp(2)-tmp(1),testq));
        failcnt=failcnt+1;
      end
    else
      disp(sprintf('Non-convergence in %s?',testq));
      nconv=nconv+1;
    end
  end
  
end

disp(sprintf('Good working LFSRs: %d',goodcnt));
disp(sprintf('Not working LFSRs: %d',failcnt));
disp(sprintf('Non-convergence? %d',nconv));

