clear all
close all
pkg load signal
addpath('./kiwiclient')

# sudo apt install octave-dev
# mkoctfile read_kiwi_iq_wav.cc
# ./kiwirecorder.py  -s g8ure.ddns.net  -p 8074 -f 162 -w -m iq
# ./kiwirecorder.py  -s gw0kig.ddns.net -p 8073 -f 162 -w -m iq
# ./kiwirecorder.py  -s kiwi.dg3sdk.de  -p 8073 -f 162 -w -m iq
# ./kiwirecorder.py  -s echofox.fr      -p 8073 -f 162 -w -m iq
# ./kiwirecorder.py  -s 22048.proxy.kiwisdr.com  -p 8073 -f 100 -w -m iq
# ./kiwirecorder.py  -s g8ure.ddns.net  -p 8074 -f 100 -w -m iq
# ./kiwirecorder.py  -s g8ure.ddns.net  -p 8074 -f 77.5 -w -m iq
# ./kiwirecorder.py  -s sdr3.on5kq.be  -p 8075 -f 100 -w -m iq
# ./kiwirecorder.py  -s sdr3.on5kq.be  -p 8075 -f 162 -w -m iq
# ./kiwirecorder.py  -s sdr3.on5kq.be  -p 8075 -f 77.5 -w -m iq
# ./kiwirecorder.py  -s wessex.zapto.org -p 8073 -f 77.5 -w -m iq
# ./kiwirecorder.py  -s wessex.zapto.org -p 8073 -f 162 -w -m iq
# ./kiwirecorder.py  -s wessex.zapto.org -p 8073 -f 100 -w -m iq
# ./kiwirecorder.py  -s sdr.autreradioautreculture.com -p 8073 -f 100 -w -m iq
# ./kiwirecorder.py  -s sdr.autreradioautreculture.com -p 8073 -f 162 -w -m iq
# ./kiwirecorder.py  -s sdr.autreradioautreculture.com -p 8073 -f 77.5 -w -m iq

# liste : http://kiwisdr.com/.public/

lfsr=load('dcf77_lfsr.dat');
np=12000*(120/77500);    % PRN chip length (120 periods of carrier)
oldP=0;
for k=1:length(lfsr)
   P=round(k*np);
   if (lfsr(k)==1) longlfsr(oldP+1:P)=ones(P-oldP,1);
     else longlfsr(oldP+1:P)=zeros(P-oldP,1);
   endif
   oldP=P;
end
longlfsr=longlfsr-mean(longlfsr);

stdthres=8;
dirname=dir('175*'); % '1754040062';
for dirnum=1:length(dirname)
  dirname(dirnum).name
  dlist=dir([dirname(dirnum).name,'/*77500*.wav']);
  for l=1:length(dlist)
    [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav([dirname(dirnum).name,'/',dlist(l).name]);
    if ((isinf(fs)==0)&&(fs>10000))
      z=cat(1,xx.z);z=z(floor(fs/20):end);
      t=cat(1,xx.t);t=t(floor(fs/20):end);
      dt(dirnum)=floor(t(1));
      sol=[];
      ph=abs(xcorr(longlfsr,angle(z)-mean(angle(z))));
      ph=fliplr(ph(1:length(t)));  % length(ph)/2
%      plot(t,ph);title(strrep([dirname(dirnum).name,'/',dlist(l).name],'_',' '));hold on
      for p=1:8
        if (((p+1)*fs)< length(ph))
          [valmax,posmax]=max(ph(floor((p*fs):floor((p+1)*fs))));posmax=posmax+floor(p*fs)-1;
          pol=polyfit([-1:+1],ph(posmax-1:posmax+1),2);
          if (valmax>std(ph)*stdthres)
             solcor(p)=mod(t(posmax),1)-pol(2)/2/pol(1)*(t(2)-t(1));
             sol(p)=mod(t(posmax),1);
          end
        end
      end % p
      kk=find(abs(sol)>0);
      printf("%s %s m=%f s=%f %d\n",dirname(dirnum).name,strrep(dlist(l).name(24:end),'_iq.wav',''),mean(sol(kk)),std(sol(kk)),length(kk))
      if (strfind(dlist(l).name,'ON5'));solm(dirnum,1)=mean(sol(kk));sols(dirnum,1)=std(sol(kk));solmcor(dirnum,1)=mean(solcor(kk));solscor(dirnum,1)=std(solcor(kk));end
      if (strfind(dlist(l).name,'ECH'));solm(dirnum,2)=mean(sol(kk));sols(dirnum,2)=std(sol(kk));solmcor(dirnum,2)=mean(solcor(kk));solscor(dirnum,2)=std(solcor(kk));end
      if (strfind(dlist(l).name,'FR')); solm(dirnum,3)=mean(sol(kk));sols(dirnum,3)=std(sol(kk));solmcor(dirnum,3)=mean(solcor(kk));solscor(dirnum,3)=std(solcor(kk));end
      if (strfind(dlist(l).name,'G80'));solm(dirnum,4)=mean(sol(kk));sols(dirnum,4)=std(sol(kk));solmcor(dirnum,4)=mean(solcor(kk));solscor(dirnum,4)=std(solcor(kk));end
      if (strfind(dlist(l).name,'G8U'));solm(dirnum,5)=mean(sol(kk));sols(dirnum,5)=std(sol(kk));solmcor(dirnum,5)=mean(solcor(kk));solscor(dirnum,5)=std(solcor(kk));end
      if (strfind(dlist(l).name,'ZAP'));solm(dirnum,6)=mean(sol(kk));sols(dirnum,6)=std(sol(kk));solmcor(dirnum,6)=mean(solcor(kk));solscor(dirnum,6)=std(solcor(kk));end
      if (strfind(dlist(l).name,'PEN'));solm(dirnum,7)=mean(sol(kk));sols(dirnum,7)=std(sol(kk));solmcor(dirnum,7)=mean(solcor(kk));solscor(dirnum,7)=std(solcor(kk));end
      if (strfind(dlist(l).name,'POL'));solm(dirnum,8)=mean(sol(kk));sols(dirnum,8)=std(sol(kk));solmcor(dirnum,8)=mean(solcor(kk));solscor(dirnum,8)=std(solcor(kk));end
      if (strfind(dlist(l).name,'NUR'));solm(dirnum,9)=mean(sol(kk));sols(dirnum,9)=std(sol(kk));solmcor(dirnum,9)=mean(solcor(kk));solscor(dirnum,9)=std(solcor(kk));end
      if (strfind(dlist(l).name,'MUN'));solm(dirnum,10)=mean(sol(kk));sols(dirnum,10)=std(sol(kk));solmcor(dirnum,10)=mean(solcor(kk));solscor(dirnum,10)=std(solcor(kk));end
    end
  end
end
for k=1:size(solm)(2)
   kk=find(solm(:,k)==0);solm(kk,k)=NaN;solmcor(kk,k)=NaN;
   kk=find(sols(:,k)>=0.5);solm(kk,k)=NaN;solmcor(kk,k)=NaN;
   kk=find(sols(:,k)>=0.001);solm(kk,k)=NaN;solmcor(kk,k)=NaN;
end
figure
k=find(dt>0);dt=dt(k);solm=solm(k,:);sols=sols(k,:);solmcor=solmcor(k,:);
dt=dt-dt(1);
dt=unwrap(dt/(86400*7)*2*pi)/2/pi*86400*7;
plot(dt/3600,solm*1000)
legend('ON5 (1.41 ms)','ECH (2.26 ms)','FR (2.80 ms)','G80 (X.XX ms)','G8U (2.31 ms)','ZAP (2.73 ms)','PEN (3.17 ms)','POL','NUR','MUN')
xlabel('GPS time (s)')
ylabel('delay (ms)')
ylim([202 207])
figure
plot(dt/3600,solmcor*1000)
legend('ON5 (1.41 ms)','ECH (2.26 ms)','FR (2.80 ms)','G80 (X.XX ms)','G8U (2.31 ms)','ZAP (2.73 ms)','PEN (3.17 ms)','POL','NUR','MUN')
xlabel('GPS time (s)')
ylabel('delay with fit (ms)')
ylim([202 207])
