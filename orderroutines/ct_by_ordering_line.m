function [result, data, params] = ....
    ct_by_ordering_line(handles, ridxs, rastermap, regions, options)

x = regions{1}(:,1);
y = regions{1}(:,2);
params = [];
% Put into first quadrant cause it's bugging me to death!
height = handles.app.experiment.Image(1).nY;
width = handles.app.experiment.Image(1).nX;    
y = -y+height;

% Note that the location and slope may appear backwards because the
% images have the y axis starting from the top, whereas a plot has the
% y axis starting from the bottom!
nlines = length(x)-1;
slopes = zeros(1,nlines);
normal_slopes = zeros(1, nlines);
%  First, compute the normal vector and ordering vector.
for i = 1:nlines
    if (x(i+1)-x(i) ~= 0)
	slopes(i) = (y(i+1)-y(i))/(x(i+1)-x(i));
    else
	slopes(i) = 1/eps;
    end
    if (slopes(i) ~= 0)
	normal_slopes(i) = -1/slopes(i);
    else
	normal_slopes(i) = -1/eps;
    end
end

% Now we compute the order of the cells.  
centroids = reshape([handles.app.experiment.contours.Centroid], 2, ...
		    handles.app.experiment.numContours);

% Determine which cells are closest to which lines. This is important
% to determine which ordering regime they are in.
%   Right now we assume there is only one line.
ang = atan(slopes);
rotation_mat = [cos(ang) -sin(ang); sin(ang) cos(ang)];
translated_centroids = rotation_mat * centroids;


% Recompute the centroid for each contour in the translated origin of
% the reordering line.
% Sort the rows by the X dimension.
if (sqrt(y(2)^2+x(2)^2) > sqrt(y(1)^2+x(1)^2))
    order = -1;				% ascending
else
    order = 1;				% descending
end

% The x value of the rotation is the ordering.
result = translated_centroids(1,:) * order;
data=[];

% Delete the reordering line from the screen.  This implies a good
% management of all the lines, patches, etc. on the plot.
%pause(1);
%handles = show_ordering_line(handles, handles.guiOptions.face.clickMap,0);