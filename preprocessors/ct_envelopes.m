function x = ct_envelopes(x, options)
% Sometime we just want the absolute magnitude of the energy and
% the Hilber transform can help us out.
[nrecordings len] = size(x);

% Yep, sure can.
x = abs(hilbert(x')');
