
input=[1 1 1 1 1 1 1 1 0 0 0 0 0 1 1 1 0 0 1 1 1 1 1 0 1 1 0 0 1 0 0 0 1 0 0 0 1 1 0 0 1 1 1 0 1 0 1 1 1 0 1 1 0 1 1 0 0 0 0 0 0 1  1 0 0 0 1 1 0 1 1 1 1 0 0 0 1 0 1 1 1 1 0 1 0 1 0 1 0 1 1 1 1 1 1 0 1 0 0 0 1 0 1 0 1 1 0 1 1 1 0 0 0 0 1 1 1 1 0 1 1 1 0 1 0 0 1  1 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 1 0 0 0 0 1 1 0 1 0 1 1 0 0 1 1 0 0 1 0 1 0 1 0 0 1 1 1 1 0 0 1 1 0 1 1 0 1 0  0 0 0 0 1 0 1 0 0 1 0 1 1 0 0 0 1 0 0 1 1 1 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 1 1 1 0 0 1 1 1 1 1 0 1 1 0 0 1 0 0 0 1];


numbits=9;
tap=5;
inbits=input(1:9);
bitlen=numel(input);

  initbits=lfsr_sim(numbits,tap,inbits,numbits)
  output=lfsr_sim(numbits,tap,initbits,bitlen);

r1=25
r2=45
output(r1:r2)
input(r1:r2)

plot(output-input);

