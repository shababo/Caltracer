function ft_traces = detrend(data) % data should be a vector

%This function is called upon in corr_traces and fixes drift in ephys
%traces by filtering out low frequencies

bw      = 30; %this number can be changed according to which frequencies should be filtered

t    = length(data);
nfft    = 2^nextpow2(t);
y       = fft(data,nfft);
y(1:bw) = 0; y(end-bw+1:end)=0;
iy      = ifft(y,nfft);
ft_traces = real(iy(1:t));

figure; plot(data); hold on; plot(ft_traces,'r');
end
