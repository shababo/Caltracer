function handles = ct_measure_time(handles)
% Get a 2 clicks from the user and compute the distance.
height = handles.app.experiment.Image(1).nY;
width = handles.app.experiment.Image(1).nX;    
[t, y, h] = draw_region(width, height, ...
			'tag', 'measuringline', ...		
			'nclicks', 2, ...
			'color', 'r', ...
			'time', 1, ...
			'pixels', 0);
dist_t = abs(t(2) - t(1));

% Since this function is so general, we want to use it before simple
% values are set, so we can check the uiedittext.
if (isfield(handles.app.experiment, 'spaceRes'))
    time_res = handles.app.experiment.timeRes;
else
    time_res = str2num(uiget(handles, 'resolution', 'inpttr', 'string'));
end

dist_idx_t = dist_t / time_res;

[s1, errmsg] = sprintf('Time: %4.2f seconds.\n\n', dist_t);
[s2, errmsg] = sprintf('Time: %4.2f indices.\n', dist_idx_t);
%[s2, errmsg] = sprintf('Distance in x-axis: %4.2fum.\n', dist_um_x);
%[s3, errmsg] = sprintf('Distance in y-axis: %4.2fum.\n', dist_um_y);
%mh = msgbox([s1 s2 s3], 'Distance Measurement.');
mh = msgbox([s1 s2], 'Time Measurement.');
uiwait(mh);
pause(1);
delete(h);

