function [result, data, param] = ct_by_mask_by_region(data, handles, clustered_contour_ids,cluster_sizes,options)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.app.experiment;

param = [];
result.data.f = zeros(size(data,1),2);
nmasks = experiment.numMasks;
nregions = experiment.numRegions;
cluster_idx = 1;
contour_mask_idxs = experiment.contourMaskIdx(clustered_contour_ids);
contour_region_idxs = experiment.contourRegionIdx(clustered_contour_ids);
for midx = 1:nmasks
    for ridx = 1:nregions
        cidx_m = find(contour_mask_idxs == midx);
        cidx_r = find(contour_region_idxs == ridx);
        cidx_mr = intersect(cidx_m, cidx_r);
        result.data.f(cidx_mr, cluster_idx) =  1;
        cluster_idx = cluster_idx + 1;
    end
end

% Should anything further be computed?  No, because there is no
% need to judge the quality of the clustering.
param.clusterValidity.value = 0;
