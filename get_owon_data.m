function [data, out] = get_owon_data(os)
%%
% This is only as a guide. For multiple channels, modify the following code
% Example for only 1 CH
fprintf(os, ':WAV:BEG CH1');
fprintf(os, '*WAI');
% The read data by one time is #9000001024XXXX: among which, “9” indicates the bytes quantity,
% “000001024” describes the length of the waveform (input signal) data, say, 1024 bytes. The value of “N”
% calculated by introducing 2 functions: "partial string" and "decimal numeric string to numeric conversion".
fprintf(os, ':WAV:PRE?');
fprintf(os, '*WAI');
%% 
% Can't read it correctly. From the NI I/O Trace, I'm getting 1035 bytes
% binblockread works, but what's the correct format... int16, char? 
out = fscanf(os, '%c'); 
% out = binblockread(os, 'char');
fprintf(os, '*WAI');
%% 
% Counter and Preallocation
current_len = 0;
% OBS: Check always your InputBufferSize
step_len = 100000; % Test your step. The max data length that the device reads per time is 256k
total_len = 10e6;  % Manual set from the DEPMEM query
data = nan(total_len,1);
%%
% Data loop
try
    while current_len < total_len
    str = sprintf(':WAV:RANG %d,%d',current_len, step_len);
    fprintf(os, str);
    fprintf(os, '*WAI');
    fprintf(os, ':WAV:FETC?');
    fprintf(os, '*WAI');
    % The read data consists of two parts - TMC header and data packet, like #900000ddddXXXX..., among
    % which, “dddd” reflects the length of the valid data packet in the data stream, “XXXX...” indicates the data
    %from the data packet, every 2 bytes forms one effective data, to be 16-bit signed integer data
    data(current_len+1:current_len+step_len) = binblockread(os, 'int16');
    current_len = current_len + step_len;
    end
catch ME
    % Sometimes there's no an effective
    % data-packet read within the loop
    fprintf(os, ':WAV:END');
    fprintf(os, '*WAI');
    fclose(os);
    rethrow(ME);
end
%%
fprintf(os, ':WAV:END');
end