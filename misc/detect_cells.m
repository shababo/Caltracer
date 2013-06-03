function handles = detect_cells(handles)
% Function is called by the detect cells callback.  If a
% user hits detect, then all cell information previosly created is
% deleted. Detect works only within a region.  It should be noted
% that this function regenerates all the cells, contours, etc.

% maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;

% Get the data from the uicontrols to find the cells.
ridx = handles.app.data.currentRegionIdx;
face = handles.guiOptions.face;
face.isAdjusted(ridx) = 0;
face.isDetected(ridx) = 1;
handles.app.experiment.regions.contours{ridx}{maskidx} = [];

% Get the top 'Cutoff' or threshold percent.
fimage = handles.app.experiment.Image(maskidx).filteredImage;
rloc = fliplr(sort(reshape(fimage,1,numel(fimage))));
ind = round(length(rloc)*face.thresh(ridx)/100);

if (ind > 0)
    % Get the actual threshold value and get the contours.
    thr = rloc(ind);
    h = contourc(fimage,[thr thr]);
    ind = 1;
    cn = [];
    reg_coords = handles.app.experiment.regions.coords;
    names = handles.app.experiment.regions.name;
    
    while 1%run until break
        v = h(2,ind);
        coords = [h(1,ind+1:ind+v)' h(2,ind+1:ind+v)']; % temp
        ind = ind+v+1;
        if ind > size(h,2)
            break
        end
        if polyarea(coords(1:end-1,1),coords(1:end-1,2)) > 0
            cn{size(cn,2)+1} = coords(1:end-1,:);
        end
    end
    
    centr = [];
    areas = [];
    for c = 1:length(cn)
        centr(c,:) = create_centroid(cn{c});
        areas(c) = polyarea(cn{c}(:,1), cn{c}(:,2))*(handles.app.experiment.mpp^2); % in um
    end
    
    in = inpolygon(centr(:,1), centr(:,2),...
		   reg_coords{ridx}(:,1), reg_coords{ridx}(:,2));
    for c = 1:length(names)
        if (polyarea(reg_coords{c}(:,1), reg_coords{c}(:,2)) ...
	    < polyarea(reg_coords{ridx}(:,1), reg_coords{ridx}(:,2)));
            inoth = inpolygon(centr(:,1), centr(:,2), ...
			      reg_coords{c}(:,1),reg_coords{c}(:,2));
            in(inoth==1) = 0;
        end
    end    
        
    f = find(in);			% finds those in the right region?
    cntemp = [];
    for c = 1:length(f)
        cntemp{c} = cn{f(c)};
    end
    centrtemp = centr(f,:);
    areastemp = areas(f);
    cidx = 1;
    for c = 1:length(cntemp)
        
	% I think we should not add contours that are meant to be
	% excluded.  It's possible that Dmitriy had some idea here but
	% I know of at least one because of this, so I'm adding the
	% following line of code, which makes the set command below
	% moot.
        if (areastemp(c) >= face.minArea(ridx) && areastemp(c) <= face.maxArea(ridx))
            good_cn{cidx} = cntemp{c};
            good_areas(cidx) = areastemp(c);
            good_centr(cidx,:) = centrtemp(c,:);
            cidx = cidx + 1;
        end
    end
try
    handles.app.experiment.regions.contours{ridx}{maskidx} = good_cn;
catch
   errordlg ('No cells detected, please check your min and max area values and try again.'); 
   handles.app.info.error = 1;
end

end
% Save the rest of the work.
handles.guiOptions.face = face;
handles.app.experiment.Image(maskidx).movementVector=[0 0];
handles.app.experiment.Image(maskidx).maskLoadedFromFile='not loaded';
