function handles = reorder_contours(handles)
% function handles = reorder_contours(handles)

% This checks to see if we are at the signals page or not.
if (isfield(handles.exp, 'partitions'))
    pidx = handles.appData.currentPartitionIdx;
    coidx = handles.exp.partitions(pidx).contourOrderId;

    hs = findobj(handles.guiOptions.face.clickMap, ...
		 'Tag', 'orderingline', ...
		 'UserData', coidx);
    valid_hs = hs(find(ishandle(hs)));
    if (~isempty(valid_hs))
	set(valid_hs, 'Visible', 'off');
    end

%%%%% This stunted logic is now going away due to a much cleaner system.
%     -DCS:2005/08/23
%
%    If the reordering line id is not in a cluster then that means it
%    % should be deleted because the user is defining a new one without
%    % having started a new parent cluster (i.e. they didn't like the
%    % last line.)
%    noids = [handles.exp.partitions.contourOrderId];
%    if (find(noids == handles.appData.currentContourOrderIdx))   
%	handles.exp.numContourOrders = handles.exp.numContourOrders + 1;
%	coidx = handles.exp.numContourOrders;
%	handles.appData.currentContourOrderIdx = coidx;
%    else					
%	% Rewrite the contour order since it wasn't used.
%	coidx = handles.appData.currentContourOrderIdx;
%	% Delete the handle since that's no good anymore either.
%	if (~isempty(handles.appData.contourOrder(coidx).reorderingLineH))
%	    delete(handles.appData.contourOrder(coidx).reorderingLineH);
%	end
%    end


	handles.exp.numContourOrders = handles.exp.numContourOrders + 1;
	coidx = handles.exp.numContourOrders;
	handles.appData.currentContourOrderIdx = coidx;

else
    handles.exp.numContourOrders = handles.exp.numContourOrders + 1;
    coidx = handles.exp.numContourOrders;
    handles.appData.currentContourOrderIdx = coidx;    
end

% Draw the line for reording.
height = handles.exp.tcImage(1).nY;
width = handles.exp.tcImage(1).nX;    
[x, y, h] = draw_region(width, height, ...
			'tag', 'orderingline', ...
			'userdata', coidx, ...
			'nclicks', 2);
handles.appData.contourOrder(coidx).reorderingLineH = h;

% Put into first quadrant cause it's bugging me to death!
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
centroids = reshape([handles.exp.contours.Centroid], 2, handles.exp.numContours);

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
    order = 1;				% ascending
else
    order = -1;				% descending
end
    
[sorted, order] = sortrows(translated_centroids', order*1);
% 'Order' gives the ids in order.  (order -> id).  That is [1 5 12]
% says that contours 1 5 12 are in order 1 2 3.  
% I.e. it answers the question:, "What id is 2nd? order(2) = 5. Answer 5.
%handles.exp.contourOrder(coidx).index = index;
handles.exp.contourOrder(coidx).order = order';

[sorted2, index] = sortrows(order);
% 'Index' gives the index into order for each id, so that you can
% reference the index _with_ the id.  (id -> order).  I.e, it
% answers the question:  "What order is the 5th id?" index(5) = 2. Answer: 2.
% [_1_ 11 8 5 _2_ 21 18 15 12 9 6 _3_ ...]
%handles.exp.contourOrder(coidx).order = index2';
handles.exp.contourOrder(coidx).index = index';
% I guess we could be nice and show this to the user.
1;					%  not implemented yet.

% Delete the contour highlighting lines.
1;					% not implemented yet.

% Delete the reordering line from the screen.  This implies a good
% management of all the lines, patches, etc. on the plot.
pause(1);
handles = show_ordering_line(handles, handles.guiOptions.face.clickMap,0);