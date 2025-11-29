% Questions:
% why all master signals are unmodulated?
% beginning of sentence when assembling bits?
% how to handle missing secondary sequence (erroneous decoding?)

% 70 bit data including 14 bit CRC followed by 140 bit RS = 210 bit frame
close all

% https://fr.mathworks.com/help/matlab/matlab_prog/perform-cyclic-redundancy-check.html
%message = [1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0];
%divisor = [1, 1, 1, 1];
%divisorDegree = 3; % must return 110
% https://ww1.microchip.com/downloads/en/appnotes/00730a.pdf
%message = [0, 1, 1, 0, 1, 0, 1];
%divisor = [1, 0, 1];
%divisorDegree = 2; % must return 11

% CRC definition in ITU-R M.589-3 page 13 section 4.5
divisor = ([1 1 0 0 0 0 0 1 0 1 1 0 0 0 1]);
divisorDegree = 14;

function res=calcCRC(message, divisor, divisorDegree,flipoutput)
  BufferInit = zeros(1,divisorDegree);
  Input = [ message  zeros(1,divisorDegree)];
  for i = 1:length(Input)
    temp1 = BufferInit(end);
    temp2 = temp1*divisor;
    for j = length(BufferInit):-1:2
      BufferInit(j) = xor(temp2(j), BufferInit(j-1));
    end
    BufferInit(1) = xor(Input(i), temp2(1));
  end
  if (flipoutput==1)
    res=fliplr(BufferInit);
  else
    res=(BufferInit);
  end
end

% chatGPT
function [isValid, calcCRC] = checkEurofixCRC(bits70)
% checkEurofixCRC  Validate and compute CRC-14 for Eurofix (eLORAN) message  
%  
% INPUT:  
%   bits70 : 70-bit vector (0/1), structured as: [56 data bits, then 14 CRC bits]  
% OUTPUT:  
%   isValid : true if received CRC matches computed CRC  
%   calcCRC : 14-bit vector of computed CRC  

    if length(bits70) ~= 70  
        error('Input must be exactly 70 bits.');  
    end  

    data = bits70(1 : 70-14);  
    receivedCRC = bits70(70-14+1 : end);  

    % Generator polynomial G(x) = x^14 + x^13 + x^7 + x^5 + x^4 + 1  
    % Represented as binary vector of length 15 (degree 14):  
    % bit i corresponds to coefficient of x^(14-(i-1))  
    % So g(1) = coefficient for x^14, ..., g(15) = constant term  
    g = zeros(1, 15);  
    g(1)  = 1;   % x^14  
    g(2)  = 1;   % x^13  
    g(15-7) = 1; % x^7 → index = 15 - 7 = 8  
    g(15-5) = 1; % x^5 → index = 10  
    g(15-4) = 1; % x^4 → index = 11  
    g(15)   = 1; % constant term  

    crcLen = length(g) - 1;

    % Append zeros to the data (left-shift by crcLen)
    reg = [data, zeros(1, crcLen)];

    % Polynomial long division (bitwise, modulo-2)
    for i = 1 : length(data)
        if reg(i) == 1
            reg(i : i + crcLen) = bitxor(reg(i : i + crcLen), g);
        end
    end

    % The remainder is the computed CRC
    remainder = reg(end - crcLen + 1 : end);
    calcCRC = remainder;

    % Compare computed vs received
    isValid = isequal(calcCRC, receivedCRC);
end
% This code assumes that the first element of bits70 is the most significant bit (i.e., corresponds to the highest power of xx) as per the “binary-to-polynomial” mapping in the spec. Make sure your bit vector matches that ordering.

% Helper: bitwise long-division CRC routine
function rem14 = compute_crc_bitwise(data56, gen, orientation)
    % data56: row vector of 0/1 (length 56)
    % gen: generator bits (length 15, highest-degree-first)
    % orientation: 'normal' or 'reversed'
    if strcmpi(orientation,'reversed')
        data = fliplr(data56);          #LSB - MSB, same as in binres
        genv = fliplr(gen);     #LSB - MSB
    else
        data = fliplr(data56);          #LSB - MSB, same as in binres
        genv = gen;             #MSB - LSB, same as in polynomial
    end

    % Append 14 zeros (multiply by x^14)
    frame = [data zeros(1, length(genv)-1)];
    L = length(data);
    Glen = length(genv);

    for i = 1:L
        if frame(i) == 1
            % XOR with generator placed at position i..i+Glen-1
            frame(i:i+Glen-1) = mod(frame(i:i+Glen-1) + genv, 2);
        end
    end

    remainder = frame(L+1:end);   % length = Glen-1 = 14
    if strcmpi(orientation,'reversed')
        %rem14 = fliplr(remainder);
        rem14 = remainder;
    else
        %rem14 = remainder;
        rem14 = fliplr(remainder);
    end
end

function binresprocess(binres)
% Ensure binres is a row vector of 0/1
  binres = double(binres(:)');     % row vector

  Nbits = length(binres);
  if Nbits < 70
    error('Not enough bits to form a 70-bit window (need >=70). Nbits = %d', Nbits);
  end
  
  # Generator polynomial coefficients with higest degree first
  # G(x) = x^14 + x^13 + x^7 + x^5 + x^4 + 1
  # Generator vector length = 15 (indices 1..15 -> degrees 14..0)
  g = zeros(1,15);
  g(1) = 1;            % x^14
  g(2) = 1;            % x^13
  g(15-7) = 1;         % x^7  => index 8
  g(15-5) = 1;         % x^5  => index 10
  g(15-4) = 1;         % x^4  => index 11
  g(15)   = 1;         % x^0  => index 15
  % MAIN sliding window check
  found = false;
  found_info = struct();
  scan_limit = Nbits - 70 + 1;

  fprintf('\nStarting CRC sliding search over %d bits\n', Nbits);

  for s = 1:scan_limit
    window70 = binres(s:s+70-1);   % 70-bit candidate (bits 1..70)
    data56 = window70(1:56);
    transmitted_crc = window70(57:70);  % bits 57..70 from candidate

    % Try both orientations and both methods
    orientations = {'normal','reversed'};    % corresponds to MSB->LSB and LSB->MSB trials

    for oi = 1:length(orientations)
        orient = orientations{oi};

        % Method 1: bitwise
        rem_b = compute_crc_bitwise(data56, g, orient);
        matched_b = isequal(rem_b, transmitted_crc);

        if matched_b 
            found = true;
            found_info.start_index = s;
            found_info.window70 = window70;
            found_info.data56 = data56;
            found_info.transmitted_crc = transmitted_crc;
            found_info.orientation = orient;
            found_info.method = 'bitwise';
            found_info.computed_crc = rem_b;

            % print details
%            fprintf('\n*** VALID CRC FOUND ***\n');
%            fprintf('Start bit index in binres: %d (window bits %d..%d)\n', s, s, s+69);
%            fprintf('Method: %s, Orientation: %s\n', found_info.method, found_info.orientation);
            fprintf('Data %05d: %s\n', s, num2str(found_info.data56,'%d'));
%            fprintf('Computed CRC(14): %s\n', num2str(found_info.computed_crc,'%d'));
%            fprintf('Tx CRC (14)     : %s\n', num2str(found_info.transmitted_crc,'%d'));
%            fprintf('Full 70-bit seg : %s\n', num2str(found_info.window70,'%d'));
        end
    end
  end
end

d=dir('binresneglr');
%for flipcode=[1 0]
%  if (flipcode==1)
%     flipdivisor=fliplr(divisor);
%  else
%     flipdivisor=(divisor);
%  end
%  for flipoutput=[1 0]
    for l=1:length(d)
      binres=load(d(l).name);
      d(l).name
      % http://jmfriedt.free.fr/EN50067_RDS_Standard.pdf
      binresprocess(binres);
      %for m=1:800 % length(binres)-55-divisorDegree
      %  message=binres(m:m+55);                           % 56 bit long message
      %  messagecrc=binres(m+55+1:m+55+1+divisorDegree-1); % 14 bit long CRC
      %  evalcrc=calcCRC(message,flipdivisor,divisorDegree,flipoutput);
      %  if (sum(messagecrc==evalcrc)==divisorDegree)
      %    printf("** %s SYNC FOUND %d %d %d**\n",d(l).name,flipcode,flipoutput,m)
      %  end
      %end
    end
%  end
%end
