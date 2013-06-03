function handles = detect_signals(handles)
% function handles = detect_signals(handles)
%
% Evaluates signals in traces using a signal detector from the signal
% detectors folder.  Takes the signal onsets, offset and any signal
% detector programer's parameters, as well as the name of the signal
% detector used and puts them into handles.app.experiment for posterity.
% Get the current partition in order to get the data.  The idea is
% that the user (programmer) can specifiy if they want to use the
% cleaned data or not.  If there are options describing preprocessing
% routines then we will process the data for the programmer.  The
% programmer can utilize the preprocessing methods simply by filling
% out structure elements.

    pidx = handles.app.data.currentPartitionIdx;
    p = handles.app.experiment.partitions(pidx);
    signal_detector_id = uiget(handles, 'signals', 'dpdetectors', 'value');
    signal_detector_strings = uiget(handles, 'signals', 'dpdetectors', 'string');
    signal_detector = signal_detector_strings{signal_detector_id};
    signal_detector_fun = ['ct_' signal_detector];
    signal_detector_options_fun = [signal_detector_fun '_options'];
    try
        options = feval(signal_detector_options_fun,handles); 
    catch
        options = [];
    end
    % Like the clustering, the signal detection routines only work on the
    % contours in the current partition.  This saves work because many
    % contours are typically junk and there are easier ways (such as
    % clustering) to get rid of those clusters and save the difficult work
    % of segmentation for good candidate traces.
    clustered_contour_ids = [p.clusters.contours];
    % Get the data for the user function.
    do_use_raster = 1;
    start_idxs = 1;
    stop_idxs = length(handles.app.experiment.contours(1).intensity);
    if (isfield(options, 'doUseRaster') & ~options.doUseRaster.value)
        do_use_raster = 0;
        start_idxs = 1;
        stop_idxs = 1;
        rastermap = [];  % the routine better handle this since they
                         % set the option.
    else    
        if isfield(options, 'preprocessStrings')
        % Add the halos because all the preprocessing routines are
            % expecting them (at the bottom).
            rastermap = [handles.app.experiment.traces(clustered_contour_ids, :); ...
                 handles.app.experiment.haloTraces(clustered_contour_ids,:)];
            do_use_partition_preprocessing = 0;
            npreprocess_steps = length(options.preprocessStrings);
            % Now run the preprocessing steps on the matrix.
            for i = 1:npreprocess_steps
                preprocessor_string = ['ct_' options.preprocessStrings{i}];
                preprocess_options_string = [preprocessor_string '_options'];
                % Get the default preprocessing options.
                preprocess_options = feval(preprocess_options_string);
                % Check to see if the programmer of the routine wanted special
                % values.
                signal_defaults = options.preprocessOptions{i};
                nsignal_defaults = length(signal_defaults);
                for j = 1:2:nsignal_defaults
                    preprocess_options.(signal_defaults{1}).value = signal_defaults{2};
                end
                preprocess_options = add_options_from_gui(handles,preprocess_options);

                rastermap = feval(preprocessor_string, rastermap, preprocess_options);	    
            end	
            % Remove the halos because they are not part of the
            % signal detection concept.
            rastermap = rastermap(1:end/2,:);
        else
            % Default is to use the clean data. (no preprocessStrings option)
            do_use_partition_preprocessing = 1;
            % Not yet in reference to clustered_contour_ids.
            rastermap = p.cleanContourTraces;
            % Now is.
            rastermap = p.cleanContourTraces(clustered_contour_ids, :);
        end

        % Get the start and stop indices, as well as the rastermap
        % reflecting them.
        [rastermap start_idxs stop_idxs x y] = ...
        get_raster_input(handles, rastermap, 'nclicks', 2);
    end
    ridxs = [start_idxs(:) stop_idxs(:)];
    options = user_check_options(options);
    if ischar(options)
        if strcmp(options,'error');%if an error from last function
            return
        end
    end
    options = add_options_from_gui(handles, options, ...
        'startidxs', start_idxs, ...
        'stopidxs', stop_idxs);
    [onsets, offsets, params] = feval(signal_detector_fun, ...
                      rastermap, ...
                      handles, ...
                      ridxs, ...
                      clustered_contour_ids, ...
                      options);
    % Assume the called function will explain to the user.
    if (isfield(params, 'wasError') & params.wasError)  
        errordlg(params.error);
    end
    % The onsets and offsets are now in reference to the start and
    % stopidxs.  So we have to put them back into reference of the entire
    % trace.
    for cidx = 1:length(clustered_contour_ids)
        % Leave this for tomorrow. -DCS:2005/08/24
        if (~isempty(onsets{cidx}))
            onsets{cidx} = onsets{cidx} + start_idxs(1) - 1;
            offsets{cidx} = offsets{cidx} + start_idxs(1) - 1;
        end
    end
    % Put the onsets and offsets into an array that has the correct size
    % (references all contours, leaving empties for thoses that weren't
    % set.
    all_onsets = cell(1, handles.app.experiment.numContours);
    all_offsets = cell(1, handles.app.experiment.numContours);
    cidx = 1;
    for cid = clustered_contour_ids
        all_onsets{cid} = onsets{cidx};
        all_offsets{cid} = offsets{cidx};
        cidx = cidx + 1;
    end
    % Create a new id and get the heck out of Dodge.
    handles.app.experiment.numDetections = handles.app.experiment.numDetections + 1;
    didx = handles.app.experiment.numDetections;
    handles.app.data.currentDetectionIdx = didx;
    handles.app.experiment.detections(didx) = newdetection;
    handles.app.experiment.detections(didx).id = didx;
    handles.app.experiment.detections(didx).title =[signal_detector '_id' num2str(didx)];
    handles.app.experiment.detections(didx).detectorName = signal_detector_fun;
    handles.app.experiment.detections(didx).params = params;
    handles.app.experiment.detections(didx).onsets = all_onsets;
    handles.app.experiment.detections(didx).offsets = all_offsets;

    %make so signals are shown
    lidx = get_label_idx(handles, 'signals');
    set(handles.uigroup{lidx}.signals_check,'value',1);