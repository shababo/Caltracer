function x = ct_derivative(x, options)

% Should give a central derivative here. -DCS:2005/05/31
time_res = options.timeRes.value;
[nrecordings len] = size(x);

% Simple difference.
%dx2 = [zeros(nrecordings, 1) diff(x')']/time_res;

% Central difference derivative approximation. (MatLab 6, pg. 331)
% "The central difference approximation is nearly two orders of
% magnitude more accurate than the forward or backward difference
% approximations."

% keep tolerence relevant across amplitude scales with zscore.

dx = [ (x(:,3:end)-x(:,1:end-2)) / (2*time_res) ];

% Try not to interfere, so pad with similar values.
padding1 = dx(:,1);
padding2 = dx(:,end);
x = [padding1 dx padding2];

