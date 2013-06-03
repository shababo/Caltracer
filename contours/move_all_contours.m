function handles = move_all_contours(handles,x,y,maskidx);
% Using x and y distances inputed by the user's clicks, 
% moves all contours in all regions of a mask

for region = 1:length(handles.app.experiment.regions.contours)
    % Move all regions except the first one.
    if region ~= 1;
        handles.app.experiment.regions.coords{region}(:,1) = handles.app.experiment.regions.coords{region}(:,1)+x;
        handles.app.experiment.regions.coords{region}(:,2) = handles.app.experiment.regions.coords{region}(:,2)+y;
    end
    % Move the cells within the region.
    for cellcontours = 1:length(handles.app.experiment.regions.contours{region}{maskidx});
        handles.app.experiment.regions.contours{region}{maskidx}{cellcontours}(:,1) = handles.app.experiment.regions.contours{region}{maskidx}{cellcontours}(:,1)+x;
        handles.app.experiment.regions.contours{region}{maskidx}{cellcontours}(:,2) = handles.app.experiment.regions.contours{region}{maskidx}{cellcontours}(:,2)+y;
    end
end
handles.app.experiment.Image(maskidx).movementVector = handles.app.experiment.Image(maskidx).movementVector + [x y];