function x = ct_normalize_by_user_defined_std(x, options)

[nrecordings len] = size(x);

% Assume mean for now.

time_res = options.timeRes.value;
start_idx = ceil(options.startTime.value/time_res);
stop_idx = floor(options.stopTime.value/time_res);

% BP
if (start_idx < 1 || start_idx > len)
    start_idx = 1;
    %warndlg('Starting index less than one. Please readsjust settings.');
end
if (stop_idx < 1 || stop_idx > len)
    stop_idx = len;
    %warndlg('Stop index is less than one. Please readjust settings.');
end

for i = 1:nrecordings
    norm_factor = std(x(i,start_idx:stop_idx));
    
    if (abs(norm_factor) > 1e-10)
        x(i,:) = x(i,:) / norm_factor;
    end
end

