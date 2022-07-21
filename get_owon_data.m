function [data, out] = get_owon_data(os)
%%
% This is only as a guide. For multiple channels, modify the following code
% Example for only 1 CH
[data.sample_rate, chs_disp]= get_sample_rate(os);
if isequal(chs_disp,[1 0]) || isequal(chs_disp,[1 1])
    str_command = ':WAV:BEG CH1';
else
    str_command = ':WAV:BEG CH2';
end
fprintf(os, str_command);
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
if sum(chs_disp) == 2
    step_len = step_len/2;
end
total_len = 10e6;  % Manual set from the DEPMEM query
data.points = nan(total_len,sum(chs_disp));
%%
% Data loop
try
    while current_len < total_len
    str_range_command = sprintf(':WAV:RANG %d,%d',current_len, step_len);
    fprintf(os, str_range_command);
    fprintf(os, '*WAI');
    fprintf(os, ':WAV:FETC?');
    fprintf(os, '*WAI');
    % The read data consists of two parts - TMC header and data packet, like #900000ddddXXXX..., among
    % which, “dddd” reflects the length of the valid data packet in the data stream, “XXXX...” indicates the data
    % from the data packet, every 2 bytes forms one effective data, to be 16-bit signed integer data
    data.points(current_len+1:current_len+step_len,1) = binblockread(os, 'int16');
    % DUAL channel status
        if isequal(chs_disp,[1 1])
            str_beg_command = ':WAV:BEG CH2';
            fprintf(os, str_beg_command);
            fprintf(os, str_range_command);
            fprintf(os, '*WAI');
            fprintf(os, ':WAV:FETC?');
            fprintf(os, '*WAI');
            data.points(current_len+1:current_len+step_len,2) = binblockread(os, 'int16');
            str_beg_command = ':WAV:BEG CH1';
            fprintf(os, str_beg_command);
        end
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
%%
function [sample, chs_status] = get_sample_rate(os)
%% MAPs
% MaxRate map
key_chs = {'single','dual'};
maxrate_vals = [1e9 0.5e9];
map_maxrate = containers.Map(key_chs, maxrate_vals);
% Sample Points / division map
key_depmem = {'1K->', '10K->', '100K->', '1M->', '10M->'};
samplepts_vals = [50 500 5e3 50e3 500e3];
map_samplepts = containers.Map(key_depmem, samplepts_vals);
% Timebase
key_timebase = {'2.0ns->','5.0ns->','10ns->','20ns->','50ns->','100ns->','200ns->','500ns->',...
            '1.0us->','2.0us->','5.0us->','10us->','20us->','50us->','100us->','200us->','500us->'...
            '1.0ms->','2.0ms->','5.0ms->','10ms->','20ms->','50ms->','100ms->','200ms->','500ms->',...
            '1.0s->','2.0s->','5.0s->' ,'10s->','20s->','50s->','100s->'};
timebase_vals = [2e-9 5e-9 10e-9 20e-9 50e-9 100e-9 200e-9 500e-9 ...
            1e-6 2e-6 5e-6 10e-6 20e-6 50e-6 100e-6 200e-6 500e-6 ...
            1e-3 2e-3 5e-3 10e-3 20e-3 50e-3 100e-3 200e-3 500e-3 ...
            1 2 5 10 20 50 100];
map_timebase = containers.Map(key_timebase, timebase_vals);
%% Query instrument
% Ch Status
ch1stat = query(os, ':CH1:DISP?'); chs2stat = query(os, ':CH2:DISP?');
if strcmp(strcat(ch1stat), 'ON->') && strcmp(strcat(chs2stat), 'ON->')
    CH_status = 'dual'; chs_status = [1 1];
elseif strcmp(strcat(ch1stat), 'OFF->') && strcmp(strcat(chs2stat), 'OFF->')
    disp('Turning ON CH1')
    CH_status = 'single'; chs_status = [1 0];
elseif strcmp(strcat(ch1stat), 'ON->') && strcmp(strcat(chs2stat), 'OFF->')
    CH_status = 'single'; chs_status = [1 0];
elseif strcmp(strcat(ch1stat), 'OFF->') && strcmp(strcat(chs2stat), 'ON->')
    CH_status = 'single'; chs_status = [0 1];
end
% Timebase
tbase = query(os, ':HORI:SCAL?');
% Depth mem
depmem = query(os, ':ACQ:DEPMEM?');
%% Sample struct output
maxRate = map_maxrate(CH_status);
samplePts = map_samplepts(strcat(depmem));
timebase = map_timebase(strcat(tbase));
% Sample rule
if maxRate > samplePts/timebase
    sample = samplePts/timebase;
else
    sample = maxRate;
end

end