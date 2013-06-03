function handles = plot_clickmap_image(handles)
% function handles = plot_clickmap_image(handles)
%
% Redraw the patches on top of the time collapsed image.
handles.app.data.activeContourColor = [1 1 1];

% Rename some variables for ease.
% Current cell concept.
current_cell = handles.app.data.currentCellId;
if (handles.app.data.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0;
    current_cell = [];			% checks for empties.
end

do_centroid_display = handles.app.data.centroidDisplay.on;

do_id_display_selected = 0;
display_id_h = findobj(handles.fig, 'Label', 'Display ids on selected contours');
val = get(display_id_h, 'Checked');
if (strcmp(val, 'on'));	
    do_id_display_selected = 1;
else
    do_id_display_selected = 0;
end

do_id_display_all = 0;
display_id_h = findobj(handles.fig, 'Label', 'Display ids on all contours');
val = get(display_id_h, 'Checked');
if (strcmp(val, 'on'));	
    do_id_display_all = 1;
else
    do_id_display_all = 0;
end


do_contour_order_line = 0;
contour_order_line_h = findobj(handles.fig, ...
			       'Label', 'Connect highlighted contours in order');
val = get(contour_order_line_h, 'Checked');
if (strcmp(val, 'on'));
    do_contour_order_line = 1;
else
    do_contour_order_line = 0;
end



cl = handles.app.experiment.regions.cl;
% onsets = handles.app.experiment.onsets;
% offsets = handles.app.experiment.offsets;
traces = handles.app.experiment.traces;
halo_traces = handles.app.experiment.haloTraces;
time_res = handles.app.experiment.timeRes;
contours = handles.app.experiment.contours;

% Update the color of the correct cell patch on the clickMap. Is this
% necessary here, yes because the slider.
subplot(handles.guiOptions.face.clickMap);

fade = 0.65*ones(1,3);
cnt = handles.guiOptions.face.cnt;
% First hide all clusters, and then repaint the highlighted ones.
% Doing this step avoids other routines having to think about the
% coloration of patches, which is a good thing.
for i = 1:length(cnt)
    set(cnt(i), 'facecolor', 'none', 'edgecolor', 'none');
    %set(cnt(i), 'edgecolor', 'none');
end
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
cluster_ids = [p.clusters.id];

% Plot the ordering line if the user so wants.
handles = show_ordering_line(handles, handles.guiOptions.face.clickMap,0);

all_contour_ids = [handles.app.experiment.contours.id];

if (p.numClusters > 0)
    %%% Could be numContours and .contours instead.  Depends on evolution.
    for i = 1:handles.app.experiment.numContours
        %%% Will break if we ever allow deletion of
            %regions. -DCS:2005/03/21

        nid = handles.app.experiment.contours(i).id;
        nidx = nid;
        cidx = p.clusterIdxsByContour{nidx};

            % Choose the default color and then go back to see if the
            % contour is special in some way and should be recolored.
            % This avoids simple checks that become expensive when
            % multiplied by 3000 contours.
        if (~isnan(cidx) & p.clusters(cidx).doShow)
            set(cnt(nidx), ...
            'facecolor', p.clusters(cidx).color.*fade, ...
            'edgecolor', p.clusters(cidx).color.*fade);
            %set(cnt(nidx), ...
            %'edgecolor', p.clusters(cidx).color.*fade);
        else
            set(cnt(nidx), 'edgecolor', [1/2 1/2 1/2], ...
                   'facecolor', 'none');
            %set(cnt(nidx)', 'facecolor', 'none');
        end	
    end
end

% Now take care of cells that are highlighted in some way (i.e. paint
% them white.  Also mark centroids if user wants.

%%
%delete old centroid markers (redraw later if desired)
for cidx = 1:length(handles.app.data.centroidDisplay.points)
    h1 = handles.app.data.centroidDisplay.points(cidx);
    h2 = handles.app.data.centroidDisplay.text(cidx);
    valid_h1 = h1(ishandle(h1));
    valid_h2 = h2(ishandle(h2));
    valid_hands = [valid_h1 valid_h2];
    if (~isempty(valid_hands))
        delete(valid_hands);
    end
end
handles.app.data.centroidDisplay.points = [];
handles.app.data.centroidDisplay.text = [];

%%
% Since the active cell and current cell GUI concepts conflict
% (i.e. the user gets confused.  It's either one or the other.
if (~do_use_current_cell)    
    highlighted_cells = handles.app.data.activeCells;
else
    highlighted_cells = current_cell;
end   
coidx = handles.app.data.currentContourOrderIdx;
index = handles.app.experiment.contourOrder(coidx).index;
if (~isempty(highlighted_cells))
for nid = highlighted_cells
    nidx = nid;
    cidx = p.clusterIdxsByContour{nidx};
    % Show that the cell is active regardless of the cluster
    % being active or not. If the cell has a cluster, we show the
    % cluster color, else we just show the edge as white.
    set(cnt(nidx), ...
	'facecolor', handles.app.data.activeContourColor);
    % Account for killed clusters as well.
    if (~isnan(cidx))
        set(cnt(nidx), ...
            'edgecolor', p.clusters(cidx).color.*fade);
    else
        set(cnt(nidx), 'edgecolor', [1 1 1]);
    end
     %if user wants contour centroids or ids of selected cells shown
    if do_centroid_display | do_id_display_selected
	color = handles.app.experiment.contourColors(index(nidx),:);
        xc = handles.app.experiment.centroids{nidx}(1);
        yc = handles.app.experiment.centroids{nidx}(2);
	
	if (do_centroid_display)
	    txt = [' ', num2str(round(xc)), ',', num2str(round(yc)),' '];
	else
	    txt = [' ', num2str(nid)];
	end
        handles.app.data.centroidDisplay.points(end+1) = ...
            line(xc,yc,'Marker','x','color', color,'HitTest','off');
        handles.app.data.centroidDisplay.text (end+1)= ...
            text(xc,yc,txt,...
            'Color', color,'FontWeight','bold','HitTest','off');
    end
end
end

if (do_id_display_all)
    for nidx = 1:handles.app.experiment.numContours
	color = handles.app.experiment.contourColors(index(nidx),:);
        xc = handles.app.experiment.centroids{nidx}(1);
        yc = handles.app.experiment.centroids{nidx}(2);
	
	if (do_centroid_display)
	    txt = [' ', num2str(round(xc)), ',', num2str(round(yc)),' '];
	else
	    txt = [' ', num2str(nidx)];
	end
        handles.app.data.centroidDisplay.points(end+1) = ...
            line(xc,yc,'Marker','x','color', color,'HitTest','off');
        handles.app.data.centroidDisplay.text (end+1)= ...
            text(xc,yc,txt,...
            'Color', color,'FontWeight','bold','HitTest','off');
    end
end

% Plot the location cluster mean and standard deviation, if selected.
% Plot some cluster means, is so desired.
nclusters = p.numClusters;
cluster_ids = [p.clusters.id];



% Show cluster position in terms of mean and covariance.
% First check if handle exists, if not, add it.
if (~isfield(handles, 'clPosH'))
    handles.clPosH = {};
end

for i = 1:length(handles.clPosH)
    if (~isempty(handles.clPosH{i}))
        nhands = length(handles.clPosH{i});
        for j = 1:nhands
            if (ishandle(handles.clPosH{i}(j)))
                delete(handles.clPosH{i}(j));
            end
        end
    end
end
cph = handles.guiOptions.face.clusterPatchH;
handles.clPosH = {};
hidx = 1;
for i = 1:nclusters
    cid = cluster_ids(i);
    cidx = find(cluster_ids == cid);
    cmenu = get(cph(cidx), 'UIContextMenu');
    show_cluster_h = findobj(cmenu, 'Label', 'Show cluster position');
    checked = is_checked(show_cluster_h);
    %disp([i checked]);
    do_show = p.clusters(cidx).doShow;
    if (checked & do_show)
	color = get(cph(cidx), 'edgecolor'); % not 'none'.

	show_cov = 1;
	h = ...
	    plotGauss(p.clusters(cidx).locMean, ...
		      p.clusters(cidx).locCov, ...
		      cid, ...
		      p.clusters(cidx).color, ...
		      show_cov);
	handles.clPosH{hidx} = h;
	hidx = hidx+1;
    end
end

% Show the cluster border in terms of the convex hull.
% First check if handle exists, if not, add it.
if (~isfield(handles, 'clBordH'))
    handles.clBordH = {};
end
for i = 1:length(handles.clBordH)
    if (~isempty(handles.clBordH{i}))
        nhands = length(handles.clBordH{i});
        for j = 1:nhands
            if (ishandle(handles.clBordH{i}(j)))
                delete(handles.clBordH{i}(j));
            end
        end
    end
end
handles.clBordH = {};
hidx = 1;
for i = 1:nclusters
    cid = cluster_ids(i);
    cidx = find(cluster_ids == cid);
    cmenu = get(cph(cidx), 'UIContextMenu');
    show_cluster_h = findobj(cmenu, 'Label', 'Show cluster border');
    checked = is_checked(show_cluster_h);
    do_show = p.clusters(cidx).doShow;
    if (checked & do_show)
	color = get(cph(cidx), 'edgecolor'); % not 'none'.
	

    nids = p.clusters(cidx).contours;
    centroids_array = [handles.app.experiment.contours(nids).Centroid];
    centroids = reshape(centroids_array, 2, p.clusters(cidx).numContours)';
    conv_hull_idxs = convhull(centroids(:,1),centroids(:,2));
    conv_hull = centroids(conv_hull_idxs,:);
    h = line(conv_hull(:,1), conv_hull(:,2), ...
        'Color', color, 'LineWidth', 1, 'HitTest','off');
	handles.clBordH{hidx} = h;
	hidx = hidx+1;
    end
end

% Show the ordering line that connects one contour to another.
% First check if handle exists, if not, add it.
if (~isfield(handles, 'contourOrderH'))
    handles.contourOrderH = {};
end
for i = 1:length(handles.contourOrderH)
    if (~isempty(handles.contourOrderH{i}))
        nhands = length(handles.contourOrderH{i});
        for j = 1:nhands
            if (ishandle(handles.contourOrderH{i}(j)))
                delete(handles.contourOrderH{i}(j));
            end
        end
    end
end
handles.contourOrderH = {};
hidx = 1;
num_highlighted_cells = length(highlighted_cells);
if (do_contour_order_line & num_highlighted_cells > 1)
    idx = 1;
    coidx = handles.app.data.currentContourOrderIdx;
    index = handles.app.experiment.contourOrder(coidx).index;
    highlighted_indices = index(highlighted_cells);
    highlighted = [highlighted_indices; highlighted_cells]';
    sorted_highlighted = sortrows(highlighted, 1);
    sorted_highlighted_cells = sorted_highlighted(:,2);
    color = 'yellow';
    for nidx = 1:num_highlighted_cells
        nid = sorted_highlighted_cells(nidx);
        centroid = [handles.app.experiment.contours(nid).Centroid];
        centroid = [handles.app.experiment.contours(nid).Centroid];
        order_line(idx,1) = centroid(1);
        order_line(idx,2) = centroid(2);
        idx = idx + 1;
    end    
    h = line(order_line(:,1), order_line(:,2), ...
	     'Color', color, 'LineWidth', 1, 'HitTest','off');
    handles.contourOrderH{hidx} = h;
end

