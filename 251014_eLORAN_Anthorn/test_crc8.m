clear all
% https://fr.mathworks.com/help/matlab/matlab_prog/perform-cyclic-redundancy-check.html

divisor(:,1) = fliplr([1 0 0 1 0 1 1 1 1]); % CRC-8/AUTOSAR    0x2F init 0xff xorout 0xff
divisor(:,2) = fliplr([1 1 1 0 1 0 1 0 1]); % CRC-8/DVB-S2     0xD5
divisor(:,3) = fliplr([1 1 0 0 1 1 0 1 1]); % CRC-8/LTE        0x9B (ou CDMA2000 avec Init 0xff)
divisor(:,4) = fliplr([1 0 0 0 1 1 1 0 1]); % CRC-8/GMS-A      0x1D init 0x00
divisor(:,5) = fliplr([1 0 0 0 1 1 1 0 1]); % CRC-8/HITAG      0x1D init 0xff
divisorDegree = 8;
% https://www.sunshine2k.de/articles/coding/crc/understanding_crc.html
% Check value: This value is not required but often specified to help to 
%   validate the implementation. This is the CRC value of input string 
%   "123456789" or as byte array: [0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39]. 
checkinput=[0 0 1 1 0 0 0 1 0 0 1 1 0 0 1 0 0 0 1 1 0 0 1 1 0 0 1 1 0 1 0 0 0 0 1 1 0 1 0 1 0 0 1 1 0 1 1 0 0 0 1 1 0 1 1 1 0 0 1 1 1 0 0 0 0 0 1 1 1 0 0 1];

function res=calcCRC(message, divisor, divisorDegree, init)
  Input = [ message  zeros(1,divisorDegree)];
  BufferInit = repmat(init,1,divisorDegree); % BufferInit = zeros(1,divisorDegree);
  for i = 1:length(Input)
    temp1 = BufferInit(end);
    temp2 = temp1*divisor;
    for j = length(BufferInit):-1:2
      BufferInit(j) = xor(temp2(j), BufferInit(j-1));
    end
    BufferInit(1) = xor(Input(i), temp2(1));
  end
  res=fliplr(BufferInit);
end

% value HEX input : 0101
% 0xD5 -> 0xDE CRC-8/DVB-S2 OK
% 0xD5 -> 0x8D CRC-8/LTE    OK
for k=[ 2 3 4]
  pol=dec2hex(bin2dec(sprintf("%d",flipud(divisor(:,k)))));
  res=dec2hex(bin2dec(sprintf("%d",calcCRC(([0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 1 ]),divisor(:,k),divisorDegree,0))));
  chk=dec2hex(bin2dec(sprintf("%d",calcCRC(checkinput,divisor(:,k),divisorDegree,0))));
  printf("%s -> %s, chk=%s ",pol,res,chk)
  if (k==2) printf("(v.s. xC8/xBC)\n",pol,res,chk);end
  if (k==3) printf("(v.s. xA1/xEA)\n",pol,res,chk);end
  if (k==4) printf("(v.s. xC9/x37)\n",pol,res,chk);end
end
printf("\n");

for k=[ 3 5 ]  % 1 : xourout=xff
  pol=dec2hex(bin2dec(sprintf("%d",flipud(divisor(:,k)))));
  res=dec2hex(bin2dec(sprintf("%d",calcCRC(([0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 1 ]),divisor(:,k),divisorDegree,1))));
  chk=dec2hex(bin2dec(sprintf("%d",calcCRC(checkinput,divisor(:,k),divisorDegree,1))));
  printf("%s -> %s, chk=%s ",pol,res,chk);
  if (k==1) printf("(v.s. x7C/xDF)\n",pol,res,chk);end
  if (k==3) printf("(v.s. x10/xDA)\n",pol,res,chk);end
  if (k==5) printf("(v.s. x88/xB4)\n",pol,res,chk);end
end
