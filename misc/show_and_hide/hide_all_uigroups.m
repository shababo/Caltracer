function handles = hide_all_uigroups(handles)
% Hide all groups of uicontrols.

% This breaks if we delete any uigroups.  I can't imagine that, though.
for i  = 1:length(handles.uigroupLabels)
    label = handles.uigroupLabels{i};
    handles = hide_uigroup(handles, label);
end
