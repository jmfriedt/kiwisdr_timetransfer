clear;
## clc;
close all

%log_file = input('Enter log file to write: ', 's');
log_file = 'binres_log';
fid_log = fopen(log_file, 'w');
if fid_log == -1, error('Cannot create log file: %s', log_file); end
print = @(varargin) fprintf(fid_log, varargin{:});

bitstream_file = 'binres';
number_of_bits = "all"; %% 200secs, 1secs = 103.996bits, 0.06731secs (GRI) = 7bits

g = [1 1 0 0 0 0 0 1 0 1 1 0 0 0 1]; % 15bits MSB Normal - 0x60b1

if ~exist(bitstream_file, 'file') %% Load bitstream from file
    error('Bitstream file "%s" not found.', bitstream_file);
end

fid = fopen(bitstream_file, 'r');
raw = fread(fid, '*char')';  % Read as string
fclose(fid);

encoded_bits = double(raw) - '0'; % Convert '0'/'1' chars to numeric bits
encoded_bits = encoded_bits(encoded_bits == 0 | encoded_bits == 1);

if isempty(encoded_bits)
    error('No valid bits found in file.');
end

if ischar(number_of_bits) && strcmpi(number_of_bits, 'all') %% Determine scan length
    Nbits = length(encoded_bits);
else
    Nbits = min(length(encoded_bits), number_of_bits);
end

if Nbits < 70
    error('Not enough bits: %d (need >=70)', Nbits);
end

fprintf('Loaded %d bits from "%s"\n', Nbits, bitstream_file);
print('Loaded %d bits from "%s"\n', Nbits, bitstream_file);
fprintf('Using generator:0x60b1 -> %s (degree %d)\n', num2str(g), length(g)-1);
print('Using generator:0x60b1 -> %s (degree %d)\n', num2str(g), length(g)-1);

%% Bitwise CRC function
function rem14 = compute_crc_bitwise(data56, gen)
    frame = [data56 zeros(1, 14)];           % Append 14 zeros
    for i = 1:56
        if frame(i) == 1
            %frame(i:i+14) = mod(frame(i:i+14) + gen, 2);
            frame(i:i+14) = bitxor(frame(i:i+14), gen);
        end
    end
    rem14 = fliplr(frame(57:70));                    % Last 14 bits
end

scan_limit = Nbits - 69; %% Sliding window search
found_all = {};

fprintf('\nStarting sliding CRC search (%d windows)...\n', scan_limit);
print('\nStarting sliding CRC search (%d windows)...\n', scan_limit);

for s = 1:scan_limit
    window70 = encoded_bits(s:s+69);
    data56 = fliplr(window70(1:56));
    tx_crc = window70(57:70);

    computed_crc = compute_crc_bitwise(data56, g);

    if isequal(computed_crc, tx_crc)
        info.start_index = s;
        info.data56 = data56;
        info.computed_crc = computed_crc;
        info.transmitted_crc = tx_crc;
        info.window70 = window70;
        found_all{end+1} = info;

        fprintf('\n*** VALID CRC MATCH *** at bit %d\n', s);
        print('\n*** VALID CRC MATCH *** at bit %d\n', s);

        fprintf('Start bit index: %d (window %d..%d)\n', s, s, s+69);
        print('Start bit index: %d (window %d..%d)\n', s, s, s+69);
        fprintf('Data (56 bits)  : %s\n', num2str(info.data56,'%d'));
        print('Data (56 bits)  : %s\n', num2str(info.data56,'%d'));
        fprintf('Computed CRC(14): %s\n', num2str(info.computed_crc,'%d'));
        print('Computed CRC(14): %s\n', num2str(info.computed_crc,'%d'));
        fprintf('Tx CRC (14)     : %s\n', num2str(info.transmitted_crc,'%d'));
        print('Tx CRC (14)     : %s\n', num2str(info.transmitted_crc,'%d'));
        fprintf('Full 70-bit seg : %s\n', num2str(info.window70,'%d'));
        print('Full 70-bit seg : %s\n', num2str(info.window70,'%d'));
        printf("-------------------------------------------------------------");
        print("-------------------------------------------------------------");
        print("-------------------------------------------------------------");
        disp('');
        disp('');

    end
end

%% Summary
if isempty(found_all)
    fprintf('\nNo valid CRC matches found.\n');
else
    fprintf('\n%d VALID MATCH(ES) FOUND!\n', numel(found_all));
    assignin('base', 'crc_matches', found_all);
end
