function map = get_config_map_owon()
%% MAPs
% MaxRate map
key_chs = {'single','dual'};
maxrate_vals = [1e9 0.5e9];
map.maxrate = containers.Map(key_chs, maxrate_vals);
% Sample Points / division map
key_depmem = {'1K->', '10K->', '100K->', '1M->', '10M->'};
samplepts_vals = [50 500 5e3 50e3 500e3];
map.samplepts = containers.Map(key_depmem, samplepts_vals);
% Timebase
key_timebase = {'2.0ns->','5.0ns->','10ns->','20ns->','50ns->','100ns->','200ns->','500ns->',...
            '1.0us->','2.0us->','5.0us->','10us->','20us->','50us->','100us->','200us->','500us->'...
            '1.0ms->','2.0ms->','5.0ms->','10ms->','20ms->','50ms->','100ms->','200ms->','500ms->',...
            '1.0s->','2.0s->','5.0s->' ,'10s->','20s->','50s->','100s->'};
timebase_vals = [2e-9 5e-9 10e-9 20e-9 50e-9 100e-9 200e-9 500e-9 ...
            1e-6 2e-6 5e-6 10e-6 20e-6 50e-6 100e-6 200e-6 500e-6 ...
            1e-3 2e-3 5e-3 10e-3 20e-3 50e-3 100e-3 200e-3 500e-3 ...
            1 2 5 10 20 50 100];
map.timebase = containers.Map(key_timebase, timebase_vals);
% Volt scale
key_Vscale = {'2.0mV->' ,'5.0mV->' ,'10.0mV->' ,'20.0mV->' ,'50.0mV->' ,...
            '100mV->' ,'200mV->' ,'500mV->' ,'1.00V->' ,'2.00V->' ,'5.00V->'};
Vscale_vals = [2e-3 5e-3 10e-3 20e-3 50e-3 100e-3 200e-3 500e-3 1 2 5];
map.Vscale = containers.Map(key_Vscale, Vscale_vals);
end