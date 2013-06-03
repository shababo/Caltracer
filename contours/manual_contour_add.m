function [handles] = manual_contour_add(handles)
while uiget(handles, 'detectcells', 'btadd', 'value')==1

% Manually add a circle or contour to the image.
maskidx = handles.app.data.currentMaskIdx;

% iscircle is used to determine if the radio button selected is a "Circle"
% and based on that we add the contour.
iscircle = findobj('style','radiobutton','string','Circle','parent',handles.fig,'visible','on');
   
%% Circle
 if get(iscircle,'value') == 1
% The user creates a resizable ellipse to define the contour (Clicking and dragging required).   
    h = imellipse;
    newcn = wait(h);
    delete (h);


 else
     isfreehand = findobj('style','radiobutton','string','Freehand','parent',handles.fig,'visible','on');
     if get(isfreehand, 'value')==1
     %% Freehand
     freehand=imfreehand;
     newcn = wait(freehand);  
     delete(freehand);     
     else
     %% Custom
        % The user creates a resizable polygon to define the contour (Clicking
        % and dragging required to continue).   
    [BW,xi,yi] = roipoly;
    % Remove the last entry to avoid doubling of first point.
    xi = xi(1:length(xi) - 1);
    yi = yi(1:length(yi) - 1);
    newcn = [xi,yi];
     end

 end

%% Check if escape is hit or if error should be thrown.
if isempty(newcn)
break;
end 
    % If the circle is off the image, throw an error and return.
if (find(newcn<0))
   errordlg('The contour specified is off the image, please try again.','Bad Contour');
    return;
end
if (find (newcn(:,1)> handles.app.experiment.Image(1).nX))
   errordlg('The contour specified is off the image, please try again.','Bad Contour');
    return;
end
if (find (newcn(:,2)>handles.app.experiment.Image(1).nY))
   errordlg('The contour specified is off the image, please try again.','Bad Contour');
    return;
end
 
% BP.
if (size(newcn,1) < 3)
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end

ct = create_centroid(newcn);
% Some kind of check to make sure these in the right region?
reg = 0;
min_area = str2num(uiget(handles, 'detectcells', 'txarlow', 'String'));
max_area = str2num(uiget(handles, 'detectcells', 'txarhigh', 'String'));

coords = handles.app.experiment.regions.coords;
nregions = handles.app.experiment.numRegions;

for c = 1:nregions
    if (inpolygon(ct(1),ct(2),coords{c}(:,1),coords{c}(:,2)))
        if (reg == 0)
            reg = c;
        elseif (polyarea(coords{c}(:,1),coords{c}(:,2)) < ...
		polyarea(coords{reg}(:,1),coords{reg}(:,2)))
            reg = c;
        end
    end
end


% Make sure region is the right size and have errors if it is not.
thisareapixels = polyarea(newcn(:,1),newcn(:,2));
thisareamicrons = thisareapixels * (handles.app.experiment.mpp^2);
if thisareamicrons == 0;
    errordlg('Attempted contour has 0 area.','Bad contour');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end
if thisareamicrons < min_area(reg)
    errordlg('Attempted contour area is too small.','Bad contour');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end
if thisareamicrons > max_area(reg)
    errordlg('Attempted contour area is too large.','Bad contour');
    handles = uiset(handles,'detectcells','all','enable','on');
    handles = uiset(handles,'filterimage','all','enable','on');
    return;
end

% Add new contour to existing ones.
handles.app.experiment.regions.contours{reg}{maskidx}{end+1} = newcn;

% Redraw Cell Contours.
ridx = handles.app.data.currentRegionIdx;

% Make sure the colors are correct in case the addition is in a specific
% mask.
nmaps = length(handles.app.experiment.Image);
mapcolors = hsv(nmaps);
handles = draw_cell_contours(handles, ...
			     'ridx',reg, ...
			     'color', mapcolors(maskidx,:));
end
handles = uiset(handles,'detectcells','btadd','value',0);