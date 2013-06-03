function options = ct_moving_average_options
options.window.value = 'rectwin';
options.windowLength.value = 10;

options.window.prompt = 'Enter the window function. (Valid MatLab window.)';
options.windowLength.prompt = 'Enter the smoothing window length.';
		    