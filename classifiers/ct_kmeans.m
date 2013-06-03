function [result, data, param] = ct_kmeans(data, handles, clustered_contour_ids,cluster_size, options)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.app.experiment;
maxiter = 100;
replicates = 1;
num_contours = size(data, 1);

% Cluster the neurons and place the number in each neuron.
[clusters, means, sumd, D] = ...
    kmeans(data, cluster_size, ...
	   'Start', 'cluster', ...
	   'EmptyAction', 'singleton');

param = [];
% Create a 'hard' fuzzy cluster matrix.
clustermtx = zeros(num_contours, cluster_size);
idxs = [(1:num_contours)' clusters];
sidxs = sub2ind(size(clustermtx), idxs(:,1), idxs(:,2));
clustermtx(sidxs) = 1;
result.data.f = clustermtx;

% Put the means in the correct structure.
result.cluster.v = means;
dists = zeros(num_contours, cluster_size);
dim = size(means,2);
num_cluster_sizes = length(cluster_size);
sigmas = zeros(dim,dim,num_cluster_sizes);
for i = 1:cluster_size
    % Compute distances for every point to every cluster mean.  This
    % should be identical to D (given from 'kmeans') but I show it for
    % illustrative purposes.
    dists(:,i) = sqrt(sum([(data - repmat(means(i,:),num_contours,1)).^2],2));
    % Compute the covariance matrix of the data.
    sigmas(:,:,i) = cov(data(find(clusters == i),:));
end
result.cluster.P = sigmas;
result.data.d = dists;
