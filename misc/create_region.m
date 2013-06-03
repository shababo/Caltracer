function handles = create_region(handles)
% function handles = create_region(handles)
% Create a region by creating the border for the region using
% mouse, selections and store it.  Redraw the region widget.

% maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;
uiset(handles, 'regions', 'bord_add', 'foreground',[1 0 0]);

nx = handles.app.experiment.Image(maskidx).nX;
ny = handles.app.experiment.Image(maskidx).nY;


[x, y, h] = draw_region(nx, nx, 'tag', 'regionborder', 'enclosedspace', 1);

handles.app.experiment.regions.bord{length(handles.app.experiment.regions.bord)+1} = [];
handles.app.experiment.regions.bord{end} = [get(h,'xdata')' get(h,'ydata')'];
        
handles.app.experiment.regions.bhand(end+1) = h;

uiset(handles, 'regions', 'bord_add', 'foreground',[0 0 0]);

handles = determine_regions(handles);
