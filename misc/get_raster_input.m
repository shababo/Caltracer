function [selected_rastermap start_idxs stop_idxs x y ] = ...
    get_raster_input(handles, rastermap, varargin)



lidx = get_label_idx(handles, 'signals');
valclickinput = get(handles.uigroup{lidx}.use_frame_click_input_checkbox,'value');
valnuminput = get(handles.uigroup{lidx}.use_numerical_frame_input_checkbox,'value');

if valclickinput & valnuminput
    error ('Both frame input indicators are clicked')
    return
elseif ~valclickinput & ~valnuminput
    selected_rastermap = rastermap;
    start_idxs = 1;
    stop_idxs = size(rastermap,2);
    x = 0;
    y = 0;
elseif ~valclickinput & valnuminput
    minval = get(handles.uigroup{lidx}.use_numerical_frame_input_min,'string');
    maxval = get(handles.uigroup{lidx}.use_numerical_frame_input_max,'string');
    if isempty(minval) || isempty(maxval)
        error('Either min or max value input box is empty');
        return
    end
    
    start_idxs = str2double(minval);
    stop_idxs = str2double(maxval);
    if stop_idxs > size(rastermap,2);
        error(['Max Frame input exceeds number of frames in movie (=',...
            num2str(size(rastermap,2)),')'])
        return
    end
    
    selected_rastermap = rastermap(:,start_idxs:stop_idxs);
    x = 0;
    y = 0;
elseif valclickinput & ~valnuminput%if "Click Input" checkbox is checked let the user click
    nclicks = 0;				% Infinite.
    for i = 1:2:length(varargin)
        switch varargin{i}
            case 'nclicks'
                nclicks = varargin{i+1};
        end
    end

    globals = handles.app.experiment.globals;
    pidx = handles.app.data.currentPartitionIdx;

    if (nclicks)
        [x, y, button, caxes, figptsx, figptsy] = bw_ginput(nclicks);		
    else
        [x, y, button, caxes, figptsx, figptsy] = bw_ginput;
    end 

    if (mod(length(x),2) ~= 0)
        errordlg('You must have pairs of ginput selections.');
        return;
    end 

    % If no limits are specified, we assume the user wants the entire
    % rasterplot
    % For some reason version 7 of MatLab has a bug such that one cannot
    % have 0 return from ginput! -DCS:2005/08/23.  I'll keep the logic in
    % here anyways.
    if (~isempty(x))%if anything selected
        %make sure all clicks were in x range of raster map, if not set to time
        %zero (if to left) or last frame (if to right)
        rasteraxespos = get(handles.guiOptions.face.imagePlotH,'position');
        %left = zero
        x(figptsx<rasteraxespos(1))= 0;%if to left of raster axis, set value to 0;
        %if to right, set value to max xlim
        maxx = get(handles.guiOptions.face.imagePlotH,'xlim');
        maxx = maxx(2);
        x(figptsx>(rasteraxespos(1)+rasteraxespos(3)))=maxx;

        %convert from time to frames
        start_idxs = ceil(x(1:2:end) * handles.app.experiment.globals.fs);
        stop_idxs = floor(x(2:2:end) * handles.app.experiment.globals.fs);
    else% if return was immediately hit
        % Else set to all frames
        start_idxs = 1;
        stop_idxs =  globals.numImagesProcess;
    end        

    % Setup the new rastermap basesd on start_idx.
    nstarts = length(start_idxs);
    % BP.
    for i = 1:nstarts
        if (start_idxs(i) < 1) 
            start_idxs(i) = 1;
        end
        if (stop_idxs(i) > globals.numImagesProcess)
            stop_idxs(i) = globals.numImagesProcess;
        end
    end

    selected_rastermap = rastermap;
    if (nstarts > 1 | ...
        (nstarts == 1 & (start_idxs ~= 1 | stop_idxs ~= globals.numImagesProcess)))
        selected_rastermap = zeros(0,0);
        for i = 1:nstarts
            start_idxi = start_idxs(i);
            stop_idxi = stop_idxs(i);
            len = stop_idxi-start_idxi;
            last = size(selected_rastermap,2)+1;
            selected_rastermap(:,last:last+len) = ...
                rastermap(:,start_idxi:stop_idxi);
        end
    end
end