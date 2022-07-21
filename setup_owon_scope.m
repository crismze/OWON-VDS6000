function [owon]  = setup_owon_scope(parameters)
% Creat a VISA-USB scope object
owon = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x5345::0x1235::2018208::0::INSTR', 'Tag', '');
if isempty(owon)
    owon = visa('NI', 'USB0::0x5345::0x1235::2018208::0::INSTR');
else
    fclose(owon);
    owon = owon(1);
end
set(owon, 'Timeout', 10.0)
npoits = 50e3; %Points per pull. Max pull at deep memory status 250e3
databytes = npoits*2;   % 2 Bytes per point
set(owon, 'InputBufferSize',databytes+100);
% Open instrument
fopen(owon);
%% My Settings
% CHs
os_settings.channels.on = [1 2];
os_settings.channels.probe = [10 10];
os_settings.channels.bwlimit = {'OFF', 'OFF'};
os_settings.channels.coupling = {'AC', 'AC'};
os_settings.channels.scale = {'1v', '2v'}; % Must consider the xFactor [2v 5v]
os_settings.channels.offset = [0 0];
% % Timebase
% SCALE
% {2.0ns|5.0ns|10ns|20ns|50ns|100ns|200ns|500ns|1.0us|2.0us|5.0us|10us|20us|50us|100us|200us|
%  500us|1.0ms|2.0ms|5.0ms|10ms|20ms|50ms|100ms|200ms|500ms|1.0s|2.0s|5.0s|10s|20s|50s|100s}
os_settings.timebase.scale = '200us';
% HOR. TRIGGER OFFSET
% in units of the scale 
os_settings.timebase.offset = 0;
% % ACQUIRE
% Mode
% {SAMPle|PEAK}
os_settings.acq.mode = 'SAMPLE';
% Deep Memory Length
% {1K|10K|100K|1M|10M}
os_settings.acq.mdep = '10M';
% % TRIGGER
% Type
% {SINgle}
os_settings.trig.type = 'SINGLE';
% Sweep
% {AUTO|NORMal|SINGle}
os_settings.trig.sweep = 'NORMAL';
% Mode EDGE
os_settings.trig.mode = 'EDGE';
os_settings.trig.source = 'CH1';
os_settings.trig.coupling = 'AC';
os_settings.trig.slope = 'RISE';
os_settings.trig.level = 1.2; % Real (>0.02) unit division 
% Holdoff
% Range 100ns - 10s
os_settings.trig.holdoff = '100ns';
%% Setup the instrument
idn = query(owon, '*IDN?');
idn = strsplit(idn, ' ');
fprintf('\nConnected to Oscilloscope: "%s %s"\n', idn{1}, idn{2});
fprintf(owon, '*RST');
fprintf(owon, ':STOP');
for n = 1:2
    CHn = sprintf(':CH%d',n);
    fprintf(owon, [CHn ':DISP OFF']);  
end
%%
% Timebase
fprintf(owon, [':HORI:SCAL ' os_settings.timebase.scale]);
fprintf(owon, [':HORI:OFFS ' num2str(os_settings.timebase.offset)]);
%%
% Trigger
fprintf(owon, [':TRIG:TYPE ' os_settings.trig.type]);
TRIGTYPE = sprintf(':TRIG:%s', os_settings.trig.type);
fprintf(owon, [TRIGTYPE ':HOLD ' os_settings.trig.holdoff]);
fprintf(owon, [TRIGTYPE ':MODE ' os_settings.trig.mode]);% mode resets the sweep 
TRIGTYPEMODE = sprintf('%s:%s', TRIGTYPE, os_settings.trig.mode);
fprintf(owon, [TRIGTYPEMODE ':SOUR ' os_settings.trig.source]);
fprintf(owon, [TRIGTYPEMODE ':COUP ' os_settings.trig.coupling]);
fprintf(owon, [TRIGTYPEMODE ':SLOP ' os_settings.trig.slope]);
fprintf(owon, [TRIGTYPEMODE ':LEV ' num2str(os_settings.trig.level)]);
fprintf(owon, [TRIGTYPE ':SWE ' os_settings.trig.sweep]);% Sweep after mode
%%
% Acquire
fprintf(owon, [':ACQ:MODE ' os_settings.acq.mode]);
fprintf(owon, [':ACQ:DEPMEM ' os_settings.acq.mdep]);

%%
% Channel
for n = 1:2
    CHn = sprintf(':CH%d',n);
    fprintf(owon, [CHn ':DISP OFF']);  
end
for n = os_settings.channels.on
    CHn = sprintf(':CH%d',n);
    fprintf(owon, [CHn ':BAND ' os_settings.channels.bwlimit{n}]);
    fprintf(owon, [CHn ':COUP ' os_settings.channels.coupling{n}]);
    fprintf(owon, [CHn ':SCAL ' os_settings.channels.scale{n}]);
    fprintf(owon, [CHn ':OFFS ' num2str(os_settings.channels.offset(n))]);
    fprintf(owon, [CHn ':DISP ON']);   
end
fclose(owon);
end
