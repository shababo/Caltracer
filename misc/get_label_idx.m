function lidx = get_label_idx(handles, label);
% Get an index to be used to access the handles.uigroup.  The whole
% point is that you don't care what this number is, you just give a
% string and get a number.  This way when new uigroups are added,
% these numbers don't have to ever by messed with.
lidx = find(strcmpi(handles.uigroupLabels, label));
if isempty(lidx)
    error('You must input a valid uigroup label string');
end

