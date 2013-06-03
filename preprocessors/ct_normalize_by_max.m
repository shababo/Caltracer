function x = ct_normalize_by_max(x, options)

npoints = options.nPoints.value;
method = 'smoothing';
[nrecordings len] = size(x);
small_win = ones(1,npoints)/npoints;

switch method
 case {'smoothing' 'SMOOTHING'}
  % Subtract the baseline, which we get by takine the minimum of a
  % smoothed version of the signal.
  for i = 1:nrecordings
      smooth = conv(small_win, x(i,:));
      smooth = smooth(npoints:end-npoints);
      max_smooth = max(smooth);
      max_smooth = max_smooth(1);
      x(i,:) = x(i,:) / max_smooth;
  end
end