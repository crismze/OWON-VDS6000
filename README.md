# OWON VDS6000 USB Oscilloscope
Matlab functions to setup and read data from OWON VDS6102 USB oscilloscopes using SCPI commands.

To create the VISA-Session with custom configuration

`os = setup_owon_scope()`

Returns
	os.obj : the instrument object.
	os.settings : the setting structure

Once created, you can modify os.settings values and configure the instrument with the new values

`os = setup_owon_scope(os)` 

To check the configuration:

`current_settings = check_owon_config(os);`

To get ADC data from the instrument:

`[data, ~] = get_owon_data(os)`

`sample_rate = data.sample_rate`

`waveform_points = data.points`

Example of the waveforms captured from both channels without considering their respective vertical offset

CH1: Test signal with Probe. 3.3V Squarte signal at 1kHz

CH2: 2V Ramp signal at 2kHz from function generatior (MULTI)
![image](./dualchannel_square_ramp.png)


