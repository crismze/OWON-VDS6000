% Checking Configuration
%%
% Timebase
out = query(os, ':HORI:SCAL?');
fprintf('HOR:SCALE %s',out);
out = query(os, ':HORI:OFFS?');
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
fprintf('ACQ:MODE %s', out);
out = query(os, [':ACQ:DEPMEM?']);
fprintf('ACQ:DEPTHMEM %s', out);
%%
% Channel
for n = 1:2
    CHn = sprintf(':CH%d',n);
    out = query(os, [CHn ':BAND?']);
    fprintf('%s:BWLIMIT %s', CHn, out);
    out = query(os, [CHn ':COUP?']);
    fprintf('%s:COUPLING %s', CHn, out);
    out = query(os, [CHn ':SCAL?']);
    fprintf('%s:SCALE %s', CHn, out);
    out = query(os, [CHn ':OFFS?']);
    fprintf('%s:OFFSET %s', CHn, out);
    out = query(os, [CHn ':DISP?']);
    fprintf('%s:DISPLAY %s', CHn, out);   
end