function options  = ct_highpass_filter_options
% This file defines the options for a given preprocessing unit, as
% well as the defaults and appropriate questions to get the right
% answers from a user.  

% Variables.
% options.nhfilt;				% filter length
% options.lpass;				% high pass in Hz.
% Defaults.
options.nhfilt.value = 10;
options.nhfilt.prompt = 'Please enter the filter length.';

options.hpass.value = 1;		% 1 Hz
options.hpass.prompt = 'Please enter the high pass band (Hz).';

