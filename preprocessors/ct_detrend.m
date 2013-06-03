function x = ct_detrend(x, options)
[nrecordings len] = size(x);
% Detrends both contours and halos.
detrend_order = options.detrendOrder.value;
detrend_type = options.detrendType.value;

% polyval does not accept a matrix of inputs so we must put a for loop
% around the code, one iteration for each recording.
time_res = options.timeRes.value;
start_idx = ceil(options.startTime.value/time_res);
stop_idx = floor(options.stopTime.value/time_res);

if (start_idx < 1 | start_idx > len)
    start_idx = 1;
end
if (stop_idx < 1 | stop_idx > len)
    stop_idx = len;
end

xnew = x(:,start_idx:stop_idx);

xidx = [1:len];
xidxnew = [start_idx:stop_idx];
trend = zeros(nrecordings, len);
for i = 1:nrecordings
    switch (detrend_type)
        case 'linear'
            [p, S] = polyfit(xidxnew, xnew(i,:), detrend_order);
            trend(i,:) = polyval(p,xidx);
        case 'exponential'
            [p, S] = polyfit(xidxnew, log(xnew(i,:)), detrend_order);
            trend(i,:) = exp(polyval(p,xidx));
        case 'msbackadj'
            x(i,:)=msbackadj(xidxnew',xnew(i,:)');
    end
end
x = x - trend;

