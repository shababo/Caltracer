function x = ct_baseline_subtract(x, options)
% function x = ct_baseline_subtract(x, options)
%
% Subtract the baseline, which we get by takine the minimum of a
% smoothed version of the signal.
% OR
% Take a kmeans of n clusters and pick the minimum centroid.

if size(x,2)<=1
    %nothing, don't change x
else 
    method = options.method.value;
    npoints = options.nPoints.value;
    [nrecordings len] = size(x);
    small_win = ones(1,npoints)/npoints;

    switch method
     case {'smoothing' 'SMOOTHING'}
      % Subtract the baseline, which we get by takine the minimum of a
      % smoothed version of the signal.
      for i = 1:nrecordings
          smooth = conv(small_win, x(i,:));
          smooth = smooth(npoints:end-npoints);
          min_smooth = min(smooth);
          min_smooth = min_smooth(1);
          x(i,:) = x(i,:) - min_smooth;
      end
     case {'kmeans', 'KMEANS'}
      % Take a kmeans of n clusters and pick the minimum centroid.
      for i = 1:nrecordings
          c = NaN;
          nclusters = 3;
          while(find(isnan(c)))
          [idx, c] = kmeans(x(i,:)', nclusters, ...
                    'replicates', 2, ...
                    'EmptyAction', 'drop');
          end
          baseline = min(c);
          x(i,:) = x(i,:) - baseline;
      end
     otherwise
      errordlg(['Baseline subtraction method ' method ' not implmented yet.']);
    end
end