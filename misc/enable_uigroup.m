function handles = enable_uigroup(handles, label)
% Enable a group of uicontrols.
handles = change_uigroup(handles, label, {'Enable'}, {'on'});
