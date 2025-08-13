clear all
close all
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

location='kiwiclient/';

dirname=dir([location,'/175*']);         % directoty names index by Unix epoch
for dirnum=1:length(dirname)
  dirname(dirnum).name
  dlist=dir([location,dirname(dirnum).name,'/*162*wav']); % all ALS162 records
  for l=1:length(dlist)
    [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav([location,dirname(dirnum).name,'/',dlist(l).name]);
    if ((isempty(xx)==0)&&(isinf(fs)==0)&&(fs>8000))               % check the file was interpreted correctly
      z=cat(1,xx.z);z=z(floor(fs/20):end);       % IQ
      t=cat(1,xx.t);t=t(floor(fs/20):end);       % time
      dt(dirnum)=floor(t(1));                    % first integer GNSS timestamp second
      sol=[];
      for p=1:9
        if ((p==1)&&(dirnum==1)&&(l==2))
          figure
          subplot(311);plot(t(1:3*fs)-floor(t(1)),abs(z(1:3*fs)));hold on;xlabel('time (s)');ylabel('|I+jQ| (a.u.)');
        end
        ph=unwrap(angle(z));ph=ph-mean(ph);      % ALS162 information encoded on phase
        k=find((t-floor(t(1)))>p-0.05);          % integer second -50 ms
        if (isempty(k)==0)
          kinit=k(1);
          k=find((t-floor(t(1)))>p+0.05);        % integer second +50 ms
          if (isempty(k)==0)
            kend=k(1);
            if (kend>kinit)
              [~,posinit]=max(ph(kinit:kend));posinit=posinit-1+kinit;
              [~,posend]=min(ph(posinit:kend));posend=posend-1+posinit;
              if ((posend-posinit)>3)
                a=polyfit(t(posinit:posend)-floor(t(1)),ph(posinit:posend),1);
                sol(p)=-a(2)/a(1)-p;             % linear fit intersection with Y=0 at X=-b/a
              else
                printf("polyfit failure\n");
              end
              if ((p==1)&&(dirnum==1)&&(l==2))
                subplot(312);plot(t(1:3*fs)-floor(t(1)),ph(1:3*fs));hold on;xlabel('time (s)');ylabel('arg(I+jQ) (rad)');
                subplot(313);plot(t(1:3*fs)-floor(t(1)),real(z(1:3*fs)));hold on;xlabel('time (s)');ylabel('I (a.u.)');
                title(strrep(dlist(l).name,'_',' '));
              end
              if ((dirnum==1)&&(p<4)&&(l==2))
                subplot(312);
                line([(p)+sol(p) (p)+sol(p)],[-0.5 0.5],'linewidth',2)
              end
            end
          end
        end
      end % p
      if (isinf(sol)!=1)
        printf("%s %s m=%f s=%f\n",dirname(dirnum).name,strrep(dlist(l).name(25:end),'_iq.wav',''),mean(sol),std(sol))
        kk=find(abs(sol)>0);
        if (strfind(dlist(l).name,'ON5'));solm(dirnum,1)=mean(sol(kk));sols(dirnum,1)=std(sol(kk));end
        if (strfind(dlist(l).name,'ECH'));solm(dirnum,2)=mean(sol(kk));sols(dirnum,2)=std(sol(kk));end
        if (strfind(dlist(l).name,'FR')); solm(dirnum,3)=mean(sol(kk));sols(dirnum,3)=std(sol(kk));end
        if (strfind(dlist(l).name,'G80'));solm(dirnum,4)=mean(sol(kk));sols(dirnum,4)=std(sol(kk));end
        if (strfind(dlist(l).name,'G8U'));solm(dirnum,5)=mean(sol(kk));sols(dirnum,5)=std(sol(kk));end
        if (strfind(dlist(l).name,'ZAP'));solm(dirnum,6)=mean(sol(kk));sols(dirnum,6)=std(sol(kk));end
%         if (strfind(dlist(l).name,'PEN'));solm(dirnum,7)=mean(sol(kk));sols(dirnum,7)=std(sol(kk));end
        if (strfind(dlist(l).name,'POL'));solm(dirnum,8)=mean(sol(kk));sols(dirnum,8)=std(sol(kk));end
        if (strfind(dlist(l).name,'NUR'));solm(dirnum,9)=mean(sol(kk));sols(dirnum,9)=std(sol(kk));end
        if (strfind(dlist(l).name,'MUN'));solm(dirnum,10)=mean(sol(kk));sols(dirnum,10)=std(sol(kk));end
      end
    else
      printf("**%s/%s fs infinity**\n",dirname(dirnum).name,dlist(l).name);
    end
  end
end
for k=1:size(solm)(2)
   kk=find(solm(:,k)==0);solm(kk,k)=NaN;
   kk=find(solm(:,k)>8E-3);solm(kk,k)=NaN;
   kk=find(sols(:,k)>=0.001);solm(kk,k)=NaN;
end
figure
k=find(dt>0);dt=dt(k);solm=solm(k,:);sols=sols(k,:);
dt=dt-dt(1);
dt=unwrap(dt/(86400*7)*2*pi)/2/pi*86400*7;
plot(dt/3600,solm*1000)
legend('ON5 (1.36 ms)','ECH (0.39 ms)','FR (0.92 ms)','G80 (2.16 ms)','G8U (1.54 ms)','ZAP (1.77 ms)','POL','NUR (2.65 ms)','MUN (2.29 ms)','location','eastoutside')
xlabel('GPS time (h)')
ylabel('delay (ms)')
ylim([0 5])
