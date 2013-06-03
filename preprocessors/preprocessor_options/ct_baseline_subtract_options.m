function options = ct_baseline_subtract_options
options.nPoints.value = 5;		% length of smoothed filter.
options.nPoints.prompt = 'Enter the length of smoothing filter.';

options.method.value = 'smoothing';	% smoothing or kmeans.
options.method.prompt = ['Enter the method for finding the baseline:' ...
		    ' kmeans or smoothing.'];


					