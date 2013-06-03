function newhandles = ct_preferences_load(handles)

try 
    filename = 'ct_preferences';
    if (~isfield(handles.app.info, 'ctPath'))
        [pathstr, name, ext] = fileparts(which('caltracer2'));
        handles.app.info.ctPath = pathstr;
    end
    loadDataName = fullfile(handles.app.info.ctPath,filename);
    prefstoadd = load(loadDataName,'preferences');
    handles.app.preferences = [];
    handles.app.preferences = prefstoadd.preferences;
catch
    
if (~isfield(handles.app, 'preferences'))
    handles.app.preferences = [];
end
end

if (~isfield(handles.app, 'guiopen'))
%Set Spatial and Temporal Resolution
lidx = get_label_idx(handles, 'resolution');
set(handles.uigroup{lidx}.inptsr,'string',handles.app.preferences.SpResolution);
set(handles.uigroup{lidx}.inpttr,'string',handles.app.preferences.TpResolution);

%Set Rows and Columns to be deleted
lidx = get_label_idx(handles, 'filterimagebadpixels');      
set(handles.uigroup{lidx}.leftcols,'String',num2str(handles.app.preferences.Lcol));
set(handles.uigroup{lidx}.rightcols,'String',num2str(handles.app.preferences.Rcol));
set(handles.uigroup{lidx}.upperrows,'String',num2str(handles.app.preferences.Urow));
set(handles.uigroup{lidx}.lowerrows,'String',num2str(handles.app.preferences.Lrow));
else
    rmfield (handles.app, 'guiopen');
end
newhandles = handles;