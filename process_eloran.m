clear all
close all
addpath('./kiwiclient')

pkg load nan
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

GRI=8830*10/1E6      % GRI*10 us repetition period
dirname=dir('175*'); % '1754040062';
weeks=0;             % KiwiSDR timestamp in GPS second every week, resets every weekend
impos=2;
pmax=8;              % pulses
for dirnum=1:length(dirname)
  dirname(dirnum).name
  dlist=dir([dirname(dirnum).name,'/*100000*PEN*wav']); % read eLORAN records
  for l=1:length(dlist)
    [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav([dirname(dirnum).name,'/',dlist(l).name]);
    if (isinf(fs)==0)
      z=cat(1,xx.z);z=z(floor(fs/20):end);
      t=cat(1,xx.t);t=t(floor(fs/20):end);
      dt(dirnum)=floor(t(1));
      if (exist('dinit')==0)
         dinit=dt(dirnum);
         % subplot(511)
         plot(t(1:3*fs)-floor(t(1)),180/pi*abs(z(1:3*fs)));
         hold on
         a=z(1:3*fs); 
         k=find(abs(a)<(max(abs(a))/2.5));
         a(k)=NaN;
         plot(t(1:3*fs)-floor(t(1)),180/pi*angle(a));hold on
%         xlim([1.15 1.27])
         k=find(angle(a)>0);
         line([min(t(1:3*fs)-floor(t(1))) max(t(1:3*fs)-floor(t(1)))],[mean(angle(a(k))) mean(angle(a(k)))]*180/pi)
         line([min(t(1:3*fs)-floor(t(1))) max(t(1:3*fs)-floor(t(1)))],[mean(angle(a(k))) mean(angle(a(k)))]*180/pi+36)
         line([min(t(1:3*fs)-floor(t(1))) max(t(1:3*fs)-floor(t(1)))],[mean(angle(a(k))) mean(angle(a(k)))]*180/pi-36)
         k=find(angle(a)<0);
         line([min(t(1:3*fs)-floor(t(1))) max(t(1:3*fs)-floor(t(1)))],[mean(angle(a(k))) mean(angle(a(k)))]*180/pi)
         line([min(t(1:3*fs)-floor(t(1))) max(t(1:3*fs)-floor(t(1)))],[mean(angle(a(k))) mean(angle(a(k)))]*180/pi+36)
         line([min(t(1:3*fs)-floor(t(1))) max(t(1:3*fs)-floor(t(1)))],[mean(angle(a(k))) mean(angle(a(k)))]*180/pi-36)
         ylabel(dirname(dirnum).name)
      end
      if (dirnum>1)
        if dt(dirnum)+weeks*86400*7<dt(dirnum-1)  % unwrap GNSS timestamp (needed for GRI offset)
           weeks=weeks+1;
        end
      end
      dt(dirnum)=dt(dirnum)+weeks*86400*7;
      loran_mag=abs(z);
      loran_time=t-floor(t(1))+mod(((dt(dirnum)-dinit)/GRI/2),1)*GRI*2; % every 2*GRI for master pulses
      kinit=find(loran_time>1.16);kinit=kinit(1);
      kstop=find(loran_time>1.20);kstop=kstop(1);
      k=find(loran_mag(kinit:kstop)>max(loran_mag(kinit:kstop))/2);k=k(1)+kinit-1; % first pulse detection
      if (isempty(k)==0)
        for griindex=0:40                                    % 40 bursts of 8 pulses *2 GRI (every 88.3*2 ms=7 s) 
           for p=1:pmax                                      % 8 pulses
             burstindex=floor(griindex*GRI*2*fs)+(p-1)*12;   % 12 = 1 ms @ 12 kS/s
             [~,posmax]=max(loran_mag(k-3+burstindex:k+3+burstindex));posmax=posmax-1+(k-3)+burstindex;  
             sol(p+(griindex)*pmax)=loran_time(posmax)-burstindex*(t(2)-t(1));
             pol=polyfit(1000*(loran_time(posmax-1:posmax+1)-loran_time(posmax)),loran_mag(posmax-1:posmax+1),2);
             solfit(p+(griindex)*pmax)=1000*loran_time(posmax)-(pol(2)/2/pol(1))-burstindex*1000*(t(2)-t(1));
           end                   % ^^^ align all bursts knowing the burst index from the GNSS timestamp
        end
        % if (sol<1.165) figure;plot(loran_time(kinit:kstop),loran_mag(kinit:kstop));hold on;pause;end
      end
      printf("%s %s m=%f s=%f\n",dirname(dirnum).name,strrep(dlist(l).name(25:end),'_iq.wav',''),mean(sol),std(sol))
      kk=find(abs(sol)>0);
      solm(dirnum)=mean(sol(kk));solf(dirnum)=mean(solfit(kk));sols(dirnum)=std(solfit(kk));end
  end
end
kk=find(solm==0);solm(kk)=NaN;
kk=find(solf==0);solf(kk)=NaN;
kk=find(abs(solm-median(solm))>.5e-3);solm(kk)=NaN;
kk=find(abs(solf-median(solf))>0.5);solf(kk)=NaN;
figure
k=find(dt>0);dt=dt(k);solm=solm(k,:);solf=solf(k,:);
dt=dt-dt(1);
% dt=unwrap(dt/(86400*7)*2*pi)/2/pi*86400*7;
plot(dt/3600,solm*1000-1167)
hold on
plot(dt/3600,solf-1167)
xlabel('GPS time (h)')
ylabel('delay (ms)')
line([0 80],[0.1 0.1]+1000/fs)  % sampling period in ms
line([0 80],[0.1 0.1]+2000/fs)
figure
plot(dt/3600,solm*1000-1167)
hold on
plot(dt/3600,solf-1167)
xlabel('GPS time (h)')
ylabel('delay (ms)')
line([0 80],[0.1 0.1]+1000/fs)  % sampling period in ms
line([0 80],[0.1 0.1]+2000/fs)
ylim([0 5])
