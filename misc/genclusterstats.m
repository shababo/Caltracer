function p = genclusterstats(handles, p, varargin)
% function p = genclusterstats(handles, p)
%
% This function generates extra information or statistics about the
% partion and clusters.  It expects that the clusters are already
% formed in so far as all the neuron ids are set for all the clusters
% in the partition.
% 
% p is the current partition, containing the cluster information.

do_compute_colors = 1;

nargs = length(varargin);
for i=1:2:nargs
    switch varargin{i}
     case 'computecolors'		
      % if kill cell, don't recompute the colors.
      do_compute_colors = varargin{i+1};      
    end
end




% Pick the color scheme.  If there is a deletion of merging of a
% cluster then we cannot pick new colors because then all the other
% colors of the clusters will be off.  Thus the reason for the
% computecolors option
if (do_compute_colors)
    if (p.numClusters > 1)
        colordiv = 1.5;
        clustercolor = hsv(p.numClusters)/colordiv + (1-1/colordiv);
    else
        clustercolor = [1 1 1];
    end
    p.colors = clustercolor;
else
    clustercolor = p.colors;
end


% Put the cleaned traces into the neuron structure hierarchy.
%for n = 1:handles.app.experiment.numContours
%    handles.app.experiment.contours(n).intensityclean = p.cleanContourTraces(n,:);
%    if (handles.app.experiment.haloMode)
%	handles.app.experiment.contours(n).haloIntensityClean = p.cleanHaloTraces(n,:);
%    end
%end

all_contours = handles.app.experiment.contours;
% Setup other "less important" information for the clusters.
%mymin_old = min([all_contours.intensityclean]);
%stddev_old = std([all_contours.intensityclean]);
%m_old = mean([all_contours.intensityclean]);
%mymax_old = m_old + 3*stddev_old;
%len_old = length(all_contours(1).intensityclean);

mymin = min(p.cleanContourTraces(:));
stddev = std(p.cleanContourTraces(:));
m = mean(p.cleanContourTraces(:));
mymax = m + 3*stddev;
len = size(p.cleanContourTraces, 2);

for i = 1:p.numClusters
    cid = p.clusters(i).id;
    cidx = find([p.clusters.id] == cid);
    % Pull out the indices of the contours that belong to the current
    % (ith) cluster.
    cluster_ids = [p.clusters(i).contours];    
    cluster_idxs = cluster_ids; % Why is this wrong anymore?
    ncontours = length(cluster_ids);
    
    % Set the color of the cluster.    
    color = clustercolor(cid,:);
    p.clusters(i).color = color;

    % Get the location of the clusters via the location of the
    % contours.
    centroids = reshape([all_contours(cluster_idxs).Centroid], ...
		       2, p.clusters(i).numContours)';    
    p.clusters(i).locMean = mean(centroids,1); % location mean.
    p.clusters(i).locCov = cov(centroids); % ellipse of one std.    
    
    % Create the color intensity plots.
    %fsclean_old = reshape([all_contours(cluster_idxs).intensityclean], ...
	%		  len, ncontours)';
    
    fsclean = p.cleanContourTraces(cluster_idxs,:);
    % This is a simple rescaling for showing color.
    fscleannorm = (fsclean-mymin)/(mymax-mymin);
    fscleannorm(find(fscleannorm > 1)) = 1;

% This is now generated in showclustercolor in preparation of
% having a generalized reordering mechanism. -DCS:2005/08/10    
%    % Create the cluster intensity map in color.
%    p.clusters(i).intensityMapColorClean = ...
%	cat(3, (fscleannorm)*color(1), ...
%	    (fscleannorm)*color(2), ...
%	    (fscleannorm)*color(3));    
    p.clusters(i).meanIntensityClean = mean(fsclean,1);
    p.clusters(i).stdIntensityClean = std(fsclean,1);
    
    % Create the clean halo mean & std plots. No need for the color
    % intensity maps at this point. -DCS:2005/05/31
    if (handles.app.experiment.haloMode)
        haloclean = p.cleanHaloTraces(cluster_idxs,:);
        p.clusters(i).meanHaloIntensityClean = mean(haloclean,1);
        p.clusters(i).stdHaloIntensityClean = std(haloclean,1);
    else
        p.clusters(i).meanHaloIntensityClean = 0;
        p.clusters(i).stdHaloIntensityClean = 0;
    end
    
    % Create the regular mean & std plot (not cleaned).
    fs = reshape([all_contours(cluster_idxs).intensity], ...
		 len, ncontours)';
    
    p.clusters(i).meanIntensity = mean(fs,1);
    p.clusters(i).stdIntensity = std(fs,1);
               
    % Create the regular halo mean & std plots (not cleaned).  
    if (handles.app.experiment.haloMode)
        fs = reshape([all_contours(cluster_idxs).haloIntensity], ...
            len, ncontours)';
        p.clusters(i).meanHaloIntensity = mean(fs, 1);
        p.clusters(i).stdHaloIntensity = std(fs,1);
    else
        p.clusters(i).meanHaloIntensity = 0;
        p.clusters(i).stdHaloIntensity = 0;
    end
end

% Now put the partition structure into it's proper place in the
% experiment structure.
pidx = handles.app.experiment.numPartitions + 1;
handles.app.experiment.numPartitions = pidx;
p.id = pidx;
p.title = num2str(p.id);
handles.app.data.currentPartitionIdx = pidx;
handles.app.experiment.partitions(pidx) = p;
