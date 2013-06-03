function plot_highlighted_contours_zero_signals(handles)

if (handles.app.data.useContourSlider)
    contours_to_plot = handles.app.data.currentCellId;
else
    contours_to_plot = handles.app.data.activeCells;
end

if (isempty(contours_to_plot))
    warndlg('You must select contours in order to plot.');
    return;
end

do_trace = uiget(handles, 'signals', 'trace_check', 'value');
do_halo = uiget(handles, 'signals', 'halo_raw_check', 'value');
do_clean_trace = uiget(handles, 'signals', 'clean_trace_check', 'value');
do_clean_halo = uiget(handles, 'signals', 'halo_preprocess_check', 'value');
do_signal_markers = uiget(handles, 'signals', 'signals_check', 'value');

if (~do_trace & ~do_halo & ~do_clean_trace & ~do_clean_halo)
    warndlg(['You must select a "Show" checkbox indicating what' ...
	      ' type of data you would like to plot.']);
    return;
end

traces = handles.app.experiment.traces;
halo_traces = handles.app.experiment.haloTraces;
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
clean_traces = p.cleanContourTraces;
clean_halo_traces = p.cleanHaloTraces;
time_res = handles.app.experiment.timeRes;
% AP 2008/02/27 - zero out signals.. cobbled together horrifically
cellnum = handles.app.data.currentCellId;
if (handles.app.data.useContourSlider)
    do_use_current_cell = 1;
else
    do_use_current_cell = 0;
end
if (do_use_current_cell)
    active_cells = cellnum;
else
    active_cells = handles.app.data.activeCells;
end
if (isempty(active_cells))
    active_cells = [];
end
for i = active_cells
    nidx = find([handles.app.experiment.contours.id] == i);
    didx = handles.app.data.currentDetectionIdx;
    if (do_signal_markers & didx > 0);
        onsets = handles.app.experiment.detections(didx).onsets(nidx);
        offsets = handles.app.experiment.detections(didx).offsets(nidx);
        onsets = onsets{1};
        offsets = offsets{1};
        for j=1:length(onsets)
            traces(nidx,onsets(j):offsets(j))=0;
            clean_traces(nidx,onsets(j):offsets(j))=0;
        end
    end
end
% AP 2008/02/27 - done jacking up the traces
halotime  = time_res*(0:size(halo_traces,2)-1);
tracetime = time_res*(0:size(traces,2)-1);

coidx = handles.app.data.currentContourOrderIdx;
index = handles.app.experiment.contourOrder(coidx).index;


f = figure; 
set(f, 'Name', [handles.app.experiment.Image(1).title]);
screen_size = get(0, 'ScreenSize');
set(f, 'Position', ...
    [screen_size(3)/20 ...
    screen_size(4)/20 ...
    screen_size(3)*9/10 ...
    screen_size(4)*8.5/10]);
set(f, 'Color', [0.1 0.1 0.1]);
ncontours_to_plot = length(contours_to_plot);
if (ncontours_to_plot <= 5)
    ncolumns = 1;
elseif (ncontours_to_plot <= 16)
    ncolumns = 2;
elseif (ncontours_to_plot <= 30)
    ncolumns = 3;
elseif (ncontours_to_plot <= 80)
    ncolumns = 4;
else
    ncolumns = 5;
end

nrows = ceil(ncontours_to_plot / ncolumns);
first_bottom = 1;
bottom = first_bottom;
left = 0+0.02;
width = 0.9*1/ncolumns;
height = 1/nrows;
coidx = handles.app.data.currentContourOrderIdx;
index = handles.app.experiment.contourOrder(coidx).index;
to_plot_order = index(contours_to_plot);
order_and_contours = [to_plot_order; contours_to_plot]';
sorted_order_and_contours = sortrows(order_and_contours, 1);
sorted_contours_to_plot = sorted_order_and_contours(:,2);

didx = handles.app.data.currentDetectionIdx;

if (do_clean_trace)
    ymax = max(max(clean_traces));
    ymin = min(min(clean_traces));
end
for i = 1:ncontours_to_plot
    cid = sorted_contours_to_plot(i);
    %subplot(nrows, ncolumns, i);
    bottom = bottom - height;
    if (bottom < -0.05)
        bottom = first_bottom - height;
        left = left + width+0.015;
    end
    
    subplot('position', [left bottom width height]);

    nidx = find([handles.app.experiment.contours.id] == cid);
    color = handles.app.experiment.contourColors(index(nidx),:);
    
    % Contour data.
    if (do_trace)
        trace_to_plot = traces(nidx,:);
    end
    if (do_clean_trace)
        trace_to_plot = clean_traces(nidx,:);
    end
    yheight = max(trace_to_plot);
    yheight = yheight(1);
    
    plot(tracetime, trace_to_plot, 'Color', color);
    xlim([0 max(tracetime)]);        
    % Only case where this makes sense.
    if (do_clean_trace)
        ylim([ymin ymax]);
    end
    
    % Halo data.
    if (do_halo)
        plot(halotime, halo_traces(nidx,:), '-x', 'Color', color);
        xlim([0 max(halotime)]);
    end
    if (do_clean_halo)
        clean_halo_trace = clean_halo_traces(nidx,:);
        plot(halotime, clean_halo_trace, '-x', 'Color', color);
    end    
    if (do_signal_markers & didx > 0);
        onsets = handles.app.experiment.detections(didx).onsets(nidx);
        offsets = handles.app.experiment.detections(didx).offsets(nidx);
        ecolor = [1 0 0];    
        if ~isempty(onsets)
            onsets = onsets{1};
            offsets = offsets{1};
            for a = 1:length(onsets)
                start_idx = onsets(a);
                stop_idx = offsets(a);
                line([tracetime(start_idx) ...
		      tracetime(stop_idx)], ...
		     [yheight yheight], ...
		     'Color', ecolor, ...
		     'LineWidth', 2, ...
		     'Marker', 'o');
            end
        end
    end
    
    % Labels.
    xl = xlim;
    yl = ylim;
    
    text(xl(2)-(xl(2)-xl(1))/5, yl(2) - (yl(2)-yl(1))/5, ['# ' num2str(cid)],...
	 'Color', [1 1 1]);
    axis off;
end


% No Ylabel.
%if (do_trace)
%    ylabel('Fluorescence (ADU)');
%elseif (do_clean_trace)
%    ylabel('Fluorescence (various units)');
%end    
xlabel('Time (secs)');