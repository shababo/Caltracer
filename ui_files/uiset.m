function handles = uiset(handles, grouplabel, widgetlabel, varargin)
% Set a property/value pairs in a uicontrol by specifying the
% grouplabel and the widget name, both as strings.
% varargin is 'Property1', 'Value1', 'Property2', 'Value2', ...
lidx = get_label_idx(handles, grouplabel);
widget_names = fieldnames(handles.uigroup{lidx});
if strcmp(widgetlabel,'all')
    widx = 1:length(widget_names);
else
    widx = find(strcmp(widget_names, widgetlabel));
    if (isempty(widx))
        error('Widget not found in uigroup.');
    end
end

for w = widx
    wn = widget_names{w};
    for i = 1:2:length(varargin)
        property = varargin{i};
        value = varargin{i+1};
        set(handles.uigroup{lidx}.(wn), property, value);
    end
end