function x = ct_highpass_filter(x, options)
% Use the filtfilt function so that we have zero phase lag.  Remember,
% that x is a matrix, but the filtfilt command can handle this.

% Setup the options.
nhfilt = options.nhfilt.value;		% filter length
hpass = options.hpass.value;		% high pass in Hz.
Fs = 1/options.timeRes.value;		% Sampling frequency.

[nrecordings len] = size(x);

%nhfilt = 5000;			% filter length.
if (nhfilt > len/3-1) % filt length must less than 1/3 of the data
    nhfilt = floor(len/3-1);
    if mod(nhfilt,2);
	nhfilt = nhfilt-1;
    end
end

normfreq_hpass = hpass/(Fs/2)	% 1 corresponds to Nyquist rate.
hfilt = fir1(nhfilt/2, normfreq_hpass, 'high');
xfilt = filtfilt(hfilt, 1, x')';
x = xfilt;
