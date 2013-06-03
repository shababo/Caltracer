function handles = edit_contour(handles,hObject)
% This function takes a contour, pulls out its coordinates, deletes it,
% creates an 'editable' polygon from it and allows the user to edit it.  It
% then adds the new contour to the rest.
% Last Edited on 4/9/2010 by MD.
    x = [];
    y = [];
    %Let the user input one click which defines the contour selected.
    [x(1) y(1) butt] = ginput(1);
    % If the user clicks any button other than left, return.
    if (butt > 1)
        handles = uiset(handles,'detectcells','all','enable','on');
        handles = uiset(handles,'filterimage','all','enable','on');
        return;
    end   
    newcn = [x y];
    
    nregions = handles.app.experiment.numRegions;
    maskidx = handles.app.data.currentMaskIdx;
    %% Delete the contour to be replaced/edited.
        for r = 1:nregions
        didx = 1;
        cn = handles.app.experiment.regions.contours{r}{maskidx};
        ncontours = length(cn);
        toedit{r} = [];
        for c = 1:ncontours
            % Find any contrours which contained the point selected and
            % mark them.
            if (find(inpolygon(newcn(1), newcn(2), cn{c}(:,1), cn{c}(:,2))))
                toedit{r}(didx) = c;
                didx = didx + 1;
            end
        end
        end
    
        for r = 1:nregions
    % If no contours were selected for deletion.
    if (isempty(toedit{r}))
        return;
    end
    cn = handles.app.experiment.regions.contours{r}{maskidx};
    ncontours = length(cn);
    saved_contour_idxs = setdiff(1:ncontours, toedit{r});
    nsaved_contours = length(saved_contour_idxs);
    % Replace handles with only contours that were not marked for deletion.
    handles.app.experiment.regions.contours{r}{maskidx} = cell(1,nsaved_contours);
    for c = 1:nsaved_contours
	handles.app.experiment.regions.contours{r}{maskidx}{c} = ...
	    cn{saved_contour_idxs(c)};
    end
end

% Make sure the colors are correct in case the addition is in a specific
% mask.
nmaps = length(handles.app.experiment.Image);
mapcolors = hsv(nmaps);
handles = draw_cell_contours(handles, ...
			     'ridx','all', ...
			     'color', mapcolors(maskidx,:));
             

to_edit = toedit{1};

xiold = cn{to_edit}(:,1);
yiold = cn{to_edit}(:,2);
% Here we decrease the number of points so there aren't a ton of points to
% move just to make a small adjustment.
newpoint = 1;
for x = 1:3 % In case the contour has many, many points.
    if length(xiold)>15
        for i = 1:2:length(xiold)    
            newxiold(newpoint,1) = xiold(i);
            newyiold(newpoint,1) = yiold(i);
            newpoint = newpoint+1;
        end
        % write latest values to xiold and yiold.
        xiold = newxiold;
        yiold = newyiold;
        % reset values for loop.
        newpoint = 1;
        newxiold = [];
        newyiold = [];
    end
end


h = impoly(gca,[xiold,yiold]);
    temp = wait(h);
    newcn = getPosition(h);
    
     % If the circle is off the image, throw an error and return.
       if (find(newcn<0))
           errordlg('The new polygon specified is off the image, please try again.','Bad Contour');
           delete (h);
            return;
       end
       if (find (newcn(:,1)> handles.app.experiment.Image(1).nX))
           errordlg('The new polygon specified is off the image, please try again.','Bad Contour');
           delete (h);
            return;
       end
       if (find (newcn(:,2)>handles.app.experiment.Image(1).nY))
           errordlg('The new polygon specified is off the image, please try again.','Bad Contour');
           delete (h);
            return;
       end
delete(h);
       
       

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


% Make sure region is the right size and have errors if it is not. If there
% are errors, draw the original contour again.
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