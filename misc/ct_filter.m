function handles = ct_filter(handles)
% function handles = ct_filter(handles)

% maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;

fid = uiget(handles, 'filterimage', 'dpfilters', 'value');
filter_name = handles.app.data.filterNames(fid);
filter_name = filter_name{1};
param = [];

if handles.app.preferences.CellDiamOnly == 1
    rad = handles.app.preferences.CellDiam; 
    rad = round(rad./handles.app.experiment.spaceRes);
    param.radius = rad;
end

[loca, param] = feval(filter_name, handles.app.experiment, maskidx , param);

if ~strcmpi(param.status, 'ok')
    return;
end


handles.app.experiment.Image(maskidx).filteredImage = loca;
handles.app.experiment.Image(maskidx).filterName = filter_name;
handles.app.experiment.Image(maskidx).filterParam = param;