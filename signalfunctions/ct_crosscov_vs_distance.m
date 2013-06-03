function handles = ct_crosscov_vs_distance(handles)
% function handles = ct_crosscov_vs_distance(handles)
%
% Pick a contour, pick some clusters, make a measure of the cross
% covariance of that contour to the contours in the clusters.  Plot
% this against distance.


pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
cluster_ids = [p.clusters.id];

if (length(cluster_ids) > 1)
    prompt = {'Enter the cluster ids:'};
    def = {''};
    dlgTitle = 'Cross covariance vs. distance.';
    lineNo = 1;
    answer = inputdlg(prompt,dlgTitle,lineNo,def);
    if isempty(answer)
        return;
    end
    cluster_ids_for_crosscov = str2num(answer{1});
else
    cluster_ids_for_crosscov = cluster_ids;
end
cluster_ids_for_crosscov = intersect(cluster_ids_for_crosscov, cluster_ids);

% Get the contour ids of all the contours in the clusters.
contour_ids = [];
for cid = cluster_ids_for_crosscov    
    cidx = find([p.clusters.id] == cid);    
    contour_ids = [contour_ids p.clusters(cidx).contours]; 
end
contour_ids = sort(contour_ids);

rastermap1 = p.cleanContourTraces;
% Get the start and stop indices, as well as the rastermap
% reflecting them.
[rastermap2 start_idxs stop_idxs x y] = ...
    get_raster_input(handles, rastermap1);


trace_len = size(rastermap2, 2);
tidx = 1;

% Get the first cell to compare against.  There are two highlighting
% modes.  One where there are many (activeCells) and one where there
% is only one. (currentCellId).
if (~handles.app.data.useContourSlider)
    i = handles.app.data.activeCells;    
    if (length(i) < 1)
        errordlg('There must be one active cell to compare to.');        
        return;
    end
    if (length(i) > 1)
	warndlg(['There are multiple active cells.  Using contour ' num2str(i(1)) '.']);
    end
    i = i(1);
else
    i = handles.app.data.currentCellId;
end
clean_contour_id = i;
clean_traceA = rastermap2(clean_contour_id,:);
clean_tracesB = rastermap2(contour_ids,:);
num_contours = size(clean_tracesB, 1);

% First compute the distances between the ids.
centroidA = handles.app.experiment.contours(clean_contour_id).Centroid;
for i = 1:num_contours
    clean_traceB = clean_tracesB(i,:);
    centroidB = handles.app.experiment.contours(contour_ids(i)).Centroid;    
    distances(i) = pdist([centroidA; centroidB], 'euclidean') * ...
        handles.app.experiment.globals.mpp;
    [xcorrAB, lags] = xcorr(clean_traceA, clean_traceB);
    m = max(xcorrAB);
    m = m(1);
    maxlags(i) = lags(find(xcorrAB == m));
end
maxlags_secs = maxlags*handles.app.experiment.globals.timeRes;

figure; plot(distances, maxlags_secs, 'x');
title('Maximal cross correlation lag vs. centroid distance.');
ylabel('Maximal time lag (sec)');
xlabel('distance (um)');


% Now plot all distances against each other.
all_contour_ids = [clean_contour_id contour_ids];
all_contour_ids = unique(all_contour_ids);
all_clean_traces = rastermap2(all_contour_ids,:);
num_contours = length(all_contour_ids);
max_lag_mat = zeros(num_contours, num_contours);
distance_mat = zeros(num_contours, num_contours);
for i = 1:num_contours
    clean_trace_i = all_clean_traces(i,:);
    centroid_i = handles.app.experiment.contours(all_contour_ids(i)).Centroid;
    for j = 1:num_contours
        clean_trace_j = all_clean_traces(j,:);
        centroid_j = handles.app.experiment.contours(all_contour_ids(j)).Centroid;
        % Compute the distance.
        distances_mat(i,j) = pdist([centroid_i; centroid_j], 'euclidean') * ...
            handles.app.experiment.globals.mpp;
        % Compute the correlation.
        [xcorrIJ, lags] = xcorr(clean_trace_i, clean_trace_j);
        m = max(xcorrIJ);
        m = m(1);
        max_lag_mat(i,j) = lags(find(xcorrIJ == m));
    end
end
max_lags_secs_mat = max_lag_mat * handles.app.experiment.globals.timeRes;

figure; 
subplot 211, imagesc(max_lags_secs_mat); colorbar;
subplot 212, imagesc(distances_mat); colorbar;




qstring = ['Would you like to dump this data into the workspace?'];
button = questdlg(qstring, 'Put the data into workspace?', ...
		  'Yes', 'No', 'No');
if (strcmpi(button, 'Yes'))
    assignin('base', 'contour_idA', clean_contour_id);
    assignin('base', 'contour_idsB', contour_ids);
    assignin('base', 'maxlags', maxlags);
    assignin('base', 'maxlags_secs', maxlags_secs);
    assignin('base', 'distances', distances);
    % Matrix values.
    assignin('base', 'all_contour_ids', all_contour_ids);
    assignin('base', 'max_lags_secs_mat', max_lags_secs_mat);
    assignin('base', 'distances_mat', distances_mat);
end
