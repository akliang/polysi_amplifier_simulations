
function output=lfsr_sim(bits,tap,input,length)

x=input;

output=[];

for f=1:length
  output(end+1)=x(1);
  for t=1:numel(x)-1
    if sum(t==tap)>0
      x2(t)=xor(x(1),x(t+1));
    else
      x2(t)=x(t+1);
    end
  end
   x2(numel(x))=x(1);
   x=x2;
end



% append the input bits back
%output=[input' output];
%output=output';




