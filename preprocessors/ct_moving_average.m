function x = ct_moving_average(x, options)


window_length = options.windowLength.value;
window = options.window.value;

[nrecordings len] = size(x);

if (mod(window_length, 2) == 1)
    window_length = window_length + 1;
    warning('Adding 1 to smooth windown length to make even.');
end

w = feval(window, window_length);
norm_win = w / sum(w);			% keep amplitude the same.

% Can this be vectorized into the function? -DCS:2005/05/31
for i = 1:nrecordings
    smooth_x = conv(x(i,:), norm_win);
    x(i,:) = smooth_x(window_length/2:end-window_length/2);
end
