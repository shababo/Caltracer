function options = ct_find_laser_pulses_options(handles)
options.zscoreThreshold.value=5;
options.zscoreThreshold.prompt='Z score of lasered frames';
options.MinChange.value=200;
options.MinChange.prompt='Minimum change in fluorescence to be considered laser pulse';