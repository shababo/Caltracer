function x = ct_lowpass_filter(x, options)
% Use the filtfilt function so that we have zero phase lag.  Remember,
% that x is a matrix, but the filtfilt command can handle this.


% Setup the options.
nlfilt = options.nlfilt.value;		% filter length
lpass = options.lpass.value;		% high pass in Hz.
Fs = 1/options.timeRes.value;		% 


[nrecordings len] = size(x);


%nlfilt = 5000;			% filter length.
if (nlfilt > len/3-1) % filt length must less than 1/3 of the data
    nlfilt = floor(len/3-1);
    if mod(nlfilt,2);
	nlfilt = nlfilt-1;
    end
end

normfreq_lpass = lpass/(Fs/2);	% 1 corresponds to Nyquist rate.
hfilt = fir1(nlfilt/2, normfreq_lpass, 'low');
xfilt = filtfilt(hfilt, 1, x')';
x = xfilt;
