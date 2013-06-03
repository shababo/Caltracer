function x = ct_baseline_subtract_user_defined(x, options)
% function x = ct_baseline_subtract_user_defined(x, options)
%
% Subtract the baseline, which we get by takine the minimum of a
% smoothed version of the signal.  OR Take a kmeans of n clusters and
% pick the minimum centroid.
%
% This routine focuses on a peice of the signal that is specified by
% the user.
[nrecordings len] = size(x);

% Assume mean for now.

time_res = options.timeRes.value;
start_idx = ceil(options.startTime.value/time_res);
stop_idx = floor(options.stopTime.value/time_res);

% BP
if (start_idx < 1)
    if (start_idx < 0)
	warndlg(['Starting index less than one. Please readsjust' ...
		 ' settings.']);
    end
    start_idx = 1;
end
if (stop_idx > len)
    stop_idx = len;
    warndlg('Stop index is less than one. Please readjust settings.');
end


method = options.method.value;
npoints = options.nPoints.value;
if (stop_idx - start_idx < npoints)
    npoints = stop_idx - start_idx;
    warndlg(['Smoothing filter is being shortened to the length of' ...
	     ' the user defined area.']);
end
small_win = ones(1,npoints)/npoints;

switch method
 case {'smoothing' 'SMOOTHING'}
  % Subtract the baseline, which we get by takine the minimum of a
  % smoothed version of the signal.
  for i = 1:nrecordings
      smooth = conv(small_win, x(i,start_idx:stop_idx));
      smooth = smooth(npoints:end-npoints);
      min_smooth = min(smooth);
      min_smooth = min_smooth(1);
      x(i,:) = x(i,:) - min_smooth;
  end
 case {'kmeans', 'KMEANS'}
  % Take a kmeans of n clusters and pick the minimum centroid.
  for i = 1:nrecordings
      c = NaN;
      nclusters = 2;
      while(find(isnan(c)))
	  [idx, c] = kmeans(x(i,start_idx:stop_idx)', nclusters, ...
			    'replicates', 2, ...
			    'EmptyAction', 'drop');
      end
      baseline = min(c);
      x(i,:) = x(i,:) - baseline;
  end
 otherwise
  errordlg(['Baseline subtraction method ' method ' not implmented yet.']);
end
