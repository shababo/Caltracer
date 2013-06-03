function ct_preferences_save(handles)
%All this file does is save the handles created by ct_preferences_gui.m
filename = 'ct_preferences';
if (~isfield(handles.app.info, 'ctPath'))
        [pathstr, name, ext] = fileparts(which('caltracer'));
        handles.app.info.ctPath = pathstr;
end
saveDataName = fullfile(handles.app.info.ctPath,filename);
preferences = handles.app.preferences;
save (saveDataName, 'preferences');
