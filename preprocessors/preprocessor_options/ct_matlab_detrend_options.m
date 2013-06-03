function options  = ct_matlab_detrend_options
options.startTime.value = -1;		% use all data.
options.stopTime.value = -1;		% use all data.
options.dbp.value = 3;
options.startTime.prompt = 'Enter the start time for the baseline period.';
options.stopTime.prompt = 'Enter the stop time for the baseline period.';
options.dbp.prompt = 'Enter the time (s) between break points';