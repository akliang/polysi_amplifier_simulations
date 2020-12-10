
function [ q2 ]=doreshape_improved(q,d)


  % figure out how large the matrix needs to be
  u=[];
  dimvals={};
  for dval=d
    u(end+1)=numel(unique(q(:,dval)));
    dimvals{dval}=unique(q(:,dval));
  end
  q2=NaN([u size(q,2)]);

  % walk through the blob data and try to put data in to the right place
  goodchunksize=u(1);
  dsel=d(2:end);



  for F=1:size(q,1)
  %for F=1:10000
    if (~exist('breakpt','var'))
      breakpt=q(F,dsel);
      Fsave=F;
    elseif (sum(breakpt~=q(F,dsel))>0)
      % do data chunking
      dchunk=q(Fsave:F-1,:);
      if (size(dchunk,1) ~= goodchunksize)
        disp(sprintf('Incorrect chunk size, skipping'));
      else
        if (numel(dsel)~=2)
          error('Currently doshape_improved only supports 3 dimensional sweeps.');
        else
          xind=find(dimvals{dsel(1)}==dchunk(1,dsel(1)));
          yind=find(dimvals{dsel(2)}==dchunk(1,dsel(2)));
          q2(:,xind,yind,:)=dchunk;
        end
         
      end
      %unique(dchunk(:,dsel))
      
      breakpt=q(F,dsel);
      Fsave=F;
    else
      % move on!
    end
  end

end
