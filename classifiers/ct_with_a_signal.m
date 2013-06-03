function [result, data, param] = ct_with_a_signal(data, handles, clustered_contour_ids,cluster_size, options)

% This 'clustering routine' simply groups contours based on the
% active cells.

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
didx = handles.app.data.currentDetectionIdx;
d = handles.app.experiment.detections(didx);
cidx = 1;
active_cells = handles.app.data.activeCells;
for cid = clustered_contour_ids
    cluster_idx = p.clusterIdxsByContour{cid};
    if (isnan(cluster_idx))
	errordlg('Something wrong in ct_by_selection.');
	return;
    end
    in = ~isempty(d.onsets{cid});
    if (in)
	result.data.f(cidx, numclusters+1) = 1;
    else
	result.data.f(cidx, cluster_idx) = 1;
    end
    cidx = cidx + 1;
end
