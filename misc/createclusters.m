function handles = createclusters(handles, cluster_sizes, varargin)
% Cluster the intensity plots of  all the contours.  Attempt to cluster
% via kmeans and  using a range of  sizes.   cluster_sizes is an array  of
% sizes to attempt to cluster.  We will compute the silhouette test in
% order to know.
%
% Variable arguments are: 
% 'debug': 1 for yes, 0 for no. 
% 
% 'start': The _time_ in seconds demarking the beginning of the data
% used to cluster.
% 
% 'start_idx': Simply give the first index to cluster on.
%
% 'stop': The _time_ in seconds demarking the end of the data used to
% cluster.
%
% 'stop_idx': Simply give the last index to cluster on.
%

%
% (C) 2004 David C. Sussillo.  All rights reserved.

all_contours = handles.app.experiment.contours;
globals = handles.app.experiment.globals;
num_cluster_sizes = length(cluster_sizes);
keep_partition_contours = 1;
keep_partition_clusters = 0;
% Options
do_order_clusters = 1;
start_idx = 1;
stop_idx = globals.numImagesProcess;
debug = 0;
start_time = 0;				% seconds
stop_time = globals.numImagesProcess/globals.fs;	% seconds
deletecontour = 0;
% The case where we don't inherit the preprocessing options, but take
% new ones.
is_new_preprocessing = 0;		
do_onecluster = 0;
num_trials = 1;
nargs = length(varargin);
for i = 1:2:nargs
    switch varargin{i},
     case 'onecluster'
          do_onecluster = varargin{i+1};
     case 'numtrials'
          num_trials = varargin{i+1};
     case 'start'
          start_time = varargin{i+1};
          start_idx = floor(start_time*globals.fs+1) - globals.movie_start_idx;
     case 'stop'
          stop_time = varargin{i+1}
          stop_idx = floor(stop_time*globals.fs) - globals.movie_start_idx      
     case 'start_idx'
          start_idx = varargin{i+1};
     case 'stop_idx'
          stop_idx = varargin{i+1};
     case 'debug'
          debug = varargin{i+1};
     case 'newpreprocessing'
          is_new_preprocessing = varargin{i+1};
     case 'keepcontours'
          keep_partition_contours = varargin{i+1};
     case 'keepclusters'
          keep_partition_clusters = varargin{i+1};
     case 'contourdelete'
          deletecontour = varargin{i+1};
        % This option is here and not in the clustering folder because we
        % don't want to give the user the option to separate the clusters
        % for deletion in that pull down bar.
            pidx = handles.app.data.currentPartitionIdx;
            p = handles.app.experiment.partitions(pidx);
            numclusters = p.numClusters;
            data = handles.app.experiment.partitions.cleanContourTraces;
            result.data.f = zeros(size(data,1),numclusters + 1);
            currp = handles.app.experiment.partitions(pidx);
            clustered_contour_ids = [currp.clusters.contours]; 
            cidx = 1;
            for cid = clustered_contour_ids
                cluster_idx = p.clusterIdxsByContour{cid};
                % look to see if the contour matches those to be deleted
                % and move them to a separate cluster.
                checkformatch = find (cid == deletecontour);
                if (checkformatch)
                    result.data.f(cidx,numclusters+1) = 1;
                else
                    result.data.f(cidx,cluster_idx) = 1;
                end
                cidx = cidx + 1;
            end
            options.doUseRaster.value = 0;
            options.doManyTrials.value = 0;
            params = [];
    end
end

% Sometimes the program will create a cluster of one and there is no
% point in doing extra work when this happens, as it can happen often.
%if (num_cluster_sizes == 1 & cluster_sizes == 1)
%    do_onecluster = 1;			% it's the trivial clustering method
%end
% Since the onecluster classifier is special (it doesn't do anything)
% the logic of the routine is tailored around it.  Thus we need to
% check the case that the user has specified 'ct_onecluster'.
classifier_id = uiget(handles, 'signals', 'dpclassifiers', 'value');
classifier_strings = uiget(handles, 'signals', 'dpclassifiers', 'string');
classifier = classifier_strings{classifier_id};
if (strcmp(classifier, 'onecluster'))
    do_onecluster = 1;
end


% Whenever we start a new cluster, we use the current partition as our
% starting point.  Here that's denoted as 'curr' since we are also
% creating a new one, which will be 'newp' and 'pidx'.
currpidx = handles.app.data.currentPartitionIdx;
if (currpidx < 1)        
    % Fake the last partition if it isn't created already, in other
    % words, if we are creating the first one.
    preprocess_strings = handles.app.experiment.preprocessStrings;
    preprocess_options = handles.app.experiment.preprocessOptions;
    clustered_contour_ids = [all_contours.id];
elseif (keep_partition_contours & is_new_preprocessing)
    currp = handles.app.experiment.partitions(currpidx);
    clustered_contour_ids = [currp.clusters.contours];
    preprocess_strings = handles.app.experiment.preprocessStrings;
    preprocess_options = handles.app.experiment.preprocessOptions;
elseif (keep_partition_contours & ~is_new_preprocessing)
    currp = handles.app.experiment.partitions(currpidx);
    preprocess_strings = currp.preprocessStrings;
    preprocess_options = currp.preprocessOptions;
    clustered_contour_ids = [currp.clusters.contours];    
elseif (~keep_partition_contours & is_new_preprocessing)
    clustered_contour_ids = [all_contours.id];
    preprocess_strings = handles.app.experiment.preprocessStrings;
    preprocess_options = handles.app.experiment.preprocessOptions;
elseif (~keep_partition_contours & ~is_new_preprocessing)
    currp = handles.app.experiment.partitions(currpidx);
    preprocess_strings = currp.preprocessStrings;
    preprocess_options = currp.preprocessOptions;
    clustered_contour_ids = [all_contours.id];   
end
           
num_contours = length(clustered_contour_ids);
if (max(cluster_sizes) >= num_contours)
    errordlg('Not clustering, too few contours for max cluster size..');
    return;
end

% Hmm, I can't imagine that the preprocessing would ever be valid
% because all partitions pull data from handles.app.experiment.contours, which
% changes with each preprocessing.  This means that each time we
% cluster we should reprocess the data.

    handles.app.experiment.preprocessStrings = preprocess_strings;
    handles.app.experiment.preprocessOptions = preprocess_options;
    [clean_contours, clean_halos, handles] = preprocess(handles);
    % Since clean contours takes the raw data from handles.app.experiment.contours
    % we have to put it into the correct order in order to cluster.
    % The order matters because we allow the user to reorder the
    % contours.
    orig_clean_contours = clean_contours;
    clean_contours = clean_contours(clustered_contour_ids,:);
    if (handles.app.experiment.haloMode)
        orig_clean_halos = clean_halos;
        clean_halos = clean_halos(clustered_contour_ids,:);
    end

    % In case the number of frames has changed as a result of a preprocessor (specifically ROPing):
    if (handles.app.experiment.globals.numImagesProcess/globals.fs)~= stop_time
        stop_time = handles.app.experiment.globals.numImagesProcess/globals.fs;	% seconds
        stop_idx = handles.app.experiment.globals.numImagesProcess;
    end

% Look at the options for the classifier at hand.  It's possible that
% the clustering algorithm has no interest in the raster data.  Then
% handle the clustering / classifying.
if (do_onecluster)
    classifier = 'onecluster';
elseif (keep_partition_clusters)
    classifier = 'identity';		% Used to preprocess differently.
else
    classifier_id = uiget(handles, 'signals', 'dpclassifiers', 'value');
    classifier_strings = uiget(handles, 'signals', 'dpclassifiers', 'string');
    classifier = classifier_strings{classifier_id};
end
if deletecontour == 0 % If this is not a part of the contour deletion process:
classifier_fun = ['ct_' classifier];
classifier_options = [classifier_fun '_options'];
options = feval(classifier_options);
end

% Break down any relevant options here.
do_use_raster = 1;
if (isfield(options, 'doUseRaster') & ~options.doUseRaster.value)
    do_use_raster = 0;
    start_idx = 1;
    stop_idx = 2;
end
do_many_trials = 1;
if (isfield(options, 'doManyTrials') & ~options.doManyTrials.value)
    do_many_trials = 0;
end
do_order_clusters = 1;
if (isfield(options, 'doOrderClusters') & ~options.doOrderClusters.value)
    do_order_clusters = 0;
end

% Handle the dimensionality reduction method.
dimreducer = '';
intensitymap = clean_contours;
orig_intensitymap = clean_contours;

if (do_use_raster)   
    [intensitymap start_idx, stop_idx, x, y] = ...
    get_raster_input(handles, intensitymap);
    if (~do_onecluster)
        dimreducer_id = uiget(handles, 'signals', 'dpdimreducers', 'value');
        dimreducer_strings = uiget(handles, 'signals', 'dpdimreducers', 'string');
        dimreducer = dimreducer_strings{dimreducer_id};
        dimreducer_fun = ['ct_' dimreducer];
        options_dimreduce = [];		% placeholder for later.
        options_dimreduce = add_options_from_gui(handles, options_dimreduce,...
            'startidxs',start_idx,'stopidxs',stop_idx);
        intensitymap = feval(dimreducer_fun, intensitymap, options_dimreduce);
    end    
end

% Run the clustering algorithms.  Then for all of the cluster sizes we
% check to see which had the best performance according to some
% validation measures.
idx = 1;
num_partition_trials = num_cluster_sizes*num_trials;
validitym = zeros(num_partition_trials, 8);
trial_id = zeros(num_partition_trials, 1);
cluster_colors = hsv(num_cluster_sizes);
options = user_check_options(options);
options = add_options_from_gui(handles, options);
if (do_many_trials & ...
    (length(cluster_sizes) > 1 | num_trials > 1))
    cidx = 1;
    wh = waitbar(0, 'Clustering.  Please wait.');
    for csize = cluster_sizes
        tidx = 1;
        for i = 1:num_trials
            waitbar(idx / (num_partition_trials));
            % Make the call out the clustering routine.
            [result, data, params] = ...
                feval(classifier_fun, intensitymap, handles,...
                clustered_contour_ids, csize, options);
            % Assume the called function will explain to the user.
            if (isfield(params, 'wasError') & params.wasError.value)  
                errordlg(params.error.value);
                return;
            end

            % Another indication of an error, but we respond silently.
            if (isempty(result))
                return;
            end        
            % Check for empty clusters and get rid of them.
            nclusters = size(result.data.f, 2);
            for r = nclusters:-1:1%go backwards bc you are eliminating things as you go
                %... don't want to change index numbers
                ncontours_in_cluster = length(find(result.data.f(:,r)));
                if (ncontours_in_cluster == 0)
                    result.data.f(:,r) = [];
                    nclusters=nclusters-1;
                end
            end


            % Some clustering methods modify the data, which will be
            % needed in the modified form for the validity measures.
            % E.g. ct_spectral.
            data_s.X = data;
            colors(idx,:) = cluster_colors(cidx,:);
            if(~isfield(params, 'clusterValidity') | ...
                    params.clusterValidity.value == 1)
                results{idx} = clustervalidity(result, data_s, params);
                validitym(idx,:) = ...
                    struct2array(results{idx}.validity);
            end
            idx = idx + 1;
            tidx = tidx + 1;
        end
        cidx = cidx + 1;
    end
    close(wh);
    
    % Do stuff with cluster validity if it was computed.    
    if(~isfield(params, 'clusterValidity') | ...
       params.clusterValidity.value == 1)
	
        validitym = validitym(:, [1 3:6 7 8]);
        validitym(:,1) = validitym(:,1)*-1;	% make PC negative for
                            % visual search.
        validitym = zscore(validitym);
        validitym(:,8) = mean(validitym,2);
        columninfo.titles={'# Clusters', ...
                   '# Trial',...
                   'Negative Partition Coefficient', ...
                   'Partition',...
                   'Separation',...
                   'Xie & Beni',...
                   'Dunn',...
                   'Davies-Bouldin''s', ...
                   'Fuzzy Hyper Volume', ...
                   'Zscore - Average'};        
        h = figure('Units', 'normalized', 'Position', [0.1 0.05 0.40 0.85]);;

        % Pick out the clustering that had the best validity numbers.
        spidx = 1; % For subplot indexing.
        vidx = 1;  % For validity measure indexing.
        height = 0.03;
        height_increase = 0.97/8;	% make equal to column title
        for i = 8:-1:1
            pos = [0.05 height 0.90 height_increase-0.04];
            ax(i) = subplot('position', pos);
            hold on;
            plot(validitym(:,i), '-X');
            [m,midx] = min(validitym(:,i));
            plot(midx,m, 'O', 'MarkerSize', 8);

            height = height+height_increase;
            vidx = vidx + 1;
            spidx = spidx + 1;
            hold off;

            title(columninfo.titles{i+2});	% skip #clusters # rows.
        end

        [x, y] = ginput(1);
        user_index = round(x);
        result = results{user_index};

        if (ishandle(h))
            delete(h);
        end
    end
else    % only one size
    if deletecontour == 0 % If this is not a part of the contour deletion process:
    % Make the call out the clustering routine.
    [result, data, params] = ...
        feval(classifier_fun, intensitymap, handles,...
        clustered_contour_ids, cluster_sizes(1), options);  
    end
    % Assume the called function will explain to the user.
    if (isfield(params, 'wasError') & params.wasError.value)  
        errordlg(params.error.value);
        return;
    end
    % Another indication of an error, but we respond silently.
    if (isempty(result))
        return;
    end
    % Check for empty clusters and get rid of them.
    nclusters = size(result.data.f, 2);
    
    for r = nclusters:-1:1%go backwards bc you are eliminating things as you go
        %... don't want to change index numbers
        ncontours_in_cluster = length(find(result.data.f(:,r)));
        if (ncontours_in_cluster == 0)
            result.data.f(:,r) = [];
            nclusters=nclusters-1;
        end
    end
end

% BP for completely empty partition.
if (size(result.data.f,2) == 0)
    warndlg('There are no clusters remaining with these options.');
    return;
end

% The cluster routines may return fuzzy results.  This has to be
% turned into hard results.  So take the best of the fuzzy clusters.
% BP for only one cluster left.
if (size(result.data.f , 2) > 1)
    maxes = max(result.data.f')';
else
    maxes = result.data.f;
end
clusters = zeros(1, num_contours);
for i = 1:num_contours
    max_idx = find(result.data.f(i,:) == maxes(i));
    clusters(i) = max_idx(1);
end
nclusters = length(unique(clusters));

% Sort the clusters by intensity. In the future, we should be able to
% sort the clusters by the directionality according to the ordering
% line.
oldclusters = clusters;
% Try sorting the clusters by intensity, see if this helps.
if (do_order_clusters)
    for i = 1:nclusters
        cidx = find(clusters == i);
        ntraces = length(cidx);
        if (ntraces == 0)
            1;
        end
        activity_sum(i) = sum(sum(orig_intensitymap(cidx,:)))/ntraces;
    end
    [sorted, sort_order_idxs] = sort(activity_sum);
    for i = 1:nclusters
        sidx = sort_order_idxs(i);
        cidx = find(clusters == sidx);
        newclusters(cidx) = i;
    end
    sorted_clusters = newclusters;
else
    sorted_clusters = clusters;
end


%%% Now that we've done the clustering in the mathematical sense we
%%% have to put the whole thing together in the structure array.

% The 'p' for partition, which will be added to handles.app.experiment at the end
% of the file.
newp = newpartition;
newp.numClusters = nclusters;
newp.options = params;
newp.startIdxs = start_idx;
newp.stopIdxs = stop_idx;
newp.preprocessStrings = preprocess_strings;
newp.preprocessOptions = preprocess_options;
coidx = handles.app.data.currentContourOrderIdx;
newp.contourOrderId = coidx;
% partition(x).cleanContourTraces is indexed by contour id, so it's safe.
% -DCS:2005/08/24
newp.cleanContourTraces = orig_clean_contours;
if (handles.app.experiment.haloMode)
    newp.cleanHaloTraces = orig_clean_halos;
else
    newp.cleanHaloTraces = [];
end
newp.clusterIdxsByContour = num2cell(NaN*ones(1,handles.app.experiment.numContours));
for i = 1:newp.numClusters
    newp.clusters(i).id = i;
    newp.clusters(i).doShow = 0;
    cid = newp.clusters(i).id;
    
    % Collect the contours in cluster i.  The numbers in the cluster
    % array are indices into handles.app.experiment.contours.  Put the contours
    % into the correct order, based on the user preference.
    clustered_contour_idxs = find(sorted_clusters == i);
    contour_ids = clustered_contour_ids(clustered_contour_idxs);
    
    % Fill in the cluster idx array.
    clusterrepeat = num2cell(i*ones(1,length(clustered_contour_idxs)));
    newp.clusterIdxsByContour(contour_ids) = clusterrepeat;
    
    order = handles.app.experiment.contourOrder(coidx).order(contour_ids);
    %clustered_contour_ids = contour_ids(order);
    sn = [order; contour_ids];
    sorted = sortrows(sn', 1); % Sort by order.
    contour_ids = sorted(:,2)';
    %contour_ids = [all_contours(contour_idxs).id];
    num_contours = length(contour_ids);   
    newp.clusters(i).numContours = num_contours;
    newp.clusters(i).contours = contour_ids;
end
%newp.clusterIdxsByContour = num2cell(sorted_clusters(clustered_contour_ids)); % can have NaN entries.
% Get the extra information for each cluster.
newp = genclusterstats(handles, newp);

% Now put the partition structure into it's proper place in the
% experiment structure.
pidx = handles.app.experiment.numPartitions + 1;
handles.app.experiment.numPartitions = pidx;
newp.id = pidx;
if deletecontour == 0 % If this is not a part of the contour deletion process:
    newp.title = ['nc' num2str(newp.numClusters) '_' dimreducer '_' classifier '_id' num2str(newp.id)];
else
    newp.title = ['nc' num2str(newp.numClusters) '_contours_were_deleted_id' num2str(newp.id)];
end
handles.app.data.currentPartitionIdx = pidx;
handles.app.data.partitions(pidx) = newpartition_appdata(newp.numClusters);
handles.app.experiment.partitions(pidx) = newp;
% handles = order_clusters_by_intensity_peak (handles, pidx);