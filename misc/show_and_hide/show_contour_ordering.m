function handles = show_contour_ordering(handles, ax, do_toggle_menu)


% First handle the menu.
sol_mi_h = findobj(handles.fig, 'Label', 'Show contour ordering');
val = get(sol_mi_h, 'Checked');
if (do_toggle_menu)
    if (strcmp(val, 'off'));	
	set(sol_mi_h, 'Checked', 'on');    
    else    
	set(sol_mi_h, 'Checked', 'off');
    end
end
val = get(sol_mi_h, 'Checked');

% Now draw the order.
midx = handles.app.data.currentMaskIdx;
ridx = handles.app.data.currentRegionIdx;
nregions = handles.app.experiment.numRegions;
rcl = hsv(nregions);
for r = 1:nregions
    contours = handles.app.experiment.regions.contours{r}{midx};
    ncontours = length(handles.app.experiment.regions.contours{r}{midx});
    for c = 1:ncontours
	set(handles.guiOptions.face.handl{r}{midx}(c), ...
	    'linewidth', 1, ...
	    'Color', rcl(r,:));
	
	set(handles.guiOptions.face.handl{r}{midx}(c), ...
	'Tag', 'cellcontour');
    end
end
if (strcmpi(val, 'on'))   
    for r = 1:nregions
	contours = handles.app.experiment.regions.contours{r}{midx};
	ncontours = length(handles.app.experiment.regions.contours{r}{midx});
	cl = jet(ncontours);
	for c = 1:ncontours
	    set(handles.guiOptions.face.handl{r}{midx}(c), ...
		'linewidth', 2, ...
		'Color', cl(c,:));	    
	    set(handles.guiOptions.face.handl{r}{midx}(c), ...
		'Tag', 'cellcontour - order');
	end
    end
end
refresh;
