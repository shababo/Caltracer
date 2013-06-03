function options  = ct_lowpass_filter_options
%This file defines the options for a given preprocessing unit, as
% well as the defaults and appropriate questions to get the right
% answers from a user.  

% Variables.
options.nlfilt.value = 10;
options.nlfilt.prompt = 'Please enter the filter length.';

options.lpass.value = 1;		% 1 Hz
options.lpass.prompt = 'Please enter the low pass band (Hz).';

