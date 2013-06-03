function handles = setup_cluster_patches(handles)
% Pick the current partition.  We work with this throughout the entire
% file.
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
nclusters = p.numClusters;
cluster_ids = [p.clusters.id];
cluster_counts = [p.clusters.numContours];

% Technically incorrect, but shows up for larger traces.
%xlen = [1/handles.app.experiment.globals.fs ...
%	handles.app.experiment.globals.numImagesProcess/handles.app.experiment.globals.fs];

% Technically correct, but rendered incorrectly for large traces.
xlen = [0 ...
	handles.app.experiment.globals.numImagesProcess/handles.app.experiment.globals.fs];

% Compute the patches.
last = 0;
for i = 1:nclusters
    cpatchx{i} = [xlen(1) xlen(2) xlen(2) xlen(1)];
        %.45 corrects so that the borders of the click box are actually on
        %the outside of cells, and not at the centers of the edge cell
        %plots (ie would be .5 in from edges otherwise... .45 to make sure
        %it's clickable and visible)
    cpatchy{i} = [last+cluster_counts(i)+.45 ... % upper
		  last+cluster_counts(i)+.45 ... % upper
		  last+1-.45 ...		% bottom
		  last+1-.45];		% bottom
    last = last + cluster_counts(i);
end

cluster_ids = [p.clusters.id];
for i = 1:nclusters
    cph(i) = patch(cpatchx{i}, cpatchy{i}, [0 0 0]);
    set(cph(i), 'FaceColor', 'none');
    % Get the current cluster index from the current cluster id.
    cidx = find(cluster_ids == cluster_ids(i));

    if (p.clusters(cidx).doShow == 1)
        set(cph(i), 'edgecolor', p.clusters(i).color);
    else
        set(cph(i), 'edgecolor', 'none');
    end
    set(cph(i), 'Visible', 'on');
    set(cph(i), 'UserData', [i p.clusters(i).id]);
    set(cph(i), 'Clipping', 'off');
    %set(cph(i), 'Parent', handles.fig);

    % Setup the context menu for each patch.
    cmenu = uicontextmenu;
    set(cmenu, 'UserData', p.clusters(i).id);
    %set(cmenu, 'Visible', 'off');
%     item = uimenu(cmenu, 'Label', 'Highlight contour', 'Callback', ...
% 		  'caltracer(''highlight_cell_callback'', gcbo, guidata(gcbo))');
%     item = uimenu(cmenu, 'Label', 'Unhighlight contour', 'Callback', ...
% 		  'caltracer(''unhighlight_cell_callback'', gcbo, guidata(gcbo))');
    item = uimenu(cmenu, 'Label', 'Highlight cluster', 'Callback', ...
		  'caltracer(''highlight_cluster_callback'', gcbo, guidata(gcbo))');
%     item = uimenu(cmenu, 'Label', 'Unhighlight cluster', 'Callback', ...
% 		  'caltracer(''unhighlight_cluster_callback'', gcbo, guidata(gcbo))');
    item = uimenu(cmenu, 'Label', 'Plot mean', 'Callback', ...
		  'caltracer(''plot_cluster_mean_callback'', gcbo, guidata(gcbo))');
    if (handles.app.data.partitions(pidx).clusters(cidx).doPlotMean)
        set(item, 'Checked', 'on');
    end    
    item = uimenu(cmenu, 'Label', 'Plot standard deviation', 'Callback', ...
		  'caltracer(''plot_cluster_stddev_callback'', gcbo, guidata(gcbo))');
    if (handles.app.data.partitions(pidx).clusters(cidx).doPlotStandardDeviation)
        set(item, 'Checked', 'on');
    end    
    item = uimenu(cmenu, 'Label', 'Show cluster position', ...
		  'Callback', ...
	'caltracer(''show_cluster_position_callback'', gcbo, guidata(gcbo))');
    if (handles.app.data.partitions(pidx).clusters(cidx).doShowPosition)
        set(item, 'Checked', 'on');
    end    
    item = uimenu(cmenu, 'Label', 'Show cluster border', ...
		  'Callback', ...
		  'caltracer(''show_cluster_border_callback'',gcbo,guidata(gcbo))');
    if (handles.app.data.partitions(pidx).clusters(cidx).doShowBorder)
        set(item, 'Checked', 'on');
    end    
    
    item = uimenu(cmenu, 'Label', 'Kill contour', 'Callback', ...
		  'caltracer(''kill_cell_callback'', gcbo, guidata(gcbo))');
    item = uimenu(cmenu, 'Label', 'Kill cluster', 'Callback', ...
		   'caltracer(''kill_cluster_callback'', gcbo, guidata(gcbo))');
    item = uimenu(cmenu, 'Label', 'Change contour color', 'Callback', ...
           'caltracer(''change_contour_color_callback'', gcbo, guidata(gcbo))');

    
    set(cph(i), 'UIContextMenu', cmenu);
    set(cph(i), 'ButtonDownFcn','caltracer2(''clustermap_buttondown_callback'',gcbo,guidata(gcbo))');    
end
handles.guiOptions.face.clusterPatchH = cph;
