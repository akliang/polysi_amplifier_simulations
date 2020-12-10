
function [r c]=find2d(in,mode,val)

  if (exist('val','var'))
    in2=abs(in-val);
  else
    in2=in;
  end


  switch mode
    case 'max'
      [r c]=find(in2==max(max(in2)));
    case 'min'
      [r c]=find(in2==min(min(in2)));
    case 'find'
      [r c]=find(in2==min(min(in2)));
    otherwise
      error('Invalid mode (input 2)');
  end



end

