
more off

run('./loadme.m');
f=fieldnames(sntft1);

for i=1:numel(f)
  T.(f(i))=[sntft1.(f(i)) sntft2.(f(i)) sntft3.(f(i)) sntft4.(f(i)) sntft5.(f(i)) sntft6.(f(i)) sntft8.(f(i)) sntft9.(f(i)) sntft10.(f(i))];
end

dispcell={'muo','von','dvt','i0','i00','vkink'};

for i=1:numel(dispcell)
  %disp(sprintf('%s - %0.2e to %0.2e (%0.2e+%0.2e)',f{i},min(T.(f(i))),max(T.(f(i))),mean(T.(f(i))),std(T.(f(i)))));
  %disp(sprintf('%0.2e PPP %0.2e',mean(T.(f(i))),std(T.(f(i)))));
  %disp(sprintf('%s,%0.2e,%0.2e,%0.2e',dispcell{i},min(T.(dispcell(i))),median(T.(dispcell(i))),max(T.(dispcell(i)))));
  disp(sprintf('%s,%0.2f,%0.2f,%0.2f',dispcell{i},min(T.(dispcell(i))),median(T.(dispcell(i))),max(T.(dispcell(i)))));
end

