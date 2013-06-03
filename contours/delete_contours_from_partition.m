function handles = delete_contours_from_partition(handles, contour_ids)
% function handles = delete_contours_from_partition(handles, contour_ids)
%
% Delete the contours from any cluster in the current partition.

pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);

num_clusters = p.numClusters;
for nid = contour_ids
    % First find the correct cluster.
    ccidx = [];				% contour index in cluster.
    for cidx = 1:num_clusters
	ccidx = find(p.clusters(cidx).contours == nid);
	if(~isempty(ccidx))
	    break;
	end	
    end    
    % If we don't find the cluster then we just skip the contour id
    % because we want to be forgiving.
    if (isempty(ccidx))
	continue;
    end    
    if (p.clusters(cidx).numContours == 1)
	errordlg(['This contour is a cluster of only one cell.' ...
		  '  Please delete the cluster to get rid of the' ...
		  ' cell.']);
	return;
    end
    % Get rid of the contour in the cluster.
    p.clusters(cidx).contours(ccidx) = [];
    p.clusters(cidx).numContours = p.clusters(cidx).numContours - 1;
    % Note that it is now deleted in the cross index.
    p.clusterIdxsByContour{nid} = NaN;
end

% Regenerate the cluster statistics for all clusters.
p = genclusterstats(handles, p, 'computecolors', 0);

% Put humpty-dumpty back together again.
handles.app.experiment.partitions(pidx) = p;

