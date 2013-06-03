function [result, data, param] = ct_manually_reassign_actives(data, handles, clustered_contour_ids,cluster_size, options)
% This 'clustering routine' simply returns a results matrix that
% replicates the current partition clustering exactly.

%% from ct_identity fcn
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
result.data.f = zeros(size(data,1),numclusters);


% Make the f matrix reproduce the current partition.
cidx = 1;
for cid = clustered_contour_ids
    cluster_idx = p.clusterIdxsByContour{cid};
    if (isnan(cluster_idx))
        errordlg('Something wrong in ct_identity.');
        return;
    end
    result.data.f(cidx, cluster_idx) = 1;
    cidx = cidx + 1;
end

%%
if p.numClusters == 1;
    return
end

actives = handles.app.data.activeCells;

answer = inputdlg('Assign active cell(s) to which cluster?');
answer = str2num(answer{1});
for cidx = 1:p.numClusters
    currentclusts(cidx) = p.clusters(cidx).id;
end
if ismember(answer,currentclusts)
    new = zeros(1,numclusters);
    new(answer) = 1;
    for aidx = 1:length(actives)
        idx = find(clustered_contour_ids == actives(aidx));
        result.data.f(idx,:) = new;
    end
else
    error('Must assign cells into already-existing cluster')
end 