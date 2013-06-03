function handles = tile_region_with_rectangles(handles)
% function handles = tile_region_with_rectangles(handles)

% Get the current region in the current map (indices).
ridx = handles.app.data.currentRegionIdx;
midx = handles.app.data.currentMaskIdx;

% Draw the line for reording.
height = handles.app.experiment.Image(1).nY;
width = handles.app.experiment.Image(1).nX;    
[x, y, h] = draw_region(width, height, ...
			'tag', 'orderingline', ...
			'userdata', ridx, ...
			'nclicks', 2);
% Put into first quadrant cause it's bugging me to death!
y = -y+height;
[ang, rotation_mat] = compute_rotation_angle(x,y);
% Recompute the centroid for each contour in the translated origin of
% the reordering line.  Sort the rows by the X dimension.
if (sqrt(y(2)^2+x(2)^2) > sqrt(y(1)^2+x(1)^2))
    order = 1;				% ascending
else
    order = -1;				% descending
end

border = handles.app.experiment.regions.coords{ridx};
border(end+1,:) = border(1,:);
% Put the border into the translated coordinates.
rotated_border = (rotation_mat * border')';

% Find the minimum (x,y) to start at.
m = min(rotated_border(:,1));
m = m(1);
find(rotated_border == m)
min_idx = find(rotated_border == m);
min_idx = min_idx(1);
min_point = rotated_border(min_idx,:);

% Now we just march along the axis until we run off the other side of
% the region contour.
in_region = 1;
cn = [];
side_len_pixels = handles.face.tileSide(ridx);
last_top = min_point;
last_bottom = min_point;
reverse_rotation_mat = rotation_mat';
min_x = 1;
min_y = 1;
max_x = width;
max_y = height;
image_border = [min_x min_y; ...
		min_x max_y; ...
		max_x max_y; ...
		max_x min_y; ...
		min_x min_y];
while in_region
    % The new points are advanced by a certain amount and the
    % border points are put in sync with the border of the polygon.         
    new_top = last_top + [side_len_pixels 0];
    new_bottom = last_bottom + [side_len_pixels 0];
    new_top2 = find_region_border(new_top, rotated_border, 'above');
    new_bottom2 = find_region_border(new_bottom, rotated_border, 'below');
    coords = [last_top; ...
	      last_bottom; ...
	      new_bottom2; ...
	      new_top2];
    
    oldcoords = [last_top; ...
		 last_bottom; ...
		 new_bottom; ...
		 new_top];
    
    centr = create_centroid(coords);   
    in_region = inpolygon(centr(:,1), centr(:,2),...
			  rotated_border(:,1), rotated_border(:,2));
    
    % Make sure all rectangles are completely inside the image
    % border.
    trans_coords = (reverse_rotation_mat*coords')';
    
    % BP around image edges.
    lt_min_x = find(trans_coords(:,1) < min_x);
    trans_coords(lt_min_x,1) == min_x;
    lt_min_y = find(trans_coords(:,2) < min_y);
    trans_coords(lt_min_y,2) = min_y;
    gt_max_x = find(trans_coords(:,1) > max_x);
    trans_coords(gt_max_x,1) = max_x;
    gt_max_y = find(trans_coords(:,2) > max_y);
    trans_coords(gt_max_y,2) = max_y;
    
    in_image = inpolygon(trans_coords(:,1), trans_coords(:,2),...
			 image_border(:,1), image_border(:,2));
    out_of_image = ~isempty(find(in_image == 0));
    if (in_region & ~out_of_image)	
	cn{end+1} = trans_coords; 
    else
	1;				% for debugging.
    end
    last_top = new_top2;
    last_bottom = new_bottom2;
end
1;


% Rotate the contours back to the original reference frame.
1;					% Not implemented yet.


if order == 1
    handles.app.experiment.regions.contours{ridx}{midx} = cn;
else
    handles.app.experiment.regions.contours{ridx}{midx} = fliplr(cn);
end

% Delete the reordering line from the screen.  This implies a good
% management of all the lines, patches, etc. on the plot.
pause(1);
lidx = get_label_idx(handles, 'image');
handles = show_ordering_line(handles, handles.uigroup{lidx}.imgax,0);


function new_point = find_region_border(point, border, direction)
% function ydist = find_region_border(point, border, direction)
%
% Approximate the distance from the point to the border above (or
% below).

switch direction
 case {'above'}
  direction = 1;
 case {'below'}
  direction = -1;
 otherwise
  errordlg(['Case not implemented yet.']);
end

[in_region, on_edge] = inpolygon(point(:,1),point(:,2),...
				 border(:,1), border(:,2));    

%if (on_edge)
%    new_point = point;
%end

% If we are in the region, then it's a simple computation to just test
% each pixel until we are no longer in the region.
max_iters = 1000;			% should be set by image height.
if (in_region)
    max_approx_dist = 2;
    iters = 1;
    p = point;
    while ((iters <= max_iters) & in_region)
	p = p + direction*[0 1]; 
	[in_region, on_edge] = inpolygon(p(:,1),p(:,2),...
					 border(:,1), border(:,2));    
	if (on_edge)
	    break;
	end
	iters = iters + 1;
    end    
else
    % If we are not in the region then we assume the boundary of the
    % region border has taken a serious angle up or down and we have
    % to handles those cases.
         
    % The most likely case is the 'above' point is slightly above the
    % contour, so we go downwards.

    % Another case is that the 'above' point is entirely below the
    % border, so we have to go through the border, into the region,
    % and stop at the 'higher' border.
    
    % We can test these two cases by comparing the y coordinte of the
    % centroid of the region, but there are cases that could be wrong,
    % so instead I can just try the most likely case and then, if
    % after a number of iterations things are working, try the other
    % direction.  It's a hack but I think it will work better than
    % trying to smart here.
      
    iters = 1;
    p = point;
    while ((iters <= max_iters) & ~in_region)
	p = p + -1*direction*[0 1]; 
	[in_region, on_edge] = inpolygon(p(:,1),p(:,2),...
					 border(:,1), border(:,2));    
	if (on_edge)
	    break;
	end
	iters = iters + 1;
    end
    

    % Another case is that the 'above' point is entirely below the
    % border, so we have to go through the border, into the region,
    % and stop at the 'higher' border.
    if (max_iters <= iters)
	iters = 1;
	p = point;
	out_of_region_twice = 0;
	in_region_once = 0;
	while ((iters <= max_iters) & ~out_of_region_twice)
	    p = p + direction*[0 1]; 
	    [in_region, on_edge] = inpolygon(p(:,1),p(:,2),...
					     border(:,1), border(:,2));    

	    if (in_region)
		in_region_once = 1;
	    end
	    if (~in_region & in_region_once)
		out_of_region_twice = 1;
	    end
	    if (on_edge & in_region_twice == 2)
		break;
	    end
	    iters = iters + 1;
	end				
    end
    
    if (max_iters <= iters)
	% This is actually OK if we've made it thru the entire region.
	1; %error('Something happened wrong.');
    end    
    
end
new_point = p;          