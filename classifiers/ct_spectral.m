function [result, data, param] = ct_spectral(data, handles, clustered_contour_ids,cluster_size, options)

% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment!
experiment = handles.app.experiment;
num_contours = size(data, 1);
sigma = 10;
smoothing_constant = 0;

%S = S_from_points(score(:,1:nscores)', sigma, smoothing_constant, 0);
% old.
%S = S_from_points(data', sigma, smoothing_constant, 0);
%clusters = cluster_spectral_general(S, cluster_size, 'njw','ward');

% New.
exp_mult_factor = -0.5/(sigma*sigma); 
%num_vectors = size(points,2);
A = squareform(pdist(data)); % need to transpose it pdist expects row vectors
A = exp(exp_mult_factor*A);

% The NJW algorithm
% Compute Laplacian L=D^-1/2 A D^-1/2
D = diag(sum(A));
Dsqrt = sqrt(D);
L = Dsqrt\A/Dsqrt;
% Above presription for L is faster, though not the direct formula.  The two
% incantations are equivalent.
%Dsqrtinv = D^(-1/2);
%L = Dsqrtinv*A*Dsqrtinv;
% the top k EV
opts.disp = 0;
Ldiff = L-L';
if max(max(abs(Ldiff))) < 1e-20 % the matrix is symm
    [v d] = eigs(L, cluster_size, 'la', opts);
else
    [v d] = eigs(L, cluster_size,'lr',opts);
end
dk = diag(d);  % top cluster_sizes work of eigenvalues.
X = v; 

% normalize along 2nd dimension to make rows have unit length.
n = size(X,1);
ss = sqrt(sum(X.^2, 2));   % normalize
Y = zeros(size(X,1),size(X,2));
for i=1:n
    if ss(i) == 0 
        1; %Y(i,:) = 0;
    else
        Y(i,:) = X(i,:)/ss(i);
    end
end

% 
% % Data
% data_s.X = Y;
% %parameters
% param.c = cluster_size;
% param.m = 2;
% param.e = 1e-6;
% param.ro = ones(1, param.c);
% param.val = 3;
% %clustering
% result = FCMclust(data_s, param);
% return;
data = Y;

% Run kmeans.
maxiter = 100;
replicates = 1;
distancefun = 'sqEuclidean';
% Cluster the neurons and place the number in each neuron.
[clusters, means, sumd, D] = ...
    kmeans(data, cluster_size, ...
	   'start', 'cluster', ...
	   'distance', distancefun, ...
	   'display', 'notify', ...
	   'maxiter', maxiter, ...
	   'replicates', replicates, ...
	   'EmptyAction', 'singleton',...
	   'start', 'sample');

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



 


