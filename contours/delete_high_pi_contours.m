function handles=delete_high_pi_contours(handles);
% Removes cells that have already been found to be above the specified pi
% limit and deletes them from the stored contours.

% maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;

% Ridx is the region currently being processed.
ridx = handles.app.data.currentRegionIdx;

% nhandlr is the number of handles for the contours within a region
nhandlr = length(handles.guiOptions.face.handl{ridx}{maskidx});
% handlr is the handles for the contours within a region
handlr = handles.guiOptions.face.handl{ridx}{maskidx};

% Initialize linewidth as zero
linewidth = zeros(1,length(handlr));

% Find the contours to delete using linewidth.
for c = 1:nhandlr
    linewidth(c)= get(handlr(c),'linewidth');
end
contourstodelete = find(linewidth ==2);

% Delete the contours and redraw.
handles.app.experiment.regions.contours{ridx}{maskidx}(contourstodelete)=[];
handles = draw_cell_contours(handles, 'ridx', 'all');
