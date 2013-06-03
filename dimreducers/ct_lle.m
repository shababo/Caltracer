function data = ct_lle(data, options)

ndata = size(data,1);
[pc, score, latent, tsquare] = princomp(data);
explained = 100*latent/sum(latent);
max_nscores = 50;
min_pc_score = 1;
nscores = max(find(explained > min_pc_score));
nscores = nscores(1);
if (nscores > max_nscores)
    disp(['Using max nscores of ' num2str(max_nscores)]);
    nscores = max_nscores;
end
    
% Not sure how much this is really helping right now because I think
% that a linear embedding is OK for our signals.  In other words, our
% signals fill out pancakes in N-space. -DCS:2005/05/17
%data = score(:,1:nscores);

% Now that we know how many significant components there are to a
% linear model, let's use locally linear embedding to search for
% nonlinear manifolds.
    
nneighbors = fix(sqrt(ndata));
nneighbors = 25;
data = lle(data', nneighbors, nscores)';
    
    
% Since nscores is the max embedding dimensionality we use PCA to
% get rid of any extra dimensions (there's typically one).
[pc, score, latent, tsquare] = princomp(data);
explained = 100*latent/sum(latent);
max_nscores = 100;
min_pc_score = 1;
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
data = score(:,1:nscores);