function [result, data, param] = ct_by_selection(data, handles, clustered_contour_ids,cluster_size, options)
% This 'clustering routine' simply groups contours based on what
% the user selects with a region line, that is, ginput.

% NB -DCS:2005/08/04 Because the data matrix DOES NOT reflect all of
% the contours, the programmer MUST used clustered_contour_ids to
% index ANYTHING in experiment!
experiment = handles.app.experiment;
param = [];
param.clusterValidity.value = 0;

% Take the old cluster and add a new cluster of selected contours,
% while preserving the old structure.
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
numclusters = p.numClusters;
result.data.f = zeros(size(data,1),numclusters + 1);

height = experiment.Image(1).nY;
width = experiment.Image(1).nX; 
[x, y, h] = draw_region(width, height, ...
			'tag', 'clustering region', ...
			'enclosedspace', 1);

cidx = 1;
for cid = clustered_contour_ids
    centr = handles.app.experiment.contours(cid).Centroid;
    cluster_idx = p.clusterIdxsByContour{cid};
    if (isnan(cluster_idx))
	errordlg('Something wrong in ct_by_selection.');
	return;
    end
    in = inpolygon(centr(:,1), centr(:,2), x, y);
    if (in)
	result.data.f(cidx, numclusters+1) = 1;
    else
	result.data.f(cidx, cluster_idx) = 1;
    end
    cidx = cidx + 1;
end

pause(1);
delete(h(ishandle(h)));