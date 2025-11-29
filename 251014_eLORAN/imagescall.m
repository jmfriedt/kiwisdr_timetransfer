d=dir('bin*');
for l=1:length(d)
  x=load(d(l).name);
  if (l==5) figure;end
  x=reshape(x(1:30*210),210,30);%subplot(121);
  subplot(1,4,mod(l-1,4)+1)
  imagesc(x)
  %x=reshape(x(1:30*210),30,210);subplot(122);imagesc(x)
  xlabel(d(l).name)
end
