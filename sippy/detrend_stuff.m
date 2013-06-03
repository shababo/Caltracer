% change these guys
s = data101009s2r2.chanDev2_ai12_CurrentMC4;
bw      = 20;

% not this stuff so much
t    = length(s);
nfft    = 2^nextpow2(t);
y       = fft(s,nfft);
y(1:bw) = 0; y(end-bw+1:end)=0;
iy      = ifft(y,nfft);
ss= real(iy(1:t));

figure; plot(s); hold on; plot(ss,'r');