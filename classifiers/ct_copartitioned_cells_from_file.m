function [result, data, options] = ct_copartitioned_cells_from_file(data, handles, clustered_contour_ids,cluster_size, options)
% ct_from_ct_file
%
% Find displayed cells from one partition from a file and from the current
% clustering.  Make a new partition where only the cells on in both are in
% one cluster, cells on in just one are in each of their own clusters and
% cells not on are in a last cluster... label clus


result = [];

[filename, pathname] = uigetfile({'*.mat'}, 'Choose an experiment to open');
if (~filename)
    return;
end
fnm = [pathname filename];
savestruct = load(fnm);

% Try to make savestruct backwards compatible.
[ssexp, ssappdata] = ct_add_missing_options_exp(savestruct.E, savestruct.A);
savestruct.E = ssexp;
savestruct.A = ssappdata;

titles = {ssexp.partitions.title};
% If there is one mask, then we simply take the contours from it.  Otherwise we
% list the titles of all the contour masks so that the user can decide for
% themselves which mask is appropriate.
if (length(titles) == 1)
    sel_idx = 1;
else
    [sel_idx,ok] = listdlg('PromptString','Select a partition:',...
        'SelectionMode','single',...
        'ListString', titles, ...
        'ListSize', [500 100]);
    if (~ok)
        errordlg('Partition not suitably selected.');
        return;
    end
end
curr_idx=handles.appData.currentPartitionIdx;
numFigClusters = handles.exp.partitions(curr_idx).numClusters;
figContours=[];
for cidx = 1:numFigClusters;
    figContours = [figContours handles.exp.partitions(curr_idx).clusters(cidx).contours];
end
numFileClusters = savestruct.E.partitions(sel_idx).numClusters;
fileContours=[];
for cidx = 1:numFileClusters;
    fileContours = [fileContours savestruct.E.partitions(sel_idx).clusters(cidx).contours];
end


% possibleContours=1:length(handles.exp.contours);

[trash,InBoth,trash2] = intersect(figContours,fileContours);
InBoth=InBoth';
% InBoth = [InBoth ones(size(InBoth))];
[trash,OnlyInFig] = setdiff(figContours,fileContours);
OnlyInFig=OnlyInFig';
% OnlyInFig = [OnlyInFig ones(size(OnlyInFig))];
% OnlyInFile = setdiff(fileContours,figContours)';
% OnlyInFile = [OnlyInFile ones(size(OnlyInFile))];
% InNeither = setdiff(possibleContours,union(fileContours,figContours))';
% InNeither = [InNeither ones(size(InNeither))];


result.data.f = zeros(size(figContours,2),2);
% result.data.f = zeros(length(possibleContours),4);
result.data.f(InBoth,1*ones(size(InBoth))) = 1;
result.data.f(OnlyInFig,2*ones(size(OnlyInFig))) = 1;
