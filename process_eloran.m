% Questions:
% why all master signals are unmodulated?
% beginning of sentence when assembling bits?
% how to handle missing secondary sequence (erroneous decoding?)

% 70 bit data including 14 bit CRC followed by 140 bit RS = 210 bit frame

close all
pkg load nan
displ=0              % display plots of intermediate processing steps

GRI=6731*10/1E6      % GRI*10 us repetition period
weeks=0;             % KiwiSDR timestamp in GPS second every week, resets every weekend
impos=2;
pmax=8;              % pulses
dlist=dir('*wav');   % read eLORAN records
pattern=[[-1 -1  0  0 +1 +1]; % 0
         [-1 -1  0 +1  0 +1]; % 1
         [-1 -1  0 +1 +1  0]; % 2
         [-1 -1 +1  0  0 +1]; % 3
         [-1 -1 +1  0 +1  0]; % 4
         [-1 -1 +1 +1  0  0]; % 5
         [-1  0 -1  0 +1 +1]; % 6
         [-1  0 -1 +1  0 +1]; % 7
         [-1  0 -1 +1 +1  0]; % 8
         [-1  0  0 -1 +1 +1]; % 9
         [-1  0  0 +1 -1 +1]; % 10
         [-1  0  0 +1 +1 -1]; % 11
         [-1  0 +1 -1  0 +1]; % 12
         [-1  0 +1 -1 +1  0]; % 13
         [-1  0 +1  0 -1 +1]; % 14
         [-1  0 +1  0 +1 -1]; % 15
         [-1  0 +1 +1 -1  0]; % 16
         [-1  0 +1 +1  0 -1]; % 17
         [-1 +1 -1  0  0 +1]; % 18
         [-1 +1 -1  0 +1  0]; % 19
         [-1 +1 -1 +1  0  0]; % 20
         [-1 +1  0 -1  0 +1]; % 21
         [-1 +1  0 -1 +1  0]; % 22
         [-1 +1  0  0 -1 +1]; % 23
         [-1 +1  0  0 +1 -1]; % 24
         [-1 +1  0 +1 -1  0]; % 25
         [-1 +1  0 +1  0 -1]; % 26
         [-1 +1 +1 -1  0  0]; % 27
         [-1 +1 +1  0 -1  0]; % 28
         [-1 +1 +1  0  0 -1]; % 29
         [ 0 -1 -1  0 +1 +1]; % 30
         [ 0 -1 -1 +1  0 +1]; % 31
         [ 0 -1 -1 +1 +1  0]; % 32
         [ 0 -1  0 -1 +1 +1]; % 33
         [ 0 -1  0 +1 -1 +1]; % 34
         [ 0 -1  0 +1 +1 -1]; % 35
         [ 0 -1 +1 -1  0 +1]; % 36
         [ 0 -1 +1 -1 +1  0]; % 37
         [ 0 -1 +1  0 -1 +1]; % 38
         [ 0 -1 +1  0 +1 -1]; % 39
         [ 0 -1 +1 +1 -1  0]; % 40
         [ 0 -1 +1 +1  0 -1]; % 41
         [ 0  0 -1 -1 +1 +1]; % 42
         [ 0  0 -1 +1 -1 +1]; % 43
         [ 0  0 -1 +1 +1 -1]; % 44
         [ 0  0 +1 -1 -1 +1]; % 45
         [ 0  0 +1 -1 +1 -1]; % 46
         [ 0  0 +1 +1 -1 -1]; % 47
         [ 0 +1 -1 -1  0 +1]; % 48
         [ 0 +1 -1 -1 +1  0]; % 49
         [ 0 +1 -1  0 -1 +1]; % 50
         [ 0 +1 -1  0 +1 -1]; % 51
         [ 0 +1 -1 +1 -1  0]; % 52
         [ 0 +1 -1 +1  0 -1]; % 53
         [ 0 +1  0 -1 -1 +1]; % 54
         [ 0 +1  0 -1 +1 -1]; % 55
         [ 0 +1  0 +1 -1 -1]; % 56
         [ 0 +1 +1 -1 -1  0]; % 57
         [ 0 +1 +1 -1  0 -1]; % 58
         [ 0 +1 +1  0 -1 -1];
         [+1 -1 -1  0  0 +1];
         [+1 -1 -1  0 +1  0];
         [+1 -1 -1 +1  0  0];
         [+1 -1  0 -1  0 +1];
         [+1 -1  0 -1 +1  0];
         [+1 -1  0  0 -1 +1];
         [+1 -1  0  0 +1 -1];
         [+1 -1  0 +1 -1  0];
         [+1 -1  0 +1  0 -1];
         [+1 -1 +1 -1  0  0];
         [+1 -1 +1  0 -1  0];
         [+1 -1 +1  0  0 -1];
         [+1  0 -1 -1  0 +1];
         [+1  0 -1 -1 +1  0];
         [+1  0 -1  0 -1 +1];
         [+1  0 -1  0 +1 -1];
         [+1  0 -1 +1 -1  0];
         [+1  0 -1 +1  0 -1];
         [+1  0  0 -1 -1 +1];
         [+1  0  0 -1 +1 -1];
         [+1  0  0 +1 -1 -1];
         [+1  0 +1 -1 -1  0];
         [+1  0 +1 -1  0 -1];
         [+1  0 +1  0 -1 -1];
         [+1 +1 -1 -1  0  0];
         [+1 +1 -1  0 -1  0];
         [+1 +1 -1  0  0 -1];
         [+1 +1  0 -1 -1  0];
         [+1 +1  0 -1  0 -1];
         [+1 +1  0  0 -1 -1];
         [-1  0  0  0  0 +1];
         [-1  0  0  0 +1  0];
         [-1  0  0 +1  0  0];
         [-1  0 +1  0  0  0];
         [-1 +1  0  0  0  0];
         [ 0 -1  0  0  0 +1];
         [ 0 -1  0  0 +1  0];
         [ 0 -1  0 +1  0  0];
         [ 0 -1 +1  0  0  0];
         [ 0  0 -1  0  0 +1];
         [ 0  0 -1  0 +1  0];
         [ 0  0 -1 +1  0  0];
         [ 0  0  0 -1  0 +1];
         [ 0  0  0 -1 +1  0];
         [ 0  0  0  0 -1 +1];
         [ 0  0  0  0 +1 -1];
         [ 0  0  0 +1 -1  0];
         [ 0  0  0 +1  0 -1];
         [ 0  0 +1 -1  0  0];
         [ 0  0 +1  0 -1  0];
         [ 0  0 +1  0  0 -1];
         [ 0 +1 -1  0  0  0];
         [ 0 +1  0 -1  0  0];
         [ 0 +1  0  0 -1  0];
         [ 0 +1  0  0  0 -1];
         [+1 -1  0  0  0  0];
         [+1  0 -1  0  0  0];
         [+1  0  0 -1  0  0];
         [+1  0  0  0 -1  0];
         [+1 -1 +1 -1 +1 -1];
         [-1 +1 -1 +1 -1 +1];
         [+1 -1 +1 -1 -1 +1];
         [-1 +1 -1 +1 +1 -1];
         [+1 -1 -1 +1 -1 +1];
         [-1 +1 +1 -1 +1 -1];
         [+1 -1 -1 +1 +1 -1];
         [-1 +1 +1 -1 -1 +1];
         [+1  0  0  0  0 -1];
        ];
for l=1:length(dlist)
  if (exist('x')==0)
     [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav(dlist(l).name);
  end
  if (isinf(fs)==0)
     z=cat(1,xx.z);z=z(floor(fs/20):end);z50ms=z(1:floor(fs/20));
     t=cat(1,xx.t);t=t(floor(fs/20):end);t=t-t(1);t50ms=t(1:floor(fs/20));
% plot the magnitude
     if (displ!=0)
        subplot(211)
        plot(t50ms,abs(z50ms))
     end
     kmag=find(abs(z50ms)<(max(abs(z50ms))/2.5));
     z50ms(kmag)=NaN;
% plot the phases
     if (displ!=0)
        subplot(212)
        plot(t50ms,180/pi*angle(z50ms));hold on
        k=find(angle(z50ms)>0);
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
     binres=[];
     do 
       if (displ!=0)
         figure
         subplot(311);
         plot(abs(z(kinit:kinit+5*GRI*fs-1)))
       end
       kinittmp=find(abs(z(kinit:kinit+5*GRI*fs-1))>max(abs(z(kinit:5*GRI*fs+kinit-1)))/2.5); 
       kinit=kinit-1+kinittmp(1)-floor(dk/2);
       tinit=t(kinit);
       tstop=tinit+11*1e-3;  % 1 ms spacing x 9 bits with last spaced by 2 ms
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
            [val,tmppos]=max(abs(zuseful(k+(m)*dk:end)));
            if (val>max(abs(zuseful)/2.5))
               pos(m)=tmppos+k+m*dk-1;
            end
          end
       end
       ph=arg(zuseful(pos));
       kinit=kstop+dk;
       if (displ!=0)
         subplot(313); plot(pos,ph,'ro');xlim([0 140])
       end
       kphasepos=find(ph>0);
       kphaseneg=find(ph<=0); % first find all the positive and negative and THEN shift
       ph(kphaseneg)+=pi/2;
       ph(kphasepos)-=pi/2;
       master=0;
       secondary=0;
% GRI-A
       if ((length(kphasepos)==4) && (ismember(kphasepos',[3 4 6 8],'rows')==1) && (length(kphaseneg)==5) && (ismember(kphaseneg',[1 2 5 7 9],'rows')==1)) master=-1;end
       if ((length(kphasepos)==6) && (ismember(kphasepos',[1 2 3 4 5 8],'rows')==1) && (length(kphaseneg)==2) && (ismember(kphaseneg',[6 7],'rows')==1)) secondary=1;end
       if ((length(kphaseneg)==4) && (ismember(kphaseneg',[3 4 6 8],'rows')==1) && (length(kphasepos)==5) && (ismember(kphasepos',[1 2 5 7 9],'rows')==1)) master=+1;end
       if ((length(kphaseneg)==6) && (ismember(kphaseneg',[1 2 3 4 5 8],'rows')==1) && (length(kphasepos)==2) && (ismember(kphasepos',[6 7],'rows')==1)) secondary=-1;end
% GRI-B
       if ((length(kphasepos)==6) && (ismember(kphasepos',[1 4 5 6 7 8],'rows')==1) && (length(kphaseneg)==3) && (ismember(kphaseneg',[2 3 9],'rows')==1)) master=2;end
       if ((length(kphasepos)==4) && (ismember(kphasepos',[1 3 5 6],'rows')==1) && (length(kphaseneg)==4) && (ismember(kphaseneg',[2 4  7 8],'rows')==1)) secondary=2;end
       if ((length(kphaseneg)==6) && (ismember(kphaseneg',[1 4 5 6 7 8],'rows')==1) && (length(kphasepos)==3) && (ismember(kphasepos',[2 3 9],'rows')==1)) master=-2;end
       if ((length(kphaseneg)==4) && (ismember(kphaseneg',[1 3 5 6],'rows')==1) && (length(kphasepos)==4) && (ismember(kphasepos',[2 4  7 8],'rows')==1)) secondary=-2;end

       bit=zeros(length(ph),1);
       ph0=mean(ph(1:2));     % identify coarse phase (+/-)
       if (displ!=0)
         hold on
         subplot(313); plot(pos,ph,'bx');xlim([0 140])
         line([0 140],[ph0+36/180/2 ph0+36/180/2])
         line([0 140],[ph0-36/180/2 ph0-36/180/2])
       end
                              % identify fine phase (+ with +/-36 degrees for 0/-1/+1 or - with +/-36 degrees)
       khard=find(ph>ph0+36/180/2*1.5);bit(khard)=1; % soft bit to hard bit threshold: 
       khard=find(ph<ph0-36/180/2*1.5);bit(khard)=-1;
%       bit'                  % here we have 1 frame with 8 or 9 bits
       if (sum(bit(3:8))!=0) printf("error\n");end
       [~,res]=ismember(bit(3:8)',pattern,'rows');   % concatenate hard bits into symbol
       res=res-1;                                    % bits (index) to byte   
       if (master==1)     printf("+master   A: ");end
       if (secondary==1)  printf("+secondaryA: ");end
       if (master==-1)    printf("-master   A: ");end
       if (secondary==-1) printf("-secondaryA: ");end
       if (master==2)     printf("+master   B: ");end
       if (secondary==2)  printf("+secondaryB: ");end
       if (master==-2)    printf("-master   B: ");end
       if (secondary==-2) printf("-secondaryB: ");end
       if (res>=0) 
           printf("%d\n",res); 
           for m=1:7
              binres=[binres mod(res,2)];
              res=floor(res/2);
           end 
           if (length(binres)>=210)
               binres
               binres=[];
           end
       else printf("\n");end
       if (master==0) && (secondary==0) printf("none\n");
          kphasepos'
          kphaseneg'
       end
     until (kinit>length(z))                         % repeat for next fram of 8 or 9 bits
  end
end
