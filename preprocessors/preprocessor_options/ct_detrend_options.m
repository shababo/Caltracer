function options  = ct_detrend_options
options.startTime.value = -1;		% use all data.
options.stopTime.value = -1;		% use all data.
options.startTime.prompt = 'Enter the start time for the baseline period.';
options.stopTime.prompt = 'Enter the stop time for the baseline period.';


options.detrendOrder.value = 1;		% line 
options.detrendType.value = 'msbackadj';	% linear or exponential
                                        % supported. 
					
options.detrendOrder.prompt = ['Enter the polynomial order for' ...
		    ' detrending.'];
options.detrendType.prompt = ['Enter type of detrending (linear|exponential|msbackadj).'];