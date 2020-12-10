
function [out]=smooth_phase(in,dir)

% todo: normalize starting point to between -180 and +180


tmp=in;
x=diff(in);
% if the angle changes more than 150 degrees in one step, consider that an inflection point
y=find(abs(x)>150);

upfac=1;
for yidx=[y]
  % note: need to do y+1 because of the nature of diff()
  % figure out if its a jump up or a jump down
  if (x(yidx)<0)
    tmp(y+1:end)=tmp(y+1:end)+360*upfac;
  else
    tmp(y+1:end)=tmp(y+1:end)-360*upfac;
  end
  upfac=upfac+1;
end

out=tmp;


