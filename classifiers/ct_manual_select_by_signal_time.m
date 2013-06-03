function [result, data, options] = ct_manual_select_by_signal_onset(data, handles, clustered_contour_ids,cluster_size, options)
% [result, data, options] = ct_manual_select_by_signal_onset(data,...
% handles, clustered_contour_ids,cluster_size, options)
%  Function that allows clustering based on several clicks by a user.
%  Vertical (time) values of the clicks are recorded and converted into
%  frame numbers.  If there have been signals (events) already detected,
%  the cells with first onset times occuring between each pair of clicks is
%  recorded (signals allow conversion of time delimitations to pick out
%  cells... otherwise don't know how to do something like this).  Each
%  cluster is the cells that have first onsets between a pair of the user
%  clicks.
%
%  Inputs: 
%  data = the rastermap (matrix of cell brightness vs frame number for all
%      cells in non-killed clusters)
%  handles = CalTracer handles
%  clustered_contour_ids = the ids of the cells represented in data... in
%      their original order
%  cluster_size = ? always = 3?
%  options = from options file
%
%  Outputs:
%  result = result.data.f is a matrix giving cluster assignments for each
%  cell.  Must have one column for each cluster and each cell must have a 1
%  in one and only one column, indicating which cluster it's in.
%  data = unchanged data in
%  options = potentially changed version of options in

warning off
result = [];

if prod(size(handles.app.experiment.detections))==1;%if no detections done yet
    errordlg('This function requires signals to be present.  No detections have been done.')
    params.wasError = 1;
    return
end

globals = handles.app.experiment.globals;
pidx = handles.app.data.currentPartitionIdx;
didx = handles.app.data.currentDetectionIdx;

%determine which contours to pay attention to.
numFigClusters = handles.app.experiment.partitions(pidx).numClusters;
partitionContours = [];
for cidx = 1:numFigClusters;
    partitionContours = [partitionContours handles.app.experiment.partitions(pidx).clusters(cidx).contours];
end
%NOTE... specifically do NOT sort this index... Dave expects it not to be sorted
%and compensates for it somewhere later.  Sorting completely messes up
%index.  Maybe has to do with "Order"... maybe only out of order if not
%using original order.

% partitionContours = sort(partitionContours);%eliminate artifact of being in clusters

for cid = 1:size(partitionContours,2);%for each cell
    cidx = partitionContours(cid);
    if ~isempty(handles.app.experiment.detections(didx).onsets{cidx})%if any signal detected in that trace
        temp = handles.app.experiment.detections(didx).onsets{cidx}(1);%take the first onset to use
        if temp == 0%if below zero, reset
            temp = 1;
        elseif temp > globals.numImagesProcess;%if too large, reset
            temp = globals.numImagesProcess;
        end
        ons(cid) = temp;%store
    else%if no signal
        ons(cid) = 0;%set to zero... this will not be detected later
    end
end
%ons is the list of onsets;... not logical, but a list of first onsets
%per cell

if ~sum(ons);%if no signals in this detection
    errordlg('This function requires signals to be present.  No signals have been detected here.')
    params.wasError = 1;
    return
end

[x, y] = ginput;
sel_idxs = ceil(x * handles.app.experiment.globals.fs);
sel_idxs = [0 ; sel_idxs];

result.data.f = zeros(size(partitionContours,2),(length(sel_idxs)-1));
%if cell had onset between each pair of clicks, call it a 1, if no leave 0
for sidx = 1:(length(sel_idxs)-1);
    clust = find(ons>sel_idxs(sidx) & ons<=sel_idxs(sidx+1));
%     clust = partitionContours(clust);
    result.data.f(clust,sidx*ones(size(clust))) = 1;
end

noclust = ~logical(sum(result.data.f,2));%find cells not falling into any clusters
yessignals = logical(ons)';%find cells with signals
noclustyessignals = noclust.*yessignals;%cells not yet clustered but having a signal (ie after last click)
noclustnosignals = noclust.*(~yessignals);%cells with no signals

noclustyessignals = find(noclustyessignals);%each of these two will be a new cluster
noclustnosignals = find(noclustnosignals);
if ~isempty(noclustyessignals);%if some cells were in no other cluster but had signals
    result.data.f(noclustyessignals,(sidx+1)*ones(size(noclust))) = 1;%add another column,
    sidx = sidx+1;
end
if ~isempty(noclustnosignals);%if some cells were in no other cluster... ie had no signals
    result.data.f(noclustnosignals,(sidx+1)*ones(size(noclust))) = 1;%add another column
end
warning on