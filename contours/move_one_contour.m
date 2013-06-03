function handles = move_one_contour(handles,x,y,ridx,contouridx,maskidx);
% Using x and y distances inputed by the user's clicks, 
% moves one contour in all regions of a mask
    handles.app.experiment.regions.contours{ridx}{maskidx}{contouridx}(:,1) = handles.app.experiment.regions.contours{ridx}{maskidx}{contouridx}(:,1)+x;
    handles.app.experiment.regions.contours{ridx}{maskidx}{contouridx}(:,2) = handles.app.experiment.regions.contours{ridx}{maskidx}{contouridx}(:,2)+y;