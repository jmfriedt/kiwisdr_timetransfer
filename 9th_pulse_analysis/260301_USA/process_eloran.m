addpath('../../kiwiclient/')
addpath('../../kiwiclient/oct/')
% 70 bit data including 14 bit CRC followed by 140 bit RS = 210 bit frame
close all
clear
pkg load nan
displ=1              % display plots of intermediate processing steps
verbose=1

fini=4

GRI=9940*10/1E6      % GRI*10 us repetition period
number_of_bits=2100;
dlist=dir('*wav');
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

phstat=[];
ph0sbefore=[];
ph0safter=[];
t0before=[];
n=1;
tinit=0;
state=1;              % 1=master, 2=sec1, 3=sec2
for l=1:length(dlist)
  df=2.9188;th=1.5;
  if (exist('x')==0)
     [x,xx,fs,last_gpsfix]=proc_kiwi_iq_wav(dlist(l).name);
     fs
  end
  if (isinf(fs)==0)
     z=cat(1,xx.z);z=z(floor(fs*4)+100:end);
     t=cat(1,xx.t);t=t(floor(fs*4)+100:end);t=t-t(1);
     z=z.*exp(-j*df*t); % polyfit(t,phi,1)=-0.02688
     t50ms=t(1:floor(fs*4)); z50ms=z(1:floor(fs*4));
     N1ms=round(fs*1E-3);   % samples in 1 ms (duration of each burst)

     z50ms=z50ms(posinit-N1ms:posinit+N1ms*10+N1ms/2);
     t50ms=t50ms(posinit-N1ms:posinit+N1ms*10+N1ms/2);
     z=z(posinit-N1ms:end);
     t=t(posinit-N1ms:end);
     kposm=[1:N1ms:8*N1ms 9*N1ms];  % master 9 pulses
     kposs=[1:N1ms:8*N1ms];         % secondary 8 pulses
     kpos=N1ms+kposm;
%     mph=mean([arg(z(kpos)) arg(z(kpos+1)) arg(z(kpos-1))]');
     mph=[arg(z(kpos))];

% plot the magnitude
     if (displ!=0)
        figure
        subplot(211)
        plot(t50ms,abs(z50ms))
     end

% plot the phases
     if (displ!=0)
        hold on
        plot(t50ms(kpos),abs(z50ms(kpos)),'rx')
        subplot(212)
        plot(t50ms(kpos),180/pi*mph,'rx');hold on
        k=find(mph>=0);
        line([min(t50ms) max(t50ms)],[mean(mph(k)) mean(mph(k))]*180/pi)
        line([min(t50ms) max(t50ms)],[mean(mph(k)) mean(mph(k))]*180/pi+36)
        line([min(t50ms) max(t50ms)],[mean(mph(k)) mean(mph(k))]*180/pi-36)
        k=find(mph<0);
        line([min(t50ms) max(t50ms)],[mean(mph(k)) mean(mph(k))]*180/pi)
        line([min(t50ms) max(t50ms)],[mean(mph(k)) mean(mph(k))]*180/pi+36)
        line([min(t50ms) max(t50ms)],[mean(mph(k)) mean(mph(k))]*180/pi-36)
     end
     kinit=kpos(1);
     binresposlr=[];
     binresposrl=[];
     binresnegrl=[];
     binresneglr=[];
     do
       [~,kinittmp]=max(abs(z(kinit-N1ms:kinit+N1ms/2)));
       kinit=kinittmp+(kinit-N1ms-1);
       tinitold=tinit;
       tinit=t(kinit);
       kstop=kinit+N1ms*10;
       zuseful=z(kinit:kstop);
                              % threshold amplitude and detect phase and amplitude maxima
       clear pos ph
       if (state==1) pos=kposm;end
       if ((state==2) || (state==3)) pos=kposs;end
       s=0;
       for k=2:length(pos)
           [~,tmp]=max(abs(zuseful(pos(k)-2:pos(k)+2)));pos(k)=pos(k)-2+tmp-1;s=s+tmp-3;
       end
       ph=arg(zuseful(pos));
       kinit=kinit+round(s/(length(pos)-1));
       
       if (displ!=0)
         figure
         subplot(211);
         plot(abs(z(kinit-N1ms:kinit+N1ms*11)))
         hold on
         plot(pos+N1ms,abs(zuseful(pos)),'rx')
       end

       phmean=mean(ph); % /!\ not the same number of positive and neg pulses
       ph0sbefore=[ph0sbefore ; phmean];
       t0before=[t0before ; tinit];
       ph-=phmean;

       if (displ!=0)
         subplot(212); plot(pos,ph,'ro');xlim([0 140])
       end
       kphasepos=find(ph>0);
       kphaseneg=find(ph<=0); % first find all the positive and negative and THEN shift
       ph(kphaseneg)+=pi/2;
       ph(kphasepos)-=pi/2;

       phmean=mean(ph);ph-=phmean;  % recompute average since not the same number of pos and neg pulses in master/secondary A/B
       master=0;
       secondary=0;
% GRI-A
       if ((length(kphasepos)==4) && (ismember(kphasepos',[3 4 6 8],'rows')==1) && (length(kphaseneg)==5) && (ismember(kphaseneg',[1 2 5 7 9],'rows')==1)) master=-1;end
       if ((length(kphasepos)==6) && (ismember(kphasepos',[1 2 3 4 5 8],'rows')==1) && (length(kphaseneg)==2) && (ismember(kphaseneg',[6 7],'rows')==1)) secondary=+1;end
       if ((length(kphaseneg)==4) && (ismember(kphaseneg',[3 4 6 8],'rows')==1) && (length(kphasepos)==5) && (ismember(kphasepos',[1 2 5 7 9],'rows')==1)) master=+1;end
       if ((length(kphaseneg)==6) && (ismember(kphaseneg',[1 2 3 4 5 8],'rows')==1) && (length(kphasepos)==2) && (ismember(kphasepos',[6 7],'rows')==1)) secondary=-1;end
% GRI-B
       if ((length(kphasepos)==6) && (ismember(kphasepos',[1 4 5 6 7 8],'rows')==1) && (length(kphaseneg)==3) && (ismember(kphaseneg',[2 3 9],'rows')==1)) master=+2;end
       if ((length(kphasepos)==4) && (ismember(kphasepos',[1 3 5 6],'rows')==1) && (length(kphaseneg)==4) && (ismember(kphaseneg',[2 4  7 8],'rows')==1)) secondary=+2;end
       if ((length(kphaseneg)==6) && (ismember(kphaseneg',[1 4 5 6 7 8],'rows')==1) && (length(kphasepos)==3) && (ismember(kphasepos',[2 3 9],'rows')==1)) master=-2;end
       if ((length(kphaseneg)==4) && (ismember(kphaseneg',[1 3 5 6],'rows')==1) && (length(kphasepos)==4) && (ismember(kphasepos',[2 4  7 8],'rows')==1)) secondary=-2;end

       bitpos=zeros(length(ph),1);
       bitneg=zeros(length(ph),1);
       ph0=mean(ph) % (1:2));     % identify coarse phase (+/-) 260118 : keep all phases since sum=0
       if (mean(ph0)>12*pi/180) ph-=ph0;end
       k=find(ph<-90/180*pi);ph(k)+=pi;
       ph0safter=[ph0safter ; ph(1:2)];
       if (displ!=0)
         hold on
         plot(pos,ph,'bx');xlim([0 140])
         line([0 140],[ph0+36/180/2 ph0+36/180/2])
         line([0 140],[ph0-36/180/2 ph0-36/180/2])
       end
       % identify fine phase (+ with +/-36 degrees for 0/-1/+1 or - with +/-36 degrees)
       khard=find(ph>+36/180/2*pi);bitpos(khard)=+1;bitneg(khard)=-1; % soft bit to hard bit threshold:
       if ((isempty(khard)==0) && (length(phstat)<5000))
          phstat=[phstat ; ph(khard)];
       end
       khard=find(ph<-36/180/2*pi);bitpos(khard)=-1;bitneg(khard)=+1;
       if ((isempty(khard)==0) && (length(phstat)<5000))
          phstat=[phstat ; ph(khard)];
       end

%       bit'                  % here we have 1 frame with 8 or 9 bits
       if ((sum(bitpos(3:8))!=0) || (bitpos(1)!=0) || (bitpos(2)!=0))
          printf("%f: error sum !=0\n",tinit);ph'*180/pi
bitpos'
          binresposrl=[zeros(1,7) binresposrl];
          binresnegrl=[zeros(1,7) binresnegrl];
          binresposlr=[binresposlr zeros(1,7)];
          binresneglr=[binresneglr zeros(1,7)];
       else
          [~,respos]=ismember(bitpos(3:8)',pattern,'rows');   % concatenate hard bits into symbol
          % [~,respos]=ismember(bitpos(8:-1:3)',pattern,'rows');   % concatenate hard bits into symbol
          respos=respos-1;                                    % bits (index) to byte
          [~,resneg]=ismember(bitneg(3:8)',pattern,'rows');   % concatenate hard bits into symbol
          % [~,resneg]=ismember(bitneg(8:-1:3)',pattern,'rows');   % concatenate hard bits into symbol
          resneg=resneg-1;                                    % bits (index) to byte
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
          if (respos>=0)
    %            newbitsposlr=[];
    %            newbitsneglr=[];
    %            newbitsposrl=[];
    %            newbitsnegrl=[];
            if (verbose==1) printf("pos%03d neg%03d\n",respos,resneg); end
            for m=1:7
%              newbitsposlr=[mod(respos,2) newbitsposlr];  % least significant bit to the right
%              newbitsneglr=[mod(resneg,2) newbitsneglr];  % least significant bit to the right
%              newbitsposrl=[mod(respos,2) newbitsposrl];  % least significant bit to the right
%              newbitsnegrl=[mod(resneg,2) newbitsnegrl];  % least significant bit to the right
               binresposrl=[mod(respos,2) binresposrl]; % least significant bit (newest) to the left
               binresnegrl=[mod(resneg,2) binresnegrl]; % least significant bit (newest) to the left
               binresposlr=[binresposlr mod(respos,2)]; % least significant bit (newest) to the right
               binresneglr=[binresneglr mod(resneg,2)]; % least significant bit (newest) to the right
               respos=floor(respos/2);
               resneg=floor(resneg/2);
             end 
          else 
             if (verbose==1) printf('\n');end
             if (master==0) printf("respos=0\n"); end
%           if (abs(secondary)==1)
%              binres=[newbits binres]; % least significant bit (newest) to the right
%           end
%           if (abs(secondary)==2)
%              binres2=[binres2 newbits]; % least significant bit (newest) to the right
%           end
%       else 
%          if (secondary!=0) binres=[binres 0 0 0 0 0 0 0];printf("0x00 appended\n")end
          end
       end
%       if (length(binresposrl)>=810)
%          % http://jmfriedt.free.fr/EN50067_RDS_Standard.pdf
%binresposrl
%binresnegrl
%binresposlr
%binresneglr
%          for m=1:length(binres)-55-divisorDegree
%            m
%            message=binres(m:m+55);                           % 56 bit long message
%            messagecrc=binres(m+55+1:m+55+1+divisorDegree-1); % 14 bit long CRC
%            evalcrc=calcCRC(message,divisor,divisorDegree);
%            if (sum(messagecrc==evalcrc)==divisorDegree)
%               printf("** SYNC FOUND **\n")
%               theend % stop execution when SYNC found
%            end
%          end
%          binres=[];
%       end
     if (state==1) kinit=kinit+round(25*N1ms);end  % master to secondary 1
     if (state==2) kinit=kinit+round(42.5*N1ms);end  % secondary to next master
     state=state+1;
     if (state==3) state=1;
         fini=fini-1;if (fini==0) return;end
     end
     until (kinit>length(z)-5*GRI*fs) % repeat for next frame of 8 or 9 bits until end of record
  end
  fid = fopen("binresposrl", "w");
  fprintf(fid, "%d", binresposrl);   % no spaces, no newline
  fclose(fid);
  fid = fopen("binresnegrl", "w");
  fprintf(fid, "%d", binresnegrl);   % no spaces, no newline
  fclose(fid);
  fid = fopen("binresposlr", "w");
  fprintf(fid, "%d", binresposlr);   % no spaces, no newline
  fclose(fid);
  fid = fopen("binresneglr", "w");
  fprintf(fid, "%d", binresneglr);   % no spaces, no newline
  fclose(fid);
end
