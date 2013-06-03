function [result, data, param] = ct_by_region(data, handles, clustered_contour_ids,cluster_sizes,options)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.app.experiment;
param = [];
param.clusterValidity.value = 0;
nregions = experiment.numRegions;
result.data.f = zeros(size(data,1),nregions);
contour_region_idxs = experiment.contourRegionIdx(clustered_contour_ids);
for ridx = 1:nregions
    cidx = find(contour_region_idxs == ridx);
    result.data.f(cidx, ridx) =  1;
end
% Should anything further be computed?  No, because there is no
% need to judge the quality of the clustering.
