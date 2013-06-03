function handles = show_ordering_line(handles, ax, do_toggle_menu)
% function handles = show_ordering_line(handles, do_toggle_menu)
%
%

% First handle the menu.
sol_mi_h = findobj(handles.fig, 'Label', 'Show ordering line');
val = get(sol_mi_h, 'Checked');
if (do_toggle_menu)
    if (strcmp(val, 'off'));	
	set(sol_mi_h, 'Checked', 'on');    
    else    
	set(sol_mi_h, 'Checked', 'off');
    end
end
val = get(sol_mi_h, 'Checked');

% Now handle the lines.
coidx = handles.app.data.currentContourOrderIdx;
% First turn everything off.
hs = findobj(ax, 'Tag', 'orderingline');    
set(hs, 'Visible', 'off');  
if (strcmp(val, 'on'))
    hs = findobj(ax, ...
		 'Tag', 'orderingline', ...
		 'UserData', coidx);
    if (~isempty(hs))
	set(hs, 'Visible', 'on');
    end
end