function [hObject, handles] = load_contours(hObject,handles);
% Load the contours from an experiment file.  Go through the masks in
% the experiment file and if the title is the same to the current map
% title we load the contours, taking into account that the regions
% might be different.

%if filename already exists (from open as call) and auto load contours is
%selected use exiting file, otherwise ask for file.
if handles.app.preferences.autoLoadContours == 1 && ~isempty(handles.app.info.openedAs);
    fnm = handles.app.info.openedAs;
else
    [filename, pathname] = uigetfile({'*.mat'}, 'Choose an experiment to open');
    if (~filename)
        return;
    end
    fnm = [pathname filename];
end
savestruct = load(fnm);
fclose('all');

% In case the user is opening "export to file" contours
if ~isfield(savestruct, 'handles')
    try
    maskidx = handles.app.data.currentMaskIdx;
    handles.app.experiment.regions.contours{1}{maskidx} = savestruct.CONTS;
    handles = draw_cell_contours(handles, 'ridx', 'all');
    catch
        errordlg('This is not a valid contours file');
    end
else
        currentX = handles.app.experiment.Image.nX;
        currentY = handles.app.experiment.Image.nY;
        loadedX = savestruct.handles.app.experiment.Image.nX;
        loadedY = savestruct.handles.app.experiment.Image.nY;
        scaletofit = 0;
        if currentX ~= loadedX && currentY ~= loadedY%if different sizes
            if currentX/currentY == loadedX/loadedY%if same aspect ratio
                %find out whether wants to scale... if not just import coordinates
                %as is
                button = questdlg('Image from loaded movie has a different size from the current movie. Scale contours to fill current image?',...
                'Scaling?','Yes','Don''t Scale','Cancel','Yes');
                if strcmp(button,'Cancel') || strcmp(button,'');
                    return
                elseif strcmp(button,'Yes');
                    scaletofit = 1;
                    scalefactor = currentX/loadedX;
                end
            end
        end

        ridx = handles.app.data.currentRegionIdx;
        maskidx = handles.app.data.currentMaskIdx;

        titles = {savestruct.handles.app.experiment.Image.title};
        % If there is one mask, then we simply take the contours from it.  Otherwise we
        % list the titles of all the contour masks so that the user can decide for
        % themselves which mask is appropriate.
        if (length(titles) == 1)
            sel_idx = 1;
        else
            [sel_idx,ok] = listdlg('PromptString','Select a mask from which to load contours:',...
                'SelectionMode','single',...
                'ListString', titles, ...
                'ListSize', [300 100]);
            if (~ok)
                errordlg('You must select a correct mask title.');
                return;
            end
        end
        nregions = handles.app.experiment.numRegions;
        new_nregions = savestruct.handles.app.experiment.numRegions;
        cidxs = ones(1, nregions);

        % Keep your head straight here.  There are two sets of regions.
        % The loaded regions, and the current, user defined regions.  We
        % need to put the contours into the right region.
        for r = 1:new_nregions
            new_contours = savestruct.handles.app.experiment.regions.contours{r}{sel_idx};
            new_ncontours = length(new_contours);

        nregions = handles.app.experiment.numRegions;
        ncontours = length(new_contours);
        region_idxs = ones(1,ncontours);%if cannot find region... go into region 1, so 
        for c = 1:ncontours
            for r = 1:nregions
                centr = create_centroid(new_contours{c});
                rborder = handles.app.experiment.regions.coords{r};
                if inpolygon(centr(1),centr(2), rborder(:,1), rborder(:,2));
                    new_ridxs(c) = r;
                end
            end
        end

        num_no_region = length(find(region_idxs == 0));

        if (num_no_region)
            warndlg([num2str(num_no_region) ' contours did not find a' ...
                 ' region when loaded.  They will be put in to region #1.']);
        end

            for c = 1:new_ncontours
                current_ridx = new_ridxs(c);
                if (current_ridx ~= 0)	    
                    % Have to keep track of indexing into the right regions.
                    cidx = cidxs(current_ridx);
                    if scaletofit
                        handles.app.experiment.regions.contours{current_ridx}{maskidx}{cidx} = ...
                        new_contours{c} * scalefactor;
                    else
                        handles.app.experiment.regions.contours{current_ridx}{maskidx}{cidx} = ...
                        new_contours{c};
                    end
                    cidxs(current_ridx) = cidxs(current_ridx)+1;
                end	
            end
        end

        handles = draw_cell_contours(handles, 'ridx', 'all');
        handles.app.experiment.Image(maskidx).movementVector = [0 0];
        %if there are previous masks
        if maskidx > 1
            warning off MATLAB:conversionToLogical
            %for all previous masks
            for idx = 1:maskidx-1
            %1 if loaded
                prevloads(idx) = ~strcmpi('not loaded',handles.app.experiment.Image(idx).maskLoadedFromFile);
            %1 if moved
                prevnonzeromoves(idx) = logical(sum(logical(handles.app.experiment.Image(idx).movementVector)));
                prevmoves(idx,:) = handles.app.experiment.Image(idx).movementVector;
                prevnonzerorotates(idx) = logical(handles.app.experiment.Image(idx).rotationRadians);
                prevrotates(idx,:) = handles.app.experiment.Image(idx).rotationRadians;
            end
            %1 if any masks were both loaded and moved
            loadedandmoved = prevloads.*prevnonzeromoves;
            loadedandrotated = prevloads.*prevnonzerorotates;
            %just keep moves of loaded masks
            prevmoves = prevmoves(find(loadedandmoved),:);
            prevrotates = prevrotates(find(loadedandrotated));
            %if any of the previous masks were loaded
            if sum(loadedandmoved) == 1
                button = questdlg(['A previous set of contours was loaded and then moved by (',num2str(prevmoves(1)),',',num2str(prevmoves(2)),') pixels.  Would you like to move the incoming contours by the same amount?'],...
                    'Move loaded contours','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    handles = move_all_contours(handles,prevmoves(1),prevmoves(2),maskidx);
                    handles = draw_cell_contours(handles,'ridx','all');
                    handles = redraw_regions(handles,hObject);
                    handles = draw_region_widget(handles);
                end
            elseif sum(loadedandmoved)>1
                % only if moves are different?
                charcell = {};%blank out
                for b=1:size(prevmoves,1);
                    charcell{b} = num2str(prevmoves(b,:));
                end
                [sel_idx,ok] = listdlg('PromptString','Previous contour move coords',...
                           'SelectionMode','single',...
                           'ListString', charcell);
                if ok
                    coords=prevmoves(sel_idx,:);
                    handles = move_all_contours(handles,coords(1),coords(2),maskidx);
                    handles = draw_cell_contours(handles,'ridx','all');
                    handles = redraw_regions(handles,hObject);
                    handles = draw_region_widget(handles);
                end
            end
            prevrotates = prevrotates * (180/pi);%easier for users to deal in degrees
            fulcrum = (size(handles.app.experiment.Image(1).image)*.5)+.5;%bad...assuming axis is center point
            %if any of the previous masks were loaded and rotated
            if sum(loadedandrotated) == 1
                button = questdlg(['A previous set of contours was loaded and then rotated by (',num2str(prevrotates(1)),') degrees.  Would you like to rotate the incoming contours by the same amount?'],...
                    'Rotate loaded contours','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    prevrotates = prevrotates * (pi/180);%convert back
                    handles = rotate_all_contours(handles,prevrotates(1),fulcrum,maskidx);
                    handles = draw_cell_contours(handles,'ridx','all');
                    handles = redraw_regions(handles,hObject);
                    handles = draw_region_widget(handles);
                end
            elseif sum(loadedandrotated)>1
                % only if rotates are different?
                charcell = {};%blank out
                for b=1:size(prevrotates,1);
                    charcell{b} = num2str(prevrotates(b));
                end
                [sel_idx,ok] = listdlg('PromptString','Previous contour rotate coords',...
                           'SelectionMode','single',...
                           'ListString', charcell);
                if ok
                    radians = prevrotates(sel_idx) * (pi/180);
                    handles = rotate_all_contours(handles,radians,fulcrum,maskidx);
                    handles = draw_cell_contours(handles,'ridx','all');
                    handles = redraw_regions(handles,hObject);
                    handles = draw_region_widget(handles);
                end
            end
            warning on MATLAB:conversionToLogical
        end
              
handles.app.experiment.Image(maskidx).maskLoadedFromFile = [fnm,'_',titles{sel_idx}];  
end

handles = menuset(handles, 'Contours','contours','Randomize contour order','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep only brightest contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep random contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep last contours','Enable','on');
handles = menuset(handles, 'Contours','contours','Keep last contours & randomize order','Enable','on');
handles = menuset(handles, 'Export', 'export', 'Export contours', 'Enable', 'on');
handles = menuset(handles, 'Export', 'export', 'Export contours to file', 'Enable', 'on');
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file', 'Enable', 'on');  
handles = menuset(handles, 'Export', 'export', 'All centroids to vnt file (more than once)', 'Enable', 'on');  

