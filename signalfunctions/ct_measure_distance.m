function handles = ct_measure_distance(handles)
% Get a 2 clicks from the user and compute the distance.
height = handles.app.experiment.Image(1).nY;
width = handles.app.experiment.Image(1).nX;    
[x, y, h] = draw_region(width, height, ...
			'tag', 'measuringline', ...		
			'nclicks', 2, ...
			'pixels', 0, ...
			'color', 'r');

dist_pixels_xy = sqrt((x(2)-x(1))^2 + (y(2)-y(1))^2);
dist_pixels_x = abs(x(2) - x(1));
dist_pixels_y = abs(y(2) - y(1));
% Since this function is so general, we want to use it before simple
% values are set, so we can check the uiedittext.
if (isfield(handles.app.experiment, 'spaceRes'))
    space_res = handles.app.experiment.spaceRes;

else
    space_res = str2num(uiget(handles, 'resolution', 'inptsr', 'string'));
end
dist_um_xy = dist_pixels_xy * space_res; % pixels * um/pixels    
dist_um_x = dist_pixels_x * space_res; 
dist_um_y = dist_pixels_y * space_res;

[s1, errmsg] = sprintf('Distance:               %4.2f um.\n', dist_um_xy);
[s2, errmsg] = sprintf('Distance in x-axis:   %4.2f um.\n', dist_um_x);
[s3, errmsg] = sprintf('Distance in y-axis:   %4.2f um.\n\n\n', dist_um_y);
[s4, errmsg] = sprintf('Distance:               %4.2f pixels.\n', dist_pixels_xy);
[s5, errmsg] = sprintf('Distance in x-axis:   %4.2f pixels.\n', dist_pixels_x);
[s6, errmsg] = sprintf('Distance in y-axis:   %4.2f pixels.\n\n\n', dist_pixels_y);
mh = msgbox([s1 s2 s3 s4 s5 s6], 'Distance Measurement.');
%mh = msgbox(['Distance in um: ' num2str(dist_um_xy) '.\n  ' ...
%	    'Distance in x-axis um: ' num2str(dist_um_x) '.  ' ...
%	    'Distance in y-axis um: ' num2str(dist_um_y) '.'], ...
%	    'Distance Measurement');
uiwait(mh);
pause(1);
delete(h);

