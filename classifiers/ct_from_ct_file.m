function [result, data, options] = ct_from_ct_file(data, handles, clustered_contour_ids,cluster_size, options)
% ct_from_ct_file
%
% The rule we employ here is if an id in clustered_contour_ids matches
% an id in p_to_copy, then we mark the correct cluster for that
% contour.  Otherwise we leave it blank, and create clusters
% should ignore that contour.
% 
% The assumption is that a user only want to use this function if the
% contour maps are identical, in which case the contour numbering is
% identical.  This typically happens when a user uses "load contours"
% on multiple movies after laboring to find the contours on the first
% movie in the sequence.

result = [];

[filename, pathname] = uigetfile({'*.mat'}, 'Choose an experiment to open');
if (~filename)
    return;
end
fnm = [pathname filename];
savestruct = load(fnm);

% Try to make savestruct backwards compatible.
[ssexp, ssappdata] = ct_add_missing_options_exp(savestruct.E, savestruct.A);
savestruct.E = ssexp;
savestruct.A = ssappdata;



titles = {ssexp.partitions.title};
% If there is one mask, then we simply take the contours from it.  Otherwise we
% list the titles of all the contour masks so that the user can decide for
% themselves which mask is appropriate.
if (length(titles) == 1)
    sel_idx = 1;
else
    [sel_idx,ok] = listdlg('PromptString','Select a partition:',...
        'SelectionMode','single',...
        'ListString', titles, ...
        'ListSize', [500 100]);
    if (~ok)
        errordlg('You must select a correct partition.');
        return;
    end
end

p_to_copy = ssexp.partitions(sel_idx);
num_clusters_to_copy = p_to_copy.numClusters;
num_contours_to_copy = length([p_to_copy.clusters.contours]);
% BP
if (num_contours_to_copy > handles.exp.numContours)
    options.error.value = ['There are more contours in the partition then in the entire current experiment.'];
    options.wasError.value = 1;
    return;
end
if (num_contours_to_copy < handles.exp.numContours)
    options.error.value = ['There are less contours in the partition then in the entire current experiment.'];
    options.wasError.value = 1;
    return;
end

result.data.f = zeros(size(data,1), num_clusters_to_copy);
% coid = contour id.  clid = cluster id.  idx = simple iterating idx
% to keep results consistent with coid.
idx = 1;
for coid = clustered_contour_ids
    clid = 0;
    for clidx = 1:num_clusters_to_copy
	if (find([p_to_copy.clusters(clidx).contours] == coid))
	    result.data.f(idx, clidx) = 1;
	end
    end
    idx = idx + 1;
end


