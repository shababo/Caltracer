function handles = hide_uiwidget(handles, grouplabel, widgetlabel)
% Hide a single uiwidget.
handles = uiset(handles, grouplabel, widgetlabel, 'Visible', 'off');

