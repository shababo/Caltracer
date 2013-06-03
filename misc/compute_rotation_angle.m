function [ang, rotation_mat] = compute_rotation_angle(x,y)
% Compute the rotation angle and rotation matrix from the line
% specified by x,y.
% 
% Note that the location and slope my appear backwards because the
% images have the y axis starting from the top, whereas a plot has the
% y axis starting from the bottom!  This function is expecting y to
% be in plot order, and not image order!!!

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

ang = atan(slopes);
rotation_mat = [cos(ang) -sin(ang); sin(ang) cos(ang)];
