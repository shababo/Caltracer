function [result, data, param] = ct_onecluster(data,handles,clustered_contour_ids,cluster_sizes,options)

% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.app.experiment;

param = [];
param.clusterValidity.value = 0;
result.data.f = zeros(size(data,1),2);
result.data.f(:,1) = 1;

% Should anything further be computed?  No, because there is no
% need to judge the quality of the clustering.
