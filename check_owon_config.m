function [config] = check_owon_config(os)
% Checking Configuration and mapping the
% ADC data convertion rule
%%
% Timebase
out = query(os, ':HORI:SCAL?');
config.timebase = strcat(out);
fprintf('HOR:SCALE %s',out);
out = query(os, ':HORI:OFFS?');
config.timeoffset = strcat(out);
fprintf('HOR:OFFSET %s',out);
%%
% Trigger
out = query(os, ':TRIG:TYPE?');
fprintf('TRIG:TYPE %s', out);
TRIGTYPE = sprintf(':TRIG:%s', out(1:end-3));
out = query(os, [TRIGTYPE ':HOLD?']);
fprintf('TRIG:HOLDOFF %s',out);
out = query(os, [TRIGTYPE ':MODE?']);
TRIGTYPEMODE = sprintf('%s:%s', TRIGTYPE, out(1:end-3));
fprintf('TRIG:MODE %s',out);
out = query(os, [TRIGTYPE ':SWE?']);
fprintf('TRIG:SWEEP %s', out);
out = query(os, [TRIGTYPEMODE ':SOUR?']);
fprintf('TRIG:SOURCE %s', out);
out = query(os, [TRIGTYPEMODE ':COUP?']);
fprintf('TRIG:COUPLING %s', out);
out = query(os, [TRIGTYPEMODE ':SLOP?']);
fprintf('TRIG:SLOPE %s', out);
out = query(os, [TRIGTYPEMODE ':LEV?']);
fprintf('TRIG:LEVEL %s', out);
%%
% Acquire
out = query(os, [':ACQ:MODE?']);
config.acq_mode = strcat(out);
fprintf('ACQ:MODE %s', out);
out = query(os, [':ACQ:DEPMEM?']);
config.acq_depmem = strcat(out);
fprintf('ACQ:DEPTHMEM %s', out);
%%
% Channel
for n = 1:2
    CHn = sprintf(':CH%d',n);
    out = query(os, [CHn ':BAND?']);
    config.ch_bwlim{n} = strcat(out);
    fprintf('%s:BWLIMIT %s', CHn, out);
    out = query(os, [CHn ':COUP?']);
    config.ch_coup{n} = strcat(out);
    fprintf('%s:COUPLING %s', CHn, out);
    out = query(os, [CHn ':SCAL?']);
    config.ch_scale{n} = strcat(out);
    fprintf('%s:SCALE %s', CHn, out);
    out = query(os, [CHn ':OFFS?']);
    config.ch_offset{n} = strcat(out);
    fprintf('%s:OFFSET %s', CHn, out);
    out = query(os, [CHn ':DISP?']);
    config.ch_status{n} = strcat(out);
    fprintf('%s:DISPLAY %s', CHn, out);   
end