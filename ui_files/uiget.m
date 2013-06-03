function val = uiget(handles, grouplabel, widgetlabel, property)
% Get a value from a uicontrol by specifying the grouplabel and the
% widget name, both as strings.
lidx = get_label_idx(handles, grouplabel);
widget_names = fieldnames(handles.uigroup{lidx});
widx = find(strcmp(widget_names, widgetlabel));
if (isempty(widx))
    error('Widget not found in uigroup.');
end
wn = widget_names(widx);
wn = wn{1};
val = get(handles.uigroup{lidx}.(wn), property);
