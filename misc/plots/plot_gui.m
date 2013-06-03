function handles = plot_gui(handles)

% Setup the gui parts.
pidx = handles.app.data.currentPartitionIdx;
uiset(handles, 'signals', 'clusterpopup', 'Value', pidx);
coidx = handles.app.data.currentContourOrderIdx;
uiset(handles, 'signals', 'contourorderpopup', 'Value', coidx);
didx = handles.app.data.currentDetectionIdx;
uiset(handles, 'signals', 'signalspopup', 'Value', didx);

% NUMSLIDER We want the contour slider to work on only those contours
% that are in the current partition.  It must take a range. i.e. [1
% num_contours_in_partition], where each value is supposed to be
% ORDER.  We will use partition.clusterIdxsByContour to determine
% those contours that are in the current partition.
if (handles.app.data.useContourSlider)    
    pidx = handles.app.data.currentPartitionIdx;
    p = handles.app.experiment.partitions(pidx);
    contour_ids = [p.clusters.contours];    
    ncontours = length(contour_ids);

    % Here we start with the contour id and update the numslider.
    % this can happen because someone has clicked on the clickmap.
    % The goal is to go from cell id and end up with it's order, that
    % is, it's order in reference to the nonnan contours, not the
    % overall order.
    contour_id = handles.app.data.currentCellId;
    nonnan_contour_ids = find(~isnan([p.clusterIdxsByContour{1:end}]) == 1);
    nonnan_contour_idx = find(nonnan_contour_ids == contour_id);

    coidx = handles.app.data.currentContourOrderIdx;
    nonnan_ordering = ...
        handles.app.experiment.contourOrder(coidx).index(nonnan_contour_ids);
    % Only update the id from here when things are no good.
    if (isempty(nonnan_contour_idx) ...
            | nonnan_contour_idx < 1 ...
            | nonnan_contour_idx > ncontours)
        nonnan_contour_order = 1;
        nn = [nonnan_ordering; nonnan_contour_ids]';
        sorted_nn = sortrows(nn,1);
        contour_id = sorted_nn(nonnan_contour_order,2);
        handles.app.data.currentCellId = contour_id;
    else
        true_contour_order = nonnan_ordering(nonnan_contour_idx);
        nonnan_contour_order = find(sort(nonnan_ordering) == true_contour_order);
    end

    handles = uiset(handles, 'signals', 'numslider', ...
		    'Min', 1, ...
		    'Max', ncontours, ...
		    'Value', nonnan_contour_order, ...
		    'Sliderstep', [1/ncontours 5/ncontours]);
    
end


% Replot the gui whenever there is a change in internal state.
handles = plot_intensity_image(handles);
handles = plot_clickmap_image(handles);
handles = plot_trace(handles);

