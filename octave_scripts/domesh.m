
fpt=find(q2(:,1,1,1,1,1)==100000);

gain=[];
for T=1:size(q2,3)
  for F=1:size(q2,4)
    for G=1:size(q2,5)
      gainmap=q2(fpt,:,T,F,G,3)./q2(fpt,:,T,F,G,2);
      %[a b]=max(max(gainmap));
      %[c d]=max(gainmap(:,b));
      [c d]=max(gainmap);
      %gain(F,G)=gainmap(d,b);
      gain(F,G)=gainmap(d);
    end
  end
  figure;
  mesh(squeeze(q2(1,1,1,1,:,4)),squeeze(q2(1,1,1,:,1,5)),gain);
  title(sprintf('m6b = %f',squeeze(q2(1,1,T,1,1,6))));
end




