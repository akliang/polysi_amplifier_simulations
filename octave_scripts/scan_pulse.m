
function [cnt]=scan_pulse(invec,dir)

if (strcmp(dir,'neg'))
  invec=~invec;
end

if (invec(1)~=0)
  cnt=0;
else
  % find the pulse
  t=diff(invec);
  t2=find(t==1);  % find the edges of the start of the pulse(s)
  t3=find(t==-1); % find the falling edges
  up=numel(t2); if (isempty(up)); up=0; end
  down=numel(t3); if (isempty(down)); down=0; end
  if (up>down)  % more rising edges that falling edges means an incomplete pulse
    cnt=down;
  elseif (up==down)
    cnt=up;
  end
end

end

