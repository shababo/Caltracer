function handles = rotate_all_contours(handles,diffang,fulcrum,maskidx);
% Using x and y distances inputed by the user's clicks, 
% rotates all contours in all regions of a mask

%For each region
for regions = 1:length(handles.app.experiment.regions.contours)
    %For each contour
    for cellcontours = 1:length(handles.app.experiment.regions.contours{regions}{maskidx});
        %Rotate the contours.
        for d =1:size(handles.app.experiment.regions.contours{regions}{maskidx}{cellcontours},1);
            %Get the coordinates relative to axis.
            coordsx = handles.app.experiment.regions.contours{regions}{maskidx}{cellcontours}(d,1) - fulcrum(1);
            coordsy = handles.app.experiment.regions.contours{regions}{maskidx}{cellcontours}(d,2) - fulcrum(2);
            %Convert to polar.
            [theta,radius] = cart2pol(coordsx,coordsy); 
            %Add the angles.
            theta = theta + diffang;
            %Convert back to cartesian.
            [coordsx,coordsy] = pol2cart(theta,radius);
            
            handles.app.experiment.regions.contours{regions}{maskidx}{cellcontours}(d,1) = coordsx + fulcrum(1);
            handles.app.experiment.regions.contours{regions}{maskidx}{cellcontours}(d,2) = coordsy + fulcrum(2);            
        end
    end
end
handles.app.experiment.Image(maskidx).rotationRadians = handles.app.experiment.Image(maskidx).rotationRadians + diffang;