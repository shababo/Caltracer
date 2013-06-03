function handles = showclustercolor(handles, varargin)
% SHOWCLUSTERCOLOR(G,E, ...)
%
% Show the intensity plot for real, clean contours in a way that
% shows the cluster index on the side.  The color of the cluster is
% also a good way to delineate the boundaries between clusters.
%
% 'clusters' - an array of cluster ids to show.
%
% 'figure' - draw a new figure (1)/0.
%
% 'orderby' - order clusters by ('id') or 'size'

% (C) 2004 David C. Sussillo.  All rights reserved.

E = handles.app.experiment;
G = handles.app.experiment.globals;
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);

wantntics = 10;
new_figure = 1;
cluster_ids = [];
nargs = length(varargin);
orderby = 'id';
if (nargs)
    for i = 1:2:nargs
        switch varargin{i},
         case 'clusters'
          cluster_ids = varargin{i+1};
          cluster_ids = sort(cluster_ids);
         case 'figure' 
          new_figure = varargin{i+1};
         case 'orderby' 
          orderby = varargin{i+1};
         case 'ntics'
          wantntics = varargin{i+1}+1;
        end
    end
end


switch orderby
 case 'id'   
      if(isempty(cluster_ids))
          cluster_ids = [p.clusters.id];
      end
  case 'size'
  % Sort the cluster ids by the number of contours in the cluster.
  clusteridsbysize = sortrows([p.clusters.id; [p.clusters.numContours]*-1]', ...
			      2);
  cluster_ids = clusteridsbysize(:,1)';
end
nclusters = length(cluster_ids);


% Create the color matrix.
% Determine the number of rows to allocate.  Count along the way.
cluster_counts = [p.clusters.numContours];
len = length(E.contours(1).intensity);
intensitymap = zeros(sum(cluster_counts), len, 3);


xlen = [0 G.numImagesProcess/G.fs];


coidx = handles.app.data.currentContourOrderIdx;
%order = handles.app.experiment.contourOrder(coidx).order;
index = handles.app.experiment.contourOrder(coidx).index;


%
mymin = min(p.cleanContourTraces(:));
stddev = std(p.cleanContourTraces(:));
m = mean(p.cleanContourTraces(:));
mymax = m + 5*stddev;
displayed_contours = [];
for i = 1:p.numClusters
    cid = p.clusters(i).id;
    % Pull out the indices of the contours that belong to the current
    % (ith) cluster.
    contour_ids = [p.clusters(i).contours];    
    
    % Account for missing, or rearranged contours in cluster.
    % Remember that not all contours are in a given partition.
    % Additionally, the createcluster routine, by default, puts the
    % contours into the order specified by the
    % currentOrderIdx. -DCS:2005/08/23       
    cluster_contour_order = index(contour_ids);
    sn = [cluster_contour_order; contour_ids];
    sorted = sortrows(sn', 1); % Sort by order.
    sorted_contour_ids = sorted(:,2)';
    
    % Save for later.
    displayed_contours = [displayed_contours sorted_contour_ids];
    
    % Set the color of the cluster.    
    color = p.clusters(i).color;

    fsclean = p.cleanContourTraces(sorted_contour_ids,:);
    % This is a simple rescaling for showing color.
    fscleannorm = (fsclean-mymin)/(mymax-mymin);
    %fscleannorm(find(fscleannorm > 1)) = 1;
    fscleannorm(fscleannorm > 1) = 1;

    % Create the cluster intensity map in color.
    intensity_map_color_clean{i} = ...
	cat(3, (fscleannorm)*color(1), ...
	    (fscleannorm)*color(2), ...
	    (fscleannorm)*color(3));    
end
% Use this for highlighting cells from the raster plot.
handles.app.data.partitions(pidx).displayedContours = displayed_contours;


% Put the rows together.
count = 1;
for i = 1:nclusters
    c = cluster_ids(i);
    cidx = find([p.clusters.id] == c);
    if (isempty(cidx))
        continue;
    end
    idxs = count:count+cluster_counts(i)-1;
    intensitymap(idxs,:,:) = ...
	intensity_map_color_clean{i};
    count = count + p.clusters(cidx).numContours;
end

% Display the color matrix.
if (new_figure)
    figure; 
end



imagesc(xlen, [1 size(intensitymap,1)], intensitymap);
title(texlabel([ 'Raster Plot'], 'literal'));

traces = handles.app.experiment.traces;
time_res = handles.app.experiment.timeRes;
tracetime = (time_res*(0:size(traces,2)-1)) * ...
    ((size(traces,2)+1)/size(traces,2));%account for start at 0 and not 1
                                        %see variable xlen... crash if diff
do_signal_markers = uiget(handles, 'signals', 'signals_check', 'value');
didx = handles.app.data.currentDetectionIdx;
if (do_signal_markers & didx > 0)
    % Put this last in order to get the yheight accurate.

    for cid = displayed_contours
        % cid are ids, not indices.
        cidx = find([handles.app.experiment.contours.id] == cid);
        onsets = handles.app.experiment.detections(didx).onsets(cidx);
        offsets = handles.app.experiment.detections(didx).offsets(cidx);
        oncolor = [1 0 0];
        offcolor = [0 0 0];
        if ~isempty(onsets)
            onsets = onsets{1};
            offsets = offsets{1};
            for m = 1:length(onsets)
                height = find(cid == displayed_contours);
                start_idx = onsets(m);
                stop_idx = offsets(m);

                line(tracetime(start_idx), ...
                     height, ...
                     'Color', oncolor, ...
                     'LineWidth', 2, ...
                     'Marker', 'o', ...
                     'HitTest', 'off');
                if (stop_idx ~= start_idx)
                    line(tracetime(stop_idx), ...
                     height, ...
                     'Color', offcolor, ...
                     'LineWidth', 2, ...
                     'Marker', 'o', ...
                     'HitTest', 'off');
                end
            end
        end
    end
end

% Plot the cluster patches now.  We want to put the 'x' marks the spot
% for active cells afterwards, so that they are on top of the cluster
% patches.
handles = setup_cluster_patches(handles);


% Now mark an X at the left, for every active contour.  Useful.
if (handles.app.data.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0; 
end
% Since the active cell and current cell GUI concepts conflict
% (i.e. the user gets confused.  It's either one or the other.
if (do_use_current_cell)
    active_cells = handles.app.data.currentCellId;
else
    active_cells = handles.app.data.activeCells;
end

if (~isempty(active_cells))
    for cid = active_cells
        % i are ids, not indices.
        cidx = find([handles.app.experiment.contours.id] == cid);
        color = handles.app.experiment.contourColors(index(cidx),:);
        height = find(cid == displayed_contours);
        if (~isempty(height))
            line(tracetime(1), ...
                height, ...
                'Color', color, ...
                'LineWidth', 2, ...
                'Marker', 'X', ...
                'HitTest', 'off');
        end
    end
end

% Label clusters, making sure to place the cluster labels in the
% right place.
count = 1;
ytics = [];
for i = 1:nclusters
    c = cluster_ids(i);
    idx = find([p.clusters.id] == c);
    n = p.clusters(idx).numContours;
    ytics = [ytics; floor(n/2) + count];
    count = count + n;
end
ylabs = num2str([cluster_ids]');

xtics = [(0:50:G.numImagesProcess)/G.fs];

nxtics = length(xtics);
dnsamp = ceil(nxtics/wantntics);
xtics = downsample(xtics, dnsamp);

%xlabs = num2str((xtics+(G.movie_start_idx)/G.fs)', 3)
xlabs = num2str(xtics', 3);
xtics = xtics * G.fs;
% Set the axes with the cluster marks.
%axeAct = gca;
% Clear the last stuff.
set(handles.guiOptions.face.imagePlotH,...
    'YTick', [], ...
    'YTickLabel', []);
set(handles.guiOptions.face.imagePlotH,...
    ... %'XTick', xtics, ...
    ... %'XTickLabel', xlabs, ...
    'YTick', ytics, ...
    'YTickLabel',ylabs, ...
    'YDir', 'reverse',...
    'Box','On' ...
    ); 

ylabel('Neuron cluster');
xlabel('Time (secs)');