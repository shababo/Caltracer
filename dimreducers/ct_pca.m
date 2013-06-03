function data = ct_pca(data, options)
% Data is num_neurons x time.  

% One can see these becoming parameters in the future.
max_nscores = 100;
% Can probably do better than this with a heuristic for picking the
% number of eigenvalues based on cluster size and amount of data.
min_pc_score = 1;

ndata = size(data,1);
[pc, score, latent, tsquare] = princomp(data);
explained = 100*latent/sum(latent);


nscores = max(find(explained > min_pc_score));
nscores = nscores(1);
if (nscores > max_nscores)
    disp(['Using max nscores of ' num2str(max_nscores)]);
    nscores = max_nscores;
end
if (nscores < 1)
    nscores = 1;
    warndlg(['The first and only principle component used before' ...
	     ' clustering explains less than ' num2str(explained(1)) ...
	     ' of the variance.']);
end

% Try the idea of multiping the data by the importance of it.
%score_size = size(score);
%weights = repmat(explained(1:nscores)', score_size(1), 1);
%intensitymap = score(:,1:nscores).*weights;
data = score(:,1:nscores);