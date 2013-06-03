function handles = ordercontours(handles, varargin)


% Advance the number of orders since we use coidx here.
coidx = handles.app.experiment.numContourOrders + 1;

pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);

order_routine_id = uiget(handles, 'signals', 'dporderroutines', 'value');
order_routine_strings = uiget(handles, 'signals', 'dporderroutines', 'string');
order_routine = order_routine_strings{order_routine_id};
order_fun = ['ct_' order_routine];
order_options_fun = [order_fun '_options'];
options = feval(order_options_fun);


contour_ids = [1:handles.app.experiment.numContours]';


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

    if (isfield(options, 'preprocessStrings'))
	% Add the halos because all the preprocessing routines are
        % expecting them (at the bottom).
        rastermap = [handles.app.experiment.traces(contour_ids, :); ...
		     handles.app.experiment.haloTraces(contour_ids,:)];
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
	% contour ordernig concept.
	rastermap = rastermap(1:end/2,:);
    else
        % Default is to use the clean data. (no preprocessStrings option)
        do_use_partition_preprocessing = 1;
        rastermap = p.cleanContourTraces;
    end
    
    [rastermap start_idxs stop_idxs x y] = ...
    get_raster_input(handles, rastermap, 'nclicks', 2);
end


% Get any regions for the user function.
do_use_clickmap = 0;
regions = {};
line_handles = [];
if (isfield(options, 'doUseClickMap') & options.doUseClickMap.value)
    do_use_clickmap = 1;
    num_regions = 1;
    if (isfield(options, 'numRegions'))
    	num_regions = options.numRegions.value;
    end
    
    num_clicks = 1e10;			% left click stops, btw.
    if (isfield(options, 'numClicks'))
        num_clicks = options.numClicks.value;
    end
    
    % Draw the line for reording.
    height = handles.app.experiment.Image(1).nY;
    width = handles.app.experiment.Image(1).nX;    

    for i = 1:num_regions
        [x, y, line_handles(i)] = draw_region(width, height, ...
                              'tag', order_routine, ...
                              'userdata', coidx, ...
                              'nclicks', num_clicks);   
        regions{i}(:,1) = x;
        regions{i}(:,2) = y;
    end
end


% Unlike the clustering, the ordering routines must work on all
% contours, including those that have been eliminated from
% clustering.  This is true because the concept of ordering extends
% to all kinds of viewing such as coloration of the clickmap and
% trace plot as well.

ridxs = [start_idxs(:) stop_idxs(:)];
options = user_check_options(options);
options = add_options_from_gui(handles, options);
[result, data, params] = feval(order_fun, handles, ridxs, rastermap, regions, options);
if (isfield(params, 'wasError') & params.wasError.value)  % Assume the called function will explain to the user.
    errordlg(params.error.value);
    return;
end

sn = [result(:) contour_ids];
sorted = sortrows(sn, -1); % Sort by the order induced by result.
order = sorted(:,2);
[sorted2, index] = sortrows(order);


% Create the new structure.
% coidx created on top.
handles.app.experiment.numContourOrders = handles.app.experiment.numContourOrders + 1;
handles.app.data.currentContourOrderIdx = coidx;

[sorted2, index] = sortrows(order);
new_order = neworder;
new_order.id = coidx;
%new_order.title = num2str(coidx);
new_order.title = [order_routine '_id' num2str(coidx)];
new_order.orderName = order_routine;
new_order.params = params;


% 'Order' gives the ids in order.  (order -> id).  That is [1 5 12]
% says that contours 1 5 12 are in order 1 2 3.  
% I.e. it answers the question:, "What id is 2nd? order(2) = 5. Answer 5.
new_order.order = order';

% 'Index' gives the index into order for each id, so that you can
% reference the index _with_ the id.  (id -> order).  I.e, it answers
% the question: "What order is the 5th id?" index(5) = 2. Answer: 2.
% [_1_ 11 8 5 _2_ 21 18 15 12 9 6 _3_ ...]
new_order.index = index';

handles.app.experiment.contourOrder(coidx) = new_order;

% Delete any line handles we may have created.
pause(1);
delete(line_handles(ishandle(line_handles)));
