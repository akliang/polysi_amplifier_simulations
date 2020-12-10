
function [ q2 ]=doreshape(q,d)

u=[];
for dval=d
  u(end+1)=numel(unique(q(:,dval)));
end

q2=reshape(q,[u size(q,2)]);

end
