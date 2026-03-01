addpath('../../kiwiclient/');
addpath('../../kiwiclient/oct/');
% 70 bit data including 14 bit CRC followed by 140 bit RS = 210 bit frame
close all
clear
pkg load nan
displ=0              % display plots of intermediate processing steps
verbose=1

GRI=5991*10/1E6      % GRI*10 us repetition period
weeks=0;             % KiwiSDR timestamp in GPS second every week, resets every weekend
impos=2;
pmax=8;              % pulses
number_of_bits=2100;
dlist=dir('*wav');
phstat=[];
ph0sbefore=[];
ph0safter=[];
t0before=[];
n=1;
tinit=0;
phlogm=[];
phlogs=[];
pmm=[];
pms=[];
pm=[];
ps=[];
for l=3:length(dlist)
  df=0.0000;th=1.5;
%  if (exist('x')==0)
     [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav(dlist(l).name);
     fs
%  end
  if (isinf(fs)==0)
     z=cat(1,xx.z);z=z(floor(fs*4):end);
     t=cat(1,xx.t);t=t(floor(fs*4):end);t=t-t(1);
     z=z.*exp(-j*df*t); % polyfit(t,phi,1)=-0.02688
     t50ms=t(1:floor(fs*4)); z50ms=z(1:floor(fs*4));
% plot the magnitude
     if (displ!=0)
        figure
        subplot(211)
        plot(t50ms,abs(z50ms))
     end

     kmag=find(abs(z50ms)<(max(abs(z50ms))/th));
     z50ms(kmag)=NaN;
% plot the phases
     if (displ!=0)
        hold on
        plot(t50ms,abs(z50ms),'rx')
        subplot(212)
        plot(t50ms,180/pi*angle(z50ms),'rx');hold on
        k=find(angle(z50ms)>=0);
        line([min(t50ms) max(t50ms)],[mean(angle(z50ms(k))) mean(angle(z50ms(k)))]*180/pi)
        line([min(t50ms) max(t50ms)],[mean(angle(z50ms(k))) mean(angle(z50ms(k)))]*180/pi+36)
        line([min(t50ms) max(t50ms)],[mean(angle(z50ms(k))) mean(angle(z50ms(k)))]*180/pi-36)
        k=find(angle(z50ms)<0);
        line([min(t50ms) max(t50ms)],[mean(angle(z50ms(k))) mean(angle(z50ms(k)))]*180/pi)
        line([min(t50ms) max(t50ms)],[mean(angle(z50ms(k))) mean(angle(z50ms(k)))]*180/pi+36)
        line([min(t50ms) max(t50ms)],[mean(angle(z50ms(k))) mean(angle(z50ms(k)))]*180/pi-36)
     end
     dk=round(1e-3*fs);  % samples in 1 ms (duration of each burst)
     kinit=1;
     do
       if (displ!=0)
         figure
         subplot(311);
         plot(abs(z(kinit:kinit+5*GRI*fs-1)))
       end
       kinittmp=find(abs(z(kinit:kinit+5*GRI*fs-1))>max(abs(z(kinit:5*GRI*fs+kinit-1)))/th);
       kinit=kinit-1+kinittmp(1)-floor(dk/2);
       tinitold=tinit;
       tinit=t(kinit);
       if (((abs(tinit-tinitold-(GRI-0.01122))>0.005)&&(abs(tinit-tinitold-0.01122)>0.005)) && (tinit>.1)) printf("%f burst position error\n",tinit);end
       tstop=tinit+10*1e-3;  % 1 ms spacing x 9 bits with last spaced by 2 ms
       kstop=find(t>=tstop);kstop=kstop(1);
       zuseful=z(kinit:kstop);
       if (displ!=0)
         subplot(312); plot(abs(zuseful));
       end
                              % threshold amplitude and detect phase and amplitude maxima
       k=find(abs(zuseful)>max(abs(zuseful))/2.5); k=k(1);
       clear pos ph
       for m=1:9
          if (m<=8)
            [~,pos(m)]=max(abs(zuseful(k+(m-1)*dk:k+m*dk-dk/2)));  % do not go too far over next bit
            pos(m)=pos(m)+k+(m-1)*dk-1;
          else
            [val,tmppos]=max(abs(zuseful(k+(m-1)*dk:end)));
%            if (val>max(abs(zuseful)/2.5))
               pos(m)=tmppos+k+(m-1)*dk-1;
%            end
          end
       end
       posdiff=diff(pos(1:8)/fs*1e3);  % in ms
       if (posdiff(end)>1.5) posdiff(end)-=1;end
       if (isempty(find(abs(posdiff-1)>(2/fs*1000)))==0)     % check that pulses are 1 ms apart (except last at 2 ms), +/- 1 sample
         printf("%f: pulse position error: ",tinit);
         if (displ!=0)
           figure
           plot(abs(zuseful))
           for k=1:length(pos) line ([pos(k) pos(k)],[0 0.4]);end
         end
         posdiff-1
       end
       ph=arg(zuseful(pos));
ph9=ph;
po9=t(pos(9))-t(pos(8));
ma9=abs(zuseful(pos(9)));
ph=ph(1:8);
       phmean=mean(ph); % /!\ not the same number of positive and neg pulses
       ph0sbefore=[ph0sbefore ; phmean];
       t0before=[t0before ; tinit];
       ph-=phmean;

       kinit=kstop; % +dk*2;  % forward by 5 ms
       %kinit=kstop+floor(GRI*fs)-11*dk;  % forward by 5 ms

%       if (displ!=0)
%         subplot(313); plot(pos,ph,'ro');xlim([0 140])
%       end
       kphasepos=find(ph>0);
       kphaseneg=find(ph<=0); % first find all the positive and negative and THEN shift
       ph(kphaseneg)+=pi/2;
       ph(kphasepos)-=pi/2;

       phmean=mean(ph);ph-=phmean;  % recompute average since not the same number of pos and neg pulses in master/secondary A/B

       master=0;
       secondary=0;
% GRI-A
       if ((length(kphasepos)==4) && (ismember(kphasepos',[3 4 6 8],'rows')==1) && (length(kphaseneg)==4) && (ismember(kphaseneg',[1 2 5 7 ],'rows')==1)) master=-1;end
       if ((length(kphasepos)==6) && (ismember(kphasepos',[1 2 3 4 5 8],'rows')==1) && (length(kphaseneg)==2) && (ismember(kphaseneg',[6 7],'rows')==1)) secondary=+1;end
       if ((length(kphaseneg)==4) && (ismember(kphaseneg',[3 4 6 8],'rows')==1) && (length(kphasepos)==4) && (ismember(kphasepos',[1 2 5 7 ],'rows')==1)) master=+1;end
       if ((length(kphaseneg)==6) && (ismember(kphaseneg',[1 2 3 4 5 8],'rows')==1) && (length(kphasepos)==2) && (ismember(kphasepos',[6 7],'rows')==1)) secondary=-1;end
% GRI-B
       if ((length(kphasepos)==6) && (ismember(kphasepos',[1 4 5 6 7 8],'rows')==1) && (length(kphaseneg)==2) && (ismember(kphaseneg',[2 3 ],'rows')==1)) master=+2;end
       if ((length(kphasepos)==4) && (ismember(kphasepos',[1 3 5 6],'rows')==1) && (length(kphaseneg)==4) && (ismember(kphaseneg',[2 4  7 8],'rows')==1)) secondary=+2;end
       if ((length(kphaseneg)==6) && (ismember(kphaseneg',[1 4 5 6 7 8],'rows')==1) && (length(kphasepos)==2) && (ismember(kphasepos',[2 3 ],'rows')==1)) master=-2;end
       if ((length(kphaseneg)==4) && (ismember(kphaseneg',[1 3 5 6],'rows')==1) && (length(kphasepos)==4) && (ismember(kphasepos',[2 4  7 8],'rows')==1)) secondary=-2;end

       bitpos=zeros(length(ph),1);
       bitneg=zeros(length(ph),1);
       ph0=mean(ph(1:2));     % identify coarse phase (+/-)
       if (mean(ph0)>12*pi/180) ph-=ph0;end
       k=find(ph<-90/180*pi);ph(k)+=pi;

       ph0safter=[ph0safter ; ph(1:2)];
%       if (displ!=0)
%         hold on
%         subplot(313); plot(pos,ph,'bx');xlim([0 140])
%         line([0 140],[ph0+36/180/2 ph0+36/180/2])
%         line([0 140],[ph0-36/180/2 ph0-36/180/2])
%       end
       % identify fine phase (+ with +/-36 degrees for 0/-1/+1 or - with +/-36 degrees)

          if (verbose==1)
            if (master==1)     printf("+master   A: ");end
            if (secondary==1)  printf("+secondaryA: ");end
            if (master==-1)    printf("-master   A: ");end
            if (secondary==-1) printf("-secondaryA: ");end
            if (master==2)     printf("+master   B: ");end
            if (secondary==2)  printf("+secondaryB: ");end
            if (master==-2)    printf("-master   B: ");end
            if (secondary==-2) printf("-secondaryB: ");end
          end
if (master!=0) phlogm=[phlogm ph9];pm=[pm po9];pmm=[pmm ma9];end
if (secondary!=0) phlogs=[phlogs ph9];ps=[ps po9];pms=[pms ma9];end
%          if (respos>=0)
%            if (verbose==1) printf("pos%03d neg%03d\n",respos,resneg); end
%            for m=1:7
%               binresposrl=[mod(respos,2) binresposrl]; % least significant bit (newest) to the left
%               binresnegrl=[mod(resneg,2) binresnegrl]; % least significant bit (newest) to the left
%               binresposlr=[binresposlr mod(respos,2)]; % least significant bit (newest) to the right
%               binresneglr=[binresneglr mod(resneg,2)]; % least significant bit (newest) to the right
%               respos=floor(respos/2);
%               resneg=floor(resneg/2);
%             end 
%          else 
             if (verbose==1) printf('\n');end
%             if (master==0) printf("respos=0\n"); end
%          end
%       end
     until (kinit>length(z)-5*GRI*fs) % repeat for next frame of 8 or 9 bits until end of record
  end
end
subplot(211)
plot(phlogm(8,:),'.')
hold on
plot(phlogm(9,:),'r.')
for k=-180:22.5:180
  line([1 length(phlogm(9,:))],[k/180*pi k/180*pi])
end
xlabel('master burst index (no unit)');ylabel('phase (rad)');legend('8th pulse','9th pulse');

subplot(212)
plot(phlogs(8,:),'.')
hold on
plot(phlogs(9,:),'r.')
for k=-180:22.5:180
  line([1 length(phlogs(9,:))],[k/180*pi k/180*pi])
end
xlabel('secondary burst index (no unit)');ylabel('phase (rad)');legend('8th pulse','9th pulse');
