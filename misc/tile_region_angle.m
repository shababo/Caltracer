function [ handles ] = tile_region_angle( handles )
% tile_region_angle 
%  For the current mask and the current region, tile the region with
% contours irrespective of any actual cells. Allow the user to input a line
% and align the squares to that line (similar to tile_region_with
% rectangles.

%   Detailed explanation goes here


% Midx is the mask that is currently being processed.
midx = handles.app.data.currentMaskIdx;
% Ridx is the current region selected.
ridx = handles.app.data.currentRegionIdx;

% Get the data from the uicontrols to find the cells.
face = handles.guiOptions.face;
face.isAdjusted(ridx) = 0;
face.isDetected(ridx) = 1;
% Remove any currently existing contours.
handles.app.experiment.regions.contours{ridx}{midx} = [];
% Get the top 'Cutoff' or threshold percent.
fimage = handles.app.experiment.Image(midx).filteredImage;
width = handles.app.experiment.Image(midx).nX;
height = handles.app.experiment.Image(midx).nY;

%Check for possible errors.
if (face.minArea(ridx) < 1)
    errordlg(['The min area, which is used for the tile side length,' ...
	      ' must be greater than one.']);
    return;
end


% Draw the line angling.
height = handles.app.experiment.Image(1).nY;
width = handles.app.experiment.Image(1).nX;    
[x, y, h] = draw_region(width, height, ...
			'tag', 'orderingline', ...
			'userdata', ridx, ...
			'nclicks', 2);
% Find the angle.
[ang, rotation_mat] = compute_rotation_angle(x,y);

% Delete the reordering line from the screen.  This implies a good
% management of all the lines, patches, etc. on the plot.
pause(1);
lidx = get_label_idx(handles, 'image');
handles = show_ordering_line(handles, handles.uigroup{lidx}.imgax,0);

side_pixels = handles.face.tileSide(ridx);

% Tile the entire image and then use inpolygon to toss out the tiles
% that are not in the current region.
cn = [];
current_x = 1;
tiledimensions.x  = 0;
tiledimensions.y = 0;
while current_x <= width
    current_y = 1;
    while current_y <= height
        if (current_x+side_pixels <= width & current_y+side_pixels <= height)
            coords = [current_x current_y; ...                    % upper left
                current_x+side_pixels current_y; ...           % upper right
                current_x+side_pixels current_y+side_pixels; ...  % lower right
                current_x current_y+side_pixels];              % lower left
            cn{end+1} = coords;
        end
        current_y = current_y + side_pixels;
        tiledimensions.y = tiledimensions.y+1;
    end
    current_x = current_x + side_pixels;
    tiledimensions.x  = tiledimensions.x +1;
end

% Check to see if the preferences are set to export the values of the
% tiles to base workspace.
if handles.app.preferences.AutoExportTileRegionVals==1
tiledimensions.y = tiledimensions.y/tiledimensions.x -1;
tiledimensions.x = tiledimensions.x -1;
tiledimensions.size = tiledimensions.x*tiledimensions.y;
numx = num2str(tiledimensions.x);
numy = num2str(tiledimensions.y);
total = num2str(tiledimensions.size);
assignin('base','TileDimensions',tiledimensions);
end

reg_coords = handles.app.experiment.regions.coords;
names = handles.app.experiment.regions.name;

% Get the centers and area of our tiles.
centr = [];
areas = [];
for c = 1:length(cn)
    centr(c,:) = create_centroid(cn{c});
    areas(c) = polyarea(cn{c}(:,1), cn{c}(:,2));
end

% Find those polygons in the right region (used for border clean-up).
in = inpolygon(centr(:,1), centr(:,2),...
	       reg_coords{ridx}(:,1), reg_coords{ridx}(:,2));
% Find those polygons in other regions.  It can happen that contours
% are in two regions, in so far as one region can be nested in
% another.
for r = 1:handles.app.experiment.numRegions
    if (polyarea(reg_coords{r}(:,1), reg_coords{r}(:,2)) ...
	< polyarea(reg_coords{ridx}(:,1), reg_coords{ridx}(:,2)));
	in_other = inpolygon(centr(:,1), centr(:,2), ...
			  reg_coords{r}(:,1),reg_coords{r}(:,2));
	in_other_idxs = find(in_other);
	in(in_other_idxs) = 0;
    end
end    
        
f = find(in);
cntemp = [];
for c = 1:length(f)
    cntemp{c} = cn{f(c)};
end
centrtemp = centr(f,:);
areastemp = areas(f);
handles.app.experiment.regions.contours{ridx}{midx} = cntemp;

% Find the center.
fulcrum = size(handles.app.experiment.Image(1).image);
fulcrum = (fulcrum * .5) + .5;
diffang = ang;
% Call the rotate all contours function, then redraw contours and regions.
handles = rotate_all_contours(handles,diffang,fulcrum,midx);

% Save the rest of the work.
handles.guiOptions.face = face;