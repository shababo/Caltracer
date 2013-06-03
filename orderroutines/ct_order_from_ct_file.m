function [result, rastermap, options] = ...
    ct_order_from_ct_file(handles, ridxs, rastermap, regions, options)

result = [];


[filename, pathname] = uigetfile({'*.mat'}, 'Choose an experiment to open');
if (~filename)
    return;
end
fnm = [pathname filename];
savestruct = load(fnm);

% Try to make savestruct backwards compatible.
% [ssexp, ssappdata] = ct_add_missing_options_exp(savestruct.E, savestruct.A);
% savestruct.E = ssexp;
% savestruct.A = ssappdata;

ssexp = savestruct.handles.app.experiment;

titles = {ssexp.contourOrder.title};
% If there is one mask, then we simply take the contours from it.  Otherwise we
% list the titles of all the contour masks so that the user can decide for
% themselves which mask is appropriate.
if (length(titles) == 1)
    sel_idx = 1;
else
    [sel_idx,ok] = listdlg('PromptString','Select an ordering:',...
        'SelectionMode','single',...
        'ListString', titles, ...
        'ListSize', [500 100]);
    if (~ok)
        errordlg('You must select a correct contour order.');
        return;
    end
end

o_to_copy = ssexp.contourOrder(sel_idx);

num_contours = length(o_to_copy.order);
% BP
if (num_contours > handles.app.experiment.numContours)
    options.error.value = ['There are more contours in the order then in the entire current experiment.'];
    options.wasError.value = 1;
    return;
end
if (num_contours < handles.app.experiment.numContours)
    options.error.value = ['There are less contours in the order then in the entire current experiment.'];
    options.wasError.value = 1;
    return;
end

result = num_contours - o_to_copy.index + 1;


