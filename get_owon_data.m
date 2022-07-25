function [data, preamble] = get_owon_data(os_struct)
%% Function to get 
% This is only as a guide. For multiple channels, modify the following code
% 
os = os_struct.obj;
os_settings = os_struct.settings;
if strcmp(os.Status, 'closed')
    fopen(os); fprintf(os, ':RUN');
end
%
[data.sample_rate, chs_disp, vertical]= get_srate_chs(os);
%% 
% Counter and Preallocation
current_len = 0;
% OBS: Check always your InputBufferSize
step_len = 50000; % Test your step. The max data length that the device reads per time is 256k
if step_len > os.InputBufferSize/2-50
    step_len = os.InputBufferSize/2-50;
end
total_len = 10e6;  % Manual set from the DEPMEM query
data.points = nan(total_len,sum(chs_disp));
% flushinput(os);
%%
% fprintf(os, ':RUN');
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
preamble = fscanf(os, '%c'); 
% out = binblockread(os, 'char');
fprintf(os, '*WAI');
%%
% Data loop
try
    while current_len < total_len
    str_range_command = sprintf(':WAV:RANG %d,%d',current_len, step_len);
    fprintf(os, str_range_command);
    fprintf(os, '*WAI');
    fprintf(os, ':WAV:FETC?');
    fprintf(os, '*WAI');
    pause(0.2);
    % The read data consists of two parts - TMC header and data packet, like #900000ddddXXXX..., among
    % which, “dddd” reflects the length of the valid data packet in the data stream, “XXXX...” indicates the data
    % from the data packet, every 2 bytes forms one effective data, to be 16-bit signed integer data
    out = binblockread(os, 'int16');
    data.points(current_len+1:current_len+step_len,1) = out;
    % DUAL channel status
        if isequal(chs_disp,[1 1])
            str_beg_command = ':WAV:BEG CH2';
            fprintf(os, str_beg_command);
            fprintf(os, str_range_command);
            fprintf(os, '*WAI');
            fprintf(os, ':WAV:FETC?');
            fprintf(os, '*WAI');
            pause(0.2);
            out = binblockread(os, 'int16');
            data.points(current_len+1:current_len+step_len,2) = out;
            str_beg_command = ':WAV:BEG CH1';
            fprintf(os, str_beg_command);
        end
    current_len = current_len + step_len;
    end
catch ME
    % Sometimes there's no an effective data-packet read within the loop
    fprintf(os, ':WAV:END');
    fprintf(os, '*WAI');
    fclose(os);
    if isempty(out)
        fprintf(2,'Empty data packet\n');
        return
    else
        rethrow(ME.message)
    end
%     rethrow(ME);
end
%%
fprintf(os, ':WAV:END');
fclose(os);
%% Process data to waveform points
vscale = vertical.scale(logical(chs_disp));
voffset = vertical.offset(logical(chs_disp));
xfactor = os_settings.chs.probe(logical(chs_disp));
ximpedf = os_settings.chs.imped(logical(chs_disp));
offset_disp = 1; % To consider the offset or not
voffset = offset_disp*voffset;
for n = 1:sum(chs_disp)
    data.points(:,n) = (data.points(:,n)/6400 - voffset(n))*vscale(n)*xfactor(n)/ximpedf(n);
end
end
%%
function [sample, chs_status, vertical] = get_srate_chs(os)
%% MAPs
map = get_config_map_owon();
%% Query instrument
% Ch Status
ch1stat = query(os, ':CH1:DISP?'); chs2stat = query(os, ':CH2:DISP?');
if strcmp(strcat(ch1stat), 'ON->') && strcmp(strcat(chs2stat), 'ON->')
    CH_status = 'dual'; chs_status = [1 1];
elseif strcmp(strcat(ch1stat), 'OFF->') && strcmp(strcat(chs2stat), 'OFF->')
    warning('All channels OFF... Turning ON CH1')
    fprintf(os, ':CH1:DISP ON');
    CH_status = 'single'; chs_status = [1 0];
elseif strcmp(strcat(ch1stat), 'ON->') && strcmp(strcat(chs2stat), 'OFF->')
    CH_status = 'single'; chs_status = [1 0];
elseif strcmp(strcat(ch1stat), 'OFF->') && strcmp(strcat(chs2stat), 'ON->')
    CH_status = 'single'; chs_status = [0 1];
end
vertical.offset = nan(2,1); vertical.scale = nan(2,1);
out = query(os, ':CH1:OFFS?');
vertical.offset(1) = str2num(out(1:end-3));
out = query(os, ':CH2:OFFS?');
vertical.offset(2) = str2num(out(1:end-3));
out = strcat(query(os, ':CH1:SCAL?'));
vertical.scale(1) = map.Vscale(out);
out = strcat(query(os, ':CH2:SCAL?'));
vertical.scale(2) = map.Vscale(out);
% Timebase
tbase = query(os, ':HORI:SCAL?');
% Depth mem
depmem = query(os, ':ACQ:DEPMEM?');
%% Sample struct output
maxRate = map.maxrate(CH_status);
samplePts = map.samplepts(strcat(depmem));
timebase = map.timebase(strcat(tbase));
% Sample rule
if maxRate > samplePts/timebase
    sample = samplePts/timebase;
else
    sample = maxRate;
end
end