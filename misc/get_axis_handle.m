function axis_handle = get_axis_handle(handles)
% function axis_handle = get_axis_handle(handles)
% Use a mouse click to determine which axes a user would like to
% select.

% Use the user input to select an axis.
[x, y] = gui_ginput(handles.fig, 1);

% Determine which axis was selected by looking at the positions.
axs = findobj(handles.fig, 'Type','axes', 'Visible', 'on');
set(axs, 'units', 'pixels');
positions = get(axs, 'Position');
set(axs, 'units', 'normalized');

for i = 1:length(positions)
    xbottomleft = positions{i}(1);
    xbottomright = xbottomleft + positions{i}(3);
    xtopleft = xbottomleft;
    xtopright = xbottomright;
    ybottomleft = positions{i}(2);
    ybottomright = ybottomleft;
    ytopleft = ybottomleft + positions{i}(4);
    ytopright = ytopleft;
    pos_xv(i,:) = [xbottomleft xbottomright xtopright xtopleft xbottomleft];
    pos_yv(i,:) = [ybottomleft ybottomright ytopright ytopleft ybottomleft];
    in(i) = inpolygon(x,y, pos_xv(i,:), pos_yv(i,:))
end
%figure; plot(pos_xv',pos_yv')
%hold on; plot(x,y, '*')
ax_idx = find(in == 1);

if length(ax_idx) == 2
    axis_handle = 0;
elseif length(ax_idx) == 0
    axis_handle = 0;
else
    axis_handle = axs(ax_idx);
end