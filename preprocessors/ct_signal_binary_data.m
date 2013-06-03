function x = ct_signal_binary_data(x, handles, options)
% function x = ct_signal_binary_data(x, handles, options)

halos_mode = 0;
if size(x,1) == 2*size(handles.exp.traces,1)
    halos_mode=1;
end
    
% for didx = 1:length(handles.exp.detections);
%     charcell{didx} = handles.exp.detections(didx).title;
% end
% if length(charcell)>1;
%     [detnum,ok] = listdlg('ListString',charcell,...
%         'SelectionMode','Single',...
%         'InitialValue',length(charcell),...
%         'PromptString','Select signals you want to binarize by');
%     if ok == 0;
%         return
%     end
% end
detnum = handles.appData.currentDetectionIdx;

x = zeros(size(handles.exp.traces));
for cidx = 1:size(x,1) %for each cell
    for oidx = 1:length(handles.exp.detections(detnum).onsets{cidx});
        on = handles.exp.detections(detnum).onsets{cidx}(oidx);
        off = handles.exp.detections(detnum).offsets{cidx}(oidx);
        x(cidx,[on:off]) = 1;
    end
end

if halos_mode;
    x = [x; zeros(size(x))];
end

%
% Subtract the baseline, which we get by takine the minimum of a
% smoothed version of the signal.
% OR
% Take a kmeans of n clusters and pick the minimum centroid.

% method = options.method.value;
% npoints = options.nPoints.value;
% [nrecordings len] = size(x);
% small_win = ones(1,npoints)/npoints;
% 
% switch method
%  case {'smoothing' 'SMOOTHING'}
%   % Subtract the baseline, which we get by takine the minimum of a
%   % smoothed version of the signal.
%   for i = 1:nrecordings
%       smooth = conv(small_win, x(i,:));
%       smooth = smooth(npoints:end-npoints);
%       min_smooth = min(smooth);
%       min_smooth = min_smooth(1);
%       x(i,:) = x(i,:) - min_smooth;
%   end
%  case {'kmeans', 'KMEANS'}
%   % Take a kmeans of n clusters and pick the minimum centroid.
%   for i = 1:nrecordings
%       c = NaN;
%       nclusters = 3;
%       while(find(isnan(c)))
% 	  [idx, c] = kmeans(x(i,:)', nclusters, ...
% 			    'replicates', 2, ...
% 			    'EmptyAction', 'drop');
%       end
%       baseline = min(c);
%       x(i,:) = x(i,:) - baseline;
%   end
%  otherwise
%   errordlg(['Baseline subtraction method ' method ' not implmented yet.']);
% end

