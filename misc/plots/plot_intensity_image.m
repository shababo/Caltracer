function handles = plot_intensity_image(handles)

pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);

% Plot the clustering.
axes(handles.guiOptions.face.imagePlotH);
c = get(handles.guiOptions.face.imagePlotH, 'Children');
if ~isempty(c)	
    valid_handles = c(find(ishandle(c)));
    if ~isempty(valid_handles)	   
        delete(valid_handles);
    end
end
handles = showclustercolor(handles, 'figure', 0);

% If everything has gone OK, put the new cluster in the partition
% popup menu.
partition_names = cellstr(uiget(handles, 'signals', 'clusterpopup', 'String'));
uiset(handles, 'signals', 'clusterpopup', 'Value', pidx);