in=[0x79,0x08,0x01,0x58,0x00,0x1C,0x73,0x2F,0x44,0x26];
% CASE 1     79 08 01 58 00 1C 73 2F 44 26 -> RS: 3D 77 1E 46 37 7E 75 4E 35 5E 1B 00 5C 36 04 0B 1E 12 2A 3D 
codeword=rs30_10_encode(in)
outnoerr=rs30_10_decode(codeword)
codeword(5)=42;
outcorr=rs30_10_decode(codeword)
