function handles = killclusters(handles, experiment, varargin)
% E = KILLCLUSTERS(G,E, varargin)
%
% Killcluster will literally remove the contours with cluster ids
% from deleteclusters.  The function removes the contours from
% E.contours.
%
% 'clusters' - Clusters to kill. ([])
%
% 'bysize' - kill clusters by the sizes found in input. ([]).
% (C) 2004 David C. Sussillo.  All rights reserved.

deleteclusters = [];
kill_by_size = 0;
kill_sizes = [];
pidx = handles.app.data.currentPartitionIdx;
p = experiment.partitions(pidx);

% Since the app.data structure tracts the GUI options for each cluster
% in each partition, it needs to be handled too, in order to keep the
% indicies in sync.
app.data.p = handles.app.data.partitions(pidx);


% For varargin:
nargs = length(varargin);
for i = 1:2:nargs
    switch varargin{i}
     case 'clusters'
      deleteclusters = varargin{i+1};
     case 'bysize'
      kill_by_size = 1;
      kill_sizes = varargin{i+1};
     otherwise
      error(['Unknown option: ' varargin{i}]);
    end
end
if (kill_by_size)
    for i = 1:p.numClusters
        if (~isempty(find(kill_sizes == p.clusters(i).numContours)))
            deleteclusters = [deleteclusters p.clusters(i).id];          
        end
    end
end


for i = deleteclusters
    if (isempty(find([p.clusters.id] == i)))
        error(['Cluster ' num2str(i) ' does not exist.']);
        return;
    end
end



% Get the deletecluster indices.
deleteclustersidx = [];
for did = deleteclusters
    didx = find([p.clusters.id] == did);
    deleteclustersidx = [deleteclustersidx didx];
end

if (isfield(p, 'clusters'))
    clusters = p.clusters;
    app.data.clusters = app.data.p.clusters;
    p = rmfield(p, 'clusters');
    app.data.p = rmfield(app.data.p, 'clusters');
else
    errordlg(['The handles.app.experiment.partition clusters fields need to' ...
	      ' be created.']);
    return;
end

% Now we have to remove the deleted clusters from the strucutre.
idx = 0;
for i = 1:p.numClusters
    if (isempty(find([deleteclusters] == clusters(i).id)))    
        idx = idx+1;
        p.clusters(idx) = clusters(i);
        app.data.p.new.clusters(idx) = app.data.clusters(i);
    end
end
p.numClusters = idx;


% Now we have to update the cluster idxs for the rest of the contours.
p.clusterIdxsByContour = updatecontourids(p.clusterIdxsByContour, deleteclustersidx);


% Now that we've deleted the 'offenseive' clusters from p we put E
% back together again.
handles.app.experiment.partitions(pidx) = p;
handles.app.data.partitions(pidx).clusters = app.data.p.new.clusters;