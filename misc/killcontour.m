function handles = killcontour(handles, deletecontour)
% handles = killcontour(handles, deletecontour)
%
% Killcontour will literally remove the contours by id from the
% deletecontour function in caltracer2.  

% It was decided to use the killcluster functionality to make this work,
% thus allowing the user to open up previous partitions easily (and
% therefore to recover previously killed contours).

% Written by Mor Dar 4/12/10 

pidx = handles.app.data.currentPartitionIdx;

    % Create another cluster containing just the chosen contours and then
    % kill that cluster.
    
    %First create the new cluster.
    varargin = [];
    nclusters = str2num(uiget(handles, 'signals', 'txnclusters', 'String'));
    ntrials = str2num(uiget(handles, 'signals', 'txntrials', 'string'));
    varargin{end+1} = 'numtrials';
    varargin{end+1} = ntrials;
    varargin{end+1} = 'contourdelete';
    varargin{end+1} = deletecontour;
    handles = createclusters(handles, nclusters, varargin{:});
    pidx = handles.app.data.currentPartitionIdx;
    partition_names = cellstr(uiget(handles, 'signals', 'clusterpopup', 'String'));
    npartitions = length(partition_names)+1;
    partition_names{end+1} = handles.app.experiment.partitions(pidx).title;
    uiset(handles, 'signals', 'clusterpopup', 'String', partition_names);
    uiset(handles, 'signals', 'clusterpopup', 'Value', npartitions);

%Call Kill Clusters
varargin = [];
varargin{1} = 'clusters';
% % Find out which cluster the contour to be deleted went into.
contourtodelete = handles.app.experiment.partitions(pidx).clusterIdxsByContour(deletecontour(1));
varargin{2} = contourtodelete{1};
handles = killclusters(handles, handles.app.experiment, varargin{:});