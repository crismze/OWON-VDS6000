function [os]  = setup_owon_scope(varargin)
% Input arguments check
os = check_args(nargin,varargin);
% Create a VISA-USB scope object
% os.obj = instrfind('Type', 'visa-usb', 'RsrcName', 'USB0::0x5345::0x1235::2018208::0::INSTR', 'Tag', '');
if isempty(os.obj)
    os.obj = visa('NI', 'USB0::0x5345::0x1235::2018208::0::INSTR');
else
    fclose(os.obj);
    os.obj = os.obj(1);
end
set(os.obj, 'Timeout', 15.0)
npoits = 100e3; %Points per pull. Max pull at deep memory status 250e3
databytes = npoits*2;   % 2 Bytes per point
set(os.obj, 'InputBufferSize',databytes+100);
%% Setup the instrument
% Open instrument
os = check_settings(os);
fopen(os.obj);
idn = query(os.obj, '*IDN?');
idn = strsplit(idn, ' ');
fprintf('\nConnected to Oscilloscope: "%s %s"\n', idn{1}, idn{2});
fprintf(os.obj, '*RST');
fprintf(os.obj, ':STOP');
for n = 1:2
    CHn = sprintf(':CH%d',n);
    fprintf(os.obj, [CHn ':DISP OFF']);  
end
%%
% Trigger
fprintf(os.obj, [':TRIG:TYPE ' os.settings.trig.type]);
TRIGTYPE = sprintf(':TRIG:%s', os.settings.trig.type);
fprintf(os.obj, [TRIGTYPE ':MODE ' os.settings.trig.mode]);% mode resets the sweep 
TRIGTYPEMODE = sprintf('%s:%s', TRIGTYPE, os.settings.trig.mode);
fprintf(os.obj, [TRIGTYPEMODE ':SOUR ' os.settings.trig.source]);
fprintf(os.obj, [TRIGTYPEMODE ':SLOP ' os.settings.trig.slope]);
fprintf(os.obj, [TRIGTYPEMODE ':LEV ' num2str(os.settings.trig.level)]);
fprintf(os.obj, [TRIGTYPEMODE ':COUP ' os.settings.trig.coupling]);
fprintf(os.obj, [TRIGTYPE ':HOLD ' os.settings.trig.holdoff]);
fprintf(os.obj, [TRIGTYPE ':SWE ' os.settings.trig.sweep]);% Sweep after mode
%%
% Channel
for n = 1:2
    CHn = sprintf(':CH%d',n);
    fprintf(os.obj, [CHn ':DISP OFF']);  
end
for n = os.settings.chs.on
    CHn = sprintf(':CH%d',n);
    fprintf(os.obj, [CHn ':BAND ' os.settings.chs.bwlimit{n}]);
    fprintf(os.obj, [CHn ':COUP ' os.settings.chs.coupling{n}]);
    fprintf(os.obj, [CHn ':SCAL ' os.settings.chs.scale{n}]);
    fprintf(os.obj, [CHn ':OFFS ' num2str(os.settings.chs.offset(n))]);
    fprintf(os.obj, [CHn ':DISP ON']);   
end
%%
% Acquire
fprintf(os.obj, [':ACQ:MODE ' os.settings.acq.mode]);
fprintf(os.obj, [':ACQ:DEPMEM ' os.settings.acq.mdep]);
fprintf(os.obj, ':ACQ:PRE 8');
%%
% Timebase
fprintf(os.obj, [':HORI:SCAL ' os.settings.timebase.scale]);
fprintf(os.obj, [':HORI:OFFS ' num2str(os.settings.timebase.offset)]);
%%
fprintf(os.obj, ':RUN');
% fclose(os.obj);
end
%%
function os = check_settings(os)
if isempty(os.settings)
%% My Settings
% CHs
os.settings.chs.on = [1 2];
os.settings.chs.probe = [1 10]; % the instrument is always displays the x10 factor
os.settings.chs.imped = [2 1]; % 1: 10MOhm Probe % 2: 50Ohm BNC cable
os.settings.chs.bwlimit = {'OFF', 'OFF'};
os.settings.chs.coupling = {'DC', 'DC'};
os.settings.chs.scale = {'5v', '200mv'}; % Must consider which channel has the x10 probe connected
os.settings.chs.offset = [0 0];
% % Timebase
% SCALE
% {2.0ns|5.0ns|10ns|20ns|50ns|100ns|200ns|500ns|1.0us|2.0us|5.0us|10us|20us|50us|100us|200us|
%  500us|1.0ms|2.0ms|5.0ms|10ms|20ms|50ms|100ms|200ms|500ms|1.0s|2.0s|5.0s|10s|20s|50s|100s}
os.settings.timebase.scale = '100us';
% HOR. TRIGGER OFFSET
% in units of the scale 
os.settings.timebase.offset = 0;
% % ACQUIRE
% Mode
% {SAMPle|PEAK}
os.settings.acq.mode = 'SAMPLE';
% Deep Memory Length
% {1K|10K|100K|1M|10M}
os.settings.acq.mdep = '10M';
% % TRIGGER
% Type
% {SINgle}
os.settings.trig.type = 'SINGLE';
% Sweep
% {AUTO|NORMal|SINGle}
os.settings.trig.sweep = 'AUTO';
% Mode EDGE
os.settings.trig.mode = 'EDGE';
os.settings.trig.source = 'CH1';
os.settings.trig.coupling = 'DC';
os.settings.trig.slope = 'RISE';
os.settings.trig.level = 1; % +-5 (>0.02) 
% Holdoff
% Range 100ns - 10s
os.settings.trig.holdoff = '100ns';
end
end

function os = check_args(nin, vargin)
if isempty(vargin)
    [os.obj, os.settings] = deal([]);
    os.settings = [];
elseif nin==1
    os = vargin{1};
elseif nin==2
    [os.obj, os.settings] = deal(vargin);
end
% Checking valid object instrument
if isobject(os.obj) && ~isvalid(os.obj)
    os.obj = [];
end
end