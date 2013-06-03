function handles = menuset(handles, menugroup, menulabel, menuitemlabel, ...
			   varargin)
% function handles = menuset(handles, menugroup, menulabel, menuitemlabel, varargin)
% Set a property/value pairs in a menuitem by specifying the
% menugroup, menulabel uimenu label as strings.
%
% Example:
% menuset ----           menugroup ,  menu,  menuitem prop1..n, value1..n
% handles = menuset(handles, 'first', 'file', 'Save', 'Enable', 'on');
% varargin is 'Property1', 'Value1', 'Property2', 'Value2', ...
mgidx = get_menu_label_idx(handles, menugroup);
menu_names = fieldnames(handles.menugroup{mgidx});
midx = find(strcmp(menu_names, menulabel));
if (isempty(midx))
    error('menu not found in menu group.');
end
mn = menu_names(midx);
mn = mn{1};
menu_item_handles = get(handles.menugroup{mgidx}.(mn), 'Children');
menu_item_labels = get(menu_item_handles, 'Label');
miidx = 0;
cmp = strcmpi(menu_item_labels, menuitemlabel);
miidx = find(cmp);

if (isempty(miidx))
    error(['menu item ',menuitemlabel,' not found in menu ',menulabel,'.'])
end
menu_item_handle = menu_item_handles(miidx);
for i = 1:2:length(varargin)
    property = varargin{i};
    value = varargin{i+1};
    set(menu_item_handle, property, value);
end
