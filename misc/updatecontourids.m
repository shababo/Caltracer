function clusteridxs = updatecontourids(clusteridxs, deletedcluster_idxs)
% function contourids = updatecontourids(contourids, deletedcluster_idxs)
% Update the cell array of cluster ids based on the deletion of
% clusters.

nclusteridxs = length(clusteridxs);

for didx = sort(deletedcluster_idxs, 'descend')
    for i = 1:nclusteridxs
        if (didx == clusteridxs{i})
            clusteridxs{i} = NaN;
        elseif (didx < clusteridxs{i})
            clusteridxs{i} = clusteridxs{i}-1;
        end
    end
end