function options = ct_dfof_options
%options = struct;

options.function.prompt = 'Mean, median filter, or mean of lower half (mean|median|lower).';
options.function.value = 'mean';

options.nSecs.value = 10;		% intentionally large
options.nSecs.prompt = 'Enter the window size, in seconds';
