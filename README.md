# OWON VDS6000 USB Oscillocope
Matlab functions to setup and read data from OWON VDS6102 USB oscilloscopes using SCPI commands.

To create the VISA-Session with custom configuration
`os = setup_owon_scope()`

To check the configuration:
`fopen(os)
check_owon_config`

To get ADC data from the instrument:
`fopen(os); fprintf(os, ':RUN);` To Run the instrument and acquire data
`fprintf(os, ':STOP');`
`[data, pream] = get_owon_data(os)`
`sample_rate = data.sample_rate
adc_points_ch = data.points`


