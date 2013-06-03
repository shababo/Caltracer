function [result, data, param] = ct_linkage(data, handles, clustered_contour_ids,cluster_size, options)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.app.experiment;
num_contours = size(data, 1);
Y = pdist(data, 'euclidean'); 
Z = linkage(Y, 'ward'); 
c = cophenet(Z,Y);
clusters = cluster(Z, 'maxclust', cluster_size);
%clusters = cluster(Z, 'cutoff', 1.1545);


param = [];
% Create a 'hard' fuzzy cluster matrix.
clustermtx = zeros(num_contours, cluster_size);
idxs = [(1:num_contours)' clusters];
sidxs = sub2ind(size(clustermtx), idxs(:,1), idxs(:,2));
clustermtx(sidxs) = 1;
result.data.f = clustermtx;

% Have to create the means.
for i = 1:cluster_size
    cidxs = find(clusters == i);
    means(i,:) = mean(data(cidxs,:));
end
    
% Put the means in the correct structure.
result.cluster.v = means;
dists = zeros(num_contours, cluster_size);
for i = 1:cluster_size
    dists(:,i) = sqrt(sum([(data - repmat(means(i,:),num_contours,1)).^2],2));
    % Compute the covariance matrix of the data.
    sigmas(:,:,i) = cov(data(find(clusters == i),:));
end
result.cluster.P = sigmas;
result.data.d = dists;

