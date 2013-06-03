function options = ct_baseline_subtract_user_defined_options
options.startTime.value = 1;
options.stopTime.value = 2;

options.startTime.prompt = 'Enter the start time for the baseline period.';
options.stopTime.prompt = 'Enter the stop time for the baseline period.';

options.nPoints.value = 20;		% length of smoothed filter.
options.nPoints.prompt = 'Enter the length of smoothing filter.';

options.method.value = 'smoothing';	% smoothing or kmeans.
options.method.prompt = ['Enter the method for finding the baseline:' ...
		    ' kmeans or smoothing.'];
