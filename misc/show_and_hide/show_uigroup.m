function handles = show_uigroup(handles, label)
% Show an entire uigroup.
handles = change_uigroup(handles, label, ...
		       {'Visible'}, ...
		       {'on'});
