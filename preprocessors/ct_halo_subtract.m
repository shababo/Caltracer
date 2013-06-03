function x = ct_halo_subtract(x, options)
% Subtract the halo from the contour. C - H.

if (options.haloMode.value == 0)
    return;
end

% First subtract the mean from each halo since we don't care about the
% average, just the differential.
[nrecordings len] = size(x);
%means = mean(x,2);
%means_mat = repmat(means, [1 len]);
%x(1:end/2,:) =
%x(1:end/2,:)-(x(end/2+1:end,:)-means_mat(end/2+1:end,:));
x(1:end/2,:) = x(1:end/2,:) - x(end/2+1:end,:);
